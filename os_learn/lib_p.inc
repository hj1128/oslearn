SHOWCHAR_P:
      PUSH AX
      MOV  AX,SELECTORVIDEO
      MOV  GS,AX
      MOV  AX,SELECTORDATA
      MOV  DS,AX
      POP  AX
      MOV  AH,0AH
      MOV  EDI,[POSITION]
      MOV  [GS:EDI],AX
      ADD  EDI,2
      MOV  [POSITION],EDI
      RET
SHOWAL_LOW_HEX_P:
      AND  AX,000FH
      CMP  AX,9
      JA   .ABOVE9
      ADD  AX,'0'
      JMP  .SHOWCHAR_HEX_P
      .ABOVE9:
        SUB  AX,0AH
        ADD  AX,'A'
      .SHOWCHAR_HEX_P:
        CALL SHOWCHAR_P
      RET

SHOWAL_HEX_P:
      PUSH AX
      SHR  AX,4
      CALL SHOWAL_LOW_HEX_P
      POP  AX
      CALL SHOWAL_LOW_HEX_P
      RET     

SHOWAX_HEX_P:
      PUSH AX
      SHR  AX,8
      CALL SHOWAL_HEX_P
      POP  AX
      AND  AX,00FFH
      CALL SHOWAL_HEX_P
      RET
SHOWSTR_P:
      XOR  EAX,EAX
      XOR  EDI,EDI
      MOV  AH,0AH
      MOV  EDI,[POSITION]
      CLD
      .STRLOOP:
        LODSB
        TEST AL,AL
        JZ   .STREND
        MOV  [GS:EDI],AX
        ADD  EDI,2
        JMP  .STRLOOP
      .STREND:
        MOV  [POSITION],EDI
      RET
DISPMEM:
      MOV  ECX,[MCRNUMBER]
      MOV  ESI,MEMCHKBUF
      .DISPMEMLOOP:
        MOV  EDI,ARDSTRUCT
        MOV  EDX,5
        .ARDSTRUCTLOOP:
          LODSD                 ;ESI�Զ�����
          SHOWEAX_HEX_P
	  STOSD                 ;EDI�Զ�����
	  ;SHOWEAX_HEX_P
	  mov eax,edi
	  SHOWEAX_HEX_P
	  DEC EDX
	  TEST EDX,EDX
	  JZ  .ARDSTRUCTLOOPOK
	  JMP .ARDSTRUCTLOOP
	.ARDSTRUCTLOOPOK:
	  NOP
	SHOWRETURN_P
	LOOP  .DISPMEMLOOP
      RET