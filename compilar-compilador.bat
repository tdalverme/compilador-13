flex Lexico.l
bison -d Sintactico.y
gcc lex.yy.c sintactico.tab.c utilidades/lista.c utilidades/arbol.c utilidades/strings.c -o Segunda.exe
del "lex.yy.c"
del "Sintactico.tab.c"
del "Sintactico.tab.h"
Segunda.exe "prueba.txt"
PAUSE