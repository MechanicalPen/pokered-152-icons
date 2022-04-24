VermilionGymObject:
	db $3 ; border block

	db $2 ; warps
	db $11, $4, $3, $ff
	db $11, $5, $3, $ff

	db $0 ; signs

	db $5 ; objects
	object SPRITE_ROCKER, $5, $1, STAY, DOWN, $1, TRAINER_START + LT__SURGE, $1
	object SPRITE_GENTLEMAN, $9, $6, STAY, LEFT, $2, TRAINER_START + GENTLEMAN, $3
	object SPRITE_BLACK_HAIR_BOY_2, $3, $8, STAY, LEFT, $3, TRAINER_START + ROCKER, $1
	object SPRITE_SAILOR, $0, $a, STAY, RIGHT, $4, TRAINER_START + SAILOR, $8
	object SPRITE_GYM_HELPER, $4, $e, STAY, DOWN, $5 ; person

	; warp-to
	EVENT_DISP VERMILION_GYM_WIDTH, $11, $4
	EVENT_DISP VERMILION_GYM_WIDTH, $11, $5
