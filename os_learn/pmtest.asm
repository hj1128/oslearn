  ORG  0100H
  JMP  LABEL_BEGIN

%MACRO SHOWCHAR 3               ;使用方法 SHOWCHAR    显示位置，颜色，字符
    MOV  EDI,[%1]
    MOV  AH,%2
    MOV  AL,%3
    MOV  [GS:EDI],AX
    ADD  EDI,2
    MOV  [%1],EDI
%ENDMACRO
%MACRO SHOWSTR 3                ;使用方法 SHOWSTR     显示位置，颜色，字符串位置
    MOV  ESI,%3
    MOV  EDI,[%1]
    MOV  AH,%2
    .SHOWSTRLOOP:
      LODSB
      TEST  AL,AL
      JZ    .SHOWSTROK
      MOV  [GS:EDI],AX
      ADD  EDI,2
      JMP  .SHOWSTRLOOP
    .SHOWSTROK:
      MOV  [%1],EDI
%ENDMACRO
%MACRO SHOWRETURN 1             ;使用方法 SHOWRETURN  显示位置
    MOV  EAX,[%1]
    MOV  BL,160
    DIV  BL
    AND  EAX,0FFH
    INC  EAX
    MOV  BL,160
    MUL  BL
    MOV  [%1],EAX
%ENDMACRO
%MACRO MEMCHK 2                 ;使用方法 MEMCHK      存储缓冲位置，内存段数量
    MOV  EBX,0
    MOV  ECX,20
    MOV  DI,%1
    .MEMCHKLOOP:
      MOV  EAX,0E820H
      MOV  EDX,534D4150H
      INT  15H
      JC   .MEMCHKFAIL
      ADD  DI,20
      INC  DWORD [%2]
      CMP  EBX,0
      JZ   .MEMCHKOK
      JMP  .MEMCHKLOOP
      .MEMCHKFAIL:
        MOV  DWORD [%2],0
      .MEMCHKOK:
        NOP
%ENDMACRO
%MACRO DISPMEM 10
;使用方法 DISPMEM  显示位置     ,存储缓冲位置，内存段数量,内存大小, 内存范围描述符结构, ARDS类型  , 基础地址低位, 长度低位, 标题栏        , 颜色        
;使用方法 DISPMEM  _SHOWPOSITION,_MEMCHKBUF  , _MCRNUMBER,_MEMSIZE, _ARDSTRUCT        , _ARDSTYPE , _BASEADDRL  , _LENGTHL, _ARDSTURCTINFO, 0CH
    MOV  ESI,%9
    MOV  EDI,[%1]
    MOV  AH,%10
    .SHOWARDSINFOLOOP:
      LODSB
      TEST  AL,AL
      JZ    .SHOWARDSINFOK
      MOV  [GS:EDI],AX
      ADD  EDI,2
      JMP  .SHOWARDSINFOLOOP
    .SHOWARDSINFOK:
      MOV  [%1],EDI
    SHOWRETURN    %1

    MOV  ESI,%2
    MOV  ECX,[%3]
    CLD
    .DISPMEMLOOP:
      MOV  EDX,5
      MOV  EDI,%5
      .ARDSLOOP:
        LODSD
        STOSD
        SHOWEAX_HEX  %1,EAX,%10
	DEC  EDX
	CMP  EDX,0
	JNE  .ARDSLOOP
        CMP  DWORD [%6],1
        JNE  .SHOWRETURN_ARDS
	MOV  EAX,[%7]
	ADD  EAX,[%8]
	CMP  EAX,[%4]
	JB   .SHOWRETURN_ARDS
	MOV  [%4],EAX
	.SHOWRETURN_ARDS:
	  SHOWRETURN %1
    LOOP .DISPMEMLOOP
    SHOWEAX_HEX  %1,[%4],%10
