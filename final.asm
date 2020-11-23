include macros2.asm
include number.asm

.MODEL LARGE
.386
.STACK 200h


.DATA
NEW_LINE DB 0AH, 0DH, '$'
_contador       dd  ?
_promedio       dd  ?
_actual     dd  ?
_suma       dd  ?
_0      dd  0.0
_1      dd  1.0
_2      dd  2.0
_3      dd  3.0
_str0       db  "hola", '$', 4 dup (?)
@aux0   dd  ?
@aux1   dd  ?
@aux2   dd  ?
@aux3   dd  ?
@aux4   dd  ?
@aux5   dd  ?
@res_contar dd  ?

.CODE
START:
    MOV EAX, @DATA
    MOV DS, EAX
    MOV ES, EAX
    FLD _0
    FST _suma
    FST @aux1
    FLD _2
    FST _contador
    FST @aux2
    FLD _2
    FST _promedio
    FST @aux3
cond0:
    FLD _contador
    FCOMP _promedio
    FSTSW AX
    SAHF
    JAE end_cond0
ini_while0:
cond1:
    FLD _suma
    FCOMP _3
    FSTSW AX
    SAHF
    JAE end_cond1
cond2:
    FLD _contador
    FCOMP _2
    FSTSW AX
    SAHF
    JNE end_cond2
    displayString _str0
    displayString NEW_LINE
end_cond2:
    FLD _suma
    FLD _1
    FADD
    FST @aux4
    FLD @aux4
    FST _suma
    FST @aux5
    JMP ini_while0
end_cond1:
end_cond0:
    MOV AX, 4C00H
    INT 21H
    END START
