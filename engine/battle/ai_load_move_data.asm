;This has to be in the same bank as the Moves data...
AILoadMoveData:
;Iterate over the Moves data, and copy the one we want into RAM.
; e contains the Moves[] index. 0 is POUND.
; hl is the pointer to the first entry in Moves[]
; bc is the number of bytes per entry (6).
	ld a,e
	ld hl,Moves
	ld bc,6
	call AddNTimes
	ld de,W_ENEMYMOVENUM
	call CopyData
	ret