%{
    #include "utilidades/lista.h"
    #include "utilidades/strings.h"
    #include "utilidades/arbol.h"
    #include "utilidades/assembler.h"
    #include <process.h>
    #include <stdio.h>
    
    FILE *yyin;
    FILE *dotFile;
    FILE *tsFile;
    FILE *f_aux;

    int yylex();
    extern int _contar_cont;
    char contar[30];
    extern int yylineno;
    void yyerror(char const *);

    FILE *f_assembler;
    FILE *f_reglas;

    struct sNodo *_pivot, *A, *arbol_aux;
    Lista lista_id;
%}


    %union {
        int integer;
        char* string;
        struct sNodo* nodo;
        float flotante;
    }

    // TOKENS
    %token T_STRING
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
    %token T_NOT
    %token T_COMA
    %token <string> T_MENORIGUAL
    %token <string> T_MENOR
    %token <string> T_MAYORIGUAL
    %token <string> T_MAYOR
    %token T_AND
    %token T_OR
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
    %token T_ERROR_LEXICO

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
    %type <nodo> dec_variables
    %type <nodo> valor_cte
    %type <nodo> contar
    %type <nodo> lista_exp
    %type <nodo> lista_tipos
    %type <nodo> tipo
    %type <string> operador_condicional

    %start programa
