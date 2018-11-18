%INCLUDE "lib_macro.inc"
%INCLUDE "pm.inc"

  ORG  0100H
  JMP  LABEL_BEGIN
[SECTION .GDT]
  LABEL_GDT                  :  Descriptor    0,                 0, 0
  LABEL_DESC_NORMAL          :  Descriptor    0,            0FFFFH, DA_DRW
  LABEL_DESC_VIDEO           :  Descriptor    0B8000H,      0FFFFH, DA_DRW              + DA_DPL3  
  LABEL_DESC_DATA            :  Descriptor    0,       DATALEN - 1, DA_DRW              + DA_DPL3
  LABEL_DESC_STACK           :  Descriptor    0,        TOPOFSTACK, DA_DRWA     + DA_32
  LABEL_DESC_CODE32          :  Descriptor    0,     CODE32LEN - 1, DA_C        + DA_32
  LABEL_DESC_P2R             :  Descriptor    0,            0FFFFH, DA_C
  LABEL_DESC_CGCODE          :  Descriptor    0,     CGCODELEN - 1, DA_C        + DA_32
  LABEL_DESC_CGATE           :  Gate SELECTORCGCODE,    0,       0, DA_386CGate         + DA_DPL3
  LABEL_DESC_LDT             :  Descriptor    0,        LDTLEN - 1, DA_LDT
  LABEL_DESC_STACK3          :  Descriptor    0,       TOPOFSTACK3, DA_DRWA     + DA_32 + DA_DPL3
  LABEL_DESC_CODE3           :  Descriptor    0,      CODE3LEN - 1, DA_C        + DA_32 + DA_DPL3
  LABEL_DESC_TSS             :  Descriptor    0,        TSSLEN - 1, DA_386TSS
  
  GDTLEN                        EQU  $ - LABEL_GDT
  GDTPTR                        DW   GDTLEN - 1
                                DD   0
  SELECTORNORMAL                EQU  LABEL_DESC_NORMAL - LABEL_GDT
  SELECTORVIDEO                 EQU  LABEL_DESC_VIDEO  - LABEL_GDT
  SELECTORDATA                  EQU  LABEL_DESC_DATA   - LABEL_GDT  
  SELECTORSTACK                 EQU  LABEL_DESC_STACK  - LABEL_GDT
  SELECTORCODE32                EQU  LABEL_DESC_CODE32 - LABEL_GDT
  SELECTORP2R                   EQU  LABEL_DESC_P2R    - LABEL_GDT
  SELECTORCGCODE                EQU  LABEL_DESC_CGCODE - LABEL_GDT
  SELECTORCGATE                 EQU  LABEL_DESC_CGATE  - LABEL_GDT + SA_RPL3
  SELECTORLDT                   EQU  LABEL_DESC_LDT    - LABEL_GDT
  SELECTORSTACK3                EQU  LABEL_DESC_STACK3 - LABEL_GDT + SA_RPL3
  SELECTORCODE3                 EQU  LABEL_DESC_CODE3  - LABEL_GDT + SA_RPL3
  SELECTORTSS                   EQU  LABEL_DESC_TSS    - LABEL_GDT
;END OF [SECTION .GDT]

[SECTION .LDT]
  LABEL_LDT:
  LABEL_DESC_LCODE           :  Descriptor    0,      LCODELEN - 1, DA_C + DA_32
  LDTLEN                        EQU  $ - LABEL_LDT
  SELECTORLCODE                 EQU  LABEL_DESC_LCODE  - LABEL_LDT + SA_TIL
;END OF [SECTION .LDT]

[SECTION .DATA]
  LABEL_DATA:
    _PMMESSAGE               :  DB   "NOW IN PROTECT MODE!^-^",0
    _POSITION                :  DD   (80*7+0)*2
    _MEMCHKBUF               :  TIMES  256  DD  0
    _MCRNUMBER               :  DD   0
    _MEMSIZE                 :  DD   0
    _ARDSTRUCT               :
      _BASEADDRLOW           :  DD   0
      _BASEADDRHIGH          :  DD   0
      _LENGTHLOW             :  DD   0
      _LENGTHHIGH            :  DD   0
      _ARDSTRUCTTYPE         :  DD   0

    PMMESSAGE                   EQU  _PMMESSAGE     - $$
    POSITION                    EQU  _POSITION      - $$
    MEMCHKBUF                   EQU  _MEMCHKBUF     - $$
    MCRNUMBER                   EQU  _MCRNUMBER     - $$
    MEMSIZE                     EQU  _MEMSIZE       - $$
    ARDSTRUCT                   EQU  _ARDSTRUCT     - $$
      BASEADDRLOW               EQU  _BASEADDRLOW   - $$
      BASEADDRHIGH              EQU  _BASEADDRHIGH  - $$
      LENGTHLOW                 EQU  _LENGTHLOW     - $$
      LENGTHHIGH                EQU  _LENGTHHIGH    - $$
      ARDSTRUCTTYPE             EQU  _ARDSTRUCTTYPE - $$

  DATALEN                       EQU  $ - LABEL_DATA
;END OF [SECTION .DATA]

[SECTION .STACK]
ALIGN 32
  LABEL_STACK:
    TIMES   256                 DB   0
  TOPOFSTACK                    EQU  $ - LABEL_STACK - 1
;END OF [SECTION .STACK]

[SECTION .STACK3]
ALIGN 32
  LABEL_STACK3:
    TIMES   256                 DB   0
  TOPOFSTACK3                   EQU  $ - LABEL_STACK3 - 1
