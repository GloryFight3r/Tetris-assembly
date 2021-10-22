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

/* Calculates 2 to the power of rdi. I needed this function because I cant bishift with two registers :^(
*@rdi the exp 
*@rax is 2^rdi
*/
twoPower:
	pushq %rbp
	movq %rsp, %rbp
	
	movq $1, %rax
twoPower_loop:
	cmp $0, %rdi
	je twoPower_loop_end
	decq %rdi

	shlq $1, %rax
	jmp twoPower_loop
twoPower_loop_end:

	movq %rbp, %rsp
	popq %rbp
	ret

/* Rotates the current number. We use the formula for a cell 
*@rdi the current block. 1 bits in the number represent a block
*
*/ 
rotateBlock:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %rax
	shrq $7, %rax # makes rax only equal to the highest byte of rdi
	shlq $7, %rax

	movq $0, %rsi # sets i,j to 0
	movq $0, %rcx

rotateBlock_loop:
	cmp $7, %rsi # if rsi becomes 7 then get out of here
	je rotateBlock_end # break the loop if it's over
	
	movq %rdi, %rbx
	and $1, %rbx
	cmp $0, %rbx
	je no_block
	
	movq %rcx, %rbx
	shlq $3, %rbx # puts (i, j) into (j, 6 - i)
	addq $6, %rbx
	subq %rsi, %rbx

	pushq %rdi
	pushq %rax # save registers before function call
	
	movq %rbx, %rdi
	call twoPower # calculates 2^rbx
	movq %rax, %rbx # saves result in rbx

	popq %rax # restores registers
	popq %rdi

	orq %rbx, %rax # adds the bit
no_block:
	# prepare the next number
	shrq $1, %rdi
	incq %rcx
	cmp $8, %rcx
	jne rotateBlock_loop

	movq $0, %rcx
	incq %rsi
rotateBlock_end:

	movq %rbp, %rsp
	popq %rbp
	ret
/* Checks if we can go one down, and if we can we do, otherwise we should put the current block and start dropping another
*@r13,r14 are x,y respectuflly
*
*/
dropOne:
	pushq %rbp
	movq %rsp, %rbp

	pushq %r8
	pushq %r9

	movq $0, %rdi
	movq $0, %rdx
	movq %r15, %r8 # current tetris block

dropOne_loop:
	cmp $7, %rdi
	je dropOne_loop_end

	movq $1, %rsi
	andq %r8, %rsi

	jne getNextCell # if current block is zero
# current block is one and we have to check whether adding one to %r13 would make the number collide/more than 20
	movq %r13, %rax
	addq $1, %rax # simulate adding one to r13
	addq %rdi, %rax
	movq $20, %r9
	mulq %r9
	addq %r14, %rax
	addq %rsi, %rax
	
	movq $tetris_window, %r8
	addq %rax, %r8
	movq (%r8), %r8
	cmp $1, %r8
	je cantPlace
	cmp $200, %r8
	jge cantPlace

getNextCell:
	shrq $1, %r8

	incq %rdx
	cmp $8, %rdx
	jne dropOne_loop
	movq $0, %rdx
	incq %rdi

dropOne_loop_end:
	movq $1, %rax # we can dropDown the block
	incq %r13 # we can drop down the current block
	jmp afterDropOne

cantPlace:
	movq $0, %rax

afterDropOne:
	popq %r9
	popq %r8

	movq %rbp, %rsp
	popq %rbp
	ret
/* Checks if we can go one left/right, and if we can we do
*@rdi direction, can be -1/+1
*
*/
moveDirection:
	pushq %rbp
	movq %rsp, %rbp

	movq %rbp, %rsp
	popq %rbp

	ret
/** Draws the tetrisField + current block to basic_screen
*
*
**/
drawFieldToScreen:
	pushq %rbp
	movq %rsp, %rbp

	# current i, j
	movq $0, %rdi
	movq $0, %rsi
	
# first put all the placed blocks in basic_screen
drawLoopOne:
	cmp $20, %rdi
	je drawLoopOne_end

	# current block is rdi * tetris_width + rsi
	movq %rdi, %rax
	movq $tetris_width, %rbx
	mulq %rbx
	addq %rsi, %rax
	movq $tetris_window, %rdx
	addq %rax, %rdx
	movq %rdx, %rcx # holds the adress of the current block

	# now we need to cacluclate the adress in basic_screen
	movq %rdi, %rax
	addq $5, %rax
	movq $80, %rbx
	mulq %rbx
	addq $36, %rax
	addq %rsi, %rax
	movq $basic_screen, %rdx
	addq %rax, %rdx

	movzb (%rcx), %rcx
	cmp $0, %rcx
	je anotherBlockDraw
	movb %cl, (%rdx)
# increments rdi if rsi is tetris_width
anotherBlockDraw:
	incq %rsi
	cmp $tetris_width, %rsi
	jne drawLoopOne
	movq $0, %rsi
	incq %rdi
	jmp drawLoopOne
drawLoopOne_end:

	

	movq %rbp, %rsp
	popq %rbp
	ret
/** Called at every tick of gameLoop. I need one more register/adress_memory which dictates whether we should drop the block down
*
*
**/
updateGameState:
	pushq %rbp
	movq %rsp, %rbp

	

	movq %rbp, %rsp
	popq %rbp
	ret
/** the actual gameLoop. We can change the tick rate by changigng 
*
*
**/
gameLoop:
	cmp $1, %r12 # should we begin dropping a new block
	jne continue_dropping

start_dropping:
	# we are going to start dropping a new block now

	# calculates j to be half of the screen
	movq $tetris_width, %rax
	movq $0, %rdx
	movq $2, %rbx
	divq %rbx
	addq $31, %rax

	# sets i,j to 0, half of the screen
	movq $0, %r13
	movq %rax, %r14

	# loads the first block intro r15
	movq blocks, %r15
	movq block_order, %rax
	shlq $3, %rax
	addq %rax, %r15
	# r13 is row, r14 is column

continue_dropping:

	call updateGameState
	call drawFieldToScreen
// finally printing the current game board
	movq $0, %r12
	movq $0, %r13
	movq $basic_screen, %r14
// 254 is ascii code for black square
loop:
	movq %r13, %rdi
	movq %r12, %rsi
	movb $0, %dl # character
	
	movb (%r14), %cl # color
	incq %r14

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

	ret
