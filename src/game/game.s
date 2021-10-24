/*
This file is part of gamelib-x64.

Copyright (C) 2014 Tim Hegeman

gamelib-x64 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

gamelib-x64 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with gamelib-x64. If not, see <http://www.gnu.org/licenses/>.
*/

.file "src/game/game.s"

.global gameInit
.global gameLoop

.section .game.data

.section .game.text

/* Sets the blocks in basic_screen. We can change the timer by chaning gameTimer
*
*
*/
gameInit:
	movq $gameTimer, %rdi
	call setTimer 
	
	call draw # makes the basic_screen array

	ret

/** the actual gameLoop. We can change the tick rate by changigng 
*
*
**/
gameLoop:

	movq amDead, %rax

	cmp $1, %rax
	jne amNotDead
	
	call deadScreen
	
	jmp gameLoopEnd

amNotDead:
	call normalGame

gameLoopEnd:

	ret
