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

	movq $0, game_status
	
	call draw # makes the basic_screen array

	ret

/* Clears tetris_window
*
*
*/
cleanTetrisScreen:
	pushq %rbp
	movq %rsp, %rbp

	movq $tetris_width, %rax
	movq $tetris_width, %rbx
	mulq %rbx

	movq $tetris_window, %rbx

cleanTetrisWindow_loop:
	cmp $0, %rax
	je cleanTetrisWindow_end

	movq $0, (%rbx)
	incq %rbx
	decq %rax
	jmp cleanTetrisWindow_loop

cleanTetrisWindow_end:

	movq %rbp, %rsp
	popq %rbp
	ret

/** prints the basic_screen
*
*
*/
printBasicScreen:
	pushq %rbp
	movq %rsp, %rbp

// finally printing the current game board
	pushq %r12
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	pushq %r15

	movq $0, %r12
	movq $0, %r13
	movq $basic_screen, %r14
	movq $basic_screen_text, %r15
// 254 is ascii code for black square
loop:
	movq %r13, %rdi
	movq %r12, %rsi
	movb (%r15), %dl # character
	
	movb (%r14), %cl # color
	incq %r14
	incq %r15

	call putChar

	incq %r13
	cmp $80, %r13
	jne loop

	incq %r12
	movq $0, %r13

	cmp $25, %r12
	je loop_end

	jmp loop
loop_end:

	popq %r15
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %r12

	movq %rbp, %rsp
	popq %rbp
	ret

/*
*
*
*/

/** the actual gameLoop. We can change the tick rate by changigng 
*
*
**/
gameLoop:
	movq game_status, %rax

	cmp $0, %rax
	jne notMainMenu
	call mainMenu
	jmp printScreen

notMainMenu:
	cmp $1, %rax
	jne notGameScreen
	call normalGame
	jmp printScreen
notGameScreen:
	cmp $2, %rax
	jne notLeaderBoard
	call leaderBoard
	jmp printScreen
notLeaderBoard:
#.....................
printScreen:
	call printBasicScreen

	ret
