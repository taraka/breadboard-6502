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


  lda #"H"
  jsr print_char
  lda #"e"
  jsr print_char
  lda #"l"
  jsr print_char
  lda #"l"
  jsr print_char
  lda #"o"
  jsr print_char
  lda #","
  jsr print_char
  lda #" "
  jsr print_char
  lda #"W"
  jsr print_char
  lda #"o"
  jsr print_char
  lda #"r"
  jsr print_char
  lda #"l"
  jsr print_char
  lda #"d"
  jsr print_char
  lda #"!"
  jsr print_char

loop:
  jmp loop


lcd_instruction:
  sta PORTB
  lda #0          ; Clear RS/RW/E bits
  sta PORTA
  lda #E          ; Set enable bit to send instruction
  sta PORTA
  lda #0          ; Clear RS/RW/E bits
  sta PORTA
  rts


print_char:
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
