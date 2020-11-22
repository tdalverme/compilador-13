#include "assembler.h"
#include "strings.h"
#include "pila.h"

int cond_cont = 0;
int else_cont = 0;
int while_cont = 0;
int guardar_resultado = 0;
int i = 1;
int not = 0;
int _contar_cont = 0;
int contar_actual = 0;

FILE *f_aux;
st *stCond;
st *stElse;
st *stWhile;
st *stOpLog;

extern Lista tabla_simbolos;

void generar_assembler(Node *a, FILE *f_aux, FILE *f) {
    Node *masIzqCon2Hijos = NULL;
    
    stCond = (st *)malloc(sizeof(st));
    stElse = (st *)malloc(sizeof(st));
    stWhile = (st *)malloc(sizeof(st));
    stOpLog = (st *)malloc(sizeof(st));
    createEmptyStack(stCond);
    createEmptyStack(stElse);
    createEmptyStack(stWhile);
    createEmptyStack(stOpLog);

    while(masIzqCon2Hijos != getSubarbolMasIzq(a, f_aux)) {
        masIzqCon2Hijos = getSubarbolMasIzq(a, f_aux);

        generar_codigo(masIzqCon2Hijos, f_aux);
        
        free(masIzqCon2Hijos->izq);
        free(masIzqCon2Hijos->der);

        masIzqCon2Hijos->izq = NULL;
        masIzqCon2Hijos->der = NULL;

        free(masIzqCon2Hijos->label);

        masIzqCon2Hijos->label = (char *)malloc(strlen("@aux") + 4);
        snprintf(masIzqCon2Hijos->label, strlen("@aux") + 4, "@aux%d", i);
        
        if(guardar_resultado) {
            fprintf(f_aux, "\tFST %s\n", masIzqCon2Hijos->label);
            guardar_resultado = 0;
            i++;
        }

    }

    generar_codigo_inicial(f);
    generar_codigo_data(f);
    rewind(f_aux);
    copiar_arch(f_aux, f);
    generar_codigo_final(f);

    fclose(f_aux);
    remove("assembler_aux.asm");
}

void copiar_arch(FILE *origen, FILE *dest) {
    char str[200];
    
    while(fgets(str, sizeof(str), origen)) {
        fprintf(dest, "%s", str);
    }
}

void generar_codigo_inicial(FILE *f) {
    fprintf(f, "include macros2.asm\n");
    fprintf(f, "include number.asm\n\n");
    fprintf(f, ".MODEL LARGE\n");
    fprintf(f, ".386\n");
    fprintf(f, ".STACK 200h\n\n");
}

void generar_codigo_final(FILE *f) {
    fprintf(f, "\tMOV AX, 4C00H\n");
    fprintf(f, "\tINT 21H\n");
    fprintf(f, "\tEND START\n");
}


