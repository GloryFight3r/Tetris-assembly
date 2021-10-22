.global draw

draw:
	pushq %rbp
	movq %rsp, %rbp

	movq $basic_screen, %rax
	movq $2000, %rdi
	
	// makes the screen gray
gameInit_loop:
	cmp $0, %rdi
	je gameInit_loop_end
	decq %rdi

	movq $0x80, (%rax)
	incq %rax

	jmp gameInit_loop
gameInit_loop_end:

	// writes tetris on screen

	movq $basic_screen, %rax
	addq $35, %rax

	movq $25, %rdi

// draws the tetris outline
first_loop:
	cmp $0, %rdi
	je first_loop_end
	decq %rdi

	cmp $20, %rdi
	jl without
	
	pushq %rax # save the register

	movq $tetris_width, %rsi
	addq $1, %rax

draw_loop:
	cmp $0, %rsi
	je draw_loop_end
	decq %rsi

	movb $0x070, (%rax)
	incq %rax

	jmp draw_loop
draw_loop_end:

	popq %rax
without:
	movb $0x70, (%rax)
	
	movq $tetris_width, %rbx
	addq $1, %rbx
	addq %rbx, %rax

	movb $0x70, (%rax)

	movq $tetris_width, %rcx
	movq $79, %rbx
	subq %rcx, %rbx

	addq %rbx, %rax
	jmp first_loop
first_loop_end:

	// types tetris
	movq $0, %rax
	movq $37, %rdi

	// draws T
	movb $0x40, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0x40, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0x40, basic_screen(%rax, %rdi, 1)
	incq %rdi

	movb $0xC0, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0xC0, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0xC0, basic_screen(%rax, %rdi, 1)
	incq %rdi

	movb $0xE0, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0xE0, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0xE0, basic_screen(%rax, %rdi, 1)
	incq %rdi

	movb $0x20, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0x20, basic_screen(%rax, %rdi, 1)
	incq %rdi
	incq %rdi

	movb $0x30, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0x30, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0x30, basic_screen(%rax, %rdi, 1)
	
	addq $2, %rdi
	movb $0x50, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0x50, basic_screen(%rax, %rdi, 1)
	
	movq $118, %rdi

	movb $0x40, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0xC0, basic_screen(%rax, %rdi, 1)
	addq $4, %rdi
	movb $0xE0, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0x20, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0x20, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0x30, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0x50, basic_screen(%rax, %rdi, 1)

	movq $198, %rdi

	movb $0x40, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0xC0, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0xC0, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0xC0, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0xE0, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0x20, basic_screen(%rax, %rdi, 1)
	addq $1, %rdi
	movb $0x20, basic_screen(%rax, %rdi, 1)
	addq $3, %rdi
	movb $0x30, basic_screen(%rax, %rdi, 1)
	addq $3, %rdi
	movb $0x50, basic_screen(%rax, %rdi, 1)
	
	movq $278, %rdi

	movb $0x40, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0xC0, basic_screen(%rax, %rdi, 1)
	addq $4, %rdi
	movb $0xE0, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0x20, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0x20, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0x30, basic_screen(%rax, %rdi, 1)
	addq $4, %rdi
	movb $0x50, basic_screen(%rax, %rdi, 1)

	movq $358, %rdi

	movb $0x40, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0xC0, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0xC0, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0xC0, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0xE0, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0x20, basic_screen(%rax, %rdi, 1)
	addq $2, %rdi
	movb $0x20, basic_screen(%rax, %rdi, 1)
	addq $1, %rdi
	movb $0x30, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0x30, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0x30, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0x50, basic_screen(%rax, %rdi, 1)
	incq %rdi
	movb $0x50, basic_screen(%rax, %rdi, 1)

	movq $1, %r12 # r12 is the flag which indicates whether we should start dropping a new block

	movq %rbp, %rsp
	popq %rbp
	ret
