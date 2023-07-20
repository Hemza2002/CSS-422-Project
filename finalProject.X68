*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Assembly Avengers
* Date       :
* Description: 
*              
*              
*-----------------------------------------------------------
START    ORG    $1000
                  ; first instruction of program
    
     *----------Welcome Output----------*
        LEA     WELCOME,A1
        MOVE.B  #14,D0
        TRAP    #15  

     INCLUDE "I-O.x68"
     INCLUDE "Opcode.x68"
     INCLUDE "BinaryRefineryEA.x68"
            
            
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
DECODING_ERROR DS.B 1

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
     INCLUDE "demo_test.x68"


    END    START        ; last line of source
















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
