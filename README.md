# Compilador - Grupo 13
- **compilar-compilador.bat:** archivo batch que compila los archivos Flex y Bison, y genera el ejecutable "Segunda.exe".
- **Segunda.exe:** ejecutable de la segunda entrega.
- **Lexico.l:** implementación del analizador léxico.
- **Sintactico.y:** implementación del analizador sintáctico.
- **lista.h:** implementación de una lista enlazada, utilizada para manejar la tabla de símbolos.
- **lista.h:** implementación de un árbol binario, utilizado para generar el árbol sintáctico.
- **strings.h:** funciones para el manejo de cadenas de caracteres.
- **prueba.txt:** código de prueba para el compilador.

## Forma de uso
1. Ejecutar ```compilar-compilador.bat```. Debería generarse el compilador ```Segunda.exe```.
2. Ejecutar el comando ```Segunda.exe "prueba.txt"```. Debería generarse el archivo de la tabla de símbolos ```ts.txt``` y el archivo ```arbol.png``` con la representación gráfica del árbol sintáctico.