%ENDMACRO
%MACRO SHOWEAX_HEX_BASE 0       ;使用时需预先设置好EAX,EDI,AH(使用DH来中转)
  PUSH ECX
  MOV  ECX,8
  .EAXLOOP:
    PUSH EAX
    AND  EAX,0F0000000H
    SHR  EAX,28
    AND  EAX,0FH
    CMP  AL,9
    JA   .ABOVE
    ADD  AL,'0'
    JMP  .SHOWAL
    .ABOVE:
      SUB  AL,0AH
      ADD  AL,'A'
    .SHOWAL:
      ;MOV  AH,0CH
      MOV  AH,DH
      MOV  [GS:EDI],AX
      ADD  EDI,2
    POP  EAX
    SHL  EAX,4
  LOOP  .EAXLOOP
  ;MOV  AH,0CH
  MOV  AH,DH
  MOV  AL,'H'
  MOV  [GS:EDI],AX
  ADD  EDI,4
  POP  ECX
%ENDMACRO
%MACRO SHOWEAX_HEX 3            ;使用方法  SHOWEAX_HEX  显示位置，EAX值   
    PUSH EAX                    ;同时要保持原有现场的EDI，以及EAX
    PUSH EDI
    MOV  EDI,[%1]
    MOV  EAX,%2
    PUSH EDX
    MOV  DH,%3
    CALL SHOWEAX_HEX_PROC       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;在保护模式下,或者说不同段内，是否可以使用同名过程？
    POP  EDX
    MOV  [%1],EDI
    POP  EDI
    POP  EAX
%ENDMACRO

  _SPVALUEINREALMODE         :  DW   0
  _SHOWPOSITION              :  DD   (80*10+0)*2
  _REALMESSAGE               :  DB   "NOW IN REAL MODE!",0
  _MEMCHKBUF                 :  TIMES 256  DB   0
  _MCRNUMBER                 :  DD   0
  _MEMSIZE                   :  DD   0
  _ARDSTRUCTINFO             :  DB   "BASEADDRL BASEADDRH  LENGTHL   LENGTHH  ARDSTYPE",0
  _ARDSTRUCT                 :
    _BASEADDRL               :  DD   0
    _BASEADDRH               :  DD   0
    _LENGTHL                 :  DD   0
    _LENGTHH                 :  DD   0
    _ARDSTYPE                :  DD   0

  SHOWPOSITION                  EQU  _SHOWPOSITION  - $$
  MEMCHKBUF                     EQU  _MEMCHKBUF     - $$
  MCRNUMBER                     EQU  _MCRNUMBER     - $$
  MEMSIZE                       EQU  _MEMSIZE       - $$
  ARDSTRUCTINFO                 EQU  _ARDSTRUCTINFO - $$
  ARDSTRUCT                     EQU  _ARDSTRUCT     - $$
    BASEADDRL                   EQU  _BASEADDRL     - $$
    BASEADDRH                   EQU  _BASEADDRH     - $$
    LENGTHL                     EQU  _LENGTHL       - $$
    LENGTHH                     EQU  _LENGTHH       - $$
    ARDSTYPE                    EQU  _ARDSTYPE      - $$

  LABEL_BEGIN:
    MOV  AX,CS
    MOV  ES,AX
    MOV  DS,AX
    MOV  SS,AX
    MOV  SP,0100H
    MOV  [_SPVALUEINREALMODE],SP

    MOV  AX,0B800H
    MOV  GS,AX
    
    SHOWCHAR      _SHOWPOSITION , 0AH           , 'R'
    SHOWRETURN    _SHOWPOSITION
    SHOWSTR       _SHOWPOSITION , 0BH           , _REALMESSAGE
    SHOWRETURN    _SHOWPOSITION

    MEMCHK        _MEMCHKBUF    , _MCRNUMBER
    SHOWEAX_HEX   _SHOWPOSITION , [_MCRNUMBER],0CH
    SHOWRETURN    _SHOWPOSITION
    DISPMEM       _SHOWPOSITION , _MEMCHKBUF,_MCRNUMBER,_MEMSIZE,_ARDSTRUCT,_ARDSTYPE,_BASEADDRL,_LENGTHL,_ARDSTRUCTINFO,0DH
    SHOWRETURN    _SHOWPOSITION


    MOV  AX,4C00H
    INT  21H

SHOWEAX_HEX_PROC:
  SHOWEAX_HEX_BASE
  RET