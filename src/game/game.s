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
	shrq $56, %rax # makes rax only equal to the highest byte of rdi
	shlq $56, %rax

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
	jmp rotateBlock_loop
rotateBlock_end:

	movq %rbp, %rsp
	popq %rbp
	ret
/** Checks whether the current x, y and block is viable
*@param r13, r14, r15
*@ret returns 0/1 in rax
*/ 
isViable:
	pushq %rbp
	movq %rsp, %rbp

	movq $0, %rdi
	movq $0, %rsi
	movq %r15, %r8
	movq %r8, %r9
	shrq $56, %r9 # holds the current color in the lowest byte of r9

isViable_loop:
	cmp $7, %rdi
	je isViable_loop_end
	
	# check if the current cell is a one
	movq $1, %rdx
	andq %r8, %rdx
	cmp $1, %rdx
	jne nextBlock # current cell is not a one

# calculates the adress where I have to put the block
	movq %rdi, %rax
	addq %r13, %rax # adds the x of our current position
	movq $tetris_width, %rbx
	mulq %rbx
	addq %rsi, %rax
	addq %r14, %rax # adds the y of our current position
	#movq $440, %rax
	
	#cmp $400, %rax
	#jle inBound
	
	#movq $0, %rax
	#jmp after_isViable

inBound:
	movq $tetris_window, %rbx
	addq %rax, %rbx # rbx holds the adress in which I have to place the current cell

	movzb (%rbx), %rbx

	cmp $0, %rbx
	je nextBlock

	# both are ones so we return

	movq $0, %rax
	jmp after_isViable	

nextBlock:
	shrq $1, %r8 # removes the lowest bit

	incq %rsi
	cmp $8, %rsi
	jne isViable_loop

	incq %rdi
	movq $0, %rsi

	jmp isViable_loop

isViable_loop_end:
	movq $1, %rax

after_isViable:

	movq %rbp, %rsp
	popq %rbp
	ret
/* Checks if we can go one down, and if we can we do, otherwise we should put the current block and start dropping another
*@r13,r14 are x,y respectuflly
*@ret rax 0 if we cant dropOne
*/
dropOne:
	pushq %rbp
	movq %rsp, %rbp
	
	incq %r13
	call isViable

	cmp $1, %rax
	je can_drop
	decq %r13
can_drop:

	movq %rbp, %rsp
	popq %rbp
	ret

/* Rotates the block if possible
*
*
*/
rotateOperation:
	pushq %rbp
	movq %rsp, %rbp

	# save the current block incase it fails
	pushq %r15
	pushq %r15

	movq %r15, %rdi
	call rotateBlock
	movq %rax, %r15

	call isViable
	cmp $1, %rax
	je rotateSuccess
	
	popq %r15
	popq %r15
rotateSuccess:

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

	push %rdi
	push %rdi

	addq %rdi, %r14
	call isViable

	popq %rdi
	popq %rdi

	cmp $1, %rax
	je can_move
	subq %rdi, %r14
can_move:

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
	movq $1, %rdi
	movq $1, %rsi
	
# first put all the placed blocks in basic_screen
drawLoopOne:
	cmp $tetris_width, %rdi
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
	addq $4, %rax
	movq $80, %rbx
	mulq %rbx
	addq $35, %rax
	addq %rsi, %rax

	movq $basic_screen, %rdx
	addq %rax, %rdx

	movzb (%rcx), %rcx
	cmp $0, %rcx
	jne placeCurrent
	movq $0x80, %rcx # an empty block

placeCurrent:
	movb %cl, (%rdx)
# increments rdi if rsi is tetris_width
anotherBlockDraw:
	incq %rsi
	cmp $tetris_width_minus, %rsi
	jne drawLoopOne
	movq $1, %rsi
	incq %rdi
	jmp drawLoopOne
drawLoopOne_end:

# now I have to draw the current block
	
	movq $0, %rdi
	movq $0, %rsi
	movq %r15, %r8
	movq %r8, %r9
	shrq $56, %r9 # holds the current color in the lowest byte of r9
	movq $0, %r11
