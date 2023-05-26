	;LDIL - Load Immediate High
	;LDIL - Load Immediate Low
	
		.org 0x0100
		
n1:		.data 15
n2:		.data 25
	

result: .res 1 ;Reservier 1 Wort für das Ergebnis

		.org 0x0000
		.start
	
start:	XOR r0, r0, r0 ;r0 wird auf 0 gesetzt
		LDIH r0, 0x0100
		LDIL r0, n1 & 255
		LDIH r0, n1 >> 8 
		LD r1, [r0] ;erste Zahl in r1 laden
		
		XOR r0, r0, r0 ;zurücksetzen auf 0
		LDIL r0, 0x0101
		LDIL r0, n2 & 255
		LDIH r0, n2 >> 8 
		LD r2, [r0] ;zweite Zahl in r2
		
		XOR r0, r0, r0 ;r0 wird auf 0 gesetzt
		
		LDIL r3, 0 ;Ergebnisregister 
		LDIL r4, 1 ;Hilfsregister auf Wert 1
			
		LDIL r5, loop & 255 ;r5 := loop
		LDIH r5, loop >> 8
		
loop: ADD r3, r3, r1 ;Addiere r1 zu r3
	  SUB r2, r2, r4 ;Subtrahiere 1 von r2 für den Schleifenindex
	  JNZ r2, r5 ;wenn r2 nicht Null Springe auf r5 -> Loop
	 
	LDIH r0, 0x0102 ;Lade r0 in 0x0102
	LDIL r0, result & 255
	LDIH r0, result >> 8
	ST [r0], r3 ;Ergebnis speichern
	
	HALT
	
	.end
