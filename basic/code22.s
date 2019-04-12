.PAG 'CODE22'
N0999	.BYT @233,@76,@274,@37,@375
N9999	.BYT @236,@156,@153,@47,@375
NMIL	.BYT @236,@156,@153,@50,0
INPRT	LDA #<INTXT
	LDY #>INTXT
	JSR STROU2
	LDA CURLIN+1
	LDX CURLIN
LINPRT	STA FACHO
	STX FACHO+1
	LDX #@220
	SEC
	JSR FLOATC
	JSR FOUTC
STROU2	JMP STROUT
FOUT	LDY #1
FOUTC	LDA #' 
	BIT FACSGN
	BPL FOUT1
	LDA #'-
FOUT1	STA FBUFFR-1,Y
	STA FACSGN
	STY FBUFPT
	INY
	LDA #'0
	LDX FACEXP
	BNE *+5
	JMP FOUT19
	LDA #0
	CPX #@200
	BEQ FOUT37
	BCS FOUT7
FOUT37	LDA #<NMIL
	LDY #>NMIL
	JSR FMULT
	LDA #250-ADDPR2-ADDPRC
FOUT7	STA DECCNT
FOUT4	LDA #<N9999
	LDY #>N9999
	JSR FCOMP
	BEQ BIGGES
	BPL FOUT9
FOUT3	LDA #<N0999
	LDY #>N0999
	JSR FCOMP
	BEQ FOUT38
	BPL FOUT5
FOUT38	JSR MUL10
	DEC DECCNT
	BNE FOUT3
FOUT9	JSR DIV10
	INC DECCNT
	BNE FOUT4
FOUT5	JSR FADDH
BIGGES	JSR QINT
	LDX #1
	LDA DECCNT
	CLC
	ADC #ADDPR2+ADDPRC+7
	BMI FOUTPI
	CMP #ADDPR2+ADDPRC+@10
	BCS FOUT6
	ADC #$FF
	TAX
	LDA #2
FOUTPI	SEC
FOUT6	SBC #2
	STA TENEXP
	STX DECCNT
	TXA
	BEQ FOUT39
	BPL FOUT8
FOUT39	LDY FBUFPT
	LDA #'.
	INY
	STA FBUFFR-1,Y
	TXA
	BEQ FOUT16
	LDA #'0
	INY
	STA FBUFFR-1,Y
FOUT16	STY FBUFPT
FOUT8	LDY #0
FOUTIM	LDX #@200
FOUT2	LDA FACLO
	CLC
	ADC FOUTBL+2+ADDPRC,Y
	STA FACLO
	LDA FACMO
	ADC FOUTBL+1+ADDPRC,Y
	STA FACMO
	LDA FACMOH
	ADC FOUTBL+1,Y
	STA FACMOH
	LDA FACHO
	ADC FOUTBL,Y
	STA FACHO
	INX
	BCS FOUT41
	BPL FOUT2
	BMI FOUT40
FOUT41	BMI FOUT2
FOUT40	TXA
	BCC FOUTYP
	EOR #@377
	ADC #@12
FOUTYP	ADC #@57
	INY
	INY
	INY
	INY
	STY FDECPT
	LDY FBUFPT
	INY
	TAX
	AND #@177
	STA FBUFFR-1,Y
	DEC DECCNT
	BNE STXBUF
	LDA #'.
	INY
	STA FBUFFR-1,Y
STXBUF	STY FBUFPT
	LDY FDECPT
	TXA
	EOR #@377
	AND #@200
	TAX
	CPY #FDCEND-FOUTBL
	BEQ FOULDY
	CPY #TIMEND-FOUTBL
	BNE FOUT2
FOULDY	LDY FBUFPT
FOUT11	LDA FBUFFR-1,Y
	DEY
	CMP #'0
	BEQ FOUT11
	CMP #'.
	BEQ FOUT12
	INY
FOUT12	LDA #'+
	LDX TENEXP
	BEQ FOUT17
	BPL FOUT14
	LDA #0
	SEC
	SBC TENEXP
	TAX
.END