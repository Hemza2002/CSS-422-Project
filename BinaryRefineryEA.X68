*--------------------------------------------------------------------
* Title      : Effective Addressing 
* Written by : 
* Date       : 
* Description: Evaluates the effective addressing for each individual
*              opcode, validates/invalidates them, and calls to IO
*              to print.
*--------------------------------------------------------------------
        
*--------------------------------------------------------------------        
* EA - ADD
*   Called by the opcode ADD. Contains personalized helpers to assist
*   in it's functions.
*--------------------------------------------------------------------

EA_ADD          MOVE.W  OPCODE,D6       ; grab fresh instruction
                JSR     OPMODE_FINDER   ; D4 = opmode
                JSR     OPMODE_SIZE_FINDER ; grabs and prints size
                                    
                CMP.W   #$0001,D3       ; D3 = 1 = <ea>,Dn
                BEQ     ADD_1  
                CMP.W   #$0000,D3       ; D3 = 0 = Dn,<ea>
                BEQ     ADD_0   
                
                BEQ     SIZE_LONG
            
*                CMP.W   #$0000,D3       ; the above didn't pass
*                BNE     EA_INVLD        ; invalid
            
                RTS
            
ADD_1           JSR     SRC_REG_SAVE    ; save register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print
                JSR     COMMA_SPACE     ; print comma
            
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save data register in D5
                MOVE.W  OPCODE,D6
                JSR     DEST_LEAST
                RTS
      
ADD_0           MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save reg num
                MOVE.W  OPCODE,D6       ; print reg
                JSR     COMMA_SPACE     ; print comma
            
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_REG_SAVE    ; save register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print  
                RTS

*--------------------------------------------------------------------         
* EA - ADDA
*   Called by the opcode ADDA. Contains personalized helpers to assist
*   in it's functions.
*--------------------------------------------------------------------

EA_ADDA         MOVE.W  OPCODE,D6       ; grab fresh instruction
                JSR     ADDA_OPMODE     ; determine size via opmode
                JSR     ADDA_SIZE        ; grabs and prints size   
                                    
                CMP.W   #$0001,D3       ; D3 = 1 = Word
                BEQ     ADDA_1  
                CMP.W   #$0000,D3       ; D3 = 0 = Long
                BEQ     ADDA_0   
            
                RTS

ADDA_SIZE       CMP.W   #$0003,D4       ; size = word
                BEQ     SIZE_WORD
                CMP.W   #$0007,D4       ; size = long
                
                RTS

ADDA_1          JSR     SRC_REG_SAVE    ; save register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print
                JSR     COMMA_SPACE     ; print comma
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save data register in D5
                JSR     MODE_DN         ; print Dn
                RTS
      
ADDA_0          JSR     MODE_DN         ; print Dn (data reg saved above)
                JSR     COMMA_SPACE     ; print comma
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_REG_SAVE    ; save register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print
                RTS

ADDA_OPMODE     MOVE.W  OPCODE,D4       ; save instruction for manip
                LSR.W   #6,D4           ; shift ea bits off the right
                LSL.W   #7,D4           ; shift opcode and reg bits off
                LSR.W   #7,D4           ; shift back into place
                ANDI.W  #$000F,D4       ; mask in case there are missed bits
                CMP.W   #$0003,D4       ; check if size word
                MOVE.W  #$0001,D3       ; set D3 = 1
                CMP.W   #$0007,D4       ; check if size long
                MOVE.W  #$0000,D3       ; set D3 = 0

*                CMP.W   #$0007,D4       ; the above didn't pass
*                BNE     EA_INVLD        ; invalid opmode - bad instruction
                RTS 
                
*--------------------------------------------------------------------        
* EA - ADDQ
*   Called by the opcode ADDQ. 
*--------------------------------------------------------------------

EA_ADDQ         MOVE.W  OPCODE,D6       ; grab fresh instruction

                LSR.W   #6,D6           ; shift off ea bits
                LSL.W   #8,D6           ; shift off opcode 13 spaces
                LSL.W   #5,D6
                LSR.W   #8,D6           ; shift back into position
                LSR.W   #5,D6           
                ANDI.W  #$000F,D6       ; mask for size bits
                CMP.W   #$0000,D6       ; size = byte
                BEQ     SIZE_BYTE       
                CMP.W   #$0001,D6       ; size = word
                BEQ     SIZE_WORD   
                CMP.W   #$0002,D6       ; size = long
                BEQ     SIZE_LONG       
            
                JSR     HASH            ; print hashtag
            
                MOVE.W  OPCODE,D5       ; move instruction to D5 for manip
                LSR.W   #8,D5           ; shift 9 to remove ea and size bits
                LSR.W   #1,D5
                LSL.W   #8,D5           ; shift off opcode 13 spaces
                LSL.W   #5,D5
                LSR.W   #8,D5           ; shift back into position
                LSR.W   #5,D5           
                JSR     NUM_FINDER      ; find data number and print
            
                JSR     COMMA_SPACE     ; print comma
            
                MOVE.W  OPCODE,D6       ; refresh instruction    
                JSR     SRC_REG_SAVE    ; save ea register
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print
            
                RTS
            
*--------------------------------------------------------------------       
* EA - AND
*   Called by the opcode AND. Contains personalized helpers to assist
*   in it's functions.
*--------------------------------------------------------------------

EA_AND          MOVE.W  OPCODE,D6       ; grab fresh instruction
                JSR     OPMODE_FINDER   ; D4 = opmode
                JSR     OPMODE_SIZE_FINDER  ; grabs/prints size
                                    
                CMP.W   #$0001,D3       ; D3 = 1 = <ea>,Dn
                BEQ     AND_1  
                CMP.W   #$0000,D3       ; D3 = 0 = Dn,<ea>
                BEQ     AND_0   
            
*                CMP.W   #$0000,D3       ; the above didn't pass
*                BNE     EA_INVLD        ; invalid
            
                RTS
            
AND_1           JSR     SRC_REG_SAVE    ; save register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print
                JSR     COMMA_SPACE     ; print comma
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save data register in D5
                JSR     MODE_DN         ; print Dn
                RTS
      
AND_0           JSR     MODE_DN         ; print Dn (data reg saved above)
                JSR     COMMA_SPACE     ; print comma
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_REG_SAVE    ; save register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print
            
                RTS

*--------------------------------------------------------------------        
* EA - BRANCH
*   Called by multiple opcodes to handle BEQ, BGT, BLE, BRA. 
*--------------------------------------------------------------------

EA_BRANCH       * needs displacement to work


*--------------------------------------------------------------------       
* EA - JSR
*   Called by the opcode JSR. 
*--------------------------------------------------------------------

EA_JSR          MOVE.W  OPCODE,D6       ; grab fresh instruction
                JSR     SRC_REG_SAVE    ; save reg num in D5
                MOVE.W  OPCODE,D3       ; instruction to manip
                LSR.W   #3,D3           ; shift off ea reg bits
                ANDI.W  #$000F,D3       ; mask to isolate ea mode - bit 3 is
                                        ;   always 0
                CMP.W   #$0002,D3       ; if (An), ok to proceed
                BEQ     SRC_LEAST       ; isolate mode and print
                CMP.W   #$0007,D3       ; if abs address, ok to proceed
                BEQ     SRC_LEAST       ; isolate mode and print
            
*                CMP.W   #$0007,D6       ; all other modes
*                BNE     EA_INVLD        ; invalid
            
                RTS
            
*--------------------------------------------------------------------        
* EA - LEA
*   Called by the opcode LEA.
*--------------------------------------------------------------------

EA_LEA          MOVE.W  OPCODE,D6       ; grab fresh instruction
                JSR     SRC_REG_SAVE    ; save src reg num in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print
            
                JSR     COMMA_SPACE     ; print ", "
            
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save dest reg num in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_LEAST      ; isolate mode and print
            
            
                ***********LOAD ADDRESS FROM A3************************************************
       
                RTS

*--------------------------------------------------------------------         
* EA - MOVE
*   Called by the opcode MOVE. Contains personalized helpers to assist
*   in it's functions.
*--------------------------------------------------------------------
       
EA_MOVE         MOVE.W  OPCODE,D6       ; grab fresh instruction
                JSR     SIZE_FINDER     ; find the size and print
        
MOVE_SRC        MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_REG_SAVE    ; store the register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print
            
                JSR     COMMA_SPACE     ; print ", "
            
MOVE_DEST       MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; store register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_LEAST      ; isolate mode and print
            
                RTS
            
*--------------------------------------------------------------------        
* EA - MOVEA
*   Called by the opcode MOVEA. Contains personalized helpers to assist
*   in it's functions.
*--------------------------------------------------------------------

EA_MOVEA        MOVE.W  OPCODE,D6       ; grab fresh instruction
                JSR     SIZE_FINDER     ; find size and print
            
MOVEA_SRC       MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_REG_SAVE    ; save the register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print
            
                JSR     COMMA_SPACE     ; print ", "
            
MOVEA_DEST      MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save the register in D5
            
                MOVE.W  OPCODE,D6       ; refresh instruction
                LSL.W   #7,D6           ; shift unneeded bits off the left
                LSR.W   #7,D6           ; move bits back to previous spot
                LSR.W   #6,D6           ; remove source bits
                ANDI.W  #$000F,D6       ; mask to isolate dest mode bits
                MOVE.W  D6,D3           ; store dest mode
            
                CMP.W   #$0001,D3       ; must = An
                BEQ     MODE_AN         ;
            
*                CMP.W   #$0001,D3       ; if not An
*                BNE     EA_INVLD        ; invalid
            
                RTS
 
*--------------------------------------------------------------------       
* EA - MOVEM
*   Called by the opcode MOVEM. Contains personalized helpers to assist
*   in it's functions.
*--------------------------------------------------------------------

EA_MOVEM        MOVE.W  OPCODE,D6       ; grab fresh instruction
                LSR.W   #6,D6           ; shift off ea bits
                ANDI.W  #$0001,D6       ; mask to isolate size bit
                CMP.W   #$0000,D6       ; size = word
                BEQ     SIZE_WORD       
                CMP.W   #$0001,D6       ; size = long
                BEQ     SIZE_LONG
            
                MOVE.W  OPCODE,D6       ; refresh instruction
                LSL.W   #5,D6           ; shift extra bits off the left
                LSR.W   #5,D6           ; shift back to position
                LSR.W   #8,D6           ; shift extra 10 bits off the right
                LSR.W   #2,D6
                CMP.W   #$0000,D6       ; reg to mem
                BEQ     MOVEM_R2M     
                CMP.W   #$0001,D6       ; mem to reg
                BEQ     MOVEM_M2R
            
                RTS
            
