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
	  LODSD                 ;DS:ESI--->EAX,ESI�Զ�����
	  STOSD                 ;EAX--->ES:EDI,EDI�Զ�����
	  CALL SHOWEAX_HEX_P
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
SETPAGE:
      XOR  EDX,EDX
      MOV  EAX,[MEMSIZE]
      MOV  EBX,400000H
      DIV  EBX
      MOV  ECX,EAX
      TEST EDX,EDX
      JZ   .NOREMAINDER
      INC  ECX
      .NOREMAINDER:
        PUSH ECX
      MOV  AX,SELECTORPAGEDIR
      MOV  ES,AX
      ;MOV  ECX,1024
      XOR  EDI,EDI
      XOR  EAX,EAX
      MOV  EAX,PAGETBLBASE1|PG_P|PG_USU|PG_RWW
      .PAGEDIRLOOP:
        STOSD
	ADD EAX,4096
	LOOP .PAGEDIRLOOP

      MOV  AX,SELECTORPAGETBL
      MOV  ES,AX
      POP  EAX
      MOV  EBX,1024
      MUL  EBX
      MOV  ECX,EAX
      ;MOV  ECX,1024*1024
      XOR  EDI,EDI
      XOR  EAX,EAX
      MOV  EAX,PG_P|PG_USU|PG_RWW
      .PAGETBLOOP:
        STOSD
	ADD EAX,4096
	LOOP .PAGETBLOOP

      MOV  EAX,PAGEDIRBASE1
      MOV  CR3,EAX
      MOV  EAX,CR0
      OR   EAX,80000000H
      MOV  CR0,EAX
      NOP
      NOP
      RET
SETPAGE2:
      XOR  EDX,EDX
      MOV  EAX,[MEMSIZE]
      MOV  EBX,400000H
      DIV  EBX
      MOV  ECX,EAX
      TEST EDX,EDX
      JZ   .NOREMAINDER
      INC  ECX
      .NOREMAINDER:
        MOV [PAGETABLENUMBER],ECX
        ;PUSH ECX
      MOV  AX,SELECTORFLATRW
      MOV  ES,AX
      ;MOV  ECX,1024
      ;XOR  EDI,EDI
      MOV  EDI,PAGEDIRBASE0
      XOR  EAX,EAX
      MOV  EAX,PAGETBLBASE0|PG_P|PG_USU|PG_RWW
      .PAGEDIRLOOP:
        STOSD
	ADD EAX,4096
	LOOP .PAGEDIRLOOP

      ;MOV  AX,SELECTORPAGETBL
      ;MOV  ES,AX
      ;POP  EAX
      MOV  EAX,[PAGETABLENUMBER]
      MOV  EBX,1024
      MUL  EBX
      MOV  ECX,EAX
      ;MOV  ECX,1024*1024
      ;XOR  EDI,EDI
      MOV  EDI,PAGETBLBASE0
      XOR  EAX,EAX
      MOV  EAX,PG_P|PG_USU|PG_RWW       ;��������ַ�У����Ե�ַ=������ַ
      .PAGETBLOOP:
        STOSD
	ADD EAX,4096
	LOOP .PAGETBLOOP

      MOV  EAX,PAGEDIRBASE0
      MOV  CR3,EAX
      MOV  EAX,CR0
      OR   EAX,80000000H
      MOV  CR0,EAX
      NOP
      NOP
      RET
MEMCPY:
      PUSH EBP
      MOV  EBP,ESP

      PUSH ESI
      PUSH EDI
      PUSH ECX

      MOV  EDI,[EBP + 8]  ;Destination
      MOV  ESI,[EBP + 12] ;Source
      MOV  ECX,[EBP + 16] ;Counter

      .MEMCPY1:
        CMP ECX,0         ;�жϼ�����
	JZ  .MEMCPY2      ;Ϊ0ʱ����

        ;���ֽ��ƶ�
	MOV AL,[DS:ESI]
	INC ESI
	MOV BYTE[ES:EDI],AL
	INC EDI

	DEC ECX           ;��������1
	JMP .MEMCPY1
      
      .MEMCPY2:
        MOV EAX,[EBP + 8] ;����ֵ

      POP ECX
      POP EDI
      POP ESI
      MOV ESP,EBP
      POP EBP
     
      RET

PAGINGDEMO:
      MOV  AX,CS
      MOV  DS,AX                          ;���ڶ����Ա���ɶ�(+R  DA_CR)����������������������Ų������:) 
                                          ;��ax��Ӧ��ѡ����������Ķ���������ϢҲ��ֵ��ds�мĴ��������Ĳ���?
      MOV  AX,SELECTORFLATRW
      MOV  ES,AX                          ;��ҳǰ�����Ե�ַ=������ַ������ֱ��д��

      PUSH LENFOO
      PUSH OFFSETFOO
      PUSH PROCFOO
      CALL MEMCPY
      ADD  ESP,12

      PUSH LENBAR
      PUSH OFFSETBAR
      PUSH PROCBAR
      CALL MEMCPY
      ADD  ESP,12

      PUSH LENPAGINGDEMOALL
      PUSH OFFSETPAGINGDEMOPROC
      PUSH PROCPAGINGDEMO
      CALL MEMCPY
      ADD  ESP,12

      MOV  AX,SELECTORDATA
      MOV  DS,AX
      MOV  ES,AX

      CALL SETPAGE2
      CALL SELECTORFLATC:PROCPAGINGDEMO
      CALL PSWITCH
      ;PSWITCH���ڷ�ҳ��ͨ�����㣬��LINEARADDRDEMO��Ӧ��������ַ���������
      ;ֱ�ӽ�PROCBAR�ĵ�ֵַд������Ե�ַλ��
      ;�򵥴ֱ�!!!
      CALL SELECTORFLATC:PROCPAGINGDEMO

      RET

