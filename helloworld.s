PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003

E  = %10000000
RW = %01000000
RS = %00100000



  .org $8000

reset:
  ldx #$ff
  txs
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
  lda #%00000001
  jsr lcd_instruction


  ldx #0
print:
  lda message,x
  beq loop
  jsr print_char
  inx
  jmp print

loop:
  jmp loop

message: .asciiz "Hello, World!"

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

endrom:
  .org $fffc
  .word reset
  .word $0000
