SHOWSTR_P:
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
        SHOWCHAR_P
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
SHOWEAX_HEX_P:
      PUSH EAX
      PUSH EAX
      SHR  EAX,16
      CALL SHOWAX_HEX_P
      POP  EAX
      AND  EAX,0000FFFFH
      CALL SHOWAX_HEX_P
      MOV  AL,'H'
      SHOWCHAR_P
      MOV  AL,' '
      SHOWCHAR_P
      POP  EAX
      RET
DISPMEM_P:
      MOV  ECX,[MCRNUMBER]
      MOV  ESI,MEMCHKBUF
      CLD
      .DISPMEMLOOP:
        MOV  EDI,ARDSTRUCT
        MOV  EDX,5
        .ARDSTRUCTLOOP:
	  MOV  EAX, [ESI]
	  MOV  [EDI],EAX
	  CALL SHOWEAX_HEX_P
	  ADD  EDI,4
	  ADD  ESI,4
	  DEC  EDX
	  TEST EDX,EDX
	  JZ  .ARDSTRUCTLOOPOK
	  JMP .ARDSTRUCTLOOP
	.ARDSTRUCTLOOPOK:
	  NOP
	  CMP DWORD [ARDSTRUCTTYPE],1
	  JNE .CHANGELINE
	  MOV EAX,[BASEADDRLOW]
	  ADD EAX,[LENGTHLOW]
	  CMP EAX,[MEMSIZE]
	  JB  .CHANGELINE
	  MOV [MEMSIZE],EAX
        .CHANGELINE:
          SHOWRETURN_P
	LOOP  .DISPMEMLOOP
        MOV  EAX,[MEMSIZE]
	CALL SHOWEAX_HEX_P
	SHOWRETURN_P
      RET