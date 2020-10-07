typedef struct DataTS {
    char *nombre;
    int tipo;
    char *valor;
    int longitud;
} DataTS;

typedef struct Nodo {
    DataTS data;
    struct Nodo * sig;
} Nodo;

typedef struct Lista {
    Nodo *head;
    Nodo *tail;
} Lista;


void init(Lista *);
int push(Lista *, DataTS *);
DataTS *verUltimo(Lista *);


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

        while (actual->sig != NULL) {
            if(strcmp(actual->data.nombre, data->nombre) == 0) {
                return -1;
            } else {
                actual = actual->sig;
            }
        }

        actual->sig = nuevo;
        lista->tail = nuevo;
    }

    return 1;
}

DataTS *verUltimo(Lista *lista) {
    Nodo *sig = NULL;

    if (lista->head == NULL) {
        fprintf(stderr, "Head no apunta a nada.\n");
        return NULL;
    }


    return &lista->tail->data;
}