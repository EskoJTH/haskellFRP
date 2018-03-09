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
import Reactive.Banana.SDL2.Types
import qualified Data.Text as T

--defining a window
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

--defining a renderer
myRenderer = RendererConfig
  { rendererType          = AcceleratedVSyncRenderer
  , rendererTargetTexture = True
  }

--put things to run
main :: IO ()
main = do
  initializeAll
  window <- createWindow "Strory of a small green rectangle" myWindow
  renderer <- createRenderer window (-1) myRenderer
  appLoop renderer

--click target square
square = Rect { rectX = 10,
                rectY = 20,
                rectW = 30,
                rectH = 40}

--main loop logic
appLoop :: Renderer -> IO ()
appLoop renderer = do
  
  --basic SDL2 thins not sure if needed with Reactive-Banana
  {-
  events <- pollEvents
  clear renderer
  let eventIsQPress event =
        case eventPayload event of
          KeyboardEvent keyboardEvent ->
            keyboardEventKeyMotion keyboardEvent == Pressed &&
            keysymKeycode (keyboardEventKeysym keyboardEvent) == KeycodeQ
          _ -> False
      --saves an event result in basic SDL2 style
      qPressed = any eventIsQPress events
  -}
  --Gets the surroundings not sure if actually needed
  events <- getSDLEventSource
  let (adder, handler) = getSDLEvent events

  --register adder _ -- wrappedEvent   Event EventPayload      




  --actual FRP part
  --This is the way WX seemed to work
  let networkDescription :: MomentIO () 
      networkDescription= do
        
        --Filter and save the wanted events using Reactive-Banana-SDL2 library
        current <- sdlEvent events
        let mouseDown = keyDownEvent $ mouseButtonEvent $ mouseEventWithin square current
        let mouseRelease = keyDownEvent $ mouseButtonEvent $ mouseEvent current
        --escape quits
        let oneKeyDown = keyDownEvent current

        --Turn the events into an behavior that has the wanted color as a function of time
        --I probably need to add the main loop into a behaviour like this
            --for it to happen constantly
        (colorer :: Behavior (LoopState)) <- accumB (Loop) $ unions [(\x->MyColor) <$ mouseDown,
                                                                      (\x->Loop) <$ mouseRelease,
                                                                      (\x->Quit) <$ oneKeyDown]
        --old trials
        --color <- valueB colorer
        --let eventsource = ((register (\color->do rectangleColor renderer color)), rectangleColor renderer)
        --valueB register (fmap handler colorer) where

        let doing :: LoopState -> IO()
            doing (MyColor) = do
              ioLogic renderer colorBlue
            doing Loop = do
              ioLogic renderer colorNotBlue
            doing Quit = do return ()
  
        --changes appears to be one way to convert the io(doing) inside the colorer behaviour into something reactimate can read.
        behaviourAsEvents <- changes $ doing <$> colorer

        --reactimate appears to be the way to run io inside a behaviour.
        reactimate' $ behaviourAsEvents 


  
  --compiles the behaviour
  network <- compile networkDescription
  actuate network

  -- Reactive Banana SDL2 Loop
  
  runCappedSDLPump 144 events

data LoopState = Loop|Quit|MyColor
  
--sets a a "color" to a rectangle in the window
ioLogic :: Renderer -> V4 Word8 -> IO()
ioLogic renderer color = do
  rendererDrawColor renderer $= color
  fillRect renderer $ Just $ Rectangle (P (V2 10 20)) (V2 30 40)
  --blue background
  rendererDrawColor renderer $= colorBlue
  --show stuff
  present renderer
  --This is supposed to create the loop but it seems to currently fail
  appLoop renderer


colorBlue :: V4 Word8
colorBlue =  V4 0 0 255 255

colorNotBlue :: V4 Word8
colorNotBlue = V4 0 255 0 0

