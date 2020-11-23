%{
    #include <float.h>
    #include <errno.h>
    #include <string.h>
    #include <stdio.h>
    #include "utilidades/lista.h"
    #include "utilidades/strings.h"
    #include "Sintactico.tab.h"

    extern int errno;

    #define MAX_CARACTERES_STRING 30
    #define ERROR_LEXICO -1
    #define FUERA_DE_RANGO -2
    #define MIN_INT -32768
    #define MAX_INT 32767

    FILE *yyin;
    FILE *fileTS;

    extern Lista tabla_simbolos;

    int validarRangoInt(char *);
    int validarRangoFloat(char *);

    int esConst = 0;
    int stringCont = 0;
%}

%option noyywrap
%option caseless
%option yylineno

DIGITO      [0-9]
LETRA       [a-zA-Z]
SIMBOLO     [;:./[\]()&!¡#$%=?¿+\-_*<>]
ESPACIOS    [ \t\n\r]

CTE_STRING  \"({DIGITO}|{SIMBOLO}|{LETRA}|{ESPACIOS})*\"
CTE_INT     -?{DIGITO}+
CTE_FLOAT   ({DIGITO}+\.{DIGITO}*)|({DIGITO}*\.{DIGITO}+)
ID          {LETRA}(({LETRA}|{DIGITO}|_)*({LETRA}|{DIGITO}))*
COMENTARIO  \*-({DIGITO}|{SIMBOLO}|{LETRA}|{ESPACIOS})*-\*

%%

{COMENTARIO} {
    printf("Comentario: %s\n\n", yytext);
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

    char *valor = (char *)malloc(strlen("_str") + 4);
    snprintf(valor, strlen("_str") + 4, "_str%d", stringCont++);

    newData.nombre = (char *)malloc(strlen(valor) + 1);
    strcpy(newData.nombre, valor);
    
    newData.tipo = TS_STRING;
    
    newData.valor = (char *)malloc(strlen(yytext) - 1);
    strcpy(newData.valor, removeAll(yytext, '\"'));
    
    newData.longitud = strlen(newData.valor);
    push(&tabla_simbolos, &newData);

    yylval.string = (char *)malloc(strlen(valor) + 1);
    strcpy(yylval.string, valor);

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
    esConst = T_CONST;
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
    
    char *nombreFormateado = (char *)malloc(strlen(getNombreFormateado(yytext)) + 1);
    strcpy(nombreFormateado, getNombreFormateado(yytext));

    if(esConst == T_CONST) {
        newData.nombre = (char *)malloc(strlen(nombreFormateado) + 7);
        if(!strcpy(newData.nombre, "_CONST"))
            printf("NULL\n");
        
        esConst = 0;
    } else {
        newData.nombre = (char *)malloc(strlen(nombreFormateado) + 1);
        newData.nombre[0] = '\0';
    }

    strcat(newData.nombre, nombreFormateado);
    newData.tipo = TS_ID;
    newData.valor = (char *)malloc(2);
    strcpy(newData.valor, " ");
    newData.longitud = -1;
    
    if(!existe(&tabla_simbolos, newData.nombre)){
        push(&tabla_simbolos, &newData);
    }

    yylval.string = (char *)malloc(strlen(getNombreFormateado(yytext)) + 1);
    if(!strcpy(yylval.string, getNombreFormateado(yytext)))
        printf("NULL\n");
    
    return T_ID;
}

{CTE_INT} {
    //printf("Constante entera: %s\n\n", yytext);

    if(validarRangoInt(yytext) == FUERA_DE_RANGO) {
        printf("\nError lexico, entero fuera de rango [%d ; %d]: %s", MIN_INT, MAX_INT, yytext);
        return ERROR_LEXICO;
    }
    else {
        if(tabla_simbolos.head == NULL) {
            init(&tabla_simbolos);
        }
        
        DataTS newData;

        char *nombreFormateado = getNombreFormateado(yytext);
        
        newData.nombre = (char *)malloc(strlen(nombreFormateado) + 1);
        if(!strcpy(newData.nombre, nombreFormateado))
            printf("NULL\n");

        newData.tipo = TS_INT;

        newData.valor = (char *)malloc(strlen(yytext) + 1);
        if(!strcpy(newData.valor, yytext))
            printf("NULL\n");

        newData.longitud = -1;

        push(&tabla_simbolos, &newData);
        
        yylval.integer = atoi(yytext);
        return T_CTE_INT;
    }
}

{CTE_FLOAT} {
    //printf("Constante flotante: %s\n\n", yytext);
    if(validarRangoFloat(yytext) == FUERA_DE_RANGO) {
        printf("\nError lexico, numero flotante fuera de rango [-%g ; %g]: %s", FLT_MAX, FLT_MAX, yytext);
        return ERROR_LEXICO;
    }
    else {
        if(tabla_simbolos.head == NULL) {
            init(&tabla_simbolos);
        }

        DataTS newData;
        
        char label[128];
        snprintf(label, sizeof(label), "_%g", atof(yytext));

        newData.nombre = (char *)malloc(strlen(replaceAll(label, '.', '_')) + 1);
        if(!strcpy(newData.nombre, replaceAll(label, '.', '_')))
            printf("NULL\n");

        newData.tipo = TS_FLOAT;

        newData.valor = (char *)malloc(strlen(yytext) + 1);
        if(!strcpy(newData.valor, yytext))
            printf("NULL\n");

        newData.longitud = -1;

        push(&tabla_simbolos, &newData);

        yylval.flotante = atof(yytext);
        return T_CTE_FLOAT;
    }
}

"<>" {
    //printf("Operador desigualdad: %s\n\n", yytext);
    yylval.string = (char *)malloc(3);
    strcpy(yylval.string, "<>");
    return T_DISTINTO;
}

"==" {
    //printf("Operador igualdad: %s\n\n", yytext);
    yylval.string = (char *)malloc(3);
    strcpy(yylval.string, "==");
    return T_IGUAL;
}

"," {
    //printf("Coma: %s\n\n", yytext);
    return T_COMA;
}

"<=" {
    //printf("Operador menor o igual: %s\n\n", yytext);
    yylval.string = (char *)malloc(3);
    strcpy(yylval.string, "<=");
    return T_MENORIGUAL;
}

"<" {
    //printf("Operador menor: %s\n\n", yytext);
    yylval.string = (char *)malloc(2);
    strcpy(yylval.string, "<");
    return T_MENOR;
}

">=" {
    //printf("Operador mayor o igual: %s\n\n", yytext);
    yylval.string = (char *)malloc(3);
    strcpy(yylval.string, ">=");
    return T_MAYORIGUAL;
}

">" {
    //printf("Operador mayor: %s\n\n", yytext);
    yylval.string = (char *)malloc(2);
    strcpy(yylval.string, ">");
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
    printf("\nERROR LEXICO, CARACTER INVALIDO: %s\n\n", yytext);
    return T_ERROR_LEXICO;
}
%%

int validarRangoInt(char *num) {
    errno = 0;
    long int resultado = strtol(num, NULL, 10);
    
    if (errno) { 
        return FUERA_DE_RANGO;
    }
    else {
        if(resultado >= MIN_INT && resultado <= MAX_INT) {
            return 1;
        }
    }

    return FUERA_DE_RANGO;
}

int validarRangoFloat(char *num) {
    errno = 0;
    double resultado = strtod(num, NULL);
    
    if (errno) { 
        return FUERA_DE_RANGO;
    }
    else {
        if(resultado >= -FLT_MAX && resultado <= FLT_MAX) {
            return 1;
        }
    }

    return FUERA_DE_RANGO;
}