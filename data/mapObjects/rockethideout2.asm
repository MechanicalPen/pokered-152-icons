RocketHideout2Object:
	db $2e ; border block

	db $5 ; warps
	db $8, $1b, $0, ROCKET_HIDEOUT_1
	db $8, $15, $0, ROCKET_HIDEOUT_3
	db $13, $18, $0, ROCKET_HIDEOUT_ELEVATOR
	db $16, $15, $3, ROCKET_HIDEOUT_1
	db $13, $19, $1, ROCKET_HIDEOUT_ELEVATOR

	db $0 ; signs

	db $5 ; objects
	object SPRITE_ROCKET, $14, $c, STAY, DOWN, $1, TRAINER_START + ROCKET, $d
	object SPRITE_BALL, $1, $b, STAY, NONE, $2, MOON_STONE
	object SPRITE_BALL, $10, $8, STAY, NONE, $3, NUGGET
	object SPRITE_BALL, $6, $c, STAY, NONE, $4, TM_07
	object SPRITE_BALL, $3, $15, STAY, NONE, $5, SUPER_POTION

	; warp-to
	EVENT_DISP ROCKET_HIDEOUT_2_WIDTH, $8, $1b ; ROCKET_HIDEOUT_1
	EVENT_DISP ROCKET_HIDEOUT_2_WIDTH, $8, $15 ; ROCKET_HIDEOUT_3
	EVENT_DISP ROCKET_HIDEOUT_2_WIDTH, $13, $18 ; ROCKET_HIDEOUT_ELEVATOR
	EVENT_DISP ROCKET_HIDEOUT_2_WIDTH, $16, $15 ; ROCKET_HIDEOUT_1
	EVENT_DISP ROCKET_HIDEOUT_2_WIDTH, $13, $19 ; ROCKET_HIDEOUT_ELEVATOR