MOVEM_R2M       MOVE.W  OPCODE,D6       ; refresh instruction
                MOVE.W  (A3),D4         ; save reg list into D5
                MOVE.B  #$0000,D2       ; reset counter
            
                    ; list - D0-D7/A0-A7
                    ; D5 = store reg num here, populated manually
                    ; D4 = holding original list
                    ; D3 = holding copy list for manip  
    
                MOVE.W  D4,D3           ; refresh list  
                ANDI.W  #$0001,D3       ; mask for D0
                MOVE.W  #$0000,D5       ; store reg num 0
                CMP.W   #$0001,D3       ; check for D0
                BEQ     MM_PRNT_DN      ; print D0
                CMP.W   #$0001,D3       ; check for D0
                BEQ     COUNT           ; counter = 1  
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0002,D3       ; mask for D1
                MOVE.W  #$0001,D5       ; store reg num 1
                CMP.W   #$0002,D3       ; check for D1
                BEQ     MM_PRNT_DN      ; print D1
                CMP.W   #$0002,D3       ; check for D1
                BEQ     COUNT           ; counter = 1   
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0004,D3       ; mask for D2
                MOVE.W  #$0002,D5       ; store reg num 2
                CMP.W   #$0004,D3       ; check for D2
                BEQ     MM_PRNT_DN      ; print D2
                CMP.W   #$0004,D3       ; check for D2
                BEQ     COUNT           ; counter = 1 
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0008,D3       ; mask for D3
                MOVE.W  #$0003,D5       ; store reg num 3
                CMP.W   #$0008,D3       ; check for D3
                BEQ     MM_PRNT_DN      ; print D3
                CMP.W   #$0008,D3       ; check for D3
                BEQ     COUNT           ; counter = 1 
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0010,D3       ; mask for D4
                MOVE.W  #$0004,D5       ; store reg num 4
                CMP.W   #$0010,D3       ; check for D4
                BEQ     MM_PRNT_DN      ; print D4
                CMP.W   #$0010,D3       ; check for D4
                BEQ     COUNT           ; counter = 1 
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0020,D3       ; mask for D5
                MOVE.W  #$0005,D5       ; store reg num 5
                CMP.W   #$0020,D3       ; check for D5
                BEQ     MM_PRNT_DN      ; print D5
                CMP.W   #$0020,D3       ; check for D5
                BEQ     COUNT           ; counter = 1 
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0040,D3       ; mask for D6
                MOVE.W  #$0006,D5       ; store reg num 6
                CMP.W   #$0040,D3       ; check for D6
                BEQ     MM_PRNT_DN      ; print D6
                CMP.W   #$0040,D3       ; check for D6
                BEQ     COUNT           ; counter = 1 
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0080,D3       ; mask for D7
                MOVE.W  #$0007,D5       ; store reg num 7
                CMP.W   #$0080,D3       ; check for D7
                BEQ     MM_PRNT_DN      ; print D7
                CMP.W   #$0080,D3       ; check for D7
                BEQ     COUNT           ; counter = 1 
            
            
                JSR     SLASH           ; print "/"
                MOVE.B  #$0000,D2       ; reset counter
            
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0100,D3       ; mask for A0
                MOVE.W  #$0000,D5       ; store reg num 0
                CMP.W   #$0100,D3       ; check for A0
                BEQ     MM_PRNT_AN      ; print A0
                CMP.W   #$0100,D3       ; check for A0
                BEQ     COUNT           ; counter = 1 
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0200,D3       ; mask for A1
                MOVE.W  #$0001,D5       ; store reg num 1
                CMP.W   #$0200,D3       ; check for A1
                BEQ     MM_PRNT_AN      ; print A1
                CMP.W   #$0200,D3       ; check for A1
                BEQ     COUNT           ; counter = 1 
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0400,D3       ; mask for A2
                MOVE.W  #$0002,D5       ; store reg num 2
                CMP.W   #$0400,D3       ; check for A2
                BEQ     MM_PRNT_AN      ; print A2
                CMP.W   #$0400,D3       ; check for A2
                BEQ     COUNT           ; counter = 1 
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0800,D3       ; mask for A3
                MOVE.W  #$0003,D5       ; store reg num 3
                CMP.W   #$0800,D3       ; check for A3
                BEQ     MM_PRNT_AN      ; print A3
                CMP.W   #$0800,D3       ; check for A3
                BEQ     COUNT           ; counter = 1 
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$1000,D3       ; mask for A4
                MOVE.W  #$0004,D5       ; store reg num 4
                CMP.W   #$1000,D3       ; check for A4
                BEQ     MM_PRNT_AN      ; print A4
                CMP.W   #$1000,D3       ; check for A4
                BEQ     COUNT           ; counter = 1 
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$2000,D3       ; mask for A5
                MOVE.W  #$0005,D5       ; store reg num 5
                CMP.W   #$2000,D3       ; check for A5
                BEQ     MM_PRNT_AN      ; print A5
                CMP.W   #$2000,D3       ; check for A5
                BEQ     COUNT           ; counter = 1 
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$4000,D3       ; mask for A6
                MOVE.W  #$0006,D5       ; store reg num 6
                CMP.W   #$4000,D3       ; check for A6
                BEQ     MM_PRNT_AN      ; print A6
                CMP.W   #$4000,D3       ; check for A6
                BEQ     COUNT           ; counter = 1 
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$8000,D3       ; mask for A7
                MOVE.W  #$0007,D5       ; store reg num 7
                CMP.W   #$8000,D3       ; check for A7
                BEQ     MM_PRNT_AN      ; print A7
                CMP.W   #$8000,D3       ; check for A7
                BEQ     COUNT           ; counter = 1 
            
            
                * call -(An) last (decrement)
                JSR     COMMA_SPACE     ; print ", "
                JSR     MODE_AN_MINUS   ; call -(An) printer
            
                RTS
            
MOVEM_M2R       MOVE.W  OPCODE,D6       ; refresh instruction
                MOVE.W  (A3),D4         ; save reg list into D5
                MOVE.B  #$0000,D2       ; reset counter
                
                    ; list = A7-A0/D7-D0
                    ; D5 = store reg num here, populated manually
                    ; D4 = holding original list
                    ; D3 = holding copy list for manip
            
                *call (An)+ first (increment)
                JSR     MODE_AN_PLUS    ; call (An)+ printer
                JSR     COMMA_SPACE     ; print ", "
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$8000,D3       ; mask for A7
                MOVE.W  #$0007,D5       ; store reg num 7
                CMP.W   #$8000,D3       ; check for A7
                BEQ     MM_PRNT_AN      ; print A7
                CMP.W   #$8000,D3       ; check for A7
                BEQ     COUNT           ; counter = 1
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$4000,D3       ; mask for A6
                MOVE.W  #$0006,D5       ; store reg num 6
                CMP.W   #$4000,D3       ; check for A6
                BEQ     MM_PRNT_AN      ; print A6
                CMP.W   #$4000,D3       ; check for A6
                BEQ     COUNT           ; counter = 1
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$2000,D3       ; mask for A5
                MOVE.W  #$0005,D5       ; store reg num 5
                CMP.W   #$2000,D3       ; check for A5
                BEQ     MM_PRNT_AN      ; print A5
                CMP.W   #$2000,D3       ; check for A5
                BEQ     COUNT           ; counter = 1
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$1000,D3       ; mask for A4
                MOVE.W  #$0004,D5       ; store reg num 4
                CMP.W   #$1000,D3       ; check for A4
                BEQ     MM_PRNT_AN      ; print A4
                CMP.W   #$1000,D3       ; check for A4
                BEQ     COUNT           ; counter = 1
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0800,D3       ; mask for A3
                MOVE.W  #$0003,D5       ; store reg num 3
                CMP.W   #$0800,D3       ; check for A3
                BEQ     MM_PRNT_AN      ; print A3
                CMP.W   #$0800,D3       ; check for A3
                BEQ     MODE_AN
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0400,D3       ; mask for A2
                MOVE.W  #$0002,D5       ; store reg num 2
                CMP.W   #$0400,D3       ; check for A2
                BEQ     MM_PRNT_AN      ; print A2
                CMP.W   #$0400,D3       ; check for A2
                BEQ     COUNT           ; counter = 1
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0200,D3       ; mask for A1
                MOVE.W  #$0001,D5       ; store reg num 1
                CMP.W   #$0200,D3       ; check for A1
                BEQ     MM_PRNT_AN      ; print A1
                CMP.W   #$0200,D3       ; check for A1
                BEQ     COUNT           ; counter = 1
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0100,D3       ; mask for A0
                MOVE.W  #$0000,D5       ; store reg num 0
                CMP.W   #$0100,D3       ; check for A0
                BEQ     MM_PRNT_AN      ; print A0
                CMP.W   #$0100,D3       ; check for A0
                BEQ     COUNT           ; counter = 1
            
            
                JSR     SLASH           ; print "/"
                MOVE.B  #$0000,D2       ; reset counter
            
           
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0080,D3       ; mask for D7
                MOVE.W  #$0007,D5       ; store reg num 7
                CMP.W   #$0080,D3       ; check for D7
                BEQ     MM_PRNT_DN      ; print D7
                CMP.W   #$0080,D3       ; check for D7
                BEQ     COUNT           ; counter = 1
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0040,D3       ; mask for D6
                MOVE.W  #$0006,D5       ; store reg num 6
                CMP.W   #$0040,D3       ; check for D6
                BEQ     MM_PRNT_DN      ; print D6
                CMP.W   #$0040,D3       ; check for D6
                BEQ     COUNT           ; counter = 1
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0020,D3       ; mask for D5
                MOVE.W  #$0005,D5       ; store reg num 5
                CMP.W   #$0020,D3       ; check for D5
                BEQ     MM_PRNT_DN      ; print D5
                CMP.W   #$0020,D3       ; check for D5
                BEQ     COUNT           ; counter = 1
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0010,D3       ; mask for D4
                MOVE.W  #$0004,D5       ; store reg num 4
                CMP.W   #$0010,D3       ; check for D4
                BEQ     MM_PRNT_DN      ; print D4
                CMP.W   #$0010,D3       ; check for D4
                BEQ     COUNT           ; counter = 1
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0008,D3       ; mask for D3
                MOVE.W  #$0003,D5       ; store reg num 3
                CMP.W   #$0008,D3       ; check for D3
                BEQ     MM_PRNT_DN      ; print D3
                CMP.W   #$0008,D3       ; check for D3
                BEQ     COUNT           ; counter = 1
                
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0004,D3       ; mask for D2
                MOVE.W  #$0002,D5       ; store reg num 2
                CMP.W   #$0004,D3       ; check for D2
                BEQ     MM_PRNT_DN      ; print D2
                CMP.W   #$0004,D3       ; check for D2
                BEQ     COUNT           ; counter = 1           
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0002,D3       ; mask for D1
                MOVE.W  #$0001,D5       ; store reg num 1
                CMP.W   #$0002,D3       ; check for D1
                BEQ     MM_PRNT_DN      ; print D1
                CMP.W   #$0002,D3       ; check for D1
                BEQ     COUNT           ; counter = 1      
            
                MOVE.W  D4,D3           ; refresh list
                ANDI.W  #$0001,D3       ; mask for D0
                MOVE.W  #$0000,D5       ; store reg num 0
                CMP.W   #$0001,D3       ; check for D0
                BEQ     MM_PRNT_DN      ; print D0
                CMP.W   #$0001,D3       ; check for D0
                BEQ     COUNT           ; counter = 1
            
                RTS
            
COUNT           MOVE.B  #1,D2           ; counter to determine 1st vs 2nd reg
                RTS
          
MM_PRNT_AN      CMP.W   #$0000,D2       ; if count = 0, this is the 1st reg
                BEQ     MODE_AN         ; print An
                CMP.W   #$0000,D2       ; if count = 0
                JSR     DASH            ; print "-"
            
                CMP.W   #$0001,D2       ; if count = 1, this is the 2nd reg
                BEQ     MODE_AN         ; print An
            
                RTS

MM_PRNT_DN      CMP.W   #$0000,D2       ; if count = 0, this is the 1st reg
                BEQ     MODE_DN         ; print Dn
                CMP.W   #$0000,D2       ; if count = 0
                JSR     DASH            ; print "-"
            
                CMP.W   #$0001,D2       ; if count = 1, this is the 2nd reg
                BEQ     MODE_DN         ; print Dn 

                RTS         

*--------------------------------------------------------------------       
* EA - MOVEQ
*   Called by the opcode MOVEQ. Contains personalized helpers to assist
*   in it's functions.
*--------------------------------------------------------------------

EA_MOVEQ        MOVE.W  OPCODE,D6       ; grab fresh instruction
                JSR     SIZE_LONG       ; only size long is valid
                LSL.W   #8,D6           ; shift extra bits off the left
                LSR.W   #8,D6           ; shift back into position
                MOVE.W  D6,D3           ; store data bits
                MOVE.W  D3,D4           ; two copies of data bits for below
                JSR     HEX             ; print "#$"
                JSR     MOVEQ_MOST      ; consider most-sig 4 bits
                JSR     MOVEQ_LEAST     ; consider least-sig 4 bits
            
                JSR     COMMA_SPACE     ; print ", "
            
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save reg num
                CMP.W   #$0000,D5       ; ok to proceed if Dn
                BEQ     MODE_DN         ; print Dn - only valid
            
