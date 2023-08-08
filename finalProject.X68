*-----------------------------------------------------------
* Title      : Combined File for Disassembler
* Written by : Team Binary Refinery
* Date       :
* Description: This file holds all includes and executes in order.
*              Run this file when executing or compiling code
*              Add test file to this to test outputs 
*-----------------------------------------------------------
START    ORG    $1000
                  ; first instruction of program
    
     *----------Welcome Output----------*
        LEA     WELCOME,A1
        MOVE.B  #14,D0
        TRAP    #15  

*-----------------------------------------------------------
* Title      : I/O Section 
* Written by : John Ghattas
* Date       : 5/16/2019
* Description: Reads instructions from the user and passes
*              to the appropriate files to disassemble them.
*              Takes starting and ending addresses from the 
*              user as well as instructions to decode. Also 
*              prints the needed instructions to the output 
*              window.
*-----------------------------------------------------------
       
        *TAKE START ADDRESS AND END ADDRESS FROM USER 
        *A3 = START, A4 = END
        
        *-----------User_Input---------------*
            LEA     NUM1,A1
            MOVE.B  #14,D0
            TRAP    #15
        
        *-----------User_Input---------------*
            MOVEA.W #STARTADDRESS, A1
            MOVE.B  #2, D0  *reading user input
            TRAP    #15


            MOVE.L   A1, ARG_HEXSTR   * Move the fetched string into the conversion register
            JSR      STR2HEX                 * Convert to numeric hex value from string
            
            MOVE.L   RET_HEXVAL, STARTADDRESS

         *-----------User_Input---------------*
            LEA     NUM2,A1
            MOVE.B  #14,D0
            TRAP    #15
        
        *-----------User_Input---------------*
            MOVEA.W #ENDADDRESS, A1
            MOVE.B  #2, D0  *reading user input
            TRAP    #15


            MOVE.L   A1, ARG_HEXSTR   * Move the fetched string into the conversion register
            JSR      STR2HEX                 * Convert to numeric hex value from string
            
            MOVE.L RET_HEXVAL, ENDADDRESS
        
        
            MOVE.L STARTADDRESS, A3   *START ADDRESS          
            MOVE.L ENDADDRESS, A4   *END ADDRESS          
    
*---------------------------------------------------------------------------
* TESTING INSTRUCTIONS 
*    MOVE.L  
*    MOVE.W  #$1601,(A2)+ *MOVE.B        
*    MOVE.W  #$7601,(A2)+ *MOVE.L    
*    MOVE.W  #$D401,(A2)+ *ADD.B         
*    MOVE.W  #$9E03,(A2)+ *SUB.B     
*---------------------------------------------------------------------------

            CLR.B D1
               
LOOP        CMP.L A3, A4
            BLE DONE
                       
            CMP.B #25, D1
            BLT CON
            
            LEA     ENTERMESSAGE,A1
            MOVE.B  #13,D0
            TRAP    #15
        
            MOVEA.L #$FFFF, A1         
            MOVE.B  #2, D0  *reading user input
            TRAP    #15
        
            CLR.B D1
        
                
CON     
            ADDQ.B #1, D1    
            *CLEAR BUFFER BOTH BUFFERS
            MOVE.L #RESULT, CLEARBUFFER_BUFFER
            JSR CLEARBUFFER        
            MOVE.L #DATARESULT, CLEARBUFFER_BUFFER
            JSR CLEARBUFFER
    
            *CLEAR ANY ERRORS
    
        
            *MOVE THE WORD ADDRESS TO WORDADDRESS
            MOVE.L A3, WORDADDRESS
        
            *MOVE WORD IN A3 TO OPCODE AND INCREAMENT
            MOVE.W (A3)+, OPCODE
            MOVE.W OPCODE, D5
 
            *CONVERT ADDRESS TO STRING
            MOVE.L WORDADDRESS, ARG_HSVAL
            MOVE.L #32, ARG_HSMODE
            JSR HEX2STR
 
            *ADD ADDRESS TO RESULT BUFFER
            MOVE.L #RESULT, ADDTORESULT_RESULT_BUFFER
            MOVE.L #ARG_HSBUFF, ADDTORESULT_STRING_TOADD
            JSR ADDTORESULT
        
            *ADD ADDRESS TO DATA BUFFER
            MOVE.L #DATARESULT, ADDTORESULT_RESULT_BUFFER
            JSR ADDTORESULT
        
            *ADD THE WORD DATA TO DATA BUFFER 
            MOVE.L #DATA_STRING, ADDTORESULT_STRING_TOADD
            JSR ADDTORESULT
        
            *CONVERT THE OPCODE TO STRING
            MOVE.L D5, ARG_HSVAL
            MOVE.L #16, ARG_HSMODE
            JSR HEX2STR
        
            *ADD THE OPCODE TO DATA BUFFER
            MOVE.L #ARG_HSBUFF, ADDTORESULT_STRING_TOADD
            JSR ADDTORESULT
                   
            *SET THE CURRENT BUFFER TO RESULT
            MOVE.L #RESULT, ADDTORESULT_RESULT_BUFFER

            *CALL THE OPCODE ROUTINE
            JSR OPCODE1
    
    
            *IF OPCODE IS INVALID 


            
            *IF EA IS INVALID 


        
            *PRINT THE RESULT BUFFER        
            MOVE.L #RESULT, A1
            MOVE.B #13, D0
            TRAP #15
    
            BRA CONTINUE
        

                                         
CONTINUE
                    
            BRA LOOP  
        
       
DONE  

ADDTORESULT        DS.W    0         
            MOVEM.L     D0-D1/A0-A4, -(SP)  			
    
            MOVE.L      ADDTORESULT_STRING_TOADD, A0		
            MOVE.L      ADDTORESULT_RESULT_BUFFER , A1			
            MOVE.L      ADDTORESULT_RESULT_BUFFER_LENGTH, D0		
            CLR.W       BUFFER_ADD_SUCCESS			
            CLR.L       D1						

STRING_BUFFER_LOOP
            CMPI.B      #0, (A1)					
            BEQ         STRING_BUFFER_ADD_LOOP			
    
            CMP.L       D0, D1				
            BGE         BUFFER_LENGTH_EXCEEDED			
    
            ADDQ.L      #1, A1					
            ADDQ.B      #1, D1					
            BRA         STRING_BUFFER_LOOP			
    
STRING_BUFFER_ADD_LOOP
            CMPI.B      #0, (A0)				       
            BEQ         STRING_ADD_SUCCESS			
    
            CMP.B       D0, D1					
            BGE         BUFFER_LENGTH_EXCEEDED			
    
            MOVE.B      (A0)+,(A1)+				
            ADDQ.B      #1, D1					
            ADDQ.W      #1, A4					
            BRA         STRING_BUFFER_ADD_LOOP			

STRING_ADD_SUCCESS
            MOVE.B      #0,(A1)					
            BRA         BUFFER_STRING_END				

BUFFER_LENGTH_EXCEEDED
            MOVE.W      #1, BUFFER_ADD_SUCCESS			

BUFFER_STRING_END
            MOVEM.L     (SP)+, D0-D1/A0-A4			
            RTS                  					




CLEARBUFFER DS.W 0

            MOVEM.L D1-D2/A1, -(SP)
 
            MOVE.L CLEARBUFFER_BUFFER, A1
            MOVE.B CLEARBUFFER_LENGTH, D1
            MOVE.B #$0, D2
                   
CLR_BUFFER_LOOP    
            CMP.B  D1, D2
            BEQ  CLR_DONE
            CLR.B  (A1)+ 
            ADDQ.B #1, D2
            BRA CLR_BUFFER_LOOP
            
CLR_DONE
            MOVEM.L (SP)+, D1-D2/A1

            RTS

* Hex to String

HEX2STR:
            MOVEM.L     D0-D3/A0-A1,-(A7)      
            
            MOVE.L      #ARG_HSBUFF,CLEARBUFFER_BUFFER
            JSR         CLEARBUFFER
 
            MOVEA.L     #ARG_HSBUFF,A0           
            MOVE.L      ARG_HSVAL,D0            
            MOVE.L      ARG_HSMODE,D2           
            CLR.L       D3                      
            
_HSCLOOP:   MOVE.L      D0,D1                   
            SUBQ.L      #4,D2                  
            CMP.L       D3,D2                   
            BLT         _HSDONE                 
            LSR.L       D2,D1                   
            AND.B       #$0F,D1                 
            
            MOVE.L      #VALU_ARRAY,A1          
_HSEQLOOP:  CMP.B       (A1)+,D1                
            BNE         _HSEQLOOP               
            
            SUBA.L      #$00000018,A1           
            MOVE.B      (A1),(A0)+              
            BRA         _HSCLOOP                
            
_HSDONE:    MOVE.B      D3,(A0)+                
            MOVEM.L     (A7)+,D0-D3/A0-A1       
            RTS                                 

*String to Hex
ARG_HEXSTR  DS.L        1                       
RET_HEXVAL  DS.L        1                       
RET_HEXTRNC DS.B        1                       
RET_HEXINV  DS.B        1                       
CHAR_ARRAY  DC.B        '0123456789ABCDEFabcdef',0 
VALU_ARRAY  DC.B        0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,10,11,12,13,14,15,0
STR2HEX:
            MOVEM.L     D0-D2/A0-A3,-(SP)       
            MOVE.B      #$0000,RET_HEXTRNC      
            MOVE.B      #$0000,RET_HEXINV       
            CLR.L       D0                      
            CLR.L       D1                      
            MOVE.L      #$0000FFFC,D2           
            MOVEA.L     ARG_HEXSTR,A0           
            MOVEA.L     A0,A1                   
            
_SHDISCLP:  CMP.B       #0,(A0)+                
            BNE         _SHDISCLP                          
            ADD.L       #$FFFFFFFF,A0           
            CMP.L       A1,A0                   
            BLE         _SHINVALID              

_SHINTPTLP: ADDQ        #4,D2                   
            CMP.L       #32,D2                  
            BEQ         _SHTRUNC                            
            CLR.L       D1                      
            MOVE.B      -(A0),D1                           
            MOVEA.L     #CHAR_ARRAY,A2          
            MOVEA.L     #VALU_ARRAY,A3      
    
_SHEQLP:    CMP.B       (A2)+,D1                
            BEQ         _SHFOUND                
            ADDQ        #1,A3                   
            CMP.B       #0,(A2)                 
            BEQ         _SHINVALID              
            BRA         _SHEQLP                

_SHFOUND:   MOVE.B      (A3)+,D1                
            LSL.L       D2,D1                   
            OR.L        D1,D0                         
            CMP.L       A1,A0                   
            BGT         _SHINTPTLP              
            BRA         _SHRET                  

_SHTRUNC:   MOVE.B      #$0001,RET_HEXTRNC     
            BRA         _SHRET                  
            
_SHINVALID: MOVE.B      #$0001,RET_HEXINV      
            CLR.L       D0                      

_SHRET:     MOVE.L      D0,RET_HEXVAL           
            MOVEM.L     (SP)+,D0-D2/A0-A3       
            RTS                                 
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
            
            RTS   

OP_7XXX     MOVE.W      OPCODE,D2           ; refresh instruction
            LSR.W       #8,D2               ; shift data bits off the right
            ANDI.W      #$00F0,D2           ; mask to isolate MOVEQ bits
            CMP.W       #$0070,D2           ; check if MOVEQ
            BEQ         OP_MOVEQ            ; add opcode to result - MOVEQ
            
            CMP.W       #$0070,D2           ; if not above

            
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
            

            RTS
*--------------------------------------------------------------------        
* EA - ADD
*   Called by the opcode ADD. Contains personalized helpers to assist
*   in it's functions.
*--------------------------------------------------------------------

EA_ADD          MOVE.W  OPCODE,D6           ; grab fresh instruction
                JSR     OPMODE_FINDER       ; D4 = opmode
                JSR     OPMODE_SIZE_FINDER  ; grabs and prints size
                                    
                CMP.W   #$0001,D3       ; D3 = 1 = <ea>,Dn
                BEQ     ADD_1  
                CMP.W   #$0000,D3       ; D3 = 0 = Dn,<ea>
                BEQ     ADD_0   
            
                CMP.W   #$0000,D3       ; the above didn't pass
                BNE     EA_INVLD        ; invalid
            
                RTS
            
ADD_1           JSR     SRC_REG_SAVE    ; save register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print
                JSR     COMMA_SPACE     ; print comma
            
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save data register in D5
                MOVE.W  OPCODE,D6
                JSR     MODE_DN
                *JSR     DEST_LEAST
                RTS
      
ADD_0           MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save reg num
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     MODE_DN
                *JSR     DEST_LEAST      ; print reg
                
                
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
            
                CMP.W   #$0000,D3       ; the above didn't pass
                BNE     EA_INVLD        ; invalid
            
                RTS
            
OR_1            JSR     SRC_REG_SAVE    ; save register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; isolate mode and print
                JSR     COMMA_SPACE     ; print comma
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save data register in D5
                JSR     MODE_DN         ; print Dn
            
                RTS
      
OR_0            MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save reg num in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     MODE_DN         ; print Dn (data reg saved from before)
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

EA_SHIFT        MOVE.W  OPCODE,D6       ; grab fresh instruction
                JSR     SHIFT_SIZE      ; grab size and print
            
                MOVE.W  OPCODE,D6       ; refresh instruction
                LSR.W   #5,D6
                LSL.W   #8,D6           ; shift extra bits off the left
                LSL.W   #7,D6           ; 
                LSR.W   #8,D6           ; shift back into position
                LSR.W   #7,D6           ; 
                MOVE.W  D6,D3           ; move i/r bit into D3
                CMP.W   #$0000,D3       ; if i/r = 0, then count
                BEQ     SHIFT_COUNT
                CMP.W   #$0001,D3       ; if i/r = 1, then reg
                BEQ     SHIFT_REG       

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
            
                CMP.W   #$0000,D3       ; the above didn't pass
                BNE     EA_INVLD        ; invalid
            
                RTS
            
SUB_1           JSR     SRC_REG_SAVE    ; save register number in D5
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_LEAST       ; print ea 
                JSR     COMMA_SPACE     ; print comma
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save data register in D5
                JSR     MODE_DN         ; print Dn
                
                RTS
      
SUB_0           MOVE.W  OPCODE,D6       ; refresh opcode
                JSR     DEST_REG_SAVE   ; save reg num in D5
                MOVE.W  OPCODE,D6       ; refresh opcode
                JSR     MODE_DN         ; print Dn (data reg saved above)
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
                BEQ     SIZE_LONG
                
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
                LSL.W   #8,D4           ; shift extra bits off
                LSL.W   #5,D4
                LSR.W   #8,D4           ; shift back into place
                LSR.W   #5,D4
                
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
                
                CMP.W   #$0006,D4       ; if none of the above
                BNE     EA_INVLD        ; invalid

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

SHIFT_SIZE      LSR.W   #6,D6           ; shift extra bits off the right
                LSL.W   #8,D6           ; shift extra bits off the left
                LSL.W   #6,D6
                LSR.W   #8,D6           ; shift back into position
                LSR.W   #6,D6
            
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
            
                CMP.W   #$0007,D5       ; if not 0-7
                BNE     EA_INVLD        ; invalid, can only go to 8
                
                JSR     COMMA_SPACE     ; print ", "
            
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_REG_SAVE    ; save reg num
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     MODE_DN         ; pass to Dn 
            
                RTS            
            
************************************************************
* Shift Register - instruction shifts by data in register
************************************************************

SHIFT_REG       MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     DEST_REG_SAVE   ; save reg num
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     MODE_DN         ; run Dn
                
                JSR     COMMA_SPACE     ; print ", "
            
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     SRC_REG_SAVE    ; save reg num
                MOVE.W  OPCODE,D6       ; refresh instruction
                JSR     MODE_DN         ; pass to Dn 
            
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
* Put program code here

            
            
    SIMHALT             ; halt simulator
            
WELCOME    DC.B    'Hello World! Welcome to the Binary Refinery Disassembler! ', CR, LF, 0
   
CR          EQU  $0D
LF          EQU  $0A

* Put variables and constants here
NUM1            DC.B    'Enter Start Address ',0
NUM2            DC.B    'Enter End Address ',0

            
STARTADDRESS DS.L 1
ENDADDRESS DS.L 1
            
            
DATA_STRING DC.B ' DATA ',0 

RESULT      DS.B 80     
DATARESULT  DS.B 80     
WORDADDRESS DS.L 1
OPCODE      DS.W 1
OP_ERROR    DS.B 1
EA_ERROR    DS.B 1

INVALID_OP    DC.B  'Invalid Opcode',0
INVALID_EA    DC.B  'Invalid Addressing',0

ADDTORESULT_RESULT_BUFFER DS.L 1
ADDTORESULT_STRING_TOADD  DS.L 1 
ADDTORESULT_RESULT_BUFFER_LENGTH	DC.L    80
BUFFER_ADD_SUCCESS		DS.B    1


CLEARBUFFER_BUFFER DS.L 1
CLEARBUFFER_LENGTH DC.B 80


ARG_HSBUFF DS.B         80                       
ARG_HSVAL  DS.L         1                       
ARG_HSMODE DS.L         1  

*CHAR_ARRAY  DC.B        '0123456789ABCDEFabcdef',0 
*VALU_ARRAY  DC.B        0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,10,11,12,13,14,15,0   

BYTE_STRING DC.B '.B ',0
WORD_STRING DC.B '.W ',0
LONG_STRING DC.B '.L ',0  
            
NOP_STRING   DC.B ' NOP',0      
MOVE_STRING  DC.B ' MOVE',0 
MOVEQ_STRING DC.B ' MOVEQ',0
MOVEM_STRING DC.B ' MOVEM',0
MOVEA_STRING DC.B ' MOVEA',0
ADD_STRING   DC.B ' ADD',0
ADDA_STRING  DC.B ' ADDA',0
ADDQ_STRING  DC.B ' ADDQ',0
SUB_STRING   DC.B ' SUB',0
LEA_STRING   DC.B ' LEA',0
AND_STRING   DC.B ' AND',0
OR_STRING    DC.B ' OR',0
NOT_STRING   DC.B ' NOT',0
LSL_STRING   DC.B ' LSL',0
LSR_STRING   DC.B ' LSR',0
ASL_STRING   DC.B ' ASL',0
ASR_STRING   DC.B ' ASR',0
ROL_STRING   DC.B ' ROL',0
ROR_STRING   DC.B ' ROR',0
BGT_STRING   DC.B ' BGT',0
BLE_STRING   DC.B ' BLE',0
BEQ_STRING   DC.B ' BEQ',0
JSR_STRING   DC.B ' JSR',0
RTS_STRING   DC.B ' RTS',0
BRA_STRING   DC.B ' BRA',0
ENTERMESSAGE DC.B '--------------PRESS ENTER TO CONTINUE--------------', 0

**********Strings EA Needs**********
N_0             DC.B '0',0
N_1             DC.B '1',0
N_2             DC.B '2',0
N_3             DC.B '3',0
N_4             DC.B '4',0
N_5             DC.B '5',0
N_6             DC.B '6',0
N_7             DC.B '7',0
N_8             DC.B '8',0
L_A             DC.B 'A',0
L_B             DC.B 'B',0
L_C             DC.B 'C',0
L_D             DC.B 'D',0
L_E             DC.B 'E',0
L_F             DC.B 'F',0
COMMA           DC.B ', ',0
CHAR_PAR        DC.B ')',0
CHAR_IndirA     DC.B '(A',0
CHAR_ParPlus    DC.B ')+',0
CHAR_MinIndirA  DC.B '-(A',0
CHAR_HASH       DC.B '#',0
CHAR_HASHDLR    DC.B '#$',0
CHAR_HASHPCT    DC.B '#%',0
CHAR_SPACE      DC.B ' ',0
CHAR_SLASH      DC.B '/',0
CHAR_DASH       DC.B '-',0


*    INCLUDE "TEST.x68"
*    INCLUDE "test.x68"
*********************************************************
*
* Test Code for the Demo
*
*********************************************************

        ORG	$00006000

*    MOVE.B    D0,D1   
*    RTS
*    NOP
    DIVU.W    D0,D1
*    MOVE.B    D0,(A0)
*    MOVE.B    D0,(A0)+
*    MOVE.B    D0,-(A0)
*    MOVE.B    (A0),D0
*    MOVE.B    (A0),(A1)
*    MOVE.B    (A0),(A1)+
*    MOVE.B    (A0),-(A1)
*    MOVE.B    (A0)+,D0
*    MOVE.B    (A0)+,(A1)
*    MOVE.B    (A0)+,(A1)+
*    MOVE.B    (A0)+,-(A1)
*    MOVE.B    -(A0),D0
*    MOVE.B    -(A0),(A1)
*    MOVE.B    -(A0),(A1)+
*    MOVE.B    -(A0),-(A1)
*    MOVE.W    D0,D1
*    MOVE.W    D0,(A0)
*    MOVE.W    D0,(A0)+
*    MOVE.W    D0,-(A0)
*    MOVE.W    A0,D0
*    MOVE.W    A0,(A1)
*    MOVE.W    A0,(A1)+
*    MOVE.W    A0,-(A1)
*    MOVE.W    (A0),D0
*    MOVE.W    (A0),(A1)
*    MOVE.W    (A0),(A1)+
*    MOVE.W    (A0),-(A1)
*    MOVE.W    (A0)+,D0
*    MOVE.W    (A0)+,(A1)
*    MOVE.W    (A0)+,(A1)+
*    MOVE.W    (A0)+,-(A1)
*    MOVE.W    -(A0),D0
*    MOVE.W    -(A0),(A1)
*    MOVE.W    -(A0),(A1)+
*    MOVE.W    -(A0),-(A1)
*    MOVE.L    D0,D1
*    MOVE.L    D0,(A0)
*    MOVE.L    D0,(A0)+
*    MOVE.L    D0,-(A0)
*    MOVE.L    A0,D0
*    MOVE.L    A0,(A1)
*    MOVE.L    A0,(A1)+
*    MOVE.L    A0,-(A1)
*    MOVE.L    (A0),D0
*    MOVE.L    (A0),(A1)
*    MOVE.L    (A0),(A1)+
*    MOVE.L    (A0),-(A1)
*    MOVE.L    (A0)+,D0
*    MOVE.L    (A0)+,(A1)
*    MOVE.L    (A0)+,(A1)+
*    MOVE.L    (A0)+,-(A1)
*    MOVE.L    -(A0),D0
*    MOVE.L    -(A0),(A1)
*    MOVE.L    -(A0),(A1)+
*    MOVE.L    -(A0),-(A1)
    ADD.B     D1,D2
    ADD.B     D1,(A1)
    ADD.B     D1,(A1)+
    ADD.B     D1,-(A1)
    ADD.B     (A1),D1
    ADD.B     (A1)+,D1
    ADD.B     -(A1),D1
    ADD.W     D1,D2
    ADD.W     D1,(A1)
    ADD.W     D1,(A1)+
    ADD.W     D1,-(A1)
    ADD.W     (A1),D1
    ADD.W     (A1)+,D1
    ADD.W     -(A1),D1
    ADD.L     D1,D2
    ADD.L     D1,(A1)
    ADD.L     D1,(A1)+
    ADD.L     D1,-(A1)
    ADD.L     (A1),D1
    ADD.L     (A1)+,D1
    ADD.L     -(A1),D1
    SUB.B     D1,D2
    SUB.B     D1,(A1)
    SUB.B     D1,(A1)+
    SUB.B     D1,-(A1)
    SUB.B     (A1),D1
    SUB.B     (A1)+,D1
    SUB.B     -(A1),D1
    SUB.W     D1,D2
    SUB.W     D1,A1
    SUB.W     D1,(A1)
    SUB.W     D1,(A1)+
    SUB.W     D1,-(A1)
    SUB.W     A1,D1
    SUB.W     (A1),D1
    SUB.W     (A1)+,D1
    SUB.W     -(A1),D1
    SUB.L     D1,D2
    SUB.L     D1,A1
    SUB.L     D1,(A1)
    SUB.L     D1,(A1)+
    SUB.L     D1,-(A1)
    SUB.L     A1,D1
    SUB.L     (A1),D1
    SUB.L     (A1)+,D1
    SUB.L     -(A1),D1    
    MULS.W    D0,D1
    MULS.W    (A0),D1
    MULS.W    -(A0),D1
    MULS.W    (A0)+,D1
    DIVU.W    D0,D1
    DIVU.W    (A0),D1
    DIVU.W    -(A0),D1
    DIVU.W    (A0)+,D1
    OR.B     D1,D2
    OR.B     D1,(A1)
    OR.B     D1,(A1)+
    OR.B     D1,-(A1)
    OR.B     (A1),D1
    OR.B     (A1)+,D1
    OR.B     -(A1),D1
    OR.W     D1,D2
    OR.W     D1,(A1)
*    OR.W     D1,(A1)+
*    OR.W     D1,-(A1)
*    OR.W     (A1),D1
*    OR.W     (A1)+,D1
*    OR.W     -(A1),D1
*    OR.L     D1,D2
*    OR.L     D1,(A1)
*    OR.L     D1,(A1)+
*    OR.L     D1,-(A1)
*    OR.L     (A1),D1
*    OR.L     (A1)+,D1
*    OR.L     -(A1),D1
*    LSL.B     D1,D2
*    LSL.W     D1,D2
*    LSL.W     (A1)
*    LSL.W     (A1)+
*    LSL.W     -(A1)
*    LSL.L     D1,D2
*    LSR.B     D1,D2
*    LSR.W     D1,D2
*    LSR.W     (A1)
*    LSR.W     (A1)+
*    LSR.W     -(A1)
*    LSR.L     D1,D2    
*    ASR.B     D1,D2
*    ASR.W     D1,D2
*    ASR.W     (A1)
*    ASR.W     (A1)+
*    ASR.W     -(A1)
*    ASR.L     D1,D2
*    ASL.B     D1,D2
*    ASL.W     D1,D2
*    ASL.W     (A1)
*    ASL.W     (A1)+
*    ASL.W     -(A1)
*    ASL.L     D1,D2  
*    JSR       (A0)
*    JSR       $1234
*    JSR       $12345678
*    JSR       label1
*    JSR       label2
*    JSR       label3
*    NOP
*    RTS
*label1
*    NOP
*    RTS
*    LEA       $12,A0
*    LEA       $1234,A0
*    LEA       $12345678,A0
*label2
*    MOVEQ     #$0,D0
*    MOVEQ     #$12,D0
*    MOVEQ     #$FF,D0
*label3
*    MOVEM.W   A1-A7,$12
*    MOVEM.L   D1-D7,$12
*    MOVEM.W   A1/D7,$12
*    MOVEM.L   A1/D7,$12
*    MOVEM.W   A1-A7,$1234
*    MOVEM.L   D1-D7,$1234
*    MOVEM.W   A1/D7,$1234
*    MOVEM.L   A1/D7,$1234
*    MOVEM.W   A1-A7,$12345678
*    MOVEM.L   D1-D7,$12345678
*    MOVEM.W   A1/D7,$12345678
*    MOVEM.L   A1/D7,$12345678
*    MOVEM.W   $12,A1-A7
*    MOVEM.L   $12,D1-D7
*    MOVEM.W   $12,A1/D7
*    MOVEM.L   $12,A1/D7
*    MOVEM.W   $1234,A1-A7
*    MOVEM.L   $1234,D1-D7
*    MOVEM.W   $1234,A1/D7
*    MOVEM.L   $1234,A1/D7
*    MOVEM.W   $12345678,A1-A7
*    MOVEM.L   $12345678,D1-D7
*    MOVEM.W   $12345678,A1/D7
*    MOVEM.L   $12345678,A1/D7
*    ADDA.W    $12,A2
*    ADDA.W    $1234,A2
*    ADDA.W    $12345678,A2
*    ADDA.W    #$1234,A2
*    ADDA.L    $12,A2
*    ADDA.L    $1234,A2
*    ADDA.L    $12345678,A2
*    ADDA.L    #$12345678,A2
*    MULS.W    $12,D1
*    MULS.W    $1234,D1
*    MULS.W    $12345678,D1
*    MULS.W    #$1234,D1
*    DIVU.W    $12,D1
*    DIVU.W    $1234,D1
*    DIVU.W    $12345678,D1
*    DIVU.W    #$1234,D1
*    AND.B     D1,$12
*    AND.B     D1,$1234
*    AND.B     D1,$12345678
*    AND.B     $12,D1
*    AND.B     $1234,D1
*    AND.B     $12345678,D1
*    AND.B     #$12,D1
*    AND.W     D1,$12
*    AND.W     D1,$1234
*    AND.W     D1,$12345678
*    AND.W     $12,D1
*    AND.W     $1234,D1
*    AND.W     $12345678,D1
*    AND.W     #$1234,D1
*    AND.L     D1,$12
*    AND.L     D1,$1234
*    AND.L     D1,$12345678
*    AND.L     $12,D1
*    AND.L     $1234,D1
*    AND.L     $12345678,D1
*    AND.L     #$12345678,D1
*    LSL.B     #$1,D2
*    LSL.W     #$2,D2
*    LSL.L     #$3,D2
*    LSL.W     $12
*    LSL.W     $1234
*    LSL.W     $12345678
*    ASR.B     #$1,D2
*    ASR.W     #$2,D2
*    ASR.L     #$3,D2
*    ASR.W     $12
*    ASR.W     $1234
*    ASR.W     $12345678
*label4
*    BGT.B     label4
*    BGT.B     label4
*    BGT.B     label4
*    BLE.W     label1
*    BLE.W     label2
*    BLE.W     label3
*    BEQ.W     label1
*    BEQ.W     label2
*    BEQ.W     label3
*    JSR       label1
*    JSR       label2
*    JSR       label3
    
*    MOVEM.W   A1-A7,-(A1)
*    MOVEM.L   D1-D7,-(A1)
*    MOVEM.W   A1/D7,-(A1)
*    MOVEM.L   A1/D7,-(A1)
*    MOVEM.W   A1-A7,(A1)
*    MOVEM.L   D1-D7,(A1)
*    MOVEM.W   A1/D7,(A1)
*    MOVEM.L   A1/D7,(A1)
*    MOVEM.W   (A1)+,A1-A7
*    MOVEM.L   (A1)+,D1-D7
*    MOVEM.W   (A1)+,A1/D7
*    MOVEM.L   (A1)+,A1/D7
*    MOVEM.W   (A1),A1-A7
*    MOVEM.L   (A1),D1-D7
*    MOVEM.W   (A1),A1/D7
*    MOVEM.L   (A1),A1/D7
*    MOVEA.W    D0,A0
*    MOVEA.W    A0,A0
*    MOVEA.W    (A0),A0
*    MOVEA.W    (A0)+,A0
*    MOVEA.W    -(A0),A0
*    MOVEA.L    D0,A0
*    MOVEA.L    A0,A0
*    MOVEA.L    (A0),A0
*    MOVEA.L    (A0)+,A0
*    MOVEA.L    -(A0),A0
*    *LEA     (A0),A0
*    *LEA     (A5),A0
*    *LEA     (A7),A0
*    *LEA     (A0),A7
*    *LEA     (A5),A7
*    *LEA     (A7),A7  
*    ADDA.W        D1,A2
*    ADDA.W        (A1),A2
*    ADDA.W        (A1)+,A2
*    ADDA.W        -(A1),A2
*    ADDA.L        D1,A2
*    ADDA.L        (A1),A2
*    ADDA.L        (A1)+,A2
*    ADDA.L        -(A1),A2
*    AND.B     D1,D2
*    AND.B     D1,(A1)
*    AND.B     D1,(A1)+
*    AND.B     D1,-(A1)
*    AND.B     (A1),D1
*    AND.B     (A1)+,D1
*    AND.B     -(A1),D1
*    AND.W     D1,D2
*    AND.W     D1,(A1)
*    AND.W     D1,(A1)+
*    AND.W     D1,-(A1)
*    AND.W     (A1),D1
*    AND.W     (A1)+,D1
*    AND.W     -(A1),D1
*    AND.L     D1,D2
*    AND.L     D1,(A1)
*    AND.L     D1,(A1)+
*    AND.L     D1,-(A1)
*    AND.L     (A1),D1
*    AND.L     (A1)+,D1
*    AND.L     -(A1),D1
*    BGT.B     label1
*    BGT.B     label2
*    BLE.B     label1
*    BLE.B     label2
*    BGE.B     label1
*    BEQ.B     label2
*    BEQ.W     label1





















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~




    END    START        ; last line of source
