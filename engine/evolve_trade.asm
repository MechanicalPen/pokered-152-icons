EvolveTradeMon: ; 17d7d (5:7d7d)
; Verify the TradeMon's species name before
; attempting to initiate a trade evolution.

; The names of the trade evolutions in Blue (JP)
; are checked. In that version, TradeMons that
; can evolve are Graveler and Haunter.

; In localization, this check was translated
; before monster names were finalized.
; Then, Haunter's name was "Spectre".
; Since its name no longer starts with
; "SP", it is prevented from evolving.

; This may have been why Red/Green's trades
; were used instead, where none can evolve.

; This was fixed in Yellow.
;(Should be fixed now, so randomizers work ok)
;TODO ADD Kadabra, Machoke

	ld a, [wInGameTradeReceiveMonName + 3]

	; GRAVELER
	cp "V"
	jr z, .ok

	; "SPECTRE" (HAUNTER)
	cp "H"
	ret nz
	ld a, [wInGameTradeReceiveMonName + 1]
	cp "A"
	ret nz

.ok
	ld a, [wPartyCount] ; wPartyCount
	dec a
	ld [wWhichPokemon], a ; wWhichPokemon
	ld a, $1
	ld [wccd4], a
	ld a, LINK_STATE_TRADING
	ld [wLinkState], a
	callab TryEvolvingMon
	xor a ; LINK_STATE_NONE
	ld [wLinkState], a
	jp PlayDefaultMusic
