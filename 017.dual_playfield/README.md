dual playfield
==============

We now try and set up a dual playfield screen with 3 bitplanes per playfield. This gives us 7 colors + transparent for each playfield.

Set the number of bitplanes per playfield in [constants.i](constants.i)

  ```
  SCREEN_BIT_DEPTH	equ 3   ; 3 bitplanes per playfield
```

New copper list that assigns bitplanes to each playfield after poking in [dual_playfield_mode.s](dual_playfield_mode.s)

  ```
copper:
pf1_bitplanepointers:
	;; this is where bitplanes are assigned to playfields
	;; http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0079.html
	;; 3 bitplanes per playfield, playfield1 gets bitplanes 1,3,5
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
pf2_bitplanepointers:
	;; 3 bitplanes per playfield, playfield2 gets bitplanes 2,4,6
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0
	dc.l	$fffffffe
```

Poke the copper list with the bitplane pointer addresses in [init.s](init.s):

  ```
	;; poke playfield 1 bitplane pointers
	lea     pf1_bitplanepointers(pc),a0
	lea     pf1_bitplanes(pc),a1
	bsr.s   pokeBitplanePointers

	;; poke playfield 2 bitplane pointers
	lea     pf2_bitplanepointers(pc),a0
	lea     pf2_bitplanes(pc),a1
	bsr.s   pokeBitplanePointers	
```

Enable 2x the bitplanes, and optionally re-order the bitplanes in [init.s](init.s):

  ```
	;; enable 2x the bitplanes as 2x playfields
	move.w #((SCREEN_BIT_DEPTH*2)<<12)|COLOR_ON|DBLPF,BPLCON0(a6)
	;; set playfield2 to have priority
	move.w #PF2PRI, BPLCON2(a6)
```

try it
------
  * [Download disk image](bin/dual_playfield_mode.adf?raw=true)
  * <a href="http://alpine9000.github.io/ScriptedAmigaEmulator/#amiga_examples/dual_playfield_mode.adf" target="_blank">Run in SAE</a>

Screenshots:

playfield 1
-----------
![playfield 1](../assets/playfield1_8.png?raw=true)

playfield 2
-----------
![playfield 2](../assets/playfield2_8.png?raw=true)

dual playfields, playfield 2 in front
-------------------------------------
	
```
	move.w #PF2PRI, BPLCON2(a6)
```

![dual playfields, playfield 2 in front](screenshots/screenshot.png?raw=true)
dual playfields, playfield 1 in front
-------------------------------------

```
	move.w #0, BPLCON2(a6)
```

![dual playfields, playfield 1 in front](screenshots/screenshot2.png?raw=true)
