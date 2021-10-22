.data 
tetris_window: 
				.skip 512 # might have to change depending on tetris_width. Currently is 20*20 pixels
basic_screen: .skip 2048
.equ tetris_width, 20
current_tick: .quad 0
			.skip 8
.equ ticks, 10
.equ gameTimer, 828500