drawBlock:
	cmp $7, %rdi
	je drawBlock_end
	
# calculates the adress where I have to put the block
	movq $4, %rax
	addq %rdi, %rax
	addq %r13, %rax # adds the x of our current position
	movq $80, %rbx
	mulq %rbx
	addq %rsi, %rax
	addq %r14, %rax # adds the y of our current position
	addq $35, %rax
	#movq $440, %rax
	movq $basic_screen, %rbx
	addq %rax, %rbx # rbx holds the adress in which I have to place the current cell

	# check if the current cell is a one
	movq $1, %rdx
	andq %r8, %rdx
	cmp $1, %rdx
	jne getNextBlock # current cell is not a one
	incq %r11
#  now it is
	movb %r9b, (%rbx) # moves the color to the adress
	
getNextBlock:
	shrq $1, %r8 # removes the lowest bit

	incq %rsi
	cmp $8, %rsi
	jne drawBlock

	incq %rdi
	movq $0, %rsi

	jmp drawBlock

drawBlock_end:
	movq %rbp, %rsp
	popq %rbp
	ret
/* Saves the block we were dropping until now
*
*
*/
saveBlock:
	pushq %rbp
	movq %rsp, %rbp

	movq $0, %rdi
	movq $0, %rsi
	movq %r15, %r8
	movq %r8, %r9
	shrq $56, %r9 # holds the current color in the lowest byte of r9

saveBlockLoop:
	cmp $7, %rdi
	je saveBlockLoop_end
	
# calculates the adress where I have to put the block
	movq %rdi, %rax
	addq %r13, %rax # adds the x of our current position
	movq $tetris_width, %rbx
	mulq %rbx
	addq %rsi, %rax
	addq %r14, %rax # adds the y of our current position
	#movq $440, %rax
	movq $tetris_window, %rbx
	addq %rax, %rbx # rbx holds the adress in which I have to place the current cell

	# check if the current cell is a one
	movq $1, %rdx
	andq %r8, %rdx
	cmp $1, %rdx
	jne getNextBlockSave # current cell is not a one
#  now it is
	movb %r9b, (%rbx) # moves the color to the adress
	
getNextBlockSave:
	shrq $1, %r8 # removes the lowest bit

	incq %rsi
	cmp $8, %rsi
	jne saveBlockLoop

	incq %rdi
	movq $0, %rsi

	jmp saveBlockLoop

saveBlockLoop_end:

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
	
	call readKeyCode
	cmp $0x1e, %al

	jne not_left_arrow
	movq $-1, %rdi
	call moveDirection

not_left_arrow:
	cmp $0x20, %al

	jne not_right_arrow
	movq $1, %rdi
	call moveDirection

not_right_arrow:
	cmp $0x11, %al
	jne not_up
	call rotateOperation

not_up:
	cmp $0x1f, %al
	jne not_down
	call dropOne
	movq $0, current_tick

not_down:

	movq current_tick, %rax
	cmp $ticks, %rax
	jl skip_drop

	mov $-1, current_tick
	call dropOne

	cmp $1, %rax
	je skip_drop
# we cant drop
	# now we have to save the current block into tetris_window
	call saveBlock

	movq $1, %r12
	movq $0, current_tick
	
	movq %rbp, %rsp
	popq %rbp

	ret

skip_drop:
	incq %rax
	movq %rax, current_tick

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

	# sets i,j to 0, half of the screen
	movq $-1, %r13
	subq $5, %rax
	movq %rax, %r14

	# loads the first block into r15
	movq $blocks, %r15

	movq $block_order, %rax
	addq current_block, %rax

	movzb (%rax), %rax
	addq $1, block_order
	#movq $0, %rax
	shlq $3, %rax
	#addq $8, %r15
	addq %rax, %r15
	movq (%r15), %r15
	# r13 is row, r14 is column
	
	movq $0, %r12 # now we start dropping it

continue_dropping:

	call updateGameState
	call drawFieldToScreen
// finally printing the current game board
	pushq %r12
	pushq %r12
	pushq %r13
	pushq %r14

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

	popq %r14
	popq %r13
	popq %r12
	popq %r12

	ret
