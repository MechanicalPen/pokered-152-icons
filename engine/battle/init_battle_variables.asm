InitBattleVariables: ; 525af (14:65af)
	ld a, [hTilesetType]
	ld [wd0d4], a
	xor a
	ld [wPlayerTurns], a
	ld [wcd6a], a
	ld [wBattleResult], a
	ld hl, wcc2b
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld [wListScrollOffset], a
	ld [wCriticalHitOrOHKO], a
	ld [wBattleMonSpecies], a
	ld [wPartyGainExpFlags], a
	ld [wPlayerMonNumber], a 
	ld [wEscapedFromBattle], a
	ld [wMapPalOffset], a
    ld a, 2 ; HP_BAR_RED
	ld hl, wcf1d ; wPlayerHPBarColor
	ld [hli], a ; wPlayerHPBarColor
	ld [hl], a ; wEnemyHPBarColor
	;set-up stuff for loop.
 	ld hl, wccd3
 	ld b, $3c
	xor a
.loop
	ld [hli], a
	dec b
	jr nz, .loop
	inc a
	ld [wccd9], a
	ld a, [W_CURMAP] 
	cp SAFARI_ZONE_EAST
	jr c, .notSafariBattle
	cp SAFARI_ZONE_REST_HOUSE_1
	jr nc, .notSafariBattle
	ld a, $2 ; safari battle
	ld [W_BATTLETYPE], a
.notSafariBattle
	ld hl, PlayBattleMusic
	ld b, BANK(PlayBattleMusic)
	jp Bankswitch
