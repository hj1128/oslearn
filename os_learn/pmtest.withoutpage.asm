%INCLUDE "pm.inc"
%INCLUDE "lib_macro.inc"

  ORG  0100H
  JMP  LABEL_BEGIN

[SECTION .GDT]
    LABEL_GDT                :  Descriptor    0,                   0, 0
    LABEL_DESC_NORMAL        :  Descriptor    0,              0FFFFH, DA_DRW
    LABEL_DESC_VIDEO         :  Descriptor    0B8000H,        0FFFFH, DA_DRW          + DA_DPL3
    LABEL_DESC_DATA          :  Descriptor    0,         DATALEN - 1, DA_DRW          + DA_DPL3         
    LABEL_DESC_STACK         :  Descriptor    0,          TOPOFSTACK, DA_DRWA + DA_32
    LABEL_DESC_STACK3        :  Descriptor    0,         TOPOFSTACK3, DA_DRWA         + DA_DPL3
    LABEL_DESC_CODE32        :  Descriptor    0,       CODE32LEN - 1, DA_CR   + DA_32
    LABEL_DESC_P2R           :  Descriptor    0,              0FFFFH, DA_C
    LABEL_DESC_CGCODE        :  Descriptor    0,       CGCODELEN - 1, DA_C    + DA_32
    LABEL_DESC_CGATE         :  Gate   SELECTORCGCODE  ,      0,   0, DA_386CGate     + DA_DPL3
    LABEL_DESC_CODE3         :  Descriptor    0,        CODE3LEN - 1, DA_C    + DA_32 + DA_DPL3
    LABEL_DESC_LDT           :  Descriptor    0,          LDTLEN - 1, DA_LDT

    GDTLEN                      EQU  $ - LABEL_GDT
    GDTPTR                      DW   GDTLEN - 1
                                DD   0
    SELECTORNORMAL              EQU  LABEL_DESC_NORMAL   - LABEL_GDT
    SELECTORVIDEO               EQU  LABEL_DESC_VIDEO    - LABEL_GDT + SA_RPL3
    SELECTORDATA                EQU  LABEL_DESC_DATA     - LABEL_GDT
    SELECTORSTACK               EQU  LABEL_DESC_STACK    - LABEL_GDT
    SELECTORSTACK3              EQU  LABEL_DESC_STACK3   - LABEL_GDT + SA_RPL3
    SELECTORCODE32              EQU  LABEL_DESC_CODE32   - LABEL_GDT
    SELECTORP2R                 EQU  LABEL_DESC_P2R      - LABEL_GDT
    SELECTORCGCODE              EQU  LABEL_DESC_CGCODE   - LABEL_GDT
    SELECTORCGATE               EQU  LABEL_DESC_CGATE    - LABEL_GDT
    SELECTORCODE3               EQU  LABEL_DESC_CODE3    - LABEL_GDT + SA_RPL3
    SELECTORLDT                 EQU  LABEL_DESC_LDT      - LABEL_GDT
    ;END OF [SECTION .GDT]

[SECTION .LDT]
  ALIGN 32
    LABEL_LDT:
    LABEL_DESC_LCODE         :  Descriptor    0,    LCODELEN - 1, DA_C    + DA_32
    LDTLEN                      EQU  $ - LABEL_LDT
    SELECTORLCODE               EQU  LABEL_DESC_LCODE - LABEL_LDT + SA_TIL
  ;END OF [SECTION .LDT]

[SECTION .STACK]
  ALIGN 32
  [BITS 32]
  LABEL_STACK:
    TIMES 512                   DB   0
  TOPOFSTACK                    EQU  $ - LABEL_STACK - 1
  ;END OF [SECTION .STACK]

[SECTION .STACK3]
  ALIGN 32
  [BITS 32]
  LABEL_STACK3:
    TIMES 512                   DB   0
  TOPOFSTACK3                   EQU  $ - LABEL_STACK3 - 1
  ;END OF [SECTION .STACK3]

[SECTION .DATA]
  ALIGN 32
  [BITS 32]
    LABEL_DATA:
      _SPVALUEINREALMODE     :  DW   0
      _SHOWPOSITION          :  DD   (80*1+0)*2
      _REALMESSAGE           :  DB   "NOW IN REAL MODE!",0
      _PMMESSAGE             :  DB   "NOW IN PROTECT MODE!",0
      _MEMCHKBUF             :  TIMES 256  DB   0
      _MCRNUMBER             :  DD   0
      _MEMSIZE               :  DD   0
      _ARDSTRUCTINFO         :  DB   "BASEADDRL BASEADDRH  LENGTHL   LENGTHH  ARDSTYPE",0
      _ARDSTRUCT             :
        _BASEADDRL           :  DD   0
        _BASEADDRH           :  DD   0
        _LENGTHL             :  DD   0
        _LENGTHH             :  DD   0
        _ARDSTYPE            :  DD   0
      _PAGENUMBER            :  DD   0

      SHOWPOSITION              EQU  _SHOWPOSITION  - $$
      PMMESSAGE                 EQU  _PMMESSAGE     - $$
      MEMCHKBUF                 EQU  _MEMCHKBUF     - $$
      MCRNUMBER                 EQU  _MCRNUMBER     - $$
      MEMSIZE                   EQU  _MEMSIZE       - $$
      ARDSTRUCTINFO             EQU  _ARDSTRUCTINFO - $$
      ARDSTRUCT                 EQU  _ARDSTRUCT     - $$
        BASEADDRL               EQU  _BASEADDRL     - $$
        BASEADDRH               EQU  _BASEADDRH     - $$
        LENGTHL                 EQU  _LENGTHL       - $$
        LENGTHH                 EQU  _LENGTHH       - $$
        ARDSTYPE                EQU  _ARDSTYPE      - $$
      PAGENUMBER                EQU  _PAGENUMBER    - $$           
    DATALEN                     EQU  $ - LABEL_DATA
  ;END OF [SECTION .DATA]

