flex Lexico.l
bison -d Sintactico.y
gcc lex.yy.c sintactico.tab.c utilidades/lista.c utilidades/arbol.c utilidades/pila.c utilidades/strings.c utilidades/assembler.c -o Grupo13.exe
del "lex.yy.c"
del "Sintactico.tab.c"
del "Sintactico.tab.h"
Grupo13.exe "prueba.txt"
PAUSE