;----------------------------------------------------------------------
; IRQ
;----------------------------------------------------------------------
; (C)1983 Commodore Business Machines (CBM)
; additions: (C)2020 Michael Steil, License: 2-clause BSD

.feature labels_without_colons

.import dfltn, dflto, kbd_scan, clock_update, cinv, cbinv
.export key

.segment "IRQ"

.import screen_init
.import mouse_scan
.import joystick_scan
.import cursor_blink
.import led_update
.import __interrupt_65c816_native_kernal_impl_ret
.import ps2data_fetch
.export panic
.export irq_emulated_impl
.import kflags

.include "banks.inc"
.include "io.inc"
.include "kflags.inc"

; VBLANK IRQ handler
;
.macro irq_impl
	; Check flags
	lda VERA_ISR
	and #3 ;Keep only VERA VSYNC and LINE IRQ bits
	beq @1 ;Not an IRQ from VERA
	and kflags
	bne @ps2 ;There's a match in kflags, do ISR tasks
	bra @ack ;Else skip ISR tasks
@1:	lda kflags
	and #EXTIRQ
	beq @ack ;kflags set to ignore external IRQs, skip ISR tasks

	; Fetch PS/2 data, update keyboard and mouse
@ps2:	lda kflags
	and #PS2EN
	beq @snes ;Fetching PS/2 data disabled in kflags register
	jsr ps2data_fetch
	jsr mouse_scan  ;scan mouse (do this first to avoid sprite tearing)
	jsr kbd_scan
	
	; Fetch SNES joystick data
@snes:	lda kflags
	and #SNESEN
	beq @other ;Fetching joystick data disabled in kflags register
	jsr joystick_scan
	
	; Other chores
@other:	jsr clock_update
	jsr cursor_blink
	jsr led_update

	;ack VSYNC and LINE IRQ
@ack:	lda #3
	sta VERA_ISR
.endmacro

irq_emulated_impl:
	irq_impl
	jmp __interrupt_65c816_native_kernal_impl_ret

; VBLANK IRQ handler
;
key
	irq_impl

	ply
	plx
	pla
	rti             ;exit from irq routines

;panic nmi entry
;
panic	lda #3          ;reset default i/o
	sta dflto
	lda #0
	sta dfltn
	lda #VSYNCIRQ | LINEIRQ | EXTIRQ | PS2EN | SNESEN
	sta kflags
	jmp screen_init
