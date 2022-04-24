LoadNicknameMonSprite:
    call DisableLCD
    xor a
    ld [H_DOWNARROWBLINKCNT2], a
    ld a, [wMonPartySpriteSpecies]
    ld de, vNPCSprites
    call LoadPartyMonSpriteIntoVRAM
    call FillPartyMonOAM
    call EnableLCD
    ld a, [H_SPRITEINDEX]
    push af
    xor a
    ld [H_SPRITEINDEX], a
    call ShowPartyMonSprite
    pop af
    ld [H_SPRITEINDEX], a
    ret
	
LoadTradeMonSprite:
	call LoadNicknameMonSprite
	call AdjustForTradeScreen
	ret
	

LoadPartyMonSprites:
    call DisableLCD
    ld de, vNPCSprites
    ld hl, wPartySpecies
.loop
    ld a, [hli]
    cp $ff
    jr z, .done
    push hl
    call LoadPartyMonSpriteIntoVRAM
    pop hl
    jr .loop
.done
	call FillPartyMonOAM
    jp EnableLCD

LoadPartyMonSpriteIntoVRAM:
	push de
	ld [wd11e], a
	predef IndexToPokedex
	xor a
	ld [H_MULTIPLICAND], a
	ld [H_MULTIPLICAND + 1], a
	ld a, [wd11e]
	ld b, a ; store dex number for a second, so we can use it to look up the bank.
	cp 96
	jr c, .startAtZero
	; else start at 96
	sub 96
.startAtZero
	; 0 is now missingno.
	ld [H_MULTIPLICAND + 2], a
	ld a, $80
	ld [H_MULTIPLIER], a
	call Multiply
	ld a, [H_PRODUCT + 2]
	ld h, a
	ld a, [H_PRODUCT + 3]
	ld l, a	
	ld a, h
	add $40
	ld h, a
	ld a, 95
	cp b ; fixme this comparison isn't right for hoq I have the sprite data laid out.
	ld a, BANK(PartyMonSprites2)
	jr c, .gotBank
	ld a, BANK(PartyMonSprites1)
.gotBank
	pop de
	ld bc, $0080
	jp FarCopyData
	  
FillPartyMonOAM:
    push hl
    push de
    push bc
    ld hl, PartyMonOAM
    ld de, wOAMBuffer
    ld bc, $60
    call CopyData
    ld hl, PartyMonOAM
    ld de, wMonPartySpritesSavedOAM
    ld bc, $60
    call CopyData
    pop bc
    pop de
    pop hl

ShowPartyMonSprite:
    push hl
    push de
    push bc
    ld a, [H_SPRITEINDEX]
    add a
    add a
    add a
    add a ;x16. a is $0 - $50 now.
	ld c, a ; store H_SPRITEINDEX * 8 for later.	
    ld hl, wOAMBuffer
    ld b, 0
    add hl, bc
    add $10 ; for OAM Y replacement
    ld de, $4
    ld [hl], a
    add hl, de
    ld [hl], a
    add hl, de
    add $8
    ld [hl], a
    add hl, de
    ld [hl], a
    add hl, de
    ; also update the saved OAM.
    ld hl, wOAMBuffer ; count back up to where we were
    ld b, 0
	; we haven't touched c yet so it's still H_SPRITEINDEX * 8.
    add hl, bc
	push hl
    ld hl, wMonPartySpritesSavedOAM
	add hl, bc
	push hl
	pop de
	pop hl
    ld bc, $10
    call CopyData
    pop bc
    pop de
    pop hl
    ret
	
AdjustForTradeScreen:
	ld hl, wOAMBuffer + $1 ;the x value of party sprite 1.
	ld de, $4
	ld b, e
.loopOAM
	ld a, [hl]
	inc a
	ld [hl], a
	add hl, de
	dec b
	jr nz, .loopOAM
	ld hl, wMonPartySpritesSavedOAM + $1 ;the x value of party sprite 1.
	ld de, $4
	ld b, e
.loopSaved
	ld a, [hl]
	inc a
	ld [hl], a
	add hl, de
	dec b
	jr nz, .loopSaved
	ret


	; fixme trade screen doesn't like our poke being offset to 15.
PartyMonOAM:
; all the Ys are set to be offscreen.
; placed at the proper y in ShowPartyMonSprite
    db 160,15,$00,$00
    db 160,23,$01,$00
    db 160,15,$04,$00
    db 160,23,$05,$00

    db 160,15,$08,$00
    db 160,23,$09,$00
    db 160,15,$0c,$00
    db 160,23,$0d,$00

    db 160,15,$10,$00
    db 160,23,$11,$00
    db 160,15,$14,$00
    db 160,23,$15,$00

    db 160,15,$18,$00
    db 160,23,$19,$00
    db 160,15,$1c,$00
    db 160,23,$1d,$00

    db 160,15,$20,$00
    db 160,23,$21,$00
    db 160,15,$24,$00
    db 160,23,$25,$00

    db 160,15,$28,$00
    db 160,23,$29,$00
    db 160,15,$2c,$00
    db 160,23,$2d,$00
