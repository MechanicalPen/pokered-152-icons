TypeEffects: ; 3e474 (f:6474)
; format: attacking type, defending type, damage multiplier
; the multiplier is a (decimal) fixed-point number:
;     20 is ×2.0
;     05 is ×0.5
;     00 is ×0
	db WATER,FIRE,20
	db FIRE,GRASS,20
	db FIRE,ICE,20
	db GRASS,WATER,20
	db ELECTRIC,WATER,20
	db WATER,ROCK,20
	db GROUND,FLYING,00
	db WATER,WATER,05
	db FIRE,FIRE,05
	db ELECTRIC,ELECTRIC,05
	db ICE,ICE,05
	db GRASS,GRASS,05
	db PSYCHIC,PSYCHIC,05
	db FIRE,WATER,05
	db GRASS,FIRE,05
	db WATER,GRASS,05
	db ELECTRIC,GRASS,05
	db NORMAL,ROCK,05
	db NORMAL,GHOST,00
	db GHOST,GHOST,20
	db FIRE,BUG,20
	db FIRE,ROCK,05
	db WATER,GROUND,20
	db ELECTRIC,GROUND,00
	db ELECTRIC,FLYING,20
	db GRASS,GROUND,20
	db GRASS,BUG,05
	db GRASS,POISON,05
	db GRASS,ROCK,20
	db GRASS,FLYING,05
	db ICE,WATER,05
	db ICE,GRASS,20
	db ICE,GROUND,20
	db ICE,FLYING,20
	db FIGHTING,NORMAL,20
	db FIGHTING,POISON,05
	db FIGHTING,FLYING,05
	db FIGHTING,PSYCHIC,05
	db FIGHTING,BUG,05
	db FIGHTING,ROCK,20
	db FIGHTING,ICE,20
	db FIGHTING,GHOST,00
	db POISON,GRASS,20
	db POISON,POISON,05
	db POISON,GROUND,05
	db POISON,BUG,20
	db POISON,ROCK,05
	db POISON,GHOST,05
	db GROUND,FIRE,20
	db GROUND,ELECTRIC,20
	db GROUND,GRASS,05
	db GROUND,BUG,05
	db GROUND,ROCK,20
	db GROUND,POISON,20
	db FLYING,ELECTRIC,05
	db FLYING,FIGHTING,20
	db FLYING,BUG,20
	db FLYING,GRASS,20
	db FLYING,ROCK,05
	db PSYCHIC,FIGHTING,20
	db PSYCHIC,POISON,20
	db BUG,FIRE,05
	db BUG,GRASS,20
	db BUG,FIGHTING,05
	db BUG,FLYING,05
	db BUG,PSYCHIC,20
	db BUG,GHOST,05
	db BUG,POISON,20
	db ROCK,FIRE,20
	db ROCK,FIGHTING,05
	db ROCK,GROUND,05
	db ROCK,FLYING,20
	db ROCK,BUG,20
	db ROCK,ICE,20
	db GHOST,NORMAL,00
	db GHOST,PSYCHIC,20 ;as per _SaffronGymAfterBattleText2
	db FIRE,DRAGON,05
	db WATER,DRAGON,05
	db ELECTRIC,DRAGON,05
	db GRASS,DRAGON,05
	db ICE,DRAGON,20
	db DRAGON,DRAGON,20
	db $FF
