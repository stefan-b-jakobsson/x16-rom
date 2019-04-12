.PAG 'CODE26'
;MOST REFERENCES TO KERNAL ARE DEFINED HERE
;
EREXIT	CMP #$F0        ;CHECK FOR SPECIAL CASE
	BNE EREXIX
; TOP OF MEMORY HAS CHANGED
	STY MEMSIZ+1
	STX MEMSIZ
	JMP CLEART      ;ACT AS IF HE TYPED CLEAR
EREXIX	TAX             ;SET TERMINATION FLAGS
	BNE EREXIY
	LDX #ERBRK      ;BREAK ERROR
EREXIY	JMP ERROR       ;NORMAL ERROR
.SKI 5
CLSCHN	=$FFCC
.SKI 5
OUTCH	JSR $FFD2
	BCS EREXIT
	RTS
.SKI 5
INCHR	JSR $FFCF
	BCS EREXIT
	RTS
.SKI 5
CCALL	=$FFE7
.SKI 5
SETTIM	=$FFDB
RDTIM	=$FFDE
.SKI 5
COOUT	JSR PPACH       ; GO OUT TO SAVE .A FOR PRINT# PATCH
	BCS EREXIT
	RTS
.SKI 5
COIN	JSR $FFC6
	BCS EREXIT
	RTS
.SKI 5
READST	=$FFB7
.SKI 5
CGETL	JSR $FFE4
	BCS EREXIT
	RTS
.SKI 5
RDBAS	=$FFF3
.SKI 5
SETMSG	=$FF90
.SKI 5
PLOT	=$FFF0
.SKI 5
CSYS	JSR FRMNUM      ;EVAL FORMULA
	JSR GETADR      ;CONVERT TO INT. ADDR
	LDA #>CSYSRZ    ;PUSH RETURN ADDRESS
	PHA
	LDA #<CSYSRZ
	PHA
	LDA SPREG       ;STATUS REG
	PHA
	LDA SAREG       ;LOAD 6502 REGS
	LDX SXREG
	LDY SYREG
	PLP             ;LOAD 6502 STATUS REG
	JMP (LINNUM)    ;GO DO IT
CSYSRZ	=*-1            ;RETURN TO HERE
	PHP             ;SAVE STATUS REG
	STA SAREG       ;SAVE 6502 REGS
	STX SXREG
	STY SYREG
	PLA             ;GET STATUS REG
	STA SPREG
	RTS             ;RETURN TO SYSTEM
.SKI 5
CSAVE	JSR PLSV        ;PARSE PARMS
	LDX VARTAB      ;END SAVE ADDR
	LDY VARTAB+1
	LDA #<TXTTAB    ;INDIRECT WITH START ADDRESS
	JSR $FFD8       ;SAVE IT
	BCS EREXIT
	RTS
.SKI 5
CVERF	LDA #1          ;VERIFY FLAG
	.BYT $2C        ;SKIP TWO BYTES
.SKI 5
CLOAD	LDA #0          ;LOAD FLAG
	STA VERCK
	JSR PLSV        ;PARSE PARAMETERS
;
CLD10	; JSR $FFE1 ;CHECK RUN/STOP
; CMP #$FF ;DONE YET?
; BNE CLD10 ;STILL BOUNCING
	LDA VERCK
	LDX TXTTAB      ;.X AND .Y HAVE ALT...
	LDY TXTTAB+1    ;...LOAD ADDRESS
	JSR $FFD5       ;LOAD IT
	BCS JERXIT      ;PROBLEMS
;
	LDA VERCK
	BEQ CLD50       ;WAS LOAD
;
;FINISH VERIFY
;
	LDX #ERVFY      ;ASSUME ERROR
	JSR $FFB7       ;READ STATUS
	AND #$10        ;CHECK ERROR
	BNE CLD55       ;REPLACES BEQ *+5/JMP ERROR
;
;PRINT VERIFY 'OK' IF DIRECT
;
	LDA TXTPTR
	CMP #BUFPAG
	BEQ CLD20
	LDA #<OKMSG
	LDY #>OKMSG
	JMP STROUT
;
CLD20	RTS
.SKI 5
;
;FINISH LOAD
;
CLD50	JSR $FFB7       ;READ STATUS
	AND #$FF-$40    ;CLEAR E.O.I.
	BEQ CLD60       ;WAS O.K.
	LDX #ERLOAD