[SECTION .REAL]
  [BITS 16]
  LABEL_BEGIN:
    MOV  AX,CS
    MOV  ES,AX
    MOV  DS,AX
    MOV  SS,AX
    MOV  SP,0100H
    MOV  [_SPVALUEINREALMODE],SP
    MOV  [LABEL_GOBACKTO_REAL + 3],AX

    MOV  AX,0B800H
    MOV  GS,AX
    SHOWCHAR      _SHOWPOSITION , 0AH           , 'R'
    SHOWRETURN    _SHOWPOSITION
    MEMCHK  _MEMCHKBUF, _MCRNUMBER

    INITDESC LABEL_DATA    , LABEL_DESC_DATA
    INITDESC LABEL_STACK   , LABEL_DESC_STACK
    INITDESC LABEL_STACK3  , LABEL_DESC_STACK3
    INITDESC LABEL_CODE32  , LABEL_DESC_CODE32
    INITDESC LABEL_P2R     , LABEL_DESC_P2R
    INITDESC LABEL_CGCODE  , LABEL_DESC_CGCODE
    INITDESC LABEL_CODE3   , LABEL_DESC_CODE3
    INITDESC LABEL_LDT     , LABEL_DESC_LDT
    INITDESC LABEL_LCODE   , LABEL_DESC_LCODE
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
    MOV  AX,CS
    MOV  DS,AX
    MOV  ES,AX
    MOV  SS,AX
    
    IN   AL,92H
    AND  AL,0FDH
    OUT  92H,AL
    STI
    MOV  AX,4C00H
    INT  21H
  ;END OF [SECTION .REAL]

[SECTION .CODE32]
  ALIGN 32
  [BITS 32]
    LABEL_CODE32:
      MOV  AX,SELECTORVIDEO
      MOV  GS,AX
      MOV  AX,SELECTORDATA
      MOV  DS,AX
      MOV  ES,AX
      DISPMEM_P     SHOWPOSITION, MEMCHKBUF, MCRNUMBER, MEMSIZE, ARDSTRUCT, ARDSTYPE, BASEADDRL, LENGTHL, ARDSTRUCTINFO, 0DH
      SHOWRETURN    SHOWPOSITION
      SHOWEAX_HEX_P SHOWPOSITION,[MEMSIZE],0CH
      SHOWCHAR      SHOWPOSITION, 0AH      , 'P'

      PUSH SELECTORSTACK3
      PUSH TOPOFSTACK3
      PUSH SELECTORCODE3
      PUSH 0
      RETF
    SHOWEAX_HEX_PROC_P:
      SHOWEAX_HEX_BASE
      RET
    CODE32LEN                   EQU  $ - LABEL_CODE32
  ;END OF [SECTION .CODE32]

[SECTION .CODE3]
  ALIGN 32
  [BITS 32]
    LABEL_CODE3:
      MOV  AX,SELECTORVIDEO
      MOV  GS,AX
      MOV  AX,SELECTORDATA
      MOV  DS,AX
      SHOWCHAR      SHOWPOSITION, 0AH      , '3'
      CALL SELECTORCGATE:0
    CODE3LEN                    EQU  $ - LABEL_CODE3
  ;END OF [SECTION .CODE3]

[SECTION .CGCODE]
  ALIGN 32
  [BITS 32]
    LABEL_CGCODE:
      MOV  AX,SELECTORVIDEO
      MOV  GS,AX
      MOV  AX,SELECTORDATA
      MOV  DS,AX
      SHOWCHAR      SHOWPOSITION, 0AH      , 'G'
      MOV  AX,SELECTORLDT
      LLDT AX
      JMP  SELECTORLCODE:0
    CGCODELEN                   EQU  $ - LABEL_CGCODE
  ;END OF [SECTION .CGCODE]

[SECTION .LCODE]
  ALIGN 32
  [BITS 32]
    LABEL_LCODE:
      MOV  AX,SELECTORVIDEO
      MOV  GS,AX
      MOV  AX,SELECTORDATA
      MOV  DS,AX
      SHOWCHAR      SHOWPOSITION, 0AH      , 'L'
      JMP  SELECTORP2R:0
    LCODELEN                    EQU  $ - LABEL_LCODE
  ;END OF [SECTION .LCODE]

[SECTION .P2R]
  ALIGN 32
  [BITS 16]
    LABEL_P2R:
      MOV  AX,SELECTORNORMAL
      MOV  DS,AX
      MOV  ES,AX
      MOV  SS,AX
      MOV  FS,AX

      MOV  EAX,CR0
      ;AND  AL,0FEH
      AND  EAX,7FFFFFFEH
      MOV  CR0,EAX

    LABEL_GOBACKTO_REAL:
      JMP  0:LABEL_REAL_ENTRY
  ;END OF [SECTION .P2R]
