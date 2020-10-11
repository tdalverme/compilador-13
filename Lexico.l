%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "lista.h"
    #include "Sintactico.tab.h"
    #include "strings.h"

    #define MAX_CARACTERES_STRING 30
    #define ERROR_LEXICO -1
    
    #define TS_NOMBRE 0
    #define TS_TIPO 1
    #define TS_VALOR 2
    #define TS_LONGITUD 3
    
    #define TS_INT 4
    #define TS_FLOAT 5
    #define TS_STRING 6
    #define TS_ID 7

    FILE *yyin;
    FILE *fileTS;
    Lista tabla_simbolos;

    void escribirTablaSimbolos();
%}

%option noyywrap
%option caseless

DIGITO      [0-9]
LETRA       [a-zA-Z]
SIMBOLO     [;:,./[\]()&!¡#$%=?¿+\-_*<>]
ESPACIOS    [ \t\n\r]

CTE_STRING  \"({DIGITO}|{SIMBOLO}|{LETRA}|{ESPACIOS})*\"
CTE_INT     {DIGITO}+
CTE_FLOAT   ({DIGITO}+\.{DIGITO}*)|({DIGITO}*\.{DIGITO}+)
ID          {LETRA}(({LETRA}|{DIGITO}|_)*({LETRA}|{DIGITO}))*
COMENTARIO  \*-({DIGITO}|{SIMBOLO}|{LETRA}|{ESPACIOS})*-\*

%%

{COMENTARIO} {
    //printf("Comentario: %s\n\n", yytext);
}

{CTE_STRING} {
    if(strlen(yytext) > MAX_CARACTERES_STRING + 2) {
        fprintf(stderr, "ERROR: %s supera los %d caracteres.\n", yytext, MAX_CARACTERES_STRING);
        return ERROR_LEXICO;
    }

    if(tabla_simbolos.head == NULL) {
        init(&tabla_simbolos);
    }

    DataTS newData;

    newData.nombre = strdup(getNombreFormateado(yytext));
    newData.tipo = TS_STRING;
    newData.valor = strdup(yytext);
    newData.longitud = strlen(yytext);

    if(push(&tabla_simbolos, &newData) == 1) {
        escribirTablaSimbolos(*verUltimo(&tabla_simbolos));
    }

    return T_CTE_STRING;
}

":=" {
    return T_ASIG;
}

":" {
    return T_ASIG;
}

"=" {
    return T_ASIG;
}

"DIM" {
    //printf("Palabra reservada: %s\n\n", yytext);

    return T_DIM;
}

"AS" {
    //printf("Palabra reservada: %s\n\n", yytext);

    return T_AS;
}

"Integer" {
    //printf("Palabra reservada: %s\n\n", yytext);

    return T_INTEGER;
}

"Float" {
    //printf("Palabra reservada: %s\n\n", yytext);

    return T_FLOAT;
}

"String" {
    return T_STRING;
}

"CONST" {
    //printf("Palabra reservada: %s\n\n", yytext);

    return T_CONST;
}

"contar" {
    //printf("Palabra reservada: %s\n\n", yytext);

    return T_CONTAR;
}

"PUT" {
    //printf("Palabra reservada: %s\n\n", yytext);

    return T_PUT;
}

"GET" {
    //printf("Palabra reservada: %s\n\n", yytext);

    return T_GET;
}

"while" {
    //printf("Palabra reservada: %s\n\n", yytext);

    return T_WHILE;
}

"if" {
    //printf("Palabra reservada: %s\n\n", yytext);

    return T_IF;
}

"else" {
    //printf("Palabra reservada: %s\n\n", yytext);

    return T_ELSE;
}

"AND" {
    //printf("Operador AND: %s\n\n", yytext);
    
    return T_AND;
}

"OR" {
    //printf("Operador AND: %s\n\n", yytext);
    
    return T_OR;
}

{ID} {
    //printf("ID: %s\n\n", yytext);

    if(tabla_simbolos.head == NULL) {
        init(&tabla_simbolos);
    }

    DataTS newData;

    newData.nombre = strdup(getNombreFormateado(yytext));
    newData.tipo = TS_ID;
    newData.valor = NULL;
    newData.longitud = -1;

    if(push(&tabla_simbolos, &newData) == 1) {
        escribirTablaSimbolos(*verUltimo(&tabla_simbolos));
    }

    return T_ID;
}

{CTE_INT} {
    //printf("Constante entera: %s\n\n", yytext);

    if(tabla_simbolos.head == NULL) {
        init(&tabla_simbolos);
    }

    DataTS newData;

    newData.nombre = strdup(getNombreFormateado(yytext));
    newData.tipo = TS_INT;
    newData.valor = strdup(yytext);
    newData.longitud = -1;

    if(push(&tabla_simbolos, &newData) == 1) {
        escribirTablaSimbolos(*verUltimo(&tabla_simbolos));
    }

    yylval = atoi(yytext);

    return T_CTE_INT;
}

{CTE_FLOAT} {
    //printf("Constante flotante: %s\n\n", yytext);

    if(tabla_simbolos.head == NULL) {
        init(&tabla_simbolos);
    }

    DataTS newData;
    
    newData.nombre = strdup(getNombreFormateado(yytext));
    newData.tipo = TS_FLOAT;
    newData.valor = strdup(yytext);
    newData.longitud = -1;

    if(push(&tabla_simbolos, &newData) == 1) {
        escribirTablaSimbolos(*verUltimo(&tabla_simbolos));
    }

    yylval = atof(yytext);

    return T_CTE_FLOAT;
}

"<>" {
    //printf("Operador desigualdad: %s\n\n", yytext);

    return T_DISTINTO;
}

"==" {
    //printf("Operador igualdad: %s\n\n", yytext);
    
    return T_IGUAL;
}

"," {
    //printf("Coma: %s\n\n", yytext);

    return T_COMA;
}

"<=" {
    //printf("Operador menor o igual: %s\n\n", yytext);

    return T_MENORIGUAL;
}

"<" {
    //printf("Operador menor: %s\n\n", yytext);

    return T_MENOR;
}

">=" {
    //printf("Operador mayor o igual: %s\n\n", yytext);

    return T_MAYORIGUAL;
}

">" {
    //printf("Operador mayor: %s\n\n", yytext);
    
    return T_MAYOR;
}

"+" {
    //printf("Operador de suma: %s\n\n", yytext);

    return T_SUMA;
}

"-" {
    //printf("Operador de resta: %s\n\n", yytext);

    return T_RESTA;
}

"/" {
    //printf("Operador de division: %s\n\n", yytext);

    return T_DIV;
}

"*" {
    //printf("Operador de multiplicacion: %s\n\n", yytext);

    return T_MULT;
}

";" {
    //printf("Punto y coma: %s\n\n", yytext);

    return T_PYC;
}

"{" {
    //printf("Llave abierta: %s\n\n", yytext);
    
    return T_LL_A;
}

"}" {
    //printf("Llave cerrada: %s\n\n", yytext);

    return T_LL_C;
}

"(" {
    //printf("Parentesis abierto: %s\n\n", yytext);

    return T_PA_A;
}

")" {
    //printf("Parentesis cerrado: %s\n\n", yytext);

    return T_PA_C;
}

"[" {
    //printf("Corchete abierto: %s\n\n", yytext);

    return T_COR_A;
}

"]" {
    //printf("Corchete cerrado: %s\n\n", yytext);

    return T_COR_C;
}

"!" {
    return T_NOT;
}

[ \t\n] {}

. {
    //printf("Error lexico, caracter invalido: %s\n\n", yytext);
    return ERROR_LEXICO;
}
%%


/*
int main(int argc, char *argv[]) {
    
    tabla_simbolos.tabla = (FilaTS *)malloc(sizeof(struct FilaTS));

    if((yyin = fopen(argv[1], "rt")) == NULL) {
        fprintf(stderr, "\nNo se pudo abrir el archivo \'%s\'", argv[1]);
    } else {
        yylex();
                
        if((fileTS = fopen("ts.txt", "wt")) == NULL) {
            fprintf(stderr, "\nNo se pudo crear el archivo de la tabla de simbolos.");
        } else {
            escribirTablaSimbolos();
            fclose(fileTS);
        }
    }

    fclose(yyin);
    return 1;
}
*/

void escribirTablaSimbolos(DataTS data) {
    if(fileTS == NULL) {
        if((fileTS = fopen("ts.txt", "wt")) == NULL) {
            fprintf(stderr, "\nNo se pudo crear el archivo de la tabla de simbolos.");
            return;
        }
    }

    int tipo = data.tipo;

    if(tipo == TS_INT) {
        fprintf(fileTS, "%s, Integer, %s, %d\n", data.nombre, data.valor, data.longitud);
    } else if(tipo == TS_FLOAT) {
        fprintf(fileTS, "%s, Float, %s, %d\n", data.nombre, data.valor, data.longitud);
    } else if(tipo == TS_STRING) {
        fprintf(fileTS, "%s, String, %s, %d\n", data.nombre, data.valor, data.longitud);
    } else {
        fprintf(fileTS, "%s, --, --, %d\n", data.nombre, data.valor, data.longitud);
    }
}

