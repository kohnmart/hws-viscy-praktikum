	;LDIL - Load Immediate High
	;LDIL - Load Immediate Low
	
	.org 0x100
	.start
	
	LDIL r0, 0 ;r0 wird auf 0 gesetzt
	LDIH r0, 0x01 ;lade r0 mit der Speicheradresse 0x100
	LD r1, [r0] ;erster Faktor in r1 laden
	
	LDIL r0, 0 ;zurücksetzen auf 0
	LDIL r0, 0x01
	LDIH r0, 0x01 ;r0 auf die Speicheradresse 0x101
	
	LD r2, [r0] ;zweite Zahl in r2
	LDIL r0, 0;r0 wird auf 0 gesetzt
	
	LDIL r3, 0 ;Ergebnisregister 
	LDIL r4, 1 ;Hilfsregister auf Wert 1
	
	LDIL r5, 0 ;Schleifenindex
loop: ADD r3, r3, r1 ;Addiere r1 zu r3
	  SUB r2, r2, r4 ;Subtrahiere 1 von r2 für den Schleifenindex
	  JZ  r2, r5 ;wenn r2 -> 0: Springe auf Schleifenadresse
	  
	LDIL r0, 0x02
	LDIH r0x 0x01 ;Lade r0 in 0x102
	ST [r0], r3 ;Ergebnis speichern
	
	HALT
	
	.org 0x100
	result: .res 4 ;Reservier 4 Bytes für das Ergebnis
	
	.end
