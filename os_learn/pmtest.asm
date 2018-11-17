%INCLUDE "lib_macro.inc"

  ORG  0100H
  JMP  LABEL_BEGIN

  _POSITION                   :  DD   (80*10+0)*2
  
  POSITION                       EQU  _POSITION - $$
  
    LABEL_BEGIN:
      INITREG

      MOV  AL,'R'
      SHOWCHAR
      MOV  AL,'s'
      SHOWCHAR

      MOV  AX,0abcdH
      SHOWAX_HEX
      
      MOV  AX,4C00H
      INT  21H
    %INCLUDE "lib_r.inc"
      
    
