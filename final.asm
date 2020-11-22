include macros2.asm
include number.asm

.MODEL LARGE
.386
.STACK 200h


.DATA
NEW_LINE DB 0AH, 0DH, '$'
_contador		dd	?
_promedio		dd	?
_actual		dd	?
_suma		dd	?
_nombre		dd	?
_80		dd	80.0
_str0		db	"Prueba.txt LyC Tema 4!", '$', 22 dup (?)
_str1		db	"Ingrese un valor entero: ", '$', 25 dup (?)
_0		dd	0.0
_2_5		dd	2.500000
_92		dd	92.0
_1		dd	1.0
_0_342		dd	0.342000
_255		dd	255.0
_52		dd	52.0
_4		dd	4.0
_str2		db	"La suma es: ", '$', 12 dup (?)
_2		dd	2.0
_str3		db	"actual es mayor que 2 y <> 0", '$', 28 dup (?)
_str4		db	"no es mayor que 2", '$', 17 dup (?)
@aux0	dd	?
@aux1	dd	?
@aux2	dd	?
@aux3	dd	?
@aux4	dd	?
@aux5	dd	?
@aux6	dd	?
@aux7	dd	?
@aux8	dd	?
@aux9	dd	?
@aux10	dd	?
@aux11	dd	?
@aux12	dd	?
@aux13	dd	?
@aux14	dd	?
@aux15	dd	?
@aux16	dd	?
@aux17	dd	?
@aux18	dd	?
@aux19	dd	?
@aux20	dd	?
@aux21	dd	?
@aux22	dd	?
@aux23	dd	?
@aux24	dd	?
@aux25	dd	?
@aux26	dd	?
@res_contar	dd	?
@contar_cont0	dd	?

.CODE
START:
	MOV EAX, @DATA
	MOV DS, EAX
	MOV ES, EAX
	FLD _0
	FST @contar_cont0
	FLD _80
	FST _nombre
	FST @aux1
	displayString _str0
	displayString NEW_LINE
	displayString _str1
	displayString NEW_LINE
	GetFloat _actual
	FLD _0
	FST _contador
	FST @aux2
	FLD _2_5
	FLD _nombre
	FADD
	FST @aux3
	FLD @aux3
	FST _suma
	FST @aux4
ini_while0:
cond0:
	FLD _contador
	FCOMP _92
	FSTSW AX
	SAHF
	JA end_cond0
	FLD _contador
	FLD _1
	FADD
	FST @aux5
	FLD @aux5
	FST _contador
	FST @aux6
	FLD _contador
	FLD _0_342
	FDIV
	FST @aux7
	FLD _actual
	FLD _contador
	FMUL
	FST @aux8
cond1:
	FLD @aux8
	FCOMP _4
	FSTSW AX
	SAHF
	JNE end_cond1
	FLD @contar_cont0
	FLD _1
	FADD
	FST @aux9
	FLD @aux9
	FST @contar_cont0
	FST @aux10
end_cond1:
	FLD _actual
	FLD _contador
	FMUL
	FST @aux11
cond2:
	FLD @aux11
	FCOMP _52
	FSTSW AX
	SAHF
	JNE end_cond2
	FLD @contar_cont0
	FLD _1
	FADD
	FST @aux12
	FLD @aux12
	FST @contar_cont0
	FST @aux13
end_cond2:
	FLD _actual
	FLD _contador
	FMUL
	FST @aux14
	FLD _nombre
	FLD _suma
	FMUL
	FST @aux15
cond3:
	FLD @aux14
	FCOMP @aux15
	FSTSW AX
	SAHF
	JNE end_cond3
	FLD @contar_cont0
	FLD _1
	FADD
	FST @aux16
	FLD @aux16
	FST @contar_cont0
	FST @aux17
end_cond3:
	FLD _actual
	FLD _contador
	FMUL
	FST @aux18
cond4:
	FLD @aux18
	FCOMP _255
	FSTSW AX
	SAHF
	JNE end_cond4
	FLD @contar_cont0
	FLD _1
	FADD
	FST @aux19
	FLD @aux19
	FST @contar_cont0
	FST @aux20
end_cond4:
	FLD @contar_cont0
	FST @res_contar
	FLD @contar_cont0
	FST @res_contar
	FLD @contar_cont0
	FST @res_contar
	FLD @contar_cont0
	FST @res_contar
	FST @aux21
	FLD _contador
	FLD @aux21
	FMUL
	FST @aux22
	FLD @aux7
	FLD @aux22
	FADD
	FST @aux23
	FLD @aux23
	FST _actual
	FST @aux24
	FLD _suma
	FLD _actual
	FADD
	FST @aux25
	FLD @aux25
	FST _suma
	FST @aux26
	JMP ini_while0
end_cond0:
	displayString _str2
	displayString NEW_LINE
	DisplayFloat _suma, 2
	displayString NEW_LINE
cond5:
	FLD _actual
	FCOMP _2
	FSTSW AX
	SAHF
	JBE end_cond5
cond6:
	FLD _actual
	FCOMP _0
	FSTSW AX
	SAHF
	JE end_cond6
	JMP then_part0
end_cond5:
end_cond6:
	JMP else_part0
then_part0:
	displayString _str3
	displayString NEW_LINE
	JMP end_if0
else_part0:
cond7:
	FLD _actual
	FCOMP _nombre
	FSTSW AX
	SAHF
	JAE end_cond7
	displayString _str4
	displayString NEW_LINE
end_cond7:
end_if0:
	MOV AX, 4C00H
	INT 21H
	END START
