;-------------------------------------------------
; Testbench aller zur Verfügung stehenden Befehle
;-------------------------------------------------

.org 0x000
.start

LDIH  r0, 0x00   ; => 00000000
LDIL  r0, 0x00   ; => 0000000000000000
LDIH  r1, 0x00   ; => 00000000
LDIL  r1, 0x00   ; => 0000000000000000
LDIH  r3, 0x00   ; => 00000000
LDIL  r3, 0x00   ; => 0000000000000000
LDIH  r4, 0x00   ; => 00000000
LDIL  r7, 0x00   ; => 0000000000000000
LDIH  r7, 0x00   ; => 00000000
LDIH  r2, 0x00   ; => 00000000
LDIL  r2, 0x00   ; => 0000000000000000

XOR   r0, r0, r0 ; Nur '0' in r0   // bitweise XOR Operation zwischen den Register r0 und r0, wodurch Wert von r0 den Wert 0
LDIL  r0, 787      ; 1. Wert in r0.  //lädt das Immediate-Low-Byte des Wertes 8 in das Register r0
XOR   r1, r1, r1
LDIL  r1, 739


; ----------
; Arithmetic
; ----------

XOR   r7, r7, r7
XOR   r3, r3, r3
XOR   r4, r4, r4
ADD   r3, r0, r1 ; Addition: r3 = r0 + r1     => 1526       addiert die Werte in den Registern r0 und r1 und speichert Ergebnis in r3
LDIL  r4, 1526 
XOR   r7, r3, r4
OR    r2, r2, r7

XOR   r4, r4, r4
XOR   r7, r7, r7
XOR   r3, r3, r3
SUB   r3, r0, r1 ; Subtraktion: r3 = r0 - r1  => 48
LDIL  r4, 48
XOR   r7, r3, r4
OR    r2, r2, r7

XOR   r4, r4, r4
XOR   r7, r7, r7
XOR   r3, r3, r3
SAL   r3, r0     ; Links-Shift:               => 1574        Linksverschiebung (Shift) des Werts in Register r0 und speichert das Ergebnis in r3
LDIL  r4, 1574
XOR   r7, r3, r4
OR    r2, r2, r7

XOR   r4, r4, r4
XOR   r7, r7, r7
XOR   r3, r3, r3
SAR   r3, r0     ; Rechts-Shift:              => 393
LDIL  r4, 393
XOR   r7, r3, r4
OR    r2, r2, r7

; -----
; Logic
; -----

XOR   r3, r3, r3
XOR   r4, r4, r4
XOR   r7, r7, r7
AND   r3, r0, r1 ; => 721
LDIL  r4, 721
XOR   r7, r3, r4
OR    r2, r2, r7

XOR   r3, r3, r3
XOR   r4, r4, r4
XOR   r7, r7, r7
OR    r3, r0, r1 ; => 795
LDIL  r4, 795
XOR   r7, r3, r4
OR    r2, r2, r7

XOR   r3, r3, r3
XOR   r4, r4, r4
XOR   r7, r7, r7
XOR   r3, r0, r1 ; => 64
LDIL  r4, 64
XOR   r7, r3, r4
OR    r2, r2, r7

XOR   r3, r3, r3
XOR   r4, r4, r4
XOR   r7, r7, r7
NOT   r3, r0     ; =>  476         bitweise Negation (NOT-Operation) des Werts in Register
LDIL  r4, 476
XOR   r7, r3, r4
OR    r2, r2, r7

HALT

.end
