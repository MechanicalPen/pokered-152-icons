RockTunnel1Object:
	db $3 ; border block

	db $8 ; warps
	db $3, $f, $1, $ff
	db $0, $f, $1, $ff
	db $21, $f, $2, $ff
	db $23, $f, $2, $ff
	db $3, $25, $0, ROCK_TUNNEL_2
	db $3, $5, $1, ROCK_TUNNEL_2
	db $b, $11, $2, ROCK_TUNNEL_2
	db $11, $25, $3, ROCK_TUNNEL_2

	db $1 ; signs
	db $1d, $b, $8 ; RockTunnel1Text8

	db $7 ; objects
	object SPRITE_HIKER, $7, $5, STAY, DOWN, $1, TRAINER_START + HIKER, $c
	object SPRITE_HIKER, $5, $10, STAY, DOWN, $2, TRAINER_START + HIKER, $d
	object SPRITE_HIKER, $11, $f, STAY, LEFT, $3, TRAINER_START + HIKER, $e
	object SPRITE_BLACK_HAIR_BOY_2, $17, $8, STAY, LEFT, $4, TRAINER_START + POKEMANIAC, $7
	object SPRITE_LASS, $25, $15, STAY, LEFT, $5, TRAINER_START + JR__TRAINER_F, $11
	object SPRITE_LASS, $16, $18, STAY, DOWN, $6, TRAINER_START + JR__TRAINER_F, $12
	object SPRITE_LASS, $20, $18, STAY, RIGHT, $7, TRAINER_START + JR__TRAINER_F, $13

	; warp-to
	EVENT_DISP ROCK_TUNNEL_1_WIDTH, $3, $f
	EVENT_DISP ROCK_TUNNEL_1_WIDTH, $0, $f
	EVENT_DISP ROCK_TUNNEL_1_WIDTH, $21, $f
	EVENT_DISP ROCK_TUNNEL_1_WIDTH, $23, $f
	EVENT_DISP ROCK_TUNNEL_1_WIDTH, $3, $25 ; ROCK_TUNNEL_2
	EVENT_DISP ROCK_TUNNEL_1_WIDTH, $3, $5 ; ROCK_TUNNEL_2
	EVENT_DISP ROCK_TUNNEL_1_WIDTH, $b, $11 ; ROCK_TUNNEL_2
	EVENT_DISP ROCK_TUNNEL_1_WIDTH, $11, $25 ; ROCK_TUNNEL_2
