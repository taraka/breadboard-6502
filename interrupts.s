PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003

E  = %10000000
RW = %01000000
RS = %00100000

value = $0200 ; 2 bytes
mod10 = $0202 ; 2 bytes
message = $2004 ; 6 bytes
counter = $200a; 2 bytes
  .org $8000

reset:
  ldx #$ff
  txs
  cli

  lda #%11111111  ; Set all pind on port B to output
  sta DDRB
  lda #%11100000  ; Set all pind on port A to output
  sta DDRA
  lda #%00111000  ; Set 8-bit mode; 2- ine display; 5x8 font
  jsr lcd_instruction
  lda #%00001110  ; Display on; curor on; blink off
  jsr lcd_instruction
  lda #%00000110  ; Increment and shift cursor; don't shift the display
  jsr lcd_instruction
  lda #%00000001  ; Clear display
  jsr lcd_instruction

  lda #0
  sta counter
  sta counter + 1

loop:
  lda #%00000010; Home cursor
  jsr lcd_instruction
  lda #0
  sta message

  ; Initialise value to the number to be converted
  sei
  lda counter
  sta value
  lda counter + 1
  sta value + 1
  cli

divide:
  ; init remainder to be 0
  lda #0
  sta mod10
  sta mod10 + 1
  clc

  ldx #16
divloop:
  ;rot quotient and remainder
  rol value
  rol value + 1
  rol mod10
  rol mod10 + 1

  sec
  lda mod10
  sbc #10
  tay ; save low byte
  lda mod10 + 1
  sbc #0
  bcc ignore_result; branch if dividend < divsor
  sty mod10
  sta mod10 + 1
ignore_result: 
  dex
  bne divloop
  rol value
  rol value + 1


  lda mod10
  clc
  adc #"0"
  jsr push_char

;if value != 0 then continue
  lda value
  ora value + 1
  bne divide ; branch if value not zero
  
  ldx #0
print:
  lda message,x
  beq loop
  jsr print_char
  inx 
  jmp print

  
  jmp loop

number: .word 1729

; Add char in A register to the beginning of the null terminated string mesage
push_char:
  pha
  ldy #0

char_loop:
  lda message,y; Get char on string and put in to X
  tax
  pla
  sta message,y ;Pull char off stack and add it to the string
  iny
  txa
  pha
  bne char_loop
  pla
  sta message,y ; put the null back on the end of the string
  rts



lcd_wait:
  pha
  lda #%00000000 ; Port B input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000 
  bne lcdbusy
  lda #RW
  sta PORTA
  lda #%11111111 ; Port B input
  sta DDRB
  pla
  rts

lcd_instruction:
  jsr lcd_wait
  sta PORTB
  lda #0          ; Clear RS/RW/E bits
  sta PORTA
  lda #E          ; Set enable bit to send instruction
  sta PORTA
  lda #0          ; Clear RS/RW/E bits
  sta PORTA
  rts


print_char:
  jsr lcd_wait
  sta PORTB
  lda #RS          ; Clear RS/RW/E bits
  sta PORTA
  lda #(RS | E)   ; Set enable bit to send instruction
  sta PORTA
  lda #RS          ; Clear RS/RW/E bits
  sta PORTA
  rts

nmi:
  rti


irq:
  inc counter
  bne exit_irq
  inc counter+1
exit_irq:
  rti
 
endrom:
  .org $fffa
  .word nmi
  .word reset
  .word irq