void generar_codigo_data(FILE *f) {
    fprintf(f, "\n.DATA\n");
    fprintf(f, "NEW_LINE DB 0AH, 0DH, '$'\n");

    if(!existe(&tabla_simbolos, "_1")) {
        fprintf(f, "_1\t\tdd\t1.0\n");
    }
    
    if(!existe(&tabla_simbolos, "_0")) {
        fprintf(f, "_0\t\tdd\t0.0\n");
    }

    Nodo *actual = tabla_simbolos.head;

    while (actual != NULL) {
        DataTS data = actual->data;

        if(data.tipo == TS_ID_FLOAT || data.tipo == TS_ID_INT) {
            if(strstr(data.nombre, "_CONST")) {
                fprintf(f, "%s\t\tdd\t?\n", data.nombre + 6);
            } else {
                fprintf(f, "%s\t\tdd\t?\n", data.nombre);
            }
        } else if(data.tipo == TS_ID_STRING) {
            fprintf(f, "%s\t\tdb\t?\n", data.nombre);
        } else if(data.tipo == TS_INT) {
            fprintf(f, "%s\t\tdd\t%d.0\n", data.nombre, atoi(data.valor));
        } else if(data.tipo == TS_FLOAT) {
            fprintf(f, "%s\t\tdd\t%f\n", replaceAll(data.nombre, '.', '_'), atof(data.valor));
        } else {
            fprintf(f, "%s\t\tdb\t\"%s\", \'$\', %d dup (?)\n", data.nombre, data.valor, data.longitud);
        }
        
        actual = actual->sig;
    }

    for (int cont = 0; cont < i; cont++) {
        fprintf(f, "@aux%d\tdd\t?\n", cont);
    }

    fprintf(f, "@res_contar\tdd\t?\n");

    for (int cont = 0; cont < _contar_cont; cont++) {
        fprintf(f, "@contar_cont%d\tdd\t?\n", cont);
    }

    fprintf(f, "\n.CODE\n");
    fprintf(f, "START:\n");
    fprintf(f, "\tMOV EAX, @DATA\n");
    fprintf(f, "\tMOV DS, EAX\n");
    fprintf(f, "\tMOV ES, EAX\n");
    for (int cont = 0; cont < _contar_cont; cont++) {
        fprintf(f, "\tFLD _0\n");
        fprintf(f, "\tFST @contar_cont%d\n", cont);
    }
}

void generar_codigo(Node *n, FILE *f) {
    if(strcmp(n->label, "+") == 0) {
        fprintf(f, "\tFLD %s\n", n->izq->label);
        fprintf(f, "\tFLD %s\n", n->der->label);
        fprintf(f, "\tFADD\n");
        guardar_resultado = 1;
    }

    else if(strcmp(n->label, "-") == 0) {
        fprintf(f, "\tFLD %s\n", n->izq->label);
        fprintf(f, "\tFLD %s\n", n->der->label);
        fprintf(f, "\tFSUB\n");
        guardar_resultado = 1;
    }

    else if(strcmp(n->label, "/") == 0) {
        fprintf(f, "\tFLD %s\n", n->izq->label);
        fprintf(f, "\tFLD %s\n", n->der->label);
        fprintf(f, "\tFDIV\n");
        guardar_resultado = 1;
    }

    else if(strcmp(n->label, "*") == 0) {
        fprintf(f, "\tFLD %s\n", n->izq->label);
        fprintf(f, "\tFLD %s\n", n->der->label);
        fprintf(f, "\tFMUL\n");
        guardar_resultado = 1;
    }

    else if(strcmp(n->label, ":=") == 0 || strcmp(n->label, "ASIG_CTE") == 0) {
        fprintf(f, "\tFLD %s\n", n->der->label);
        fprintf(f, "\tFST %s\n", n->izq->label);
        guardar_resultado = 1;
    }

    else if(strcmp(n->label, "ASIG_CTE") == 0) {
        fprintf(f, "\tFLD %s\n", n->der->label);
        fprintf(f, "\tFST %s\n", n->izq->label);
    }

    else if(strcmp(n->label, "<=") == 0) {
        fprintf(f, "cond%d:\n", cond_cont);
        fprintf(f, "\tFLD %s\n", n->izq->label);
        fprintf(f, "\tFCOMP %s\n", n->der->label);
        fprintf(f, "\tFSTSW AX\n");
        fprintf(f, "\tSAHF\n");

        if(not) {
            fprintf(f, "\tJBE end_cond%d\n", cond_cont);
            not = 0;
        }
        else
            fprintf(f, "\tJA end_cond%d\n", cond_cont);
        pushStack(stCond, cond_cont++);
        pushStack(stOpLog, 1);
    }

    else if(strcmp(n->label, "<") == 0) {
        fprintf(f, "cond%d:\n", cond_cont);
        fprintf(f, "\tFLD %s\n", n->izq->label);
        fprintf(f, "\tFCOMP %s\n", n->der->label);
        fprintf(f, "\tFSTSW AX\n");
        fprintf(f, "\tSAHF\n");

        if(not) {
            fprintf(f, "\tJB end_cond%d\n", cond_cont);
            not = 0;
        }
        else
            fprintf(f, "\tJAE end_cond%d\n", cond_cont);
        pushStack(stCond, cond_cont++);
        pushStack(stOpLog, 1);
    }

    else if(strcmp(n->label, ">=") == 0) {
        fprintf(f, "cond%d:\n", cond_cont);
        fprintf(f, "\tFLD %s\n", n->izq->label);
        fprintf(f, "\tFCOMP %s\n", n->der->label);
        fprintf(f, "\tFSTSW AX\n");
        fprintf(f, "\tSAHF\n");

        if(not) {
            fprintf(f, "\tJAE end_cond%d\n", cond_cont);
            not = 0;
        }
        else
            fprintf(f, "\tJB end_cond%d\n", cond_cont);
        pushStack(stCond, cond_cont++);
        pushStack(stOpLog, 1);
    }

    else if(strcmp(n->label, ">") == 0) {
        fprintf(f, "cond%d:\n", cond_cont);
        fprintf(f, "\tFLD %s\n", n->izq->label);
        fprintf(f, "\tFCOMP %s\n", n->der->label);
        fprintf(f, "\tFSTSW AX\n");
        fprintf(f, "\tSAHF\n");

        if(not) {
            fprintf(f, "\tJA end_cond%d\n", cond_cont);
            not = 0;
        }
        else
            fprintf(f, "\tJBE end_cond%d\n", cond_cont);
        pushStack(stCond, cond_cont++);
        pushStack(stOpLog, 1);
    }

    else if(strcmp(n->label, "<>") == 0) {
        fprintf(f, "cond%d:\n", cond_cont);
        fprintf(f, "\tFLD %s\n", n->izq->label);
        fprintf(f, "\tFCOMP %s\n", n->der->label);
        fprintf(f, "\tFSTSW AX\n");
        fprintf(f, "\tSAHF\n");

        if(not) {
            fprintf(f, "\tJNE end_cond%d\n", cond_cont);
            not = 0;
        }
        else
            fprintf(f, "\tJE end_cond%d\n", cond_cont);
        pushStack(stCond, cond_cont++);
        pushStack(stOpLog, 1);
    }

    else if(strcmp(n->label, "==") == 0) {
        fprintf(f, "cond%d:\n", cond_cont);
        fprintf(f, "\tFLD %s\n", n->izq->label);
        fprintf(f, "\tFCOMP %s\n", n->der->label);
        fprintf(f, "\tFSTSW AX\n");
        fprintf(f, "\tSAHF\n");

        if(not) {
            fprintf(f, "\tJE end_cond%d\n", cond_cont);
            not = 0;
        }
        else
            fprintf(f, "\tJNE end_cond%d\n", cond_cont);
        pushStack(stCond, cond_cont++);
        pushStack(stOpLog, 1);
    }

    else if(strcmp(n->label, "while") == 0) {
        fprintf(f, "\tJMP ini_while%d\n", popStack(stWhile));

        if(popStack(stOpLog) == 1) {
            fprintf(f, "end_cond%d:\n", popStack(stCond));
        } else {
            fprintf(f, "else_part%d:\n", popStack(stElse));
        }
    }

    else if(strcmp(n->label, "if-else") == 0) {
        fprintf(f, "end_if%d:\n", popStack(stElse));

        if(popStack(stOpLog) == 1) {
            fprintf(f, "end_cond%d:\n", popStack(stCond));
        }
    }

    else if(strcmp(n->label, "IF") == 0) {
        if(popStack(stOpLog) == 1) {
            fprintf(f, "end_cond%d:\n", popStack(stCond));
        }
    }

    else if(strcmp(n->label, "not") == 0) {
        //pushStack(stElse, else_cont++);
    }

    else if(strcmp(n->label, "OR") == 0) {
        int e1 = popStack(stElse);
        int e2 = popStack(stElse);

        fprintf(f, "\tJMP then_part%d\n", else_cont);
        fprintf(f, "end_cond%d:\n", e2);
        fprintf(f, "\tJMP cond%d:\n", e1);
        fprintf(f, "end_cond%d:\n", e1);
        fprintf(f, "\tJMP else_part%d\n", else_cont);
        //pushStack(stElse, else_cont++);
        fprintf(f, "then_part%d:\n", else_cont++);
        popStack(stOpLog);
        popStack(stOpLog);
        pushStack(stOpLog, 2);
    }

    else if(strcmp(n->label, "AND") == 0) {
        int e1 = popStack(stCond);
        int e2 = popStack(stCond);

        fprintf(f, "\tJMP then_part%d\n", else_cont);
        fprintf(f, "end_cond%d:\n", e2);
        fprintf(f, "end_cond%d:\n", e1);
        fprintf(f, "\tJMP else_part%d\n", else_cont);
        fprintf(f, "then_part%d:\n", else_cont);
        //pushStack(stElse, else_cont++);
        popStack(stOpLog);
        popStack(stOpLog);
        pushStack(stOpLog, 2);
    }

    else if(strcmp(n->label, "CONTAR") == 0) {
        fprintf(f, "\tFLD @contar_cont%d\n", contar_actual);
        fprintf(f, "\tFST @res_contar\n");
    }

    else if(strcmp(n->label, "CONTAR_INI") == 0) {
        guardar_resultado = 1;
        contar_actual++;
    }

    else if(strcmp(n->label, "PRINT_INT") == 0) {
        fprintf(f, "\tDisplayFloat %s, 0\n", n->izq->label);
        fprintf(f, "\tdisplayString NEW_LINE\n");
    }

    else if(strcmp(n->label, "PRINT_FT") == 0) {
        fprintf(f, "\tDisplayFloat %s, 2\n", n->izq->label);
        fprintf(f, "\tdisplayString NEW_LINE\n");
    }

    else if(strcmp(n->label, "PRINT_ST") == 0) {
        fprintf(f, "\tdisplayString %s\n", n->izq->label);
        fprintf(f, "\tdisplayString NEW_LINE\n");
    }
    else if(strcmp(n->label, "READ_FT") == 0 || strcmp(n->label, "READ_INT") == 0) {
        fprintf(f, "\tGetFloat %s\n", n->izq->label);
    }

    else if(strcmp(n->label, "READ_ST") == 0) {
        fprintf(f, "\tGetString %s\n", n->izq->label);
    }
}

Node *getSubarbolMasIzq(Node *n, FILE *f) {
    if(tieneHijos(n->izq)) {
        if(strcmp(n->label, "WHILE") == 0) {
            fprintf(f, "ini_while%d:\n", while_cont);
            pushStack(stWhile, while_cont++);
            strcpy(n->label, "while");
        }
        return getSubarbolMasIzq(n->izq, f);
    }

    if(tieneHijos(n->der)) {
        if(strcmp(n->label, "CUERPO") == 0) {
            int endIf = verTope(stElse);
            fprintf(f, "\tJMP end_if%d\n", endIf);
            fprintf(f, "else_part%d:\n", endIf);
            strcpy(n->label, "cuerpo");
        } else if(strcmp(n->label, "NOT") == 0) {
            not = 1;
            strcpy(n->label, "not");
        } else if(strcmp(n->label, "IF-ELSE") == 0) {
            pushStack(stElse, else_cont++);
            strcpy(n->label, "if-else");
        }

        return getSubarbolMasIzq(n->der, f);
    }

    return n;
}

int tieneHijos(Node *n) {
    if(n == NULL)
        return 0;

    return n->der != NULL || n->izq != NULL;
}