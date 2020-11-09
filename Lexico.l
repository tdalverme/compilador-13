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
    #define MIN_INT -256
    #define MAX_INT 255

    FILE *yyin;
    FILE *fileTS;
    Lista tabla_simbolos;

    int validarRangoInt(char *);
    int validarRangoFloat(char *);

    int esConst = 0;
%}

%option noyywrap
%option caseless

DIGITO      [0-9]
LETRA       [a-zA-Z]
SIMBOLO     [;:,./[\]()&!¡#$%=?¿+\-_*<>]
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

    newData.nombre = strdup(getNombreFormateado(yytext));
    newData.tipo = TS_STRING;
    newData.valor = strdup(yytext);
    newData.longitud = strlen(yytext);

    push(&tabla_simbolos, &newData);

    yylval.string = strdup(removeAll(yytext, '\"'));
    return T_CTE_STRING;
}

":=" {
    yylval.string = ":=";
    return T_ASIG;
}

":" {
    yylval.string = ":";
    return T_ASIG;
}

"=" {
    yylval.string = "=";
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
    yylval.string = "AND";
    return T_AND;
}

"OR" {
    //printf("Operador AND: %s\n\n", yytext);
    yylval.string = "OR";
    return T_OR;
}

{ID} {
    //printf("ID: %s\n\n", yytext);
    
    if(tabla_simbolos.head == NULL) {
        init(&tabla_simbolos);
    }

    DataTS newData;
    char *nombreFormateado = getNombreFormateado(yytext);

    if(esConst == T_CONST) {
        newData.nombre = (char *)malloc(strlen(nombreFormateado) + 7);
        strcpy(newData.nombre, "_CONST");
    } else {
        newData.nombre = (char *)malloc(strlen(nombreFormateado) + 1);
        newData.nombre[0] = '\0';
    }

    strcat(newData.nombre, nombreFormateado);
    newData.tipo = TS_ID;
    newData.valor = NULL;
    newData.longitud = -1;
    
    push(&tabla_simbolos, &newData);
    yylval.string = strdup(newData.nombre);
    
    return T_ID;
}

{CTE_INT} {
    //printf("Constante entera: %s\n\n", yytext);

    if(validarRangoInt(yytext) == FUERA_DE_RANGO) {
        printf("\nError lexico, entero fuera de rango [-256 ; 255]: %s", yytext);
        return ERROR_LEXICO;
    }
    else {
        if(tabla_simbolos.head == NULL) {
            init(&tabla_simbolos);
        }

        if(esConst == T_CONST) {
            esConst = 0;
        } else {
            DataTS newData;

            newData.nombre = strdup(getNombreFormateado(yytext));
            newData.tipo = TS_INT;
            newData.valor = strdup(yytext);
            newData.longitud = -1;

            push(&tabla_simbolos, &newData);
            esConst = 0;
        }
        
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
        
        newData.nombre = strdup(getNombreFormateado(yytext));
        newData.tipo = TS_FLOAT;
        newData.valor = strdup(yytext);
        newData.longitud = -1;

        push(&tabla_simbolos, &newData);

        yylval.flotante = atof(yytext);
        return T_CTE_FLOAT;
    }
}

"<>" {
    //printf("Operador desigualdad: %s\n\n", yytext);
    yylval.string = "<>";
    return T_DISTINTO;
}

"==" {
    //printf("Operador igualdad: %s\n\n", yytext);
    yylval.string = "==";
    return T_IGUAL;
}

"," {
    //printf("Coma: %s\n\n", yytext);
    yylval.string = ",";
    return T_COMA;
}

"<=" {
    //printf("Operador menor o igual: %s\n\n", yytext);
    yylval.string = "<=";
    return T_MENORIGUAL;
}

"<" {
    //printf("Operador menor: %s\n\n", yytext);
    yylval.string = "<";
    return T_MENOR;
}

">=" {
    //printf("Operador mayor o igual: %s\n\n", yytext);
    yylval.string = ">=";
    return T_MAYORIGUAL;
}

">" {
    //printf("Operador mayor: %s\n\n", yytext);
    yylval.string = ">";
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
    printf("\nError lexico, caracter invalido: %s\n\n", yytext);
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

int validarRangoInt(char *num) {
    errno = 0;
    long int resultado = strtol(num, NULL, 10);
    
    if (errno) { 
        return FUERA_DE_RANGO;
    }
    else {
        if(resultado >= -256 && resultado <= 255) {
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