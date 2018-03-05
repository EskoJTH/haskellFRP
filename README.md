Trying to figure out FRP in haskell. Most important used tools are Reactive-Banana and Reactive-Banana-SDL2 and SDL2. At the moment of writing WX appears to be brokent in latest version of GHC so that is one reason to use SDL instead. I have managed to get some FRP mixed with regular SDL2 so that the code compiles but the gui loop doesn't sustain itself for some reason yet. The program is supposed to display a turquoise window with a red square in it that turns turquoise while mouse click is detected on top of it and turns back red once button is raised. I already managed to do this with only SDL2 withouth the events just following the documetation.

# Difficulties with gui libraries #
* WX seems to be very difficult to get to work. Had disambiguous type definitions with latest GHC around 20.2.2018
* SDL2 seems to work on linux pretty easily. I am using that currently . I have not been able to compile the necessary libraries on windows yet. seems like a bunch of work. The binaries meant for windows didn't want to be recognized by windows10.
