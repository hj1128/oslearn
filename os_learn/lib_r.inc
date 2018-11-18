SHOWAL_LOW_HEX:
      AND  AX,000FH
      CMP  AX,9
      JA   .ABOVE9
      ADD  AX,'0'
      JMP  .SHOWCHAR_HEX 
      .ABOVE9:
        SUB  AX,0AH
        ADD  AX,'A'
      .SHOWCHAR_HEX:
        SHOWCHAR
      RET


SHOWAL_HEX:
      PUSH AX
      SHR  AX,4
      CALL SHOWAL_LOW_HEX
      POP  AX
      CALL SHOWAL_LOW_HEX
      RET     

SHOWAX_HEX:
      PUSH AX
      SHR  AX,8
      CALL SHOWAL_HEX
      POP  AX
      AND  AX,00FFH
      CALL SHOWAL_HEX
      RET