%%
    // REGLAS
    programa : conj_sentencias { 
        fprintf(f_reglas, "Fin programa\n");
        A = $$;
        arbol_aux = copiarArbol(A);        

        if((dotFile = fopen("intermedia.dot", "wt")) == NULL) {
            fprintf(stderr, "\nNo se pudo abrir el archivo \'intermedia.dot\'");
            return -3;
        } else {
            printf("Generando imagen del arbol sintactico...\n");
            escribirDotFile(dotFile, A, 0);
            fclose(dotFile);
            system(".\\Graphviz\\bin\\dot.exe -Gcharset=latin1 -Tpng \"intermedia.dot\" -o intermedia.png");
            system("del \"intermedia.dot\"");
        }

        printf("Generando assembler...\n");
        generar_assembler(arbol_aux, f_aux, f_assembler);
    }
    bloque : T_LL_A conj_sentencias T_LL_C {
        fprintf(f_reglas, "Bloque\n");
        $$ = $2;
    }
    conj_sentencias : conj_sentencias sentencia { $$ = crear_nodo("CONJ", $1, $2);  } | conj_sentencias bloque { $$ = crear_nodo("BLOQUE", $1, $2); } | sentencia | bloque
    sentencia : asignacion | put | get | while_loop | sentencia_if_else | sentencia_if | dec_variables | dec_const | error { yyerror("Error sintactico"); YYABORT; }
    

    // DECLARACION DE VARIABLES
    dec_variables : T_DIM T_MENOR lista_ids T_MAYOR T_AS T_MENOR lista_tipos T_MAYOR T_PYC {
        fprintf(f_reglas, "\tDeclaracion de variables\n");
        $$ = $7;
        free($2);
        free($4);
        free($6);
        free($8);
    }


    // DECLARACION CONSTANTES
    dec_const : T_CONST T_ID T_ASIG valor_cte T_PYC {
        fprintf(f_reglas, "\tDeclaracion de constante\n");
        $$ = crear_nodo("ASIG_CTE", crear_hoja($2), $4);
        
        char label[50] = "_CONST";
        strcat(label, $2);

        modificarTipo(&tabla_simbolos, label, TS_ID_INT);
        modificarValor(&tabla_simbolos, label, $4->label + 1);
        free($2);
    }
    valor_cte : T_CTE_FLOAT { 
        char label[128];
        snprintf(label, sizeof(label), "_%g", $1);
        $$ = crear_hoja(replaceAll(label, '.', '_'));
    }
    | T_CTE_INT {
        char label[10];
        itoa($1, label, 10);
        $$ = crear_hoja(getNombreFormateado(label));
    }
    | T_CTE_STRING {
        $$ = crear_hoja($1);
        free($1);
    }


    // ASIGNACION
    asignacion : T_ID T_ASIG right_side T_PYC {
        fprintf(f_reglas, "\tAsignacion\n");

        if(esConstante($1)) {
            fprintf(stderr, "No se puede asignar a una constante.\n");
            yyerror("Error sintactico");

            YYABORT;
        }

        if(!asignacionCompatible($1, $3->label)) {
            fprintf(stderr, "Los tipos de los operandos no son compatibles.\n");
            yyerror("Error sintactico");

            YYABORT;
        }

        $$ = crear_nodo(":=", crear_hoja($1), $3);

        free($1);
    }
    right_side : expresion { $$ = $1; }
    | T_CTE_STRING { 
        $$ = crear_hoja($1);
        free($1);
    }


    // PUT
    put : T_PUT valor_string T_PYC {
        fprintf(f_reglas, "\tSentencia PUT\n");
        
        switch(getTipo(&tabla_simbolos, $2->label)) {
            case TS_ID_INT:
                $$ = crear_nodo("PRINT_INT", $2, NULL);
                break;

            case TS_ID_FLOAT:
                $$ = crear_nodo("PRINT_FT", $2, NULL);
                break;

            case TS_STRING:
                $$ = crear_nodo("PRINT_ST", $2, NULL);
                break;
            
            case -1:
                printf("\nError: no se encontro el tipo de \'%s\' en la tabla de simbolos.\n", $2->label);
                break;
        }
    }
    valor_string : T_ID { $$ = crear_hoja($1); free($1); }
    | T_CTE_STRING {
        $$ = crear_hoja($1);
        free($1);
    }


    // GET
    get : T_GET T_ID T_PYC {
        fprintf(f_reglas, "\tSentencia GET\n");

        switch(getTipo(&tabla_simbolos, $2)) {
            case TS_ID_INT:
                $$ = crear_nodo("READ_INT", crear_hoja($2), NULL);
                break;

            case TS_ID_FLOAT:
                $$ = crear_nodo("READ_FT", crear_hoja($2), NULL);
                break;

            case TS_ID_STRING:
                $$ = crear_nodo("READ_ST", crear_hoja($2), NULL);
                break;
            
            case -1:
                printf("\nError: no se encontro el tipo de \'%s\' en la tabla de simbolos.\n", $2);
                break;
        }

        
        free($2);
    }


    // WHILE
    while_loop : T_WHILE T_PA_A condicion_comp T_PA_C bloque {
        fprintf(f_reglas, "\tWhile loop\n");
        $$ = crear_nodo("WHILE", $3, $5);
    }
    

    // IF
    sentencia_if : T_IF T_PA_A condicion_comp T_PA_C bloque {
        fprintf(f_reglas, "\tSentencia if\n");
        $$ = crear_nodo("IF", $3, $5);
    }
    sentencia_if : T_IF T_PA_A condicion_comp T_PA_C sentencia {
        fprintf(f_reglas, "\tSentencia if unica sentencia\n");
        $$ = crear_nodo("IF", $3, $5);
    }

    // IF - ELSE
    sentencia_if_else : T_IF T_PA_A condicion_comp T_PA_C bloque T_ELSE bloque {
        fprintf(f_reglas, "\tSentencia if-else\n");
        $$ = crear_nodo("IF-ELSE", $3, crear_nodo("CUERPO", $5, $7));
    }    

    condicion_comp : condicion T_AND condicion {
        fprintf(f_reglas, "\tCondicion AND\n"); 
        $$ = crear_nodo("AND", $1, $3);
    }
    | condicion T_OR condicion {
        fprintf(f_reglas, "\tCondicion OR\n");
        $$ = crear_nodo("OR", $1, $3);
    }
    | T_NOT condicion {
        fprintf(f_reglas, "\tCondicion NOT\n");
        $$ = crear_nodo("NOT", NULL, $2);
    }
    | condicion
    
    condicion : expresion operador_condicional expresion {
        fprintf(f_reglas, "\tCondicion\n");
        if(!tiposCompatibles($1->label, $3->label)) {
            fprintf(stderr, "Los tipos de los operandos no son comparables.\n");
            yyerror("Error sintactico");

            YYABORT;
        }

        $$ = crear_nodo($2, $1, $3);
        free($2);
    }
    operador_condicional : T_MAYOR | T_MENOR | T_MAYORIGUAL | T_MENORIGUAL | T_IGUAL | T_DISTINTO


    // EXPRESION
    expresion : expresion T_SUMA termino { 
        fprintf(f_reglas, "\tSuma\n");
        if(!tiposCompatibles($1->label, $3->label)) {
            fprintf(stderr, "Los tipos de los operandos no son compatibles con la suma.\n");
            yyerror("Error sintactico");

            YYABORT;
        }

        $$ = crear_nodo("+", $1, $3);
    }
    expresion : expresion T_RESTA termino { 
        fprintf(f_reglas, "\tResta\n");
        if(!tiposCompatibles($1->label, $3->label)) {
            fprintf(stderr, "Los tipos de los operandos no son compatibles con la resta.\n");
            yyerror("Error sintactico");

            YYABORT;
        }

        $$ = crear_nodo("-", $1, $3);
    }
    expresion : termino { 
        fprintf(f_reglas, "\tTermino es expresion\n");
        $$ = $1;
    }


    // TERMINO
    termino : termino T_MULT factor { 
        fprintf(f_reglas, "\tMultiplicacion\n");
        if(!tiposCompatibles($1->label, $3->label)) {
            fprintf(stderr, "Los tipos de los operandos no son compatibles con la multiplicacion.\n");
            yyerror("Error sintactico");

            YYABORT;
        }

        $$ = crear_nodo("*", $1, $3);
    }
    termino : termino T_DIV factor { 
        fprintf(f_reglas, "\tDivision\n");
        if(!tiposCompatibles($1->label, $3->label)) {
            fprintf(stderr, "Los tipos de los operandos no son compatibles con la division.\n");
            yyerror("Error sintactico");

            YYABORT;
        }

        $$ = crear_nodo("/", $1, $3);
    }
    termino : factor { 
        fprintf(f_reglas, "\tFactor es termino\n");
        $$ = $1;
    }
    

    // FACTOR
    factor : T_PA_A expresion T_PA_C { 
        fprintf(f_reglas, "\tExpresion entre parentesis\n");
        $$ = $2;
    }
    | T_ID {
        fprintf(f_reglas, "\tID es factor\n");
        $$ = crear_hoja($1);
        free($1);
    }
    | T_CTE_INT {
        fprintf(f_reglas, "\tInt es factor\n");
        char label[5];
        itoa($1, label, 10);
        $$ = crear_hoja(getNombreFormateado(label));
    }
    | T_CTE_FLOAT {
        fprintf(f_reglas, "\tFloat es factor\n");
        char label[128];
        snprintf(label, sizeof(label), "_%g", $1);
        $$ = crear_hoja(replaceAll(label, '.', '_'));
    }
    | contar


    // CONTAR
    contar : T_CONTAR T_PA_A expresion { _pivot = $3; } T_PYC T_COR_A lista_exp T_COR_C T_PA_C {
        fprintf(f_reglas, "\tFuncion contar\n");
        $$ = crear_nodo("CONTAR_INI", NULL, $7);
    }


    // LISTA DE EXPRESIONES
    lista_exp : lista_exp T_COMA expresion {
        fprintf(f_reglas, "\tLista de expresiones\n");
        $$ = crear_nodo("CONTAR", crear_nodo("IF", crear_nodo("==", _pivot, $3), crear_nodo(":=", crear_hoja(contar), crear_nodo("+", crear_hoja(contar), crear_hoja("_1")))), $1);
    }
    | expresion {
        fprintf(f_reglas, "\tLista de expresiones\n"); 
        snprintf(contar, sizeof(contar), "@contar_cont%d", _contar_cont++);
        $$ = crear_nodo("CONTAR", crear_nodo("IF", crear_nodo("==", _pivot, $1), crear_nodo(":=", crear_hoja(contar), crear_nodo("+", crear_hoja(contar), crear_hoja("_1")))), NULL);
    }

    // LISTA DE IDS
    lista_ids : lista_ids T_COMA T_ID {
        fprintf(f_reglas, "\tLista de IDs\n"); 
        DataTS newData;

        newData.nombre = (char *)malloc(strlen($3) + 1);
        strcpy(newData.nombre, $3);
        newData.valor = (char *)malloc(1);
        strcpy(newData.valor, "");
        newData.tipo = -1;

        push(&lista_id, &newData);
        free($3);
    }
    | T_ID {
        fprintf(f_reglas, "\tLista de IDs\n"); 
        if(lista_id.head == NULL) {
            init(&lista_id);
        } else {
            empty(&lista_id);
        }

        DataTS newData;

        newData.nombre = (char *)malloc(strlen($1) + 1);
        newData.valor = (char *)malloc(1);
        strcpy(newData.valor, "");
        strcpy(newData.nombre, $1);
        newData.tipo = -1;

        push(&lista_id, &newData);
        free($1);
    }

    // LISTA DE TIPOS DE DATOS
    lista_tipos : lista_tipos T_COMA tipo {
        fprintf(f_reglas, "\tLista de tipos\n"); 
        $$ = crear_nodo("DEC", $3, $1);
    } 
    | tipo
    tipo : T_INTEGER {
        DataTS actual = pop(&lista_id);
        $$ = crear_nodo("->", crear_hoja(actual.nombre), crear_hoja("Integer"));
        modificarTipo(&tabla_simbolos, actual.nombre, TS_ID_INT);
    }
    | T_FLOAT {
        DataTS actual = pop(&lista_id);
        $$ = crear_nodo("->", crear_hoja(actual.nombre), crear_hoja("Float"));
        modificarTipo(&tabla_simbolos, actual.nombre, TS_ID_FLOAT);
    }
    | T_STRING {
        DataTS actual = pop(&lista_id);
        $$ = crear_nodo("->", crear_hoja(actual.nombre), crear_hoja("String"));
        modificarTipo(&tabla_simbolos, actual.nombre, TS_ID_STRING);
    }
%%

int main (int argc, char *argv[]) {
    if((yyin = fopen(argv[1], "rt")) == NULL) {
        fprintf(stderr, "\nNo se pudo abrir el archivo \'%s\'", argv[1]);
        return -1;
    } else {
        if((f_aux = fopen("assembler_aux.asm", "w+")) == NULL)  {
            fprintf(stderr, "\nNo se pudo abrir el archivo \'aux.asm\'");
            return -1;
        } 

        if((f_assembler = fopen("Final.asm", "w")) == NULL) {
            fprintf(stderr, "\nNo se pudo abrir el archivo \'Final.asm\'");
            return -1;
        }
        
        if((f_reglas = fopen("reglas.txt", "wt")) == NULL) {
            fprintf(stderr, "\nNo se pudo abrir el archivo \'reglas.txt\'");
            return -1;
        }

        printf("Parseando...\n");

        if(yyparse() == 1) {
            fclose(f_assembler);
            fclose(f_reglas);
            return -1;
        }
    }

    if((tsFile = fopen("ts.txt", "wt")) == NULL) {
        fprintf(stderr, "\nNo se pudo abrir el archivo \'ts.txt\'");
        return -2;
    } else {
        printf("Escribiendo tabla de simbolos a archivo...\n");
        listaToFile(&tabla_simbolos, tsFile);
    }

    fclose(yyin);
    fclose(f_assembler);
    fclose(f_reglas);
    fclose(tsFile);
    fclose(f_assembler);
    
    freeLista(&lista_id);
    freeLista(&tabla_simbolos);
    freeArbol(A);
    freeArbol(arbol_aux);
    free(_pivot);

    FILE *f = fopen("aaaaaaaaaaaa.txt", "w");

    fprintf(f, "Hola");

    return 1;
}

void yyerror(char const *s) {
    if(strcmp("syntax error", s) != 0) {
        fprintf(stderr, "\nERROR SINTACTICO, LINEA: %d\n", yylineno);
    }
}