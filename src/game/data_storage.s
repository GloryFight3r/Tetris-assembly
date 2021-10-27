.data 
tetris_window: 
				.skip 1024 # might have to change depending on tetris_width. Currently is 20*20 pixels
basic_screen: .skip 5096
basic_screen_text: .skip 5096
.equ tetris_width, 22
.equ tetris_width_minus, 21
.equ tetris_width_normal, 20
current_tick: .quad 0
			.skip 8
current_block: .quad 0
			.skip 8
game_status: .quad 1 # 0 is main menu, 1 is game screen, 2 is leaderboard, 3 is score save
current_score: .quad 0 # current score of the game
current_level: .quad 1 # the current level, every 10 lines we level up
current_lines: .quad 0 # the lines we have cleared
.equ ticks, 30
.equ gameTimer, 828500

score_screen: .asciz "Score:0000000"
level_screen: .asciz "Level:0000000"
lines_screen: .asciz "Lines:0000000"
