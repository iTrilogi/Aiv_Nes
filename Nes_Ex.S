.db "NES", $1A, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
.ORG $8000

.define PPUCTRL         $2000
.define PPUMASK         $2001
.define OAMADDR         $2003
.define OAMDATA         $2004
.define PPUSCROLL       $2005
.define PPUADDR         $2006
.define PPUDATA         $2007
.define OAMDMA          $4014
.define JOYPAD1         $4016
.define JOYPAD2         $4017

.define Scrolling       $00
.define Buttons         $01
.define Background      $02
.define Vertical        $03
.define Horizontal      $04
     

start:

    LDA #%10010000
    STA PPUCTRL
    LDA #%00011010
    STA PPUMASK
 
   ; load background palette
    LDA #$3f
    STA PPUADDR
    LDA #0
    STA PPUADDR
    
    LDA #$3F
    STA PPUDATA
    LDA #$12
    STA PPUDATA
    LDA #$2A
    STA PPUDATA
    LDA #$12
    STA PPUDATA
  
   ; load sprite palette
    LDA #$3f
    STA PPUADDR
    LDA #$10
    STA PPUADDR

    LDA #$3F
    STA PPUDATA
    LDA #$20
    STA PPUDATA
    LDA #$20
    STA PPUDATA
    LDA #$20
    STA PPUDATA

    ; Loop BG
    BackgroundLoop_24:
    LDA #$24
    STA PPUADDR
    LDA #$A9
    STA PPUADDR
    JSR BG_Loop    
    
    BackgroundLoop_20:    
    LDA #0 
    STA Background
    LDA #$20
    STA PPUADDR
    LDA #$A9
    STA PPUADDR
    JSR BG_Loop
    JMP SpriteLoop
    
    BG_Loop:
    LDA Background                    
    STA PPUDATA
    INC Background                    
    LDA Background
    AND #$0F                           
    BEQ NewLine
    INC Scrolling
    BNE BG_Loop
    RTS
    
    NewLine: 
    LDY #$10 
      AddSpace:
      LDA #00
      STA PPUDATA
      DEY 
      BNE AddSpace
    JMP BG_Loop

    
    SpriteLoop: 
    LDA #$85
    STA Vertical
    STA OAMDATA
    LDA #$F0 
    STA OAMDATA
    LDA #$10
    STA OAMDATA
    LDA #$82
    STA Horizontal
    STA OAMDATA   
    
loop:
    JMP loop

readjoy:
    LDA #$01
    STA JOYPAD1
    STA Buttons
    LSR A
    STA JOYPAD1
joyloop:
    LDA JOYPAD1
    LSR A 
    ROL Buttons
    BCC joyloop
    RTS

nmi:
    PHA
    JSR readjoy
    PLA
    
    ;input
    Up:
   
    LDA Buttons
    AND #%00001000
    BEQ Down
    LDA Vertical
    CMP #$09
    BEQ Stop
    DEC Vertical
    LDA Vertical
    STA OAMDATA
    LDA #01
    STA OAMADDR
    LDA #$60
    STA OAMDATA
    LDA #02
    STA OAMADDR
    LDA #%00000000   
    STA OAMDATA
    
    Down:
    LDA Buttons
    AND #%00000100
    BEQ Right
    LDA Vertical
    CMP #$E0
    BEQ Stop
    INC Vertical
    LDA Vertical
    STA OAMDATA
    LDA #01
    STA OAMADDR
    LDA #$60
    STA OAMDATA
    LDA #02
    STA OAMADDR
    LDA #%10000000   
    STA OAMDATA
    
Stop:
 NOP
   
    Right:
    LDA Buttons
    AND #%00000001
    BEQ Left
    LDA Horizontal
    CMP #$F2
    BEQ Stop1
    INC Scrolling
    INC Horizontal
    LDA #01
    STA OAMADDR
    LDA #$F0
    STA OAMDATA
    LDA #02
    STA OAMADDR
    LDA #%00000000
    STA OAMDATA
    LDA #03
    STA OAMADDR
    LDA Horizontal
    STA OAMDATA
    
    Left:   
    LDA Buttons
    AND #%00000010
    BEQ loadscroll
    LDA Horizontal
    CMP #$08
    BEQ Stop1
    DEC Scrolling
    DEC Horizontal
    LDA #01
    STA OAMADDR
    LDA #$F0
    STA OAMDATA
    LDA #02
    STA OAMADDR
    LDA #%01000000
    STA OAMDATA
    LDA #03
    STA OAMADDR
    LDA Horizontal
    STA OAMDATA
Stop1:
 NOP
loadscroll:
    LDA Scrolling
    STA PPUSCROLL
    LDA #0
    STA PPUSCROLL
    RTI


irq:
RTI

.goto $FFFA

.dw nmi
.dw start
.dw irq

.incbin mario0.chr
.incbin aiv256.chr