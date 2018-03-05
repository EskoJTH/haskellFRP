{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Main where

import GHC.Word
import SDL
import SDL.Raw.Types hiding (Renderer, KeyboardEvent, Window, keysymKeycode, keyboardEventKeysym)
--import Linear (V4(..))
import Control.Monad (unless)
import Linear.V4
import Reactive.Banana
import Reactive.Banana.Frameworks
import Reactive.Banana.SDL2
import qualified Data.Text as T

myWindow = WindowConfig
  { windowBorder       = True
  , windowHighDPI      = False
  , windowInputGrabbed = False
  , windowMode         = Windowed
  , windowOpenGL       = Nothing
  , windowPosition     = Wherever
  , windowResizable    = True
  , windowInitialSize  = V2 1500 1000
  }

myRenderer = RendererConfig
  { rendererType          = AcceleratedVSyncRenderer
  , rendererTargetTexture = True
  }


main :: IO ()
main = do
  initializeAll
  window <- createWindow "Strory of a small green rectangle" myWindow
  renderer <- createRenderer window (-1) myRenderer
  appLoop renderer

square = Rect { rectX = 10,
                rectY = 20,
                rectW = 30,
                rectH = 40}

appLoop :: Renderer -> IO ()
appLoop renderer = do
  events <- pollEvents
  clear renderer
  let eventIsQPress event =
        case eventPayload event of
          KeyboardEvent keyboardEvent ->
            keyboardEventKeyMotion keyboardEvent == Pressed &&
            keysymKeycode (keyboardEventKeysym keyboardEvent) == KeycodeQ
          _ -> False
      qPressed = any eventIsQPress events

  kissa <- getSDLEventSource

  -- :: MonadMoment a => a ()
  let networkDescription :: MomentIO () 
      networkDescription= do

        --addHandler kissa --Gives me addHandler from event source
        --momentIO <- compile $ sdlEvent kissa
        current <- sdlEvent kissa
        let mouseDown = keyDownEvent $ mouseButtonEvent $ mouseEventWithin square current
        let mouseRelease = keyDownEvent $ mouseButtonEvent $ mouseEvent current

        --mouseUp <- mouseEventWithin $ eventSource $ Rectangle (P (V2 10 20)) (V2 30 40)customMouseButtonUp window
        --mouseDown <- mouseButtonEvent $ customMouseButtonDown window

        (colorer :: Behavior (V4 Word8)) <- accumB (colorNotBlue) $ unions [(\x->(colorBlue)) <$ mouseDown,
                                                                              (\x->(colorNotBlue)) <$ mouseRelease]
        --color <- valueB colorer
        --let eventsource = ((register (\color->do rectangleColor renderer color)), rectangleColor renderer)

        --valueB register (fmap handler colorer) where
        
        let doing c = do
              rectangleColor renderer c
              rendererDrawColor renderer $= colorBlue
              present renderer
              appLoop renderer

        future <- changes $ doing <$> colorer

        reactimate' $ future


  
  --runSDLPump
  network <- compile networkDescription
  actuate network

  
--color V4 0 255 0 255
rectangleColor :: Renderer -> V4 Word8 -> IO()
rectangleColor renderer color = do
  rendererDrawColor renderer $= color
  fillRect renderer $ Just $ Rectangle (P (V2 10 20)) (V2 30 40)

colorBlue :: V4 Word8
colorBlue =  V4 0 0 255 255

colorNotBlue :: V4 Word8
colorNotBlue = V4 0 255 0 255

