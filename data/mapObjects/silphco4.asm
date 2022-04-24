SilphCo4Object:
	db $2e ; border block

	db $7 ; warps
	db $0, $18, $1, SILPH_CO_3F
	db $0, $1a, $1, SILPH_CO_5F
	db $0, $14, $0, SILPH_CO_ELEVATOR
	db $7, $b, $3, SILPH_CO_10F
	db $3, $11, $3, SILPH_CO_6F
	db $f, $3, $4, SILPH_CO_10F
	db $b, $11, $5, SILPH_CO_10F

	db $0 ; signs

	db $7 ; objects
	object SPRITE_LAPRAS_GIVER, $6, $2, STAY, NONE, $1 ; person
	object SPRITE_ROCKET, $9, $e, STAY, RIGHT, $2, TRAINER_START + ROCKET, $1a
	object SPRITE_OAK_AIDE, $e, $6, STAY, LEFT, $3, TRAINER_START + SCIENTIST, $5
	object SPRITE_ROCKET, $1a, $a, STAY, UP, $4, TRAINER_START + ROCKET, $1b
	object SPRITE_BALL, $3, $9, STAY, NONE, $5, FULL_HEAL
	object SPRITE_BALL, $4, $7, STAY, NONE, $6, MAX_REVIVE
	object SPRITE_BALL, $5, $8, STAY, NONE, $7, ESCAPE_ROPE

	; warp-to
	EVENT_DISP SILPH_CO_4F_WIDTH, $0, $18 ; SILPH_CO_3F
	EVENT_DISP SILPH_CO_4F_WIDTH, $0, $1a ; SILPH_CO_5F
	EVENT_DISP SILPH_CO_4F_WIDTH, $0, $14 ; SILPH_CO_ELEVATOR
	EVENT_DISP SILPH_CO_4F_WIDTH, $7, $b ; SILPH_CO_10F
	EVENT_DISP SILPH_CO_4F_WIDTH, $3, $11 ; SILPH_CO_6F
	EVENT_DISP SILPH_CO_4F_WIDTH, $f, $3 ; SILPH_CO_10F
	EVENT_DISP SILPH_CO_4F_WIDTH, $b, $11 ; SILPH_CO_10F
