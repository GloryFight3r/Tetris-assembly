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
*@rdi is the multiplicator for the score, r13,r14 are x,y respectuflly
*@ret rax 0 if we cant dropOne
*/
dropOne:
	pushq %rbp
	movq %rsp, %rbp
	
	pushq %rdi
	pushq %rdi

	incq %r13
	call isViable

	cmp $1, %rax
	je can_drop
	decq %r13
	movq $0, -8(%rbp)
can_drop:

	popq %rdi
	popq %rdi
	pushq %rax
	
	movq %rdi, %rax
	movq current_level, %rbx
	mulq %rbx
	#TODO Uncomment
	addq %rax, current_score # multiplies rdi which is the multiplier by our current level and adds it to current_score
	popq %rax

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

/* Draws the block that is falling to the basic_screen
*
*
*/
drawToBasicScreen:
	pushq %rbp
	movq %rsp, %rbp

	movq $0, %rdi
	movq $0, %rsi
	movq %r15, %r8
	movq %r8, %r9
	shrq $56, %r9 # holds the current color in the lowest byte of r9
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
	
	pushq %r13
	pushq %r14
	pushq %r15
	pushq %r15

	shlq $8, %r15 # removes current color
	shrq $8, %r15

	movq $0x90, %rax
	shlq $56, %rax
	xorq %rax, %r15
	
	movq $0, %rdi
	call instantDrop

	call drawToBasicScreen
	
	popq %r15
	popq %r15
	popq %r14
	popq %r13
	call drawToBasicScreen

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

/* Shifts all lines uptill rdi
*@param rdi show uptill which line we should shift
*
*/
shiftLines:
	pushq %rbp
	movq %rsp, %rbp
	decq %rdi

	#TODO Remove this
	#jmp shiftLines

shiftLines_loop:
	cmp $0, %rdi
	je shiftLines_end
	
	movq %rdi, %rax
	movq $tetris_width, %rbx
	mulq %rbx
	movq $tetris_window, %rbx
	addq %rax, %rbx
	incq %rbx

	movq $1, %rsi
shiftLines_row_loop:
	cmp $tetris_width_minus, %rsi
	je shiftLines_row_end

	movq %rbx, %rcx
	addq $tetris_width, %rcx

	movzb (%rbx), %rax
	movb %al, (%rcx)
	movb $0, (%rbx)

	incq %rsi
	incq %rbx
	incq %rcx

	jmp shiftLines_row_loop
shiftLines_row_end:
	
	decq %rdi
	jmp shiftLines_loop
shiftLines_end:

	movq %rbp, %rsp
	popq %rbp
	ret

/* Removes all filled lines
*
*
*/
removeLines:
	push %rbp
	movq %rsp, %rbp

	movq $tetris_width_normal, %rdi
	#TODO remove this line
	#movq $1, %rdi

removeLines_loop:
	cmp $0, %rdi
	je removeLines_end

	movq %rdi, %rbx
	movq $tetris_width, %rax
	mulq %rbx
	movq $tetris_window, %rbx
	addq %rax, %rbx

	movq $1, %rax # indicates whether there is a hole in the row
	movq $0, %rsi

removeLines_row:
	cmp $tetris_width, %rsi
	je removeLines_row_end

	movzb (%rbx), %rcx
	cmp $0, %rcx

	jne notAHole
	movq $0, %rax
	jmp removeLines_row_end

notAHole:
	incq %rsi
	incq %rbx
	jmp removeLines_row
removeLines_row_end:

	cmp $1, %rax

	jne dontClear
	
	pushq %rdi
	pushq %rdi
	
	call shiftLines
	incq current_lines
	movq $100, %rax
	movq current_level, %rbx
	mulq %rbx
	addq %rax, current_score


	popq %rdi
	popq %rdi

	incq %rdi

dontClear:

	decq %rdi
	jmp removeLines_loop
removeLines_end:

	# recalculate current_level

	movq current_lines, %rax
	movq $10, %rbx
	divq %rbx
	incq %rax
	movq %rax, current_level

	movq %rbp, %rsp
	popq %rbp
	ret

/* Drops the block instantly to the end
*@param rdi is the multiplier
*
*/
instantDrop:
	pushq %rbp
	movq %rsp, %rbp

	pushq %rdi
	pushq %rdi

