CeladonGymObject:
	db $3 ; border block

	db $2 ; warps
	db $11, $4, $6, $ff
	db $11, $5, $6, $ff

	db $0 ; signs

	db $8 ; objects
	object SPRITE_ERIKA, $4, $3, STAY, DOWN, $1, TRAINER_START + ERIKA, $1
	object SPRITE_LASS, $2, $b, STAY, RIGHT, $2, TRAINER_START + LASS, $11
	object SPRITE_FOULARD_WOMAN, $7, $a, STAY, LEFT, $3, TRAINER_START + BEAUTY, $1
	object SPRITE_LASS, $9, $5, STAY, DOWN, $4, TRAINER_START + JR__TRAINER_F, $b
	object SPRITE_FOULARD_WOMAN, $1, $5, STAY, DOWN, $5, TRAINER_START + BEAUTY, $2
	object SPRITE_LASS, $6, $3, STAY, DOWN, $6, TRAINER_START + LASS, $12
	object SPRITE_FOULARD_WOMAN, $3, $3, STAY, DOWN, $7, TRAINER_START + BEAUTY, $3
	object SPRITE_LASS, $5, $3, STAY, DOWN, $8, TRAINER_START + COOLTRAINER_F, $1

	; warp-to
	EVENT_DISP CELADON_GYM_WIDTH, $11, $4
	EVENT_DISP CELADON_GYM_WIDTH, $11, $5