PAGINGDEMOPROC:
OFFSETPAGINGDEMOPROC            EQU  PAGINGDEMOPROC - $$
      MOV  EAX,LINEARADDRDEMO
      CALL EAX
      RETF                                                         ;�Ƕ��ⲿ�������Ӷ�����ã�������retf
LENPAGINGDEMOALL                EQU  $ - PAGINGDEMOPROC

FOO:
OFFSETFOO                       EQU  FOO - $$
      MOV  AH,0CH
      MOV  AL,'F'
      MOV  [GS:((80*17 + 0)*2)],AX
      MOV  AL,'O'
      MOV  [GS:((80*17 + 1)*2)],AX
      MOV  [GS:((80*17 + 2)*2)],AX
      RET
LENFOO                          EQU  $ - FOO

BAR:
OFFSETBAR                       EQU  BAR - $$
      MOV  AH,0BH
      MOV  AL,'B'
      MOV  [GS:((80*18 + 0)*2)],AX
      MOV  AL,'A'
      MOV  [GS:((80*18 + 1)*2)],AX
      MOV  AL,'R'
      MOV  [GS:((80*18 + 2)*2)],AX
      RET
LENBAR                          EQU  $ - BAR

PSWITCH:
      ;��ʼ��ҳĿ¼
      MOV  AX,SELECTORFLATRW
      MOV  ES,AX
      MOV  EDI,PAGEDIRBASE1
      XOR  EAX,EAX
      MOV  EAX,PAGETBLBASE1|PG_P|PG_USU|PG_RWW
      MOV  ECX,[PAGETABLENUMBER]
      .PSWITCH1:
        STOSD
	ADD EAX,4096
	LOOP .PSWITCH1

      ;��ʼ��ҳ��
      MOV  EAX,[PAGETABLENUMBER]
      MOV  EBX,1024
      MUL  EBX
      MOV  ECX,EAX
      MOV  EDI,PAGETBLBASE1
      XOR  EAX,EAX
      MOV  EAX,PG_P|PG_USU|PG_RWW
      .PSWITCH2:
        STOSD
	ADD EAX,4096
	LOOP .PSWITCH2

      ;  ���Ե�ַ    10BIT      10BIT     12BIT
      ;        CR3-->PDE   ---> PTD   ---> P_ADDR      
      ;  CR3--------ͼ�����ʼλ��
      ;  PDE--------�鼮����---����¥�㣬��1024¥��ÿ¥ʹ��4��
      ;  PTD--------�鼮С��---�������䣬��1024�䣬ÿ��ʹ��4��
      ;  P_ADDR-----���˳��---�����ܺ�, ��1024*4=4K�ţ�ÿ��ʹ��4�У�Ĭ��ֵΪ0
      ;  ȫ����¼��һ��������

      MOV  EAX,LINEARADDRDEMO        ;������Ϊ���Ե�ַ
      SHR  EAX,22                    ;��ȡ¥���
      MOV  EBX,4096                  ;ÿ��¥ռ1024�䣨ÿ��ռ4�У�����ȡ¥���ڱ����ϵ���ʼλ��(��PTDλ������
      MUL  EBX                       ;ÿ��¥ռ1024�䣨ÿ��ռ4�У�����ȡ¥���ڱ����ϵ���ʼλ��(��PTDλ������
      MOV  ECX,EAX

      MOV  EAX,LINEARADDRDEMO        ;��ȡPTD���
      SHR  EAX,12                    ;��ȡPTD���
      AND  EAX,03FFH                 ;��ȡPTD���               
      MOV  EBX,4                     ;��ȡ���������кţ�ÿ��ռ4�У�,��¥��λ������
      MUL  EBX                       ;��ȡ���������кţ�ÿ��ռ4�У�,��¥��λ������
      ADD  EAX,ECX                   ;���к�λ�ü���¥��λ��
      ADD  EAX,PAGETBLBASE1          ;����ͼ�����ʼλ��
      ;���ϣ����ڷ�ҳ��ͨ�����㣬��LINEARADDRDEMO��Ӧ��������ַ���������
      ;��һ����ֱ�ӽ�PROCBAR�ĵ�ֵַд������Ե�ַλ��
      ;�򵥴ֱ�!!!
      PUSH EAX
      MOV  EAX,DWORD [ES:EAX]
      call SHOWEAX_HEX_P
      POP  EAX
      MOV  DWORD [ES:EAX],PROCBAR|PG_P|PG_USU|PG_RWW    
      MOV  EAX,DWORD [ES:EAX]
      CALL SHOWEAX_HEX_P
      

      MOV  EAX,PAGEDIRBASE1
      MOV  CR3,EAX
      NOP
      NOP

      RET