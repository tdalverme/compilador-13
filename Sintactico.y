%{
    #include "utilidades/lista.h"
    #include "utilidades/arbol.h"
    #include <process.h>
    #include <stdio.h>
    
    FILE *yyin;
    FILE *dotFile;
    FILE *tsFile;

    int yylex();
    int _contar_cont;
    void yyerror(char const *);

    struct sNodo *_pivot, *A;
    Lista lista_id;
%}


    %union {
        int integer;
        char* string;
        struct sNodo* nodo;
        float flotante;
    }

    // TOKENS
    %token <string> T_STRING
    %token <string> T_CTE_STRING
    %token T_DIM
    %token T_AS
    %token T_CONST
    %token T_CONTAR
    %token T_WHILE
    %token T_IF
    %token T_ELSE
    %token T_PUT
    %token T_GET
    %token <string> T_ID
    %token T_INTEGER
    %token <integer> T_CTE_INT
    %token T_FLOAT
    %token <flotante> T_CTE_FLOAT
    %right T_ASIG
    %token <string> T_DISTINTO
    %token <string> T_IGUAL
    %token <string> T_NOT
    %token <string> T_COMA
    %token <string> T_MENORIGUAL
    %token <string> T_MENOR
    %token <string> T_MAYORIGUAL
    %token <string> T_MAYOR
    %token <string> T_AND
    %token <string> T_OR
    %left T_SUMA
    %left T_RESTA
    %left T_MULT
    %left T_DIV
    %right MENOS_UNARIO
    %token T_PYC
    %token T_LL_A
    %token T_LL_C
    %token T_PA_A
    %token T_PA_C
    %token T_COR_A
    %token T_COR_C

    %type <nodo> factor
    %type <nodo> termino
    %type <nodo> expresion
    %type <nodo> right_side
    %type <nodo> asignacion
    %type <nodo> sentencia
    %type <nodo> conj_sentencias
    %type <nodo> bloque
    %type <nodo> programa
    %type <nodo> put
    %type <nodo> get
    %type <nodo> valor_string
    %type <nodo> sentencia_if_else
    %type <nodo> sentencia_if
    %type <nodo> while_loop
    %type <nodo> condicion
    %type <nodo> condicion_comp
    %type <nodo> dec_const
    %type <nodo> valor_cte
    %type <nodo> contar
    %type <nodo> lista_exp
    %type <string> operador_condicional

    %start programa
%%
    // REGLAS
    programa : conj_sentencias { A = $$; }
    bloque : T_LL_A conj_sentencias T_LL_C {
        printf("Bloque\n");
        //BLOQUE = CONJ_SENT;
        $$ = $2;
    }
    conj_sentencias : conj_sentencias sentencia { $$ = crear_nodo("CONJ", $1, $2) } | conj_sentencias bloque { $$ = crear_nodo("BLOQUE", $1, $2) } | sentencia | bloque
    sentencia : asignacion | put | get | while_loop | sentencia_if_else | sentencia_if | dec_variables | dec_const
    

    // DECLARACION DE VARIABLES
    dec_variables : T_DIM T_MENOR lista_ids T_MAYOR T_AS T_MENOR lista_tipos T_MAYOR T_PYC {
        printf("\tDeclaracion de variables\n");
    }


    // DECLARACION CONSTANTES
    dec_const : T_CONST T_ID T_ASIG valor_cte T_PYC{
        printf("\tDeclaracion de constante\n");
        $$ = crear_nodo("ASIG_CTE", crear_hoja($2), $4);
        modificarTipo(&tabla_simbolos, $2, TS_INT);
        modificarValor(&tabla_simbolos, $2, $4->label);
    }
    valor_cte : T_CTE_FLOAT { 
        char label[128];
        snprintf(label, sizeof(label), "%g", $1);
        $$ = crear_hoja(label);
    }
    | T_CTE_INT {
        char label[5];
        itoa($1, label, 10);
        $$ = crear_hoja(label);
    }
    | T_CTE_STRING {
        $$ = crear_hoja($1);
    }


    // ASIGNACION
    asignacion : T_ID T_ASIG right_side T_PYC {
        printf("\tAsignacion\n");
        $$ = crear_nodo(":=", crear_hoja($<string>1), $3)
    }
    right_side : expresion { $$ = $1; } | T_CTE_STRING { $$ = crear_hoja($1); }


    // PUT
    put : T_PUT valor_string T_PYC {
        printf("\tSentencia PUT\n");
        $$ = crear_nodo("PRINT", $2, NULL);
    }
    valor_string : T_ID { $$ = crear_hoja($1); } | T_CTE_STRING { $$ = crear_hoja($1); }


    // GET
    get : T_GET T_ID T_PYC {
        printf("\tSentencia GET\n");
        $$ = crear_nodo("READ", crear_hoja($2), NULL);
    }


    // WHILE
    while_loop : T_WHILE T_PA_A condicion_comp T_PA_C bloque {
        printf("\tWhile loop\n");
        $$ = crear_nodo("WHILE", $3, $5);
    }
    

    // IF
    sentencia_if : T_IF T_PA_A condicion_comp T_PA_C bloque {
        printf("\tSentencia if\n");
        $$ = crear_nodo("IF", $3, $5);
    }
    sentencia_if : T_IF T_PA_A condicion_comp T_PA_C sentencia {
        printf("\tSentencia if unica sentencia\n");
        $$ = crear_nodo("IF", $3, $5);
    }

    // IF - ELSE
    sentencia_if_else : T_IF T_PA_A condicion_comp T_PA_C bloque T_ELSE bloque {
        printf("\tSentencia if-else\n");
        $$ = crear_nodo("IF", $3, crear_nodo("CUERPO", $5, $7));
    }    

    condicion_comp : condicion T_AND condicion { 
        $$ = crear_nodo("AND", $1, $3);
    }
    | condicion T_OR condicion {
        $$ = crear_nodo("OR", $1, $3);
    }
    | T_NOT condicion {
        $$ = crear_nodo("NOT", $2, NULL);
    }
    | condicion
    
    condicion : expresion operador_condicional expresion {
        $$ = crear_nodo($2, $1, $3);
    }
    operador_condicional : T_MAYOR | T_MENOR | T_MAYORIGUAL | T_MENORIGUAL | T_IGUAL | T_DISTINTO


    // EXPRESION
    expresion : expresion T_SUMA termino { 
        printf("\tSuma\n");
        $$ = crear_nodo("+", $1, $3);
    }
    expresion : expresion T_RESTA termino { 
        printf("\tResta\n");
        $$ = crear_nodo("-", $1, $3);
    }
    expresion : termino { 
        printf("\tTermino es expresion\n");
        $$ = $1;
    }


    // TERMINO
    termino : termino T_MULT factor { 
        printf("\tMultiplicacion\n");
        $$ = crear_nodo("*", $1, $3);
    }
    termino : termino T_DIV factor { 
        printf("\tDivision\n");
        $$ = crear_nodo("/", $1, $3);
    }
    termino : factor { 
        printf("\tFactor es termino\n");
        $$ = $1;
    }
    

    // FACTOR
    factor : T_PA_A expresion T_PA_C { 
        printf("\tExpresion entre parentesis\n");
        $$ = $2;
    }
    | T_ID {
        $$ = crear_hoja($1);
    }
    | T_CTE_INT {
        char label[5];
        itoa($1, label, 10);
        $$ = crear_hoja(label);
    }
    | T_CTE_FLOAT {
        char label[128];
        snprintf(label, sizeof(label), "%g", $1);
        $$ = crear_hoja(label);
    }
    | contar


    // CONTAR
    contar : T_CONTAR T_PA_A expresion { _pivot = $3; } T_PYC T_COR_A lista_exp T_COR_C T_PA_C {
        printf("\tFuncion contar\n");
        $$ = $7;
    }


    // LISTA DE EXPRESIONES
    lista_exp : lista_exp T_COMA expresion {
        $$ = crear_nodo("CONTAR", crear_nodo("IF", crear_nodo("==", _pivot, $3), crear_nodo(":=", crear_hoja("_contar_cont"), crear_nodo("+", crear_hoja("_contar_cont"), crear_hoja("1")))), $1);
    }
    | expresion { 
        $$ = crear_nodo("CONTAR", crear_nodo("IF", crear_nodo("==", _pivot, $1), crear_nodo(":=", crear_hoja("_contar_cont"), crear_nodo("+", crear_hoja("_contar_cont"), crear_hoja("1")))), NULL);
    }

    // LISTA DE IDS
    lista_ids : lista_ids T_COMA T_ID {
        DataTS newData;

        newData.nombre = $3;
        newData.tipo = -1;

        push(&lista_id, &newData);
    }
    | T_ID {
        if(lista_id.head == NULL) {
            init(&lista_id);
        } else {
            empty(&lista_id);
        }

        DataTS newData;

        newData.nombre = $1;
        newData.tipo = -1;

        push(&lista_id, &newData);
    }

    // LISTA DE TIPOS DE DATOS
    lista_tipos : lista_tipos T_COMA tipo | tipo
    tipo : T_INTEGER {
        DataTS actual = pop(&lista_id);
        modificarTipo(&tabla_simbolos, actual.nombre, TS_INT);
    }
    | T_FLOAT {
        DataTS actual = pop(&lista_id);
        modificarTipo(&tabla_simbolos, actual.nombre, TS_FLOAT);
    }
    | T_STRING {
        DataTS actual = pop(&lista_id);
        modificarTipo(&tabla_simbolos, actual.nombre, TS_STRING);
    }
%%

int main (int argc, char *argv[]) {
    
    if((yyin = fopen(argv[1], "rt")) == NULL) {
        fprintf(stderr, "\nNo se pudo abrir el archivo \'%s\'", argv[1]);
        return -1;
    } else {
        yyparse();
    }

    if((tsFile = fopen("ts.txt", "wt")) == NULL) {
        fprintf(stderr, "\nNo se pudo abrir el archivo \'ts.txt\'");
        return -2;
    } else {
        listaToFile(&tabla_simbolos, tsFile);
    }

    if((dotFile = fopen("./intermedia.dot", "wt")) == NULL) {
        fprintf(stderr, "\nNo se pudo abrir el archivo \'intermedia.dot\'");
        return -3;
    } else {
        escribirDotFile(dotFile, A, 0);
        fclose(dotFile);
        system("dot -Tpng \"intermedia.dot\" -o intermedia.png");
        system("del \"intermedia.dot\"");
    }

    fclose(yyin);
    return 1;     
}

void yyerror (char const *s) {
}