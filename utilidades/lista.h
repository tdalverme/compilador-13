#ifndef LISTA_H
#define LISTA_H

#define TS_NOMBRE 0
#define TS_TIPO 1
#define TS_VALOR 2
#define TS_LONGITUD 3

#define TS_INT 4
#define TS_FLOAT 5
#define TS_STRING 6
#define TS_ID 7

#include <stdio.h>

typedef struct DataTS {
    char *nombre;
    int tipo;
    char *valor;
    int longitud;
} DataTS;

typedef struct Nodo {
    DataTS data;
    struct Nodo *sig;
} Nodo;

typedef struct Lista {
    Nodo *head;
    Nodo *tail;
} Lista;


void init(Lista *);
int push(Lista *, DataTS *);
DataTS pop(Lista *);
void empty(Lista *);
int modificarTipo(Lista *, char *, int);
int modificarValor(Lista *, char *, char *);
int modificarLongitud(Lista *, char *, int);
DataTS *verUltimo(Lista *);
void listaToFile(Lista *, FILE *);

extern Lista tabla_simbolos;

#endif