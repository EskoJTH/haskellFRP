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
import Debug.Trace as De

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
  appLoop renderer window

--click target square
--Change to "Point" Rectangle as used in SDL2?
square = Rect { rectX = 20,
                rectY = 20,
                rectW = 100,
                rectH = 100}

--main loop logic
appLoop :: Renderer -> Window -> IO ()
appLoop renderer window = do

  events <- getSDLEventSource
  -- let (adder, handler) = getSDLEvent events


  --actual FRP part
  let networkDescription :: MomentIO () 
      networkDescription= do
        
        --Filter and save the wanted events using Reactive-Banana-SDL2 library
        current <- sdlEvent events
        
        --mouseEvent within works wrong. detects all mouse events apparently. On the original R.Banana.SDL2 it is undefined.
        let mouseDown = mouseButtonEvent $ mouseEvent current   --mouseEventWithin square current
        let mouseRelease = mouseButtonEvent $ mouseEvent current
        let oneKeyDown = keyDownEvent current

        --Turn the events into an behavior that has the wanted color as a function of time
        --I probably need to add the main loop into a behaviour like this
            --for it to happen constantly
        (colorer :: Behavior (LoopState)) <- accumB (NotBlue) $ unions [ --mouseDownHandle <$> mouseDown, --use with mouseEventWithin
                                                                      mouseUpHandle <$> mouseRelease, 
                                                                      (\x->Quit) <$ oneKeyDown]
        --Execute different IO states.
        let doing :: LoopState -> IO()
            doing Blue = do
              De.trace "loop1" ioLogic renderer colorBlue
            doing NotBlue = do
              De.trace "loop2" ioLogic renderer colorNotBlue
            doing Quit = do
              destroyWindow window
              destroyRenderer renderer
  
        --changes appears to be one way to convert the io(doing) inside the colorer behaviour into something reactimate can read.
        behaviourAsEvents <- changes $ doing <$> colorer

        --reactimate appears to be the way to run io inside a behaviour.
        reactimate' $ behaviourAsEvents 

  --compiles the behaviour
   
  network <-compile networkDescription
  actuate network

  -- Reactive Banana SDL2 Loop
  
  runCappedSDLPump 60 events


mouseUpHandle :: EventPayload -> LoopState -> LoopState
mouseUpHandle wre a = case wre of
  SDL.MouseButtonEvent (MouseButtonEventData _ Pressed _ _ _ _)   -> Blue
  _ -> NotBlue


mouseDownHandle ::  EventPayload -> LoopState -> LoopState
mouseDownHandle wre a = case wre of
  SDL.MouseButtonEvent (MouseButtonEventData _ Released _ _ _ _) -> NotBlue
  _ -> NotBlue


data LoopState = Blue|Quit|NotBlue

  
--sets a a "color" to a rectangle in the window
ioLogic :: Renderer -> V4 Word8 -> IO()
ioLogic renderer color = do

  clear renderer
  
  --blue background
  rendererDrawColor renderer $= colorBlue
  fillRect renderer Nothing
  
  --the small green rectangle
  rendererDrawColor renderer $= color
  fillRect renderer $ Just $ Rectangle (P (V2 20 20)) (V2 100 100)

  putStrLn "looped"

  present renderer


colorBlue :: V4 Word8
colorBlue =  V4 0 0 255 255

colorNotBlue :: V4 Word8
colorNotBlue = V4 0 255 0 0