*                CMP.W   #$0000,D5       ; if not Dn
*                BNE     EA_INVLD        ; invalid
            
            
MOVEQ_MOST      ANDI.W  #$00F0,D3       ; mask to isolate most-sig 4 bits
                CMP.W   #$0000,D3       ; check and print if 0 - 7
                BEQ     NUM_0
                CMP.W   #$0010,D3
                BEQ     NUM_1
                CMP.W   #$0020,D3
                BEQ     NUM_2
                CMP.W   #$0030,D3
                BEQ     NUM_3
                CMP.W   #$0040,D3
                BEQ     NUM_4
                CMP.W   #$0050,D3
                BEQ     NUM_5
                CMP.W   #$0060,D3
                BEQ     NUM_6
                CMP.W   #$0070,D3
                BEQ     NUM_7   
            
                CMP.W   #$00A0,D3       ; check if A - F
                BEQ     NUM_A
                CMP.W   #$00B0,D3
                BEQ     NUM_B
                CMP.W   #$00C0,D3
                BEQ     NUM_C
                CMP.W   #$00D0,D3
                BEQ     NUM_D
                CMP.W   #$00E0,D3
                BEQ     NUM_E
                CMP.W   #$00F0,D3
                BEQ     NUM_F 
            
                RTS
            
MOVEQ_LEAST     ANDI.W  #$000F,D4       ; mask to isolate least-sig 4 bits
                ANDI.W  #$00F0,D3       ; mask to isolate most-sig 4 bits
                JSR     NUM_FINDER      ; check and print if 0 - 7
            
                CMP.W   #$000A,D3       ; check if A - F
                BEQ     NUM_A
                CMP.W   #$000B,D3
                BEQ     NUM_B
                CMP.W   #$000C,D3
                BEQ     NUM_C
                CMP.W   #$000D,D3
                BEQ     NUM_D
                CMP.W   #$000E,D3
                BEQ     NUM_E
                CMP.W   #$000F,D3
                BEQ     NUM_F 
            
                RTS
 
*--------------------------------------------------------------------        
* EA - NOT
*   Called by the opcode NOT.
*-------------------------------------------------------------------- 

EA_NOT          MOVE.W  OPCODE,D6       ; refresh instruction
                LSR.W   #6,D6           ; shift off ea bits
                ANDI.W  #$000F,D6       ; mask to isolate size bits
                CMP.W   #$0008,D6       ; check if byte
                BEQ     SIZE_BYTE          
                CMP.W   #$0009,D6       ; check if word
                BEQ     SIZE_WORD          
                CMP.W   #$000A,D6       ; check if long
                BEQ     SIZE_LONG  

                MOVE.W  OPCODE,D6       ; grab fresh instruction
                JSR     SRC_REG_SAVE    ; save the register number
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print  
            
*                CMP.W   #$000A,D6       ; if above don't pass
*                BEQ     EA_INVLD        ; invalid
            
                RTS

*--------------------------------------------------------------------       
* EA - OR   
*   Called by the opcode OR. Contains personalized helpers to assist
*   in it's functions.
*--------------------------------------------------------------------

EA_OR           MOVE.W  OPCODE,D6       ; grab fresh instruction
                JSR     OPMODE_FINDER   ; D4 = opmode
                JSR     OPMODE_SIZE_FINDER  ; grab and print size
                                    
                CMP.W   #$0001,D3       ; D3 = 1 = <ea>,Dn
                BEQ     OR_1  
                CMP.W   #$0000,D3       ; D3 = 0 = Dn,<ea>
                BEQ     OR_0   
            
*                CMP.W   #$0000,D3       ; the above didn't pass
*                BNE     EA_INVLD        ; invalid
            
                RTS
            
OR_1            JSR     SRC_REG_SAVE    ; save register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print
                JSR     COMMA_SPACE     ; print comma
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save data register in D5
                JSR     MODE_DN         ; print Dn
            
                RTS
      
OR_0            JSR     MODE_DN         ; print Dn (data reg saved from before)
                JSR     COMMA_SPACE     ; print comma
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_REG_SAVE    ; save register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; print ea
            
                RTS

*--------------------------------------------------------------------        
* EA - Shifting Instructions
*   Called by multiple opcodes to handle ASL, ASR, LSL, LSR, ROL, ROR.
*--------------------------------------------------------------------

EA_SHIFT        MOVE.W  OPCODE,D6       ; grab fresh instructioN
                JSR     SHIFT_SIZE      ; grab size and print
            
                MOVE.W  OPCODE,D6       ; refresh instruction
                LSL.W   #8,D6           ; shift extra bits off the left
                LSL.W   #2,D6           ; 
                LSR.W   #8,D6           ; shift back into position
                LSR.W   #2,D6           ; 
                MOVE.W  D6,D3           ; move i/r bit into D3
                CMP.W   #$0000,D3       ; if i/r = 0, then count
                BEQ     SHIFT_COUNT
                CMP.W   #$0001,D3       ; if i/r = 1, then reg
                BEQ     SHIFT_REG       
            
                JSR     COMMA_SPACE     ; print ", "
            
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save reg num
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_LEAST      ; isolate mode and print
                CMP.W   #$0000,D3       ; make sure Dn
                BEQ     MODE_DN         ; pass to Dn - only valid
            
*                CMP.W   #$0000,D3       ; otherwise invalid
*                BNE     EA_INVLD        
            
                RTS

*--------------------------------------------------------------------       
* EA - SUB
*   Called by the opcode SUB. Contains personalized helpers to assist
*   in it's functions.
*--------------------------------------------------------------------

EA_SUB          MOVE.W  OPCODE,D6       ; grab fresh instruction
                JSR     OPMODE_FINDER   ; D4 = opmode
                JSR     OPMODE_SIZE_FINDER  ; grab and print size
                                    
                CMP.W   #$0001,D3       ; D3 = 1 = <ea>,Dn
                BEQ     SUB_1  
                CMP.W   #$0000,D3       ; D3 = 0 = Dn,<ea>
                BEQ     SUB_0   
            
*                CMP.W   #$0000,D3       ; the above didn't pass
*                BNE     EA_INVLD        ; invalid
            
                RTS
            
SUB_1           JSR     SRC_REG_SAVE    ; save register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; print ea 
                JSR     COMMA_SPACE     ; print comma
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save data register in D5
                JSR     MODE_DN         ; print Dn
                
                RTS
      