instantDrop_loop:
	movq -8(%rbp), %rdi
	call dropOne
	cmp $1, %rax
	
	je instantDrop_loop

	#movq %rax, -8(%rbp)

	#movq (%rsp), %rax
	#movq $2, %rbx
	#mulq %rbx

	#addq %rax, current_score

	#movq -8(%rbp), %rax

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
	movq $1, %rdi
	call dropOne
	movq $0, current_tick
not_down:
	cmp $0x39, %al
	jne not_instant_drop

	movq $2, %rdi
	call instantDrop
	movq $0, current_tick
	jmp saveTime

not_instant_drop:

	movq current_tick, %rax
	cmp $ticks, %rax
	jl skip_drop

	movq $-1, current_tick
	movq $0, %rdi
	call dropOne

	cmp $1, %rax
	je skip_drop
saveTime:
# we cant drop
	# now we have to save the current block into tetris_window
	call saveBlock
	# removes all filled lines
	call removeLines

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

/* Checks if we are dead 💀
*
*
*/
isDead:
	pushq %rbp
	movq %rsp, %rbp

	call isViable
	
	cmp $1, %rax

	je notDead
	
	movq $3, game_status

notDead:

	movq %rbp, %rsp
	popq %rbp
	ret

/* Display the number into the provided adress
*@param rdi is the number, rsi is the adress
*
*/
numberToScreen:
	pushq %rbp
	movq %rsp, %rbp

	pushq %rdi
	pushq %rsi
	pushq %rdx

	decq %rsp
	movb $0x00, (%rsp)

	movq $7, %rcx

	#movq current_score, %rdi

numberToScreen_loop:
	cmp $0, %rcx
	je numberToScreen_loop_end

	movq $0, %rdx
	movq %rdi, %rax
	movq $10, %rbx
	divq %rbx
	
	movq %rax, %rdi
	addq $'0', %rdx
	decq %rsp
	movb %dl, (%rsp)

	decq %rcx
	jmp numberToScreen_loop
numberToScreen_loop_end:

	movq -24(%rbp), %rdx

	movq %rsp, %rdi
	#movq $score_screen, %rdi
	call textToScreen2

	movq %rbp, %rsp
	popq %rbp
	ret

/* Puts a string into the screen
*@param rdi is the text, %rsi is starting adress, %rdx is the adress of basic_screen
*
*/
textToScreen2:
	pushq %rbp
	movq %rsp, %rbp

textToScreen2_loop:
	movzb (%rdi), %rax

	cmp $0x00, %rax
	je textToScreen2_loop_end

	movb %al, (%rsi)
	movb $0x14, (%rdx)

	incq %rdi
	incq %rsi
	incq %rdx
	
	jmp textToScreen2_loop
textToScreen2_loop_end:

	movq %rbp, %rsp
	popq %rbp
	ret

/* Updates the scores
*	
*
*/
updateResults:
	pushq %rbp
	movq %rsp, %rbp

	# displays the score
	movq current_score, %rdi
	movq $basic_screen_text, %rsi
	movq $basic_screen, %rdx
	addq $1616, %rsi
	addq $1616, %rdx
	call numberToScreen

	#displays the level
	movq current_level, %rdi
	movq $basic_screen_text, %rsi
	movq $basic_screen, %rdx
	addq $1696, %rsi
	addq $1696, %rdx
	call numberToScreen

	
	#displays the lines
	movq current_lines, %rdi
	movq $basic_screen_text, %rsi
	movq $basic_screen, %rdx
	addq $1776, %rsi
	addq $1776, %rdx
	call numberToScreen


	movq %rbp, %rsp
	popq %rbp
	ret

/* Normal game
*
*
*/
normalGame:
	pushq %rbp
	movq %rsp, %rbp

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
	addq $1, current_block
	#movq $0, %rax
	shlq $3, %rax
	#addq $8, %r15
	addq %rax, %r15
	movq (%r15), %r15
	# r13 is row, r14 is column
	
	call isDead

	movq $0, %r12 # now we start dropping it

continue_dropping:

	call updateGameState
	call updateResults
	call drawFieldToScreen

	movq %rbp, %rsp
	popq %rbp
	ret

