ForestMons:
		db $19
		IF DEF(_RED)
			db 3,WEEDLE
			db 5,KAKUNA
			db 4,WEEDLE
			db 5,WEEDLE
			db 4,KAKUNA
			db 6,KAKUNA
			db 6,METAPOD
			db 6,CATERPIE
		ENDC
		IF DEF(_BLUE)
			db 3,CATERPIE
			db 5,METAPOD
			db 4,CATERPIE
			db 5,CATERPIE
			db 4,METAPOD
			db 6,METAPOD
			db 6,KAKUNA
			db 6,WEEDLE
		ENDC
		db 3,PIKACHU
		db 5,PIKACHU
		
	db $00