CLD55	JMP ERROR
;
CLD60	LDA TXTPTR+1
	CMP #BUFPAG     ;DIRECT?
	BNE CLD70       ;NO...
;
	STX VARTAB
	STY VARTAB+1    ;END LOAD ADDRESS
	LDA #<REDDY
	LDY #>REDDY
	JSR STROUT
	JMP FINI
;
;PROGRAM LOAD
;
CLD70	JSR STXTPT
	JSR LNKPRG
	JMP FLOAD
.SKI 5
COPEN	JSR PAOC        ;PARSE STATEMENT
	JSR $FFC0       ;OPEN IT
	BCS JERXIT      ;BAD STUFF OR MEMSIZ CHANGE
	RTS             ;A.O.K.
.SKI 5
CCLOS	JSR PAOC        ;PARSE STATEMENT
	LDA ANDMSK      ;GET LA
	JSR $FFC3       ;CLOSE IT
	BCC CLD20       ;IT'S OKAY...NO MEMSIZE CHANGE
;
JERXIT	JMP EREXIT
.SKI 5
;
;PARSE LOAD AND SAVE COMMANDS
;
PLSV
;DEFAULT FILE NAME
;
	LDA #0          ;LENGTH=0
	JSR $FFBD
;
;DEFAULT DEVICE #
;
	LDX #1          ;DEVICE #1
	LDY #0          ;COMMAND 0
	JSR $FFBA
;
	JSR PAOC20      ;BY-PASS JUNK
	JSR PAOC15      ;GET/SET FILE NAME
	JSR PAOC20      ;BY-PASS JUNK
	JSR PLSV7       ;GET ',FA'
	LDY #0          ;COMMAND 0
	STX ANDMSK
	JSR $FFBA
	JSR PAOC20      ;BY-PASS JUNK
	JSR PLSV7       ;GET ',SA'
	TXA             ;NEW COMMAND
	TAY
	LDX ANDMSK      ;DEVICE #
	JMP $FFBA
.SKI 5
;LOOK FOR COMMA FOLLOWED BY BYTE
PLSV7	JSR PAOC30
	JMP GETBYT
.SKI 5
;SKIP RETURN IF NEXT CHAR IS END
;
PAOC20	JSR CHRGOT
	BNE PAOCX
	PLA
	PLA
PAOCX	RTS
.SKI 5
;CHECK FOR COMMA AND GOOD STUFF
;
PAOC30	JSR CHKCOM      ;CHECK COMMA
PAOC32	JSR CHRGOT      ;GET CURRENT
	BNE PAOCX       ;IS O.K.
PAOC40	JMP SNERR       ;BAD...END OF LINE
.SKI 5
;PARSE OPEN/CLOSE
;
PAOC	LDA #0
	JSR $FFBD       ;DEFAULT FILE NAME
;
	JSR PAOC32      ;MUST GOT SOMETHING
	JSR GETBYT      ;GET LA
	STX ANDMSK
	TXA
	LDX #1          ;DEFAULT DEVICE
	LDY #0          ;DEFAULT COMMAND
	JSR $FFBA       ;STORE IT
	JSR PAOC20      ;SKIP JUNK
	JSR PLSV7
	STX EORMSK
	LDY #0          ;DEFAULT COMMAND
	LDA ANDMSK      ;GET LA
	CPX #3
	BCC PAOC5
	DEY             ;DEFAULT IEEE TO $FF
PAOC5	JSR $FFBA       ;STORE THEM
	JSR PAOC20      ;SKIP JUNK
	JSR PLSV7       ;GET SA
	TXA
	TAY
	LDX EORMSK
	LDA ANDMSK
	JSR $FFBA       ;SET UP REAL EVEYTHING
PAOC7	JSR PAOC20
	JSR PAOC30
PAOC15	JSR FRMEVL
	JSR FRESTR      ;LENGTH IN .A
	LDX INDEX1
	LDY INDEX1+1
	JMP $FFBD
.END
; RSR 8/10/80 - CHANGE SYS COMMAND
; RSR 8/26/80 - ADD OPEN&CLOSE MEMSIZ DETECT
; RSR 10/7/80 - CHANGE LOAD (REMOVE RUN WAIT)
; RSR 4/10/82 - INLINE FIX PROGRAM LOAD
; RSR 7/02/82 - FIX PRINT# PROBLEM