;END OF [SECTION .STACK3]

[SECTION .TSS]
  LABEL_TSS:
    DD    0
    DD    TOPOFSTACK
    DD    SELECTORSTACK
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DD    0
    DW    0
    DW    $ - LABEL_TSS + 2
    DD    0FFH
  TSSLEN                        EQU  $ - LABEL_TSS
;END OF [SECTION .TSS]

[SECTION .REAL]  
[BITS 16]
  LABEL_BEGIN:
    INITREG
    MOV  [LABEL_GOBACKTO_REAL + 3],AX
    MOV  AL,'R'
    SHOWCHAR
    SHOWRETURN

    CALL MEMCHK
    MOV  EAX,[_MCRNUMBER]
    SHOWEAX_HEX 
    SHOWRETURN

    INITDESC LABEL_DATA    , LABEL_DESC_DATA
    INITDESC LABEL_STACK   , LABEL_DESC_STACK
    INITDESC LABEL_CODE32  , LABEL_DESC_CODE32
    INITDESC LABEL_P2R     , LABEL_DESC_P2R
    INITDESC LABEL_CGCODE  , LABEL_DESC_CGCODE
    INITDESC LABEL_LDT     , LABEL_DESC_LDT
    INITDESC LABEL_LCODE   , LABEL_DESC_LCODE
    INITDESC LABEL_STACK3  , LABEL_DESC_STACK3
    INITDESC LABEL_CODE3   , LABEL_DESC_CODE3
    INITDESC LABEL_TSS     , LABEL_DESC_TSS

    INITGDT
      
    LGDT [GDTPTR]
     
    CLI
      
    IN   AL,92H
    OR   AL,2
    OUT  92H,AL
      
    MOV  EAX,CR0
    OR   EAX,1
    MOV  CR0,EAX
      
    JMP  DWORD SELECTORCODE32:0
  LABEL_REAL_ENTRY:
    INITREG
    IN   AL,92H
    AND  AL,0FDH
    OUT  92H,AL
      
    STI
       
    MOV  AX,4C00H
    INT  21H
  %INCLUDE "lib_r.inc"
;END OF [SECTION .REAL]      

[SECTION .CODE32]
[BITS 32]
  LABEL_CODE32:
    MOV  AX,SELECTORDATA
    MOV  DS,AX
    MOV  AX,SELECTORVIDEO
    MOV  GS,AX

    MOV  AH,0CH
    MOV  AL,'P'
    MOV  EDI,[POSITION]
    MOV  [GS:EDI],AX
    ADD  EDI,2
    MOV  [POSITION],EDI
    SHOWRETURN_P

    XOR  ESI,ESI
    MOV  ESI,PMMESSAGE
    CALL SHOWSTR_P
    SHOWRETURN_P
    
    ;MOV  EAX,01234ABCFH
    ;SHOWEAX_HEX_P
    CALL DISPMEM
    SHOWRETURN_P

    PUSH SELECTORSTACK3
    PUSH TOPOFSTACK3
    PUSH SELECTORCODE3
    PUSH 0
    RETF
  %INCLUDE "lib_p.inc"
  CODE32LEN                      EQU  $ - LABEL_CODE32
;END OF [SECTION .CODE32]  

[SECTION .CODE3]
[BITS 32]
  LABEL_CODE3:
    MOV  AX,SELECTORDATA
    MOV  DS,AX
    MOV  AX,SELECTORVIDEO
    MOV  GS,AX

    MOV  AH,0CH
    MOV  AL,'3'
    MOV  EDI,[POSITION]
    MOV  [GS:EDI],AX
    ADD  EDI,2
    MOV  [POSITION],EDI
    
    CALL SELECTORCGATE:0
  CODE3LEN                      EQU  $ - LABEL_CODE3
;END OF [SECTION .CODE3]

[SECTION .CGCODE]
[BITS 32]
  LABEL_CGCODE:
    MOV  AX,SELECTORDATA
    MOV  DS,AX
    MOV  AX,SELECTORVIDEO
    MOV  GS,AX

    MOV  AH,0CH
    MOV  AL,'G'
    MOV  EDI,[POSITION]
    MOV  [GS:EDI],AX
    ADD  EDI,2
    MOV  [POSITION],EDI
    
    MOV  AX,SELECTORLDT
    LLDT AX
    JMP  SELECTORLCODE:0
  CGCODELEN                     EQU  $ - LABEL_CGCODE
;END OF [SECTION .CGCODE]

[SECTION .LCODE]
[BITS 32]
  LABEL_LCODE:
    MOV  AX,SELECTORDATA
    MOV  DS,AX
    MOV  AX,SELECTORVIDEO
    MOV  GS,AX

    MOV  AH,0CH
    MOV  AL,'L'
    MOV  EDI,[POSITION]
    MOV  [GS:EDI],AX
    ADD  EDI,2
    MOV  [POSITION],EDI
    
    JMP  SELECTORP2R:0
  LCODELEN                      EQU  $ - LABEL_LCODE
;END OF [SECTION .LCODE]

[SECTION .P2R]
ALIGN 32
[BITS 16]
  LABEL_P2R:
    MOV  AX,SELECTORNORMAL
    MOV  ES,AX
    MOV  SS,AX
    MOV  DS,AX
    MOV  FS,AX

    MOV  EAX,CR0
    AND  AL,0FEH
    MOV  CR0,EAX
    
  LABEL_GOBACKTO_REAL:
    JMP  0:LABEL_REAL_ENTRY
;END OF [SECTION .P2R]        

    