SUB_0           JSR     MODE_DN         ; print Dn (data reg saved above)
                JSR     COMMA_SPACE     ; print comma
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_REG_SAVE    ; save register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print
 
                RTS
                  
*--------------------------------------------------------------------            
            
*--------------------------------------------------------------------
* Isolating Source Register
*   This subroutine isolates the register mode after the reg number
*   is saved by another subroutine into D5. This SR is used only when
*   the register bits are the right-most 6 bits.
*--------------------------------------------------------------------

SRC_LEAST       LSR.W   #3,D6           ; shift src reg off the right side
                LSL.W   #8,D6           ; shift 13 spaces for dest reg/mode bits
                LSL.W   #5,D6           
                LSR.W   #8,D6           ; shift 13 spaces to move back needed bits
                LSR.W   #5,D6        
                ANDI.W  #$000F,D6       ; mask to isolate the src mode bits
                MOVE.W  D6,D3           ; store src mode
                JSR     MODE_FINDER     ; print
                
                RTS
                
*--------------------------------------------------------------------
* Isolating Destination Register
*   This subroutine isolates the register mode after the reg number
*   is saved by another subroutine into D5. This SR is used only when
*   the register bits are located at bits 6-11. 
*--------------------------------------------------------------------

DEST_LEAST      LSL.W   #7,D6           ; shift unneeded bits off the left
                LSR.W   #7,D6           ; move bits back to previous spot
                LSR.W   #6,D6           ; remove source bits
                ANDI.W  #$000F,D6       ; mask to isolate dest mode bits
                MOVE.W  D6,D3           ; store dest mode
                JSR     MODE_FINDER     ; print
                
                RTS
                
*--------------------------------------------------------------------
* Size Finder
*   Figures out which size needs to be printed for this 
*   instruction. Works for when sizes are attached to bits
*   12-13 (opcode bits).
*--------------------------------------------------------------------

SIZE_FINDER     LSR.W   #8,D6           ; shift extra bits off 
                LSR.W   #4,D6           ;    the right side
                ANDI.W  #$000F,D6       ; isolate size bits
                CMP.W   #$0001,D6       ; does size = byte?
                BEQ     SIZE_BYTE       ; size = byte
                CMP.W   #$0003,D6       ; does size = word?
                BEQ     SIZE_WORD       ; size = word
                CMP.W   #$0002,D6       ; does size = long?
                BEQ     SIZE_LONG       ; size = long
                
                RTS             
                
*--------------------------------------------------------------------
* Opmode Size Finder
*   Figures out which size needs to be printed for this 
*   instruction. Works for when sizes are attached to the opcode bits.
*--------------------------------------------------------------------                
OPMODE_SIZE_FINDER                
                CMP.W   #$0000,D4       ; size = byte
                BEQ     SIZE_BYTE       
                CMP.W   #$0004,D4       ; size = byte
                BEQ     SIZE_BYTE
                
                CMP.W   #$0001,D4       ; size = word
                BEQ     SIZE_WORD       
                CMP.W   #$0005,D4       ; size = word
                BEQ     SIZE_WORD
                
                CMP.W   #$0002,D4       ; size = long
                BEQ     SIZE_LONG       
                CMP.W   #$0006,D4       ; size = long
                
                RTS
                
*--------------------------------------------------------------------
* Opmode Finder
*   Finds and stores the opmode in D4 if it exists in bits 6-8. Also 
*   sets D3 to 1 or 0 depending on the addressing format needed.
*   D3 = 1 = <ea>,Dn
*   D3 = 0 = Dn,<ea>
*--------------------------------------------------------------------

OPMODE_FINDER   MOVE.W  D6,D4           ; save instruction
                LSR.W   #6,D4           ; shift ea bits off the right
                LSL.W   #7,D4           ; shift opcode and reg bits off
                LSR.W   #7,D4           ; shift back into place
                
                ANDI.W  #$000F,D4       ; mask in case there are missed bits
                CMP.W   #$0000,D4       ; byte - <ea>,Dn
                BEQ     OPMODE_EADN
                CMP.W   #$0001,D4       ; word - <ea>,Dn
                BEQ     OPMODE_EADN   
                CMP.W   #$0002,D4       ; long - <ea>,Dn
                BEQ     OPMODE_EADN
                
                CMP.W   #$0004,D4       ; byte - Dn,<ea>
                BEQ     OPMODE_DNEA    
                CMP.W   #$0005,D4       ; word - Dn,<ea>
                BEQ     OPMODE_DNEA
                CMP.W   #$0006,D4       ; long - Dn,<ea>
                BEQ     OPMODE_DNEA

OPMODE_EADN     MOVE.B  #$0001,D3       ; set D3 to 1 - indicates <ea>,Dn
                RTS
                
OPMODE_DNEA     MOVE.B  #$0000,D3       ; set D3 to 0 - indicates Dn,<ea>
                RTS
                
                RTS

*--------------------------------------------------------------------
* Mode Finder
*   This subroutine figures out which mode this instruction needs
*   to print for the register being currently evaluated. The caller 
*   has isolated the mode to the least- most bits and the register 
*   number to D4/5 depending on where it's located.
*--------------------------------------------------------------------
                
MODE_FINDER     CMP.W       #$0000,D6       ; if dest mode = Dn
                BEQ         MODE_DN
                
                CMP.W       #$0001,D6       ; if dest mode = An
                BEQ         MODE_AN
                
                CMP.W       #$0002,D6       ; if dest mode = (An)
                BEQ         MODE_AN_PARENS
                
                CMP.W       #$0003,D6       ; if dest mode = (An)+
                BEQ         MODE_AN_PLUS
                
                CMP.W       #$0004,D6       ; if dest mode = -(An)
                BEQ         MODE_AN_MINUS   
                
                CMP.W       #$0007,D6       ; if dest mode = (xxx).size/#data
                BEQ         SRC_ABS
                
                RTS
                
*--------------------------------------------------------------------
* Number Finder
*   This subroutine figures out which register number this 
*   instruction needs to print. 
*--------------------------------------------------------------------

NUM_FINDER      CMP.W       #$0000,D5       ; if num = 0
                BEQ         NUM_0
                
                CMP.W       #$0001,D5       ; if num = 1
                BEQ         NUM_1
                
                CMP.W       #$0002,D5       ; if num = 2
                BEQ         NUM_2
                
                CMP.W       #$0003,D5       ; if num = 3
                BEQ         NUM_3
                
                CMP.W       #$0004,D5       ; if num = 4
                BEQ         NUM_4
                
                CMP.W       #$0005,D5       ; if num = 5
                BEQ         NUM_5
                
                CMP.W       #$0006,D5       ; if num = 6
                BEQ         NUM_6
                
                CMP.W       #$0007,D5       ; if num = 7
                BEQ         NUM_7
                
*                CMP.W       #$0007,D5       ; if none of the above
*                BNE         EA_INVLD        ; invalid
                
                RTS
                
*--------------------------------------------------------------------
* Displacement Finder
*   This subroutine figures out how much displacement comes after
*   this instruction when immediate values are used by the instruction.

*       WIP - not sure what this needs to do yet
*--------------------------------------------------------------------

DISP_FINDER     MOVE.W      D6,D5       ; grab instruction for manip
                ANDI.W      #$00FF,D5   ; mask to isolate the displacement
                CMP.W       #$0000,D5   ; $00 = 16-bit displacement
                *grab 16-bits of A3? beq to a SR for this
                
                *MOVE.L (A3)+, D2
                
                CMP.W       #$00FF,D5   ; $FF = 32-bit displacement
                *grab 32-bits of A3? beq to a SR for this

                CMP.W       #$00FF,D5   ; if none of the above, 8-bit
                *grab 8-bits of A3? bne to a SR for this
                
                RTS                

*--------------------------------------------------------------------
* Register Number Savers
*   These subroutines save the register numbers for use by other
*   subroutines throughout depending on their locations.
*--------------------------------------------------------------------

SRC_REG_SAVE    MOVE.W      D6,D5       ; grab instruction
                ANDI.W      #$000F,D5   ; mask to isolate needed bits
                LSL.W       #8,D5       ; shift 13 spaces to remove extra bit
                LSL.W       #5,D5
                LSR.W       #8,D5       ; shift 13 spaces back to position
                LSR.W       #5,D5       
                                        ; reg num saved in D5
                
                RTS

DEST_REG_SAVE   MOVE.W      D6,D5       ; grab instruction
                LSR.W       #8,D5       ; shift 9 spaces to remove extra bits
                LSR.W       #1,D5
                LSL.W       #8,D5       ; shift 13 spaces to remove extra bit
                LSL.W       #5,D5
                LSR.W       #8,D5       ; shift 13 spaces back to position
                LSR.W       #5,D5       
                                        ; reg num saved in D5   
                RTS 
            
*--------------------------------------------------------------------
* Absolute Addressing Determiners
*   These subroutines determine whether the addressing is a word or 
*   long, then branches to the appropriate handler/printer.
*--------------------------------------------------------------------

************************************************************
* Absolute Addressing - Destination Register
************************************************************

DEST_ABS        MOVE.W  OPCODE,D6       ; fresh instruction
                LSR.W   #6,D6           ; remove source bits
                ANDI.W  #$000F,D6       ; mask to isolate dest bits
                CMP.W   #$0007,D6       ; check if .W
                BEQ     MODE_WORD
            
                CMP.W   #$000F,D6       ; check if .L
                BEQ     MODE_LONG
            
                CMP.W   #$0027,D6       ; check if immediate
                BEQ     MODE_DATA
            
*                CMP.W   #$0027,D6       ; if none of the above 
*                BNE     EA_INVLD        ; invalid
            
                RTS

************************************************************
* Absolute Addressing - Source Register
************************************************************

SRC_ABS         MOVE.W  OPCODE,D6       ; fresh instruction
                ANDI.W  #$000F,D6       ; mask to isolate src bits
                CMP.W   #$0038,D6       ; check if .W
                BEQ     MODE_WORD
            
                CMP.W   #$0039,D6       ; check if .L
                BEQ     MODE_LONG
            
                CMP.W   #$003C,D6       ; check if immediate
                BEQ     MODE_DATA
            
*                CMP.W   #$003C,D6       ; if none of the above
*                BNE     EA_INVLD        ; invalid
            
                RTS
            
*--------------------------------------------------------------------
* Shift Instruction Helpers
*   This subroutin assists the subroutine that handles shifting 
*   instructions.
*--------------------------------------------------------------------

************************************************************
* Shift Size - determines the size of the shift instruction
************************************************************

SHIFT_SIZE      LSL.W   #8,D6           ; shift extra bits off the left
                LSR.W   #8,D6           ; shift back into position
                LSR.W   #6,D6           ; shift extra bits off the right
                ANDI.W  #$000F,D6       ; mask to isolate the size bits
            
                CMP.W   #$0000,D6       ; size = byte
                BEQ     SIZE_BYTE
            
                CMP.W   #$0001,D6       ; size = word
                BEQ     SIZE_WORD
            
                CMP.W   #$0002,D6       ; size = long
                BEQ     SIZE_LONG
            
                RTS

************************************************************
* Shift Count - instruction shifts by immediate number
************************************************************   
               
SHIFT_COUNT     JSR     HASH            ; print "#"

                CMP.W   #$0000,D5       ; count 0 = 8
                JSR     NUM_8           
                
                CMP.W   #$0001,D5       ; check counts 1 - 7
                BEQ     NUM_1
                CMP.W   #$0002,D5        
                BEQ     NUM_2
                CMP.W   #$0003,D5
                BEQ     NUM_3
                CMP.W   #$0004,D5
                BEQ     NUM_4
                CMP.W   #$0005,D5
                BEQ     NUM_5
                CMP.W   #$0006,D5
                BEQ     NUM_6
                CMP.W   #$0007,D5
                BEQ     NUM_7
            
*                CMP.W   #$0007,D5       ; if not 0-7
*                BNE     EA_INVLD        ; invalid, can only go to 8
            
                RTS            
            
************************************************************
* Shift Register - instruction shifts by data in register
************************************************************

