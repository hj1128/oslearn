%INCLUDE "lib_macro.inc"

  ORG  0100H
  JMP  LABEL_BEGIN

    LABEL_BEGIN:
      INITREG

      MOV  AX,0B800H
      MOV  GS,AX
      MOV  AH,0CH
      MOV  AL,'R'
      MOV  EDI,(80*10+0)*2
      MOV  [GS:EDI],AX

      MOV  AX,4C00H
      INT  21H
