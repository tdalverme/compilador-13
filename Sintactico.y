%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "Sintactico.tab.h"
    
    FILE *yyin;

    int yylex();
    void yyerror(char const *);
%}

    // TOKENS
    %token T_STRING
    %token T_DIM
    %token T_AS
    %token T_CONST
    %token T_CONTAR
    %token T_WHILE
    %token T_IF
    %token T_ELSE
    %token T_PUT
    %token T_GET
    %token T_ID
    %token T_INTEGER
    %token T_CTE_INT
    %token T_FLOAT
    %token T_CTE_FLOAT
    %right T_ASIG
    %token T_DISTINTO
    %token T_IGUAL
    %token T_COMA
    %token T_MENORIGUAL
    %token T_MENOR
    %token T_MAYORIGUAL
    %token T_MAYOR
    %token T_AND
    %token T_OR
    %left T_SUMA
    %left T_RESTA
    %left T_MULT
    %left T_DIV
    %token T_PYC
    %token T_LL_A
    %token T_LL_C
    %token T_PA_A
    %token T_PA_C
    %token T_COR_A
    %token T_COR_C

    %start programa
%%
    // REGLAS
    programa : conj_sentencias
    bloque : T_LL_A conj_sentencias T_LL_C {
        printf("Bloque\n");
    }
    conj_sentencias : conj_sentencias sentencia | conj_sentencias bloque | sentencia | bloque
    sentencia : asignacion | put | get | while_loop | sentencia_if | sentencia_else | dec_variables | dec_const
    

    // DECLARACION DE VARIABLES
    dec_variables : T_DIM T_MENOR lista_ids T_MAYOR T_AS T_MENOR lista_tipos T_MAYOR T_PYC {
        printf("\tDeclaracion de variables\n");
    }


    // DECLARACION CONSTANTES
    dec_const : T_CONST T_ID T_ASIG valor_cte T_PYC{
        printf("\tDeclaracion de constante\n");
    }
    valor_cte : T_CTE_FLOAT | T_CTE_INT | T_STRING


    // ASIGNACION
    asignacion : left_side T_ASIG right_side T_PYC {
        printf("\tAsignacion\n");
    }
    left_side : T_ID
    right_side : expresion


    // PUT
    put : T_PUT valor_string T_PYC {
        printf("\tPut\n");
    }
    valor_string : T_ID | T_STRING


    // GET
    get : T_GET T_ID T_PYC {
        printf("\tGet\n");
    }


    // WHILE
    while_loop : T_WHILE T_PA_A condicion_comp T_PA_C bloque {
        printf("\tWhile loop\n");
    }
    

    // IF
    sentencia_if : T_IF T_PA_A condicion_comp T_PA_C bloque {
        printf("\tSentencia if\n")
    }
    sentencia_if : T_IF T_PA_A condicion_comp T_PA_C sentencia {
        printf("\tSentencia if unica sentencia\n")
    }


    // ELSE
    sentencia_else : T_ELSE bloque {
        printf("\tSentencia else\n")
    }

    condicion_comp : condicion T_AND condicion | condicion T_OR condicion | condicion
    condicion : expresion operador_condicional expresion
    operador_condicional : T_MAYOR | T_MENOR | T_MAYORIGUAL | T_MENORIGUAL | T_IGUAL | T_DISTINTO


    // EXPRESIONES
    expresion : expresion T_SUMA termino { 
        $$ = $1 + $3;
        printf("\tSuma\n");
    }
    expresion : expresion T_RESTA termino { 
        $$ = $1 - $3;
        printf("\tResta\n");
    }
    expresion : termino
    termino : termino T_MULT factor { 
        $$ = $1 * $3;
        printf("\tMultiplicacion\n");
    }
    termino : termino T_DIV factor { 
        //$$ = $1 / $3;
        printf("\tDivision\n");
    }
    termino : factor
    factor : T_PA_A expresion T_PA_C { 
        $$ = $2;
    }
    factor : T_ID | T_CTE_INT | T_CTE_FLOAT | contar


    // CONTAR
    contar : T_CONTAR T_PA_A expresion T_PYC T_COR_A lista_exp T_COR_C T_PA_C {
        printf("\tContar\n");
    }


    // LISTA
    lista_exp : lista_exp T_COMA expresion | expresion

    lista_ids : lista_ids T_COMA T_ID | T_ID

    lista_tipos : lista_tipos T_COMA tipo | tipo
    tipo : T_INTEGER | T_FLOAT
%%

int main (int argc, char *argv[]) {
    
    if((yyin = fopen(argv[1], "rt")) == NULL) {
        fprintf(stderr, "\nNo se pudo abrir el archivo \'%s\'", argv[1]);
    } else {
        yyparse();
    }

    fclose(yyin);
    return 1;     
}

void yyerror (char const *s) {
    fprintf (stderr, "%s\n", s);
}