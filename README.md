# Example on functional reactive programming with Reactive.Banana.SDL2 #
## Current state ##
The Example is operational. Shows a blue window with a green square in it that dissappears upon mouse press and reappears on mouse release. Any keyboard button will close the window and renderer but not stop the execution.

## Difficulties with gui libraries ##
* WX seems to be very difficult to get to work. Had disambiguous type definitions with latest GHC around 20.2.2018
* SDL2 seems to work on linux pretty easily. I am using that currently . I have not been able to compile the necessary libraries on windows yet. seems like a bunch of work. The binaries meant for windows didn't want to be recognized by windows10.
* Reactive.Banana.SDL2 doesn't have good documentation and it needs some improvement. You can use this as an example. Don't be afraid to look at the source code of Reactive.Banana.SDL2.

## Building ##
* I recommend using haskell tool stack to build the program
* You will need SDL2 binaries. I got them on ubuntu simply by running "sudo apt install libsdl2-dbg libsdl2-dev"
* I would simply create new stack project and pull this repository directly there removing all duplicate files and the old "YOURPROJECTNAME.cabal" file to make stack detect "frp.cabal" . On linux this might directly work with no changes to either .yaml file. Then remember to run "stack update", "stack upgrade" and "stack build". Executing should work by "stack exec frp-exe". You might also need to install the SDL2 libraries.
* stack build will probably take several minutes.

