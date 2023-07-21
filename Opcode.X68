*-----------------------------------------------------------
* Title      : Opcode Decoder
* Written by : Annie J Kehn, Amy Meyers, John Ghattas
* Date       : 05/05/2019
* Description: Vers. 5
*-----------------------------------------------------------

*-----------------------------------------------------------------------------
* Program Start
*-----------------------------------------------------------------------------                                     

OPCODE1     BRA         OP_MAIN             ; start decoding opcodes

*-----------------------------------------------------------------------------
* Opcode Main
*-----------------------------------------------------------------------------

OP_MAIN     MOVEM.W     D1,-(SP)            ; save the register
            MOVE.W      OPCODE,D1           ; grab opcode instruction
            ANDI.W      #$F000,D1           ; bit mask to isolate the first byte
            LSR.W       #8,D1               ; shift off the extra bytes
            LSR.W       #4,D1               
            JMP         OP_CMP              ; move on to finding opcode groups   
        
*-----------------------------------------------------------------------------
* Opcode Group Tester Subroutines 
*   Compares the most significant byte to programmed hexadecimal numbers to 
*   determine which opcode group to check this instruction against. If it 
*   doesn't compare to any, the instruction is invalid.
*-----------------------------------------------------------------------------

OP_CMP    

OP_1        CMP.B       #$01,D1             ; compare opcode to number
            BNE         OP_2                ; branch if not in this group
            JSR         OP_1XXX             ; branch if in this group
            BRA         OP_MAIN_DONE        ; finished
            
OP_2        CMP.B       #$02,D1
            BNE         OP_3
            JSR         OP_2XXX
            BRA         OP_MAIN_DONE

OP_3        CMP.B       #$03,D1
            BNE         OP_4
            JSR         OP_3XXX
            BRA         OP_MAIN_DONE  
        
OP_4        CMP.B       #$04,D1             
            BNE         OP_5
            JSR         OP_4XXX
            BRA         OP_MAIN_DONE

OP_5        CMP.B       #$05, D1
            BNE         OP_6
            JSR         OP_5XXX
            BRA         OP_MAIN_DONE
            
OP_6        CMP.B       #$06, D1            
            BNE         OP_7                
            JSR         OP_6XXX             
            BRA         OP_MAIN_DONE        

OP_7        CMP.B       #$07,D1
            BNE         OP_8
            JSR         OP_7XXX
            BRA         OP_MAIN_DONE

OP_8        CMP.B       #$08,D1
            BNE         OP_9
            JSR         OP_8XXX
            BRA         OP_MAIN_DONE

OP_9        CMP.B       #$09,D1
            BNE         OP_C
            JSR         OP_9XXX
            BRA         OP_MAIN_DONE

OP_C        CMP.B       #$0C,D1
            BNE         OP_D
            JSR         OP_CXXX
            BRA         OP_MAIN_DONE

OP_D        CMP.B       #$0D,D1
            BNE         OP_E
            JSR         OP_DXXX
            BRA         OP_MAIN_DONE

OP_E        CMP.B       #$0E,D1
            BNE         OP_INVLD            ; if none of the above, invalid opcode  
            JSR         OP_EXXX
            BRA         OP_MAIN_DONE     

*-----------------------------------------------------------------------------
* Main Done
*    Finishes the main subroutines of the opcode decoder.   
*-----------------------------------------------------------------------------

OP_MAIN_DONE 
            MOVEM.W (SP)+,D1                ; restore register   
            RTS

*-----------------------------------------------------------------------------
* Opcode Decoding Subroutines
*     
*-----------------------------------------------------------------------------

OP_1XXX     MOVE.W      OPCODE,D2           ; move opcode into D2
            LSR.W       #6,D2               ; shift source bits off the right
            LSR.W       #6,D2               ; shift destination bits off the right
            ANDI.W      #$000F,D2           ; isolate the MOVE bits
            CMP.W       #$0001,D2           ; make sure it's MOVE
            BEQ         OP_MOVE             ; add opcode to result - MOVE
           
            CMP.W       #$0001,D2           ; if not the above
            BNE         OP_INVLD            ; it's invalid
            RTS

OP_2XXX     MOVE.W      OPCODE,D2 
            LSR.W       #6,D2               ; shift ea bits off the right
            ANDI.W      #$000F,D2           ; mask to isolate the MOVEA bits 
            CMP.W       #$0001,D2           ; check if MOVEA
            BEQ         OP_MOVEA            ; add opcode to result - MOVEA
            
            MOVE.W      OPCODE,D2           ; reset opcode
            LSR.W       #6,D2               ; shift source bits off the right
            LSR.W       #6,D2               ; shift destination bits off the right
            ANDI.W      #$000F,D2           ; mask to isolate the MOVE bits
            CMP.W       #$0002,D2           ; check if MOVE
            BEQ         OP_MOVE             ; add opcode to result - MOVE
            
            CMP.W       #$0002,D2           ; wasn't MOVEA or MOVE
            BNE         OP_INVLD
            
            RTS

OP_3XXX     MOVE.W      OPCODE,D2
            LSR.W       #6,D2               ; shift ea bits off the right
            ANDI.W      #$000F,D2           ; mask to isolate the MOVEA bits
            CMP.W       #$0001,D2           ; check if MOVEA
            BEQ         OP_MOVEA            ; add opcode to result - MOVEA
            
            MOVE.W      OPCODE,D2
            LSR.W       #6,D2               ; shift source bits off the right
            LSR.W       #6,D2               ; shift destination bits off the right
            ANDI.W      #$000F,D2           ; mask to isolate the MOVE bits
            CMP.W       #$0003,D2           ; check if MOVE
            BEQ         OP_MOVE             ; add opcode to result - MOVE 
            
            CMP.W       #$0003,D2           ; if none of the above
            BNE         OP_INVLD            ; it's invalid
            
            RTS

OP_4XXX     MOVE.W      OPCODE,D2
            LSR.W       #6,D2               ; shift ea bits off the right
            ANDI.W      #$00FF,D2           ; mask to isolate the JSR bits
            CMP.W       #$003A,D2           ; check if JSR
            BEQ         OP_JSR              ; add opcode  to result - JSR                               

            MOVE.W      OPCODE,D2           ; reset the opcode to decode
            LSR.W       #6,D2               ; shift ea bits off the right
            LSR.W       #1,D2               ; shift size bit off the right
            ANDI.W      #$00FF,D2           ; mask to isolate the MOVEM bits
            CMP.W       #$0011,D2           ; check if MOVEM
            BEQ         OP_MOVEM            ; add opcode to result - MOVEM     
            ANDI.W      #$00FF,D2           ; mask to isolate the MOVEM bits
            CMP.W       #$0019,D2           ; check if MOVEM
            BEQ         OP_MOVEM            ; add opcode to result - MOVEM
            
            MOVE.W      OPCODE,D2           ; reset the opcode to decode
            CMP.W       #$4E71,D2           ; check if NOP
            BEQ         OP_NOP              ; add opcode to result - NOP 
            
            MOVE.W      OPCODE,D2           ; reset the opcode to decode
            CMP.W       #$4E75,D2           ; check if RTS
            BEQ         OP_RTS              ; add opcode to result - RTS
            
            BRA         X_NOT               ; if none of these, check for LEA or NOT

X_NOT       MOVE.W      OPCODE,D2           ; reset the opcode to decode
            LSR.W       #6,D2               ; shift ea bits off the right
            LSR.W       #2,D2               ; shift size bits off the right
            ANDI.W      #$001,D2            ; single NOT vs. LEA bit left over
            BEQ         X_LEA               ; bit = 1, this is LEA
                                            ; bit = 0, this is NOT
            MOVE.W      OPCODE,D2           ; reset the opcode to decode
            LSR.W       #6,D2               ; shift ea bits off the right
            LSR.W       #2,D2               ; shift size bits off the right
            ANDI.W      #$0006,D2           ; mask to isolate the NOT bits
            BEQ         OP_NOT              ; add opcode to result - NOT 
            
X_LEA       MOVE.W      OPCODE,D2           ; reset the opcode to decode
            LSR.W       #6,D2               ; shift the ea bits off the right
            ANDI.W      #$0007,D2           ; mask to isolate the LEA bits
            BEQ         OP_LEA              ; add opcode to result - LEA
            
            CMP.W       #$0007,D2           ; none of the tests above were valid
            BNE         OP_INVLD            ; invalid
            
            RTS         
            
OP_5XXX     MOVE.W      OPCODE,D2           ; reset the opcode to decode
            LSR.W       #6,D2               ; shift ea bits off the right
            ANDI.W      #$000F,D2           ; isolate the ADDQ bits
            CMP.W       #$0000,D2           ; check if valid ADDQ 
            BEQ         OP_ADDQ             ; add opcode to result - ADDQ
            CMP.W       #$0001,D2           ; check if valid ADDQ 
            BEQ         OP_ADDQ             ; add opcode to result - ADDQ
            CMP.W       #$0002,D2           ; check if valid ADDQ 
            BEQ         OP_ADDQ             ; add opcode to result - ADDQ
            
            CMP.W       #$0002,D2           ; if none above passed
            BNE         OP_INVLD            ; invalid
            
            RTS          

OP_6XXX     MOVE.W      OPCODE,D2 
            LSR.W       #8,D2               ; shift displacement bits off the right
            ANDI.W      #$000F,D2           ; mask to isolate the BEQ bits
            CMP.W       #$0007,D2           ; check if BEQ
            BEQ         OP_BEQ              ; add opcode to result - BEQ
            
            MOVE.W      OPCODE,D2
            LSR.W       #8,D2               ; shift displacement bits off the right
            ANDI.W      #$000F,D2           ; mask to isolate the BGT bits
            CMP.W       #$000E,D2           ; check if BGT
            BEQ         OP_BGT              ; add opcode to result - BGT
            
            MOVE.W      OPCODE,D2
            LSR.W       #8,D2               ; shift displacement bits off the right
            ANDI.W      #$000F,D2           ; mask to isolate the BLE bits
            CMP.W       #$000D,D2           ; check if BLE
            BEQ         OP_BLE              ; add opcode to result - BLE
            
            MOVE.W      OPCODE,D2
            LSR.W       #8,D2               ; shift displacement bits off the right
            ANDI.W      #$000F,D2           ; mask to isoalte the BRA bits
            CMP.W       #$0000,D2           ; check if BRA
            BEQ         OP_BRA              ; add opcode to result - BRA
            
            CMP.W       #$0000,D2           ; if none above passed
            BNE         OP_INVLD            ; invalid
            
            RTS   

OP_7XXX     MOVE.W      OPCODE,D2           ; refresh instruction
            LSR.W       #8,D2               ; shift data bits off the right
            ANDI.W      #$00F0,D2           ; mask to isolate MOVEQ bits
            CMP.W       #$0070,D2           ; check if MOVEQ
            BEQ         OP_MOVEQ            ; add opcode to result - MOVEQ
            
            CMP.W       #$0070,D2           ; if not above
            BNE         OP_INVLD            ; invalid
            
            RTS 

OP_8XXX     MOVE.W      OPCODE,D2           ; refresh the instruction
            LSR.W       #6,D2               ; shift the ea bits off the right
            LSR.W       #8,D2               ; shift extra bits off the left
            LSR.W       #5,D2
            LSL.W       #8,D2               ; shift back into position
            LSL.W       #5,D2
            ANDI.W      #$000F,D2           ; mask to isolate the OR bits
            CMP.W       #$0000,D2           ; check if OR  
            BEQ         OP_OR               ; add opcode to result - OR
            CMP.W       #$0001,D2           ; check if OR 
            BEQ         OP_OR               ; add opcode to result - OR
            CMP.W       #$0002,D2           ; check if OR 
            BEQ         OP_OR               ; add opcode to result - OR
            CMP.W       #$0004,D2           ; check if OR 
            BEQ         OP_OR               ; add opcode to result - OR
            CMP.W       #$0005,D2           ; check if OR 
            BEQ         OP_OR               ; add opcode to result - OR
            CMP.W       #$0006,D2           ; check if OR 
            BEQ         OP_OR               ; add opcode to result - OR
            
            CMP.W       #$0006,D2           ; if none above were valid
            BNE         OP_INVLD            ; invalid
            
            RTS 

OP_9XXX     MOVE.W      OPCODE,D2           ; refresh the instruction
            LSR.W       #6,D2               ; shift the ea bits off the right
            LSR.W       #8,D2               ; shift extra bits off the left
            LSR.W       #5,D2
            LSL.W       #8,D2               ; shift back into position
            LSL.W       #5,D2
            ANDI.W      #$000F,D2           ; mask to isolate the SUB bits
            CMP.W       #$0000,D2           ; check if SUB   
            BEQ         OP_SUB              ; add opcode to result - SUB 
            CMP.W       #$0001,D2           ; check if SUB  
            BEQ         OP_SUB              ; add opcode to result - SUB 
            CMP.W       #$0002,D2           ; check if SUB  
            BEQ         OP_SUB              ; add opcode to result - SUB 
            CMP.W       #$0004,D2           ; check if SUB  
            BEQ         OP_SUB              ; add opcode to result - SUB 
            CMP.W       #$0005,D2           ; check if SUB  
            BEQ         OP_SUB              ; add opcode to result - SUB 
            CMP.W       #$0006,D2           ; check if SUB  
            BEQ         OP_SUB              ; add opcode to result - SUB 
            
            CMP.W       #$0006,D2           ; if none above were valid
            BNE         OP_INVLD            ; invalid
 
            RTS                         
      
OP_CXXX     MOVE.W      OPCODE,D2           ; refresh the instruction
            LSR.W       #6,D2               ; shift the ea bits off the right
            ANDI.W      #$000F,D2           ; mask to isolate the AND bits
            CMP.W       #$0000,D2           ; check if AND   
            BEQ         OP_AND              ; add opcode to result - AND
            CMP.W       #$0001,D2           ; check if AND  
            BEQ         OP_AND              ; add opcode to result - AND
            CMP.W       #$0002,D2           ; check if AND  
            BEQ         OP_AND              ; add opcode to result - AND
            CMP.W       #$0004,D2           ; check if AND
            BEQ         OP_AND              ; add opcode to result - AND
            CMP.W       #$0005,D2           ; check if AND
            BEQ         OP_AND              ; add opcode to result - AND
            CMP.W       #$0006,D2           ; check if AND
            BEQ         OP_AND              ; add opcode to result - AND
            
            CMP.W       #$0006,D2           ; if none above were valid
            BNE         OP_INVLD            ; invalid
 
            RTS 
            
      
OP_DXXX     MOVE.W      OPCODE,D2
            LSR.W       #6,D2               ; shift ea bits off the right
            ANDI.W      #$000F,D2           ; mask - destination
            LSL.W       #8,D2               ;
            LSL.W       #5,D2               
            LSR.W       #8,D2               ;
            LSR.W       #5,D2
            CMP.W       #$0003,D2           ; check if ADDA
            BEQ         OP_ADDA             ; add opcode to result - ADDA
            CMP.W       #$0007,D2           ; check if ADDA
            BEQ         OP_ADDA             ; add opcode to result - ADDA            
           
            CMP.W       #$0000,D2           ; check if ADD
            BEQ         OP_ADD              ; add opcode to result - ADD
            CMP.W       #$0001,D2           ; check if ADD
            BEQ         OP_ADD              ; add opcode to result - ADD
            CMP.W       #$0002,D2           ; check if ADD
            BEQ         OP_ADD              ; add opcode to result - ADD
            CMP.W       #$0004,D2           ; check if ADD
            BEQ         OP_ADD              ; add opcode to result - ADD
            CMP.W       #$0005,D2           ; check if ADD
            BEQ         OP_ADD              ; add opcode to result - ADD
            CMP.W       #$0006,D2           ; check if ADD
            BEQ         OP_ADD              ; add opcode to result - ADD
            
            CMP.W       #$0006,D2           ; if above didn't pass
            BNE         OP_INVLD            ; invalid
            
            RTS

OP_EXXX     MOVE.W      OPCODE,D2
            LSR.W       #3,D2               ; shifting to isolate bits 3-4
            LSL.W       #8,D2
            LSL.W       #6,D2
            LSR.W       #8,D2
            LSR.W       #6,D2
            
            CMP.W       #$0000,D2           ; check if Arithmetic
            BEQ         EX_ARITH
            CMP.W       #$0001,D2           ; check if Logical
            BEQ         EX_LOG
            CMP.W       #$0003,D2           ; check if Rotate
            BEQ         EX_ROT
            
            CMP.W       #$0003,D2           ; if none above passed
            BNE         OP_INVLD            ; invalid             
            
EX_ARITH    MOVE.W      OPCODE,D2           ; refresh instruction
            LSR.W       #8,D2               ; shift off extra bits
            LSL.W       #8,D2               ; shift extra bits off left
            LSL.W       #7,D2
            LSR.W       #8,D2               ; shift back into position
            LSR.W       #7,D2
            CMP.W       #$0001,D2           ; if dir = 1
            BEQ         OP_ASL              ; dir = left
            CMP.W       #$0000,D2           ; if dir = 0
            BEQ         OP_ASR              ; dir = right
            
            RTS
            
EX_LOG      MOVE.W      OPCODE,D2           ; refresh instruction
            LSR.W       #8,D2               ; shift off extra bits
            LSL.W       #8,D2
            LSL.W       #7,D2               ; shift extra bits off left
            LSR.W       #8,D2
            LSR.W       #7,D2               ; shift back into position
            CMP.W       #$0001,D2           ; if dir = 1
            BEQ         OP_LSL              ; dir = left
            CMP.W       #$0000,D2           ; if dir = 0
            BEQ         OP_LSR              ; dir = right
            
            RTS
            
EX_ROT      MOVE.W      OPCODE,D2           ; refresh instruction
            LSR.W       #8,D2               ; shift off extra bits
            LSL.W       #8,D2
            LSL.W       #7,D2               ; shift extra bits off left
            LSR.W       #8,D2
            LSR.W       #7,D2  
            CMP.W       #$0001,D2           ; if dir = 1
            BEQ         OP_ROL              ; dir = left
            CMP.W       #$0000,D2           ; if dir = 0
            BEQ         OP_ROR              ; dir = right
            
            RTS     
            
*-----------------------------------------------------------------------------
* Opcode String Result Subroutines
*   These subroutines add the opcode's name to the print result to be handled
*   by the IO file. 
*-----------------------------------------------------------------------------            
        
OP_ADD      MOVE.L      #ADD_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT 
            JSR         EA_ADD 
            RTS 

OP_ADDA     MOVE.L      #ADDA_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_ADDA
            RTS

OP_ADDQ     MOVE.L      #ADDQ_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_ADDQ
            RTS

OP_AND      MOVE.L      #AND_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_AND
            RTS

OP_ASL      MOVE.L      #ASL_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_SHIFT
            RTS

OP_ASR      MOVE.L      #ASR_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_SHIFT
            RTS

OP_BEQ      MOVE.L      #BEQ_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_BRANCH
            RTS

OP_BGT      MOVE.L      #BGT_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_BRANCH
            RTS
            
OP_BLE      MOVE.L      #BLE_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_BRANCH     
            RTS

OP_BRA      MOVE.L      #BRA_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_BRANCH
            RTS

OP_JSR      MOVE.L      #JSR_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_JSR
            RTS

OP_LEA      MOVE.L      #LEA_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_LEA
            RTS
            
OP_LSL      MOVE.L      #LSL_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_SHIFT
            RTS
            
OP_LSR      MOVE.L      #LSR_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_SHIFT
            RTS

OP_MOVE     MOVE.L      #MOVE_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_MOVE 
            RTS
            
OP_MOVEA    MOVE.L      #MOVEA_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_MOVEA
            RTS
            
OP_MOVEM    MOVE.L      #MOVEM_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_MOVEM
            RTS

OP_MOVEQ    MOVE.L      #MOVEQ_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_MOVEQ
            RTS

OP_NOP      MOVE.L      #NOP_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            RTS

OP_NOT      MOVE.L      #NOT_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_NOT
            RTS

OP_OR       MOVE.L      #OR_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_OR
            RTS

OP_ROL      MOVE.L      #ROL_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_SHIFT
            RTS

OP_ROR      MOVE.L      #ROR_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_SHIFT
            RTS

OP_RTS      MOVE.L      #RTS_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            RTS

OP_SUB      MOVE.L      #SUB_STRING,ADDTORESULT_STRING_TOADD
            JSR         ADDTORESULT
            JSR         EA_SUB
            RTS
            
OP_INVLD    ADD.B       #1,OP_ERROR           ; invalid opcode
            RTS


















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
