# Compilador - Grupo 13
- **Lexico.l:** implementación del analizador léxico.
- **Sintactico.y:** implementación del analizador sintáctico.
- **lista.h:** implementación de una lista enlazada, utilizada para manejar la tabla de símbolos.
- **strings.h:** funciones para el manejo de cadenas de caracteres.
- **codigo.analizar:** código de prueba para el compilador.

## Forma de uso
1.  Abrir una terminal en el directorio con los archivos anteriormente descriptos.
2. Ejecutar el comando ```flex Lexico.l```. Debería generarse el archivo "lex.yy.c".
3. Ejecutar el comando ```bison -d Sintactico.y```. Deberían generarse los archivos ```Sintactico.tab.c``` y ```Sintactico.tab.h```.
4. Ejectuar el comando ```gcc lex.yy.c Sintactico.tab.c -o Primera.exe```. Debería generarse el archivo ```Primera.exe```.
5. Ejecutar el comando ```Primera.exe "codigo.analizar"```. Debería generarse el archivo de la tabla de símbolos ```ts.txt```.
