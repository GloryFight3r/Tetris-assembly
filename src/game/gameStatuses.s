/* shows the leaderboard
*
*
*/
leaderBoard:
	pushq %rbp
	movq %rsp, %rbp

	# time to save the score
#	call cleanTetrisScreen

	movq current_score, %rax
	
	movq $0, %rdi
	movq $leaderboard, %rsi

	#movq %rax, (%rsi)

deadScreen_loop:
	movq (%rsi), %rdx

	addq $8, %rsi
	incq %rdi
	cmp %rax, %rdx

	jg deadScreen_loop

	# time to change that score and shift all remaining to the right
	
	movq current_score, %rax

	pushq -8(%rsi)

	movq %rax, -8(%rsi)

shift_loop:
	cmp $128, %rdi
	je shift_loop_end
	
	popq %rcx
	pushq (%rsi)
	movq %rcx, (%rsi)

	addq $8, %rsi
	incq %rdi
	jmp shift_loop
shift_loop_end:

	movq $0, game_status
	movq %rbp, %rsp
	popq %rbp
	ret


/* Display the number into the provided adress
*@param rdi is the number, rsi is the adress
*
*/
numberToScreen2:
	pushq %rbp
	movq %rsp, %rbp

	pushq %rdi
	pushq %rsi
	pushq %rdx

	decq %rsp
	movb $0x00, (%rsp)

	movq $12, %rcx

	#movq $3, %rdi

	#movq current_score, %rdi

numberToScreen2_loop:
	cmp $0, %rcx
	je numberToScreen2_loop_end

	movq $0, %rdx
	movq %rdi, %rax
	movq $10, %rbx
	divq %rbx
	
	movq %rax, %rdi
	addq $'0', %rdx
	decq %rsp
	movb %dl, (%rsp)

	decq %rcx
	jmp numberToScreen2_loop
numberToScreen2_loop_end:

	movq -24(%rbp), %rdx

	movq %rsp, %rdi
	#movq $score_screen, %rdi
	call textToScreen3

	movq %rbp, %rsp
	popq %rbp
	ret

/* Puts a string into the screen
*@param rdi is the text, %rsi is starting adress, %rdx is the adress of basic_screen
*
*/
textToScreen3:
	pushq %rbp
	movq %rsp, %rbp

textToScreen3_loop:
	movzb (%rdi), %rax

	cmp $0x00, %rax
	je textToScreen3_loop_end

	movb %al, (%rsi)
	movb $0x41, (%rdx)

	incq %rdi
	incq %rsi
	incq %rdx
	
	jmp textToScreen3_loop
textToScreen3_loop_end:

	movq %rbp, %rsp
	popq %rbp
	ret

/* Updates the leaderboard
*
*
*/
updateLeaderboard:
	pushq %rbp
	movq %rsp, %rbp

	movq $0, %rsi
	movq $leaderboard, %rax

	movq $basic_screen_text, %rbx
	addq $223, %rbx

	movq $basic_screen, %rdx
	addq $223, %rdx

updateLeaderboard_loop:
	cmp $15, %rsi
	je updateLeaderboard_loop_end

	push %rax
	push %rsi
	push %rbx
	push %rdx

	movq (%rax), %rdi
	movq %rbx, %rsi

	call numberToScreen2

	popq %rdx
	popq %rbx
	popq %rsi
	popq %rax

	addq $8, %rax
	incq %rsi
	addq $80, %rbx
	addq $80, %rdx
	jmp updateLeaderboard_loop
updateLeaderboard_loop_end:

	movq %rbp, %rsp
	popq %rbp
	ret

/* shows main menu
*
*
*/
mainMenu:
	pushq %rbp
	movq %rsp, %rbp

	call cleanTetrisScreen
	call draw
	call updateLeaderboard

	movq $1, current_level
	movq $0, current_score
	movq $0, current_lines

	movq $starting_ticks, ticks
	movq $1, game_status # start the game

	movq %rbp, %rsp
	popq %rbp
	ret
