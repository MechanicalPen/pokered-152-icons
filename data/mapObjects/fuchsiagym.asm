FuchsiaGymObject:
	db $3 ; border block

	db $2 ; warps
	db $11, $4, $5, $ff
	db $11, $5, $5, $ff

	db $0 ; signs

	db $8 ; objects
	object SPRITE_BLACKBELT, $4, $a, STAY, DOWN, $1, TRAINER_START + KOGA, $1
	object SPRITE_ROCKER, $8, $d, STAY, DOWN, $2, TRAINER_START + JUGGLER, $7
	object SPRITE_ROCKER, $7, $8, STAY, RIGHT, $3, TRAINER_START + JUGGLER, $3
	object SPRITE_ROCKER, $1, $c, STAY, DOWN, $4, TRAINER_START + JUGGLER, $8
	object SPRITE_ROCKER, $3, $5, STAY, UP, $5, TRAINER_START + TAMER, $1
	object SPRITE_ROCKER, $8, $2, STAY, DOWN, $6, TRAINER_START + TAMER, $2
	object SPRITE_ROCKER, $2, $7, STAY, LEFT, $7, TRAINER_START + JUGGLER, $4
	object SPRITE_GYM_HELPER, $7, $f, STAY, DOWN, $8 ; person

	; warp-to
	EVENT_DISP FUCHSIA_GYM_WIDTH, $11, $4
	EVENT_DISP FUCHSIA_GYM_WIDTH, $11, $5
