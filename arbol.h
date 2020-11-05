#include <stdio.h>
#include <stdlib.h>

typedef struct sNodo  
{ 
  char *label; 
  struct sNodo *izq; 
  struct sNodo *der; 
} Node;

void posorder(Node *);
void inorder(Node *);
int inorderToFile(FILE *, Node *, int);

Node* crearNodo(char* data) 
{ 
    Node* nodo = (Node*)malloc(sizeof(Node)); 
    nodo->label = data;
  
    nodo->izq = NULL; 
    nodo->der = NULL;

    return(nodo);
}

Node *crear_hoja(char *label) {
    Node *nodo = (Node*)malloc(sizeof(Node));
    nodo->label = strdup(label);
    nodo->izq = NULL;
    nodo->der = NULL;

    return nodo;
}

Node *crear_nodo(char *label, Node *izq, Node *der) {
    Node *nodo = (Node*)malloc(sizeof(Node));
    nodo->label = strdup(label);
    nodo->izq = izq;
    nodo->der = der;
    
    return nodo;
}

int inorderToFile(FILE *f, Node * n, int i) {
    int actual = i;
    fprintf(f, "\t%d [label=\"%s\"]\n", i, n->label);
	
    if(n->izq) {
        fprintf(f, "\t%d -- %d\n", actual, i + 1);
        i = inorderToFile(f, n->izq, i + 1);
    } else {
        fprintf(f, "\t%d [style=invis, label=\"\"]\n", i + 1, n->label);
        fprintf(f, "\t{ edge[style=invis];\n\t%d -- %d\n\t}\n", actual, i + 1);
        i++;
    }
	
    if(n->der) {
        fprintf(f, "\t%d -- %d\n", actual, i + 1);
        i = inorderToFile(f, n->der, i + 1);
    } else {
        fprintf(f, "\t%d [style=invis, label=\"\"]\n", i + 1, n->label);
        fprintf(f, "\t{ edge[style=invis];\n\t%d -- %d\n\t}\n", actual, i + 1);
        i++;
    }

    return i;
}

void inorder(Node * n) {
	if(n->izq) posorder(n->izq);
	printf("%s ", n->label);
	if(n->der) posorder(n->der);
}

void posorder(Node * n) {
	printf("%s ", n->label);
	if(n->izq) posorder(n->izq);
	if(n->der) posorder(n->der);
}

void escribirDotFile(FILE *f, Node *arbol, int i) {
    fprintf(f, "graph G {\n");
    inorderToFile(f, arbol, i);
    fprintf(f, "}");
}