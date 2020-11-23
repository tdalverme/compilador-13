#include "lista.h"
#include <stdlib.h>
#include <string.h>

Lista tabla_simbolos;

void init(Lista *lista) {
    lista->head = NULL;
    lista->tail = NULL;
}

int push(Lista *lista, DataTS *data) {

    if (lista->head == NULL) {
        Nodo *nuevo = (Nodo *) malloc(sizeof(Nodo));
    
        nuevo->data.nombre = (char *)malloc(strlen(data->nombre) + 1);
        strcpy(nuevo->data.nombre, data->nombre);

        if(strcmp(data->valor, "") != 0) {
            nuevo->data.valor = (char *)malloc(strlen(data->valor) + 1);
            strcpy(nuevo->data.valor, data->valor);
        }

        nuevo->data.longitud = data->longitud;

        nuevo->data.tipo = data->tipo;
        
        nuevo->sig = NULL;

        lista->head = nuevo;
        lista->tail = nuevo;
    } else {
        Nodo *actual = lista->head;
        char *nombreCte = (char *)malloc(7 + sizeof(strlen(data->nombre)));
        strcpy(nombreCte, "_CONST");
        strcat(nombreCte, data->nombre);

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
            Nodo *nuevo = (Nodo *) malloc(sizeof(Nodo));

            nuevo->data.nombre = (char *)malloc(strlen(data->nombre) + 1);
            strcpy(nuevo->data.nombre, data->nombre);


            if(data->valor) {
                nuevo->data.valor = (char *)malloc(strlen(data->valor) + 1);
                strcpy(nuevo->data.valor, data->valor);
            }
            nuevo->data.longitud = data->longitud;

            nuevo->data.tipo = data->tipo;
            
            nuevo->sig = NULL;

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
                actual->data.valor = (char *)malloc(strlen(nuevoValor) + 1);
                strcpy(actual->data.valor, nuevoValor);
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

        char *valor;
        if(actual->data.valor == NULL) {
            valor = (char *)malloc(1);
            strcpy(valor, "");
        } else {
            valor = (char *)malloc(strlen(actual->data.valor) + 1);
            strcpy(valor, actual->data.valor);
        }


        if(actual->data.tipo == TS_INT) {
            fprintf(file, "Integer    %-38s --\n", valor);
        } else if(actual->data.tipo == TS_ID_INT) {
            fprintf(file, "Integer    %-38s --\n", "--");
        } else if(actual->data.tipo == TS_FLOAT ) {
            fprintf(file, "Float      %-38s --\n", valor);
        } else if(actual->data.tipo == TS_ID_FLOAT) {
            fprintf(file, "Float      %-38s --\n", "--");
        } else if(actual->data.tipo == TS_ID_STRING) {
            fprintf(file, "String      %-38s --\n", "--");
        } else if(actual->data.tipo == TS_STRING) {
            fprintf(file, "String     %-38s %d\n", valor, actual->data.longitud);
        }

        actual = actual->sig;
    }

}

void freeLista(Lista *lista)
{
   Nodo* tmp;

   while (lista->head != NULL)
   {
       tmp = lista->head;
       lista->head = lista->head->sig;
       free(tmp->data.nombre);
       free(tmp->data.valor);
       free(tmp);
   }

    free(lista->head);
    free(lista->tail);
    free(lista);
}

int getTipo(Lista *lista, char *nombre) {
    Nodo *actual = lista->head;
    char *nombreCte = (char *)malloc(7 + sizeof(strlen(nombre)));
    strcpy(nombreCte, "_CONST");
    strcat(nombreCte, nombre);

    while (actual != NULL) {
        if(strcmp(actual->data.nombre, nombre) == 0 || strcmp(actual->data.nombre, nombreCte) == 0) {
            return actual->data.tipo;
        } else {
            actual = actual->sig;
        }
    }
    
    free(nombreCte);
    return -1;
}

int existe(Lista *lista, char *nombre) {
    Nodo *actual = lista->head;

    while (actual != NULL) {
        if(strcmp(actual->data.nombre, nombre) == 0) {
            return 1;
        } else {
            actual = actual->sig;
        }
    }

    return 0;
}

int declarado(Lista *lista, char *nombre) {
    Nodo *actual = lista->head;
    char *nombreCte = (char *)malloc(7 + sizeof(strlen(nombre)));
    strcpy(nombreCte, "_CONST");
    strcat(nombreCte, nombre);

    while (actual->sig != NULL) {
        if(strcmp(actual->data.nombre, nombre) == 0 || strcmp(actual->data.nombre, nombreCte) == 0) {
            return 1;
        } else {
            actual = actual->sig;
        }
    }

    return 0;
}

int tiposCompatibles(char *n1, char *n2) {
    int t1 = getTipo(&tabla_simbolos, n1);
    int t2 = getTipo(&tabla_simbolos, n2);

    if(t1 == TS_STRING || t2 == TS_STRING || t1 == TS_ID_STRING || t2 == TS_ID_STRING)
        return 0;

    return 1;
}

int esConstante(char *nombre) {
    Nodo *actual = tabla_simbolos.head;

    char *nombreCte = (char *)malloc(7 + sizeof(strlen(nombre)));
    strcpy(nombreCte, "_CONST");
    strcat(nombreCte, nombre);

    while (actual != NULL) {
        if(strcmp(actual->data.nombre, nombreCte) == 0) {
            return 1;
        } else {
            actual = actual->sig;
        }
    }

    return 0;
}

int asignacionCompatible(char *n1, char *n2) {
    int t1 = getTipo(&tabla_simbolos, n1);
    int t2 = getTipo(&tabla_simbolos, n2);

    if(t1 == t2)
        return 1;

    if((t1 == TS_FLOAT || t1 == TS_ID_FLOAT) && (t2 == TS_INT || t2 == TS_ID_INT))
        return 1;

    if((t1 == TS_INT || t1 == TS_ID_INT) && (t2 == TS_FLOAT || t2 == TS_ID_FLOAT))
        return 0;

    if((t1 == TS_STRING && t2 == TS_ID_STRING) || (t1 == TS_ID_STRING || t2 == TS_STRING))
        return 1;

    return 1;
}