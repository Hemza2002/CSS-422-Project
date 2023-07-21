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
            CLR.B OP_ERROR
            CLR.B EA_ERROR    
        
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
            CMP.B #0, OP_ERROR
            BNE INVALID_OPCODE
            
            *IF EA IS INVALID 
            CMP.B #0, EA_ERROR
            BNE INVALID_EFFADD
        
            *PRINT THE RESULT BUFFER        
            MOVE.L #RESULT, A1
            MOVE.B #13, D0
            TRAP #15
    
            BRA CONTINUE
        
INVALID_OPCODE  
            *IF OPCODE IS INVALID PRINT ERROR MESSAGE
            MOVE.L  #INVALID_OP, A1
            MOVE.B  #13, D0
            TRAP    #15
            BRA     CONTINUE
            
INVALID_EFFADD  
            *IF OPCODE IS INVALID PRINT ERROR MESSAGE
            MOVE.L  #INVALID_EA, A1
            MOVE.B  #13, D0
            TRAP    #15 
            BRA     CONTINUE
                                         
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














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
