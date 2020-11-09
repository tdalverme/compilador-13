#include "lista.h"
#include <stdlib.h>
#include <string.h>

void init(Lista *lista) {
    lista->head = NULL;
    lista->tail = NULL;
}

int push(Lista *lista, DataTS *data) {
    Nodo *nuevo = (Nodo *) malloc(sizeof(Nodo));
    nuevo->data = *data;
    nuevo->sig = NULL;
    
    if (lista->head == NULL) {
        lista->head = nuevo;
        lista->tail = nuevo;
    } else {
        Nodo *actual = lista->head;
        char *nombreCte = (char *)malloc(7 + sizeof(strlen(data->nombre)));
        strcpy(nombreCte, "_CONST");
        strcat(nombreCte, data->nombre);
        printf("%s\n", nombreCte);

        while (actual->sig != NULL) {
            if(strcmp(actual->data.nombre, data->nombre) == 0 || strcmp(actual->data.nombre, nombreCte) == 0) {
                return -1;
            } else {
                actual = actual->sig;
            }
        }

        if(strcmp(actual->data.nombre, data->nombre) == 0 || strcmp(actual->data.nombre, nombreCte) == 0) {
            return -1;
        } else {
            actual->sig = nuevo;
            lista->tail = nuevo;
        }
        
        free(nombreCte);
    }

    return 1;
}

DataTS pop(Lista *lista) {
    Nodo * sig = NULL;
    DataTS data;

    if (lista->head == NULL) {
        return data;
    }

    sig = lista->head->sig;
    data = lista->head->data;
    free(lista->head);

    if(sig == NULL) {
        lista->tail = NULL;
    }

    lista->head = sig;

    return data;
}

void empty(Lista *lista) {
    while(lista->head != lista->tail) {
        Nodo* sig = lista->head->sig;
        free(lista->head);
        lista->head = sig;
    }

    free(lista->head);
    lista->head = NULL;
    lista->tail = NULL;
}

int modificarTipo(Lista *lista, char *nombre, int nuevoTipo) {
    if (lista->head == NULL) {
        return -1;
    } else {
        Nodo *actual = lista->head;

        while (actual != NULL) {
            if(strcmp(actual->data.nombre, nombre) == 0) {
                actual->data.tipo = nuevoTipo;
                return 1;
            } else {
                actual = actual->sig;
            }
        }
    }

    return -1;
}

int modificarValor(Lista *lista, char *nombre, char *nuevoValor) {
    if (lista->head == NULL) {
       return -1;
    } else {
        Nodo *actual = lista->head;

        while (actual != NULL) {
            if(strcmp(actual->data.nombre, nombre) == 0) {
                actual->data.valor = strdup(nuevoValor);
                return 1;
            } else {
                actual = actual->sig;
            }
        }
    }

    return -1;
}

int modificarLongitud(Lista *lista, char *nombre, int nuevaLongitud) {
    if (lista->head == NULL) {
        return -1;
    } else {
        Nodo *actual = lista->head;

        while (actual->sig != NULL) {
            if(strcmp(actual->data.nombre, nombre) == 0) {
                actual->data.longitud = nuevaLongitud;
                return 1;
            } else {
                actual = actual->sig;
            }
        }
    }

    return -1;
}

DataTS *verUltimo(Lista *lista) {
    Nodo *sig = NULL;

    if (lista->head == NULL) {
        fprintf(stderr, "Head no apunta a nada.\n");
        return NULL;
    }


    return &lista->tail->data;
}

void listaToFile(Lista *lista, FILE *file) {
    if(file == NULL) {
        return;
    }

    fprintf(file, "NOMBRE                                  TIPO       VALOR                                  LONGITUD\n");

    Nodo *actual = lista->head;
    
    while(actual != NULL) {
        fprintf(file, "%-38s  ", actual->data.nombre);

        if(actual->data.tipo == TS_INT) {
            fprintf(file, "Integer    %-38s --\n", actual->data.valor);
        } else if(actual->data.tipo == TS_FLOAT) {
            fprintf(file, "Float      %-38s --\n", actual->data.valor);
        } else if(actual->data.tipo == TS_STRING) {
            fprintf(file, "String     %-38s %d\n", actual->data.valor, actual->data.longitud);
        }

        actual = actual->sig;
    }
}