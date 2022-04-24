RocketHideout1Object:
	db $2e ; border block

	db $5 ; warps
	db $2, $17, $0, ROCKET_HIDEOUT_2
	db $2, $15, $2, GAME_CORNER
	db $13, $18, $0, ROCKET_HIDEOUT_ELEVATOR
	db $18, $15, $3, ROCKET_HIDEOUT_2
	db $13, $19, $1, ROCKET_HIDEOUT_ELEVATOR

	db $0 ; signs

	db $7 ; objects
	object SPRITE_ROCKET, $1a, $8, STAY, LEFT, $1, TRAINER_START + ROCKET, $8
	object SPRITE_ROCKET, $c, $6, STAY, RIGHT, $2, TRAINER_START + ROCKET, $9
	object SPRITE_ROCKET, $12, $11, STAY, DOWN, $3, TRAINER_START + ROCKET, $a
	object SPRITE_ROCKET, $f, $19, STAY, RIGHT, $4, TRAINER_START + ROCKET, $b
	object SPRITE_ROCKET, $1c, $12, STAY, LEFT, $5, TRAINER_START + ROCKET, $c
	object SPRITE_BALL, $b, $e, STAY, NONE, $6, ESCAPE_ROPE
	object SPRITE_BALL, $9, $11, STAY, NONE, $7, HYPER_POTION

	; warp-to
	EVENT_DISP ROCKET_HIDEOUT_1_WIDTH, $2, $17 ; ROCKET_HIDEOUT_2
	EVENT_DISP ROCKET_HIDEOUT_1_WIDTH, $2, $15 ; GAME_CORNER
	EVENT_DISP ROCKET_HIDEOUT_1_WIDTH, $13, $18 ; ROCKET_HIDEOUT_ELEVATOR
	EVENT_DISP ROCKET_HIDEOUT_1_WIDTH, $18, $15 ; ROCKET_HIDEOUT_2
	EVENT_DISP ROCKET_HIDEOUT_1_WIDTH, $13, $19 ; ROCKET_HIDEOUT_ELEVATOR
