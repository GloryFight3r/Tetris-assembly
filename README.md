dynamic-tetris-assembly
===========

Bootable tetris game with new introduced powers, written purely in Assembly AT&T.

Uses the following [bootloader](https://github.com/thegeman/gamelib-x64)

Requirements
===========

To build your game based on gamelib-x64, you need to ensure you are using a Linux distribution on a x86-64 architecture (i.e., 64-bit Linux on any modern Intel/AMD processor) with a recent version of GNU binutils to compile. In addition, you will need Qemu or Bochs (both emulators for a.o. the x86-64 platforrm) to test your game.

Getting started
===========

Download a copy of the repo, using either `git clone` or the "Download ZIP" button to the right of this page.

Open a terminal and navigate to the root of the gamelib-x64 folder.

Execute `make qemu` to launch the compiled game in the Qemu emulator.

Copyright
===========

GNU General Public License

Uses the bootloader written by Otto Visser, Tim Hegeman https://github.com/thegeman/gamelib-x64
