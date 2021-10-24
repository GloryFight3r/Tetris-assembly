.data 
tetris_window: 
				.skip 1024 # might have to change depending on tetris_width. Currently is 20*20 pixels
basic_screen: .skip 5096
.equ tetris_width, 22
.equ tetris_width_minus, 21
.equ tetris_width_normal, 20
current_tick: .quad 0
			.skip 8
current_block: .quad 0
			.skip 8
.equ ticks, 30
.equ gameTimer, 828500