SHIFT_REG       MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_REG_SAVE    ; save reg num
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode
                CMP.W   #$0000,D3       ; make sure Dn
                BEQ     MODE_DN         ; pass to Dn - only valid
            
*                CMP.W   #$0000,D3       ; otherwise invalid
*                BNE     EA_INVLD        
            
                RTS
                  
*--------------------------------------------------------------------            
            
*--------------------------------------------------------------------
* Printing Sub-Routines
*   These sub-routines print the needed ea parts of the instruction.
*--------------------------------------------------------------------

************************************************************
* Printer - Size Byte
************************************************************          
SIZE_BYTE       MOVE.L  #BYTE_STRING,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS
            
************************************************************
* Printer - Size Word 
************************************************************                     
SIZE_WORD       MOVE.L  #WORD_STRING,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS
            
************************************************************
* Printer - Size Long
************************************************************           
SIZE_LONG       MOVE.L  #LONG_STRING,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS
            
************************************************************
* Printer - Dn
************************************************************
MODE_DN         MOVE.L  #L_D,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT 
                JSR     NUM_FINDER   
                RTS
                    
************************************************************
* Printer - An
************************************************************
MODE_AN         MOVE.L  #L_A,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                JSR     NUM_FINDER
                RTS
                    
************************************************************
* Printer - (An)
************************************************************
MODE_AN_PARENS  MOVE.L  #CHAR_IndirA,ADDTORESULT_STRING_TOADD    ;(A
                JSR     ADDTORESULT
                JSR     NUM_FINDER
                MOVE.L  #CHAR_PAR,ADDTORESULT_STRING_TOADD       ; )
                JSR     ADDTORESULT
                RTS
                    
************************************************************
* Printer - (An)+
************************************************************
MODE_AN_PLUS    MOVE.L  #CHAR_IndirA,ADDTORESULT_STRING_TOADD    ; (A
                JSR     ADDTORESULT
                JSR     NUM_FINDER
                MOVE.L  #CHAR_ParPlus,ADDTORESULT_STRING_TOADD   ; )+
                JSR     ADDTORESULT
                RTS
                    
************************************************************
* Printer - -(An)
************************************************************
MODE_AN_MINUS   MOVE.L  #CHAR_MinIndirA,ADDTORESULT_STRING_TOADD ; -(A
                JSR     ADDTORESULT
                JSR     NUM_FINDER
                MOVE.L  #CHAR_PAR,ADDTORESULT_STRING_TOADD       ; )
                JSR     ADDTORESULT
                RTS
                    
************************************************************
* Printer - (xxx).W            ---- WIP
************************************************************
MODE_WORD       JSR     HASH            ; #
                MOVE.W (A3)+,D2         ; grab word from A3 address
                * pass this to print
                JSR     ADDTORESULT
                RTS
                    
************************************************************
* Printer - (xxx).L             ---- WIP
************************************************************
MODE_LONG       JSR     HASH            ; #
                MOVE.L  (A3)+,D2        ; grab word from A3 address
                * pass this to print
                JSR     ADDTORESULT
                RTS
                    
************************************************************
* Printer - Immediate #<data>   ---- WIP
************************************************************  
MODE_DATA       JSR     HEX             ; #$
                MOVE.L  (A3),D2         ; grab from A3 address
                * pass this to print (is L right?)
                JSR     ADDTORESULT
                RTS    

************************************************************
* Printer - 0
************************************************************  
NUM_0           MOVE.L  #N_0,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS

************************************************************
* Printer - 1
************************************************************
NUM_1           MOVE.L  #N_1,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS

************************************************************
* Printer - 2
************************************************************
NUM_2           MOVE.L  #N_2,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS

************************************************************
* Printer - 3
************************************************************
NUM_3           MOVE.L  #N_3,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS

************************************************************
* Printer - 4
************************************************************
NUM_4           MOVE.L  #N_4,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS

************************************************************
* Printer - 5
************************************************************
NUM_5           MOVE.L  #N_5,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS

************************************************************
* Printer - 6
************************************************************
NUM_6           MOVE.L  #N_6,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS

************************************************************
* Printer - 7
************************************************************
NUM_7           MOVE.L  #N_7,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS
                    
************************************************************
* Printer - 8 
*   Used by the shift instructions.
************************************************************                   
NUM_8           MOVE.L  #N_8,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS
                    
************************************************************
* Printer - A
************************************************************
NUM_A           MOVE.L  #L_A,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS

************************************************************
* Printer - B
************************************************************
NUM_B           MOVE.L  #L_B,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS
                    
************************************************************
* Printer - C
************************************************************
NUM_C           MOVE.L  #L_C,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS

************************************************************
* Printer - D
************************************************************
NUM_D           MOVE.L  #L_D,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS
                    
************************************************************
* Printer - E
************************************************************
NUM_E           MOVE.L  #L_E,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS
                    
************************************************************
* Printer - F
************************************************************
NUM_F           MOVE.L  #L_F,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS

************************************************************
* Printer - Comma ", "
************************************************************
COMMA_SPACE     MOVE.L  #COMMA,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS

************************************************************
* Printer - Parenthesis ")"
************************************************************
PARENS          MOVE.L  #CHAR_PAR,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS

************************************************************
* Printer - Immediate "#"
************************************************************
HASH            MOVE.L  #CHAR_HASH,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS
                
************************************************************
* Printer - Hexadecimal "#$"
************************************************************
HEX             MOVE.L  #CHAR_HASHDLR,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS

************************************************************
* Printer - Binary "#%"
************************************************************
BIN             MOVE.L  #CHAR_HASHPCT,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS
                    
************************************************************
* Printer - SLASH "/"
************************************************************
SLASH           MOVE.L  #CHAR_SLASH,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS
                 
************************************************************
* Printer - DASH "-"
************************************************************
DASH            MOVE.L  #CHAR_DASH,ADDTORESULT_STRING_TOADD
                JSR     ADDTORESULT
                RTS

************************************************************
* Printer - Invalid Addressing
************************************************************ 
EA_INVLD        ADD.B       #1,EA_ERROR   ; invalid adress
                RTS         
           




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
