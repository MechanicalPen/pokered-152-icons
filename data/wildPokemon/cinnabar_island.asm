Cinnabar:
	db $0A
	IF DEF(_RED)
		db 32,KRABBY     ;20%
		db 30,STARYU     ;20%
		db 24,TENTACOOL  ;15%
		db 30,HORSEA     ;10%
		db 35,FEAROW     ;10%
		db 32,KRABBY     ;10%
		db 30,SHELLDER   ; 5%
		db 28,PSYDUCK    ; 5%
		db 34,SEADRA     ; 4%
		db 38,CLOYSTER   ; 1%
	ENDC

	IF DEF(_GREEN) || DEF(_BLUE)
		db 32,STARYU
		db 30,KRABBY
		db 24,HORSEA
		db 30,PSYDUCK
		db 35,FEAROW
		db 32,SHELLDER
		db 30,STARYU
		db 28,HORSEA
		db 34,TENTACOOL
		db 38,STARMIE
	ENDC
	
	db $00