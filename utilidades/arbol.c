#include "arbol.h"

Node *crear_hoja(char *label) {
    Node *nodo = (Node*)malloc(sizeof(Node));
    nodo->label = (char *)malloc(strlen(label) + 1);
    strcpy(nodo->label, label);
    nodo->izq = NULL;
    nodo->der = NULL;

    return nodo;
}

Node *crear_nodo(char *label, Node *izq, Node *der) {
    Node *nodo = (Node*)malloc(sizeof(Node));
    nodo->label = (char *)malloc(strlen(label) + 1);
    strcpy(nodo->label, label);
    nodo->izq = izq;
    nodo->der = der;
    
    return nodo;
}

int inorderToFile(FILE *f, Node * n, unsigned int i) {
    unsigned int actual = i;
    fprintf(f, "\t%d [label=\"%s\"]\n", i, n->label);

    if(n->izq) {
        fprintf(f, "\t%d -- %d\n", actual, i + 1);
        i = inorderToFile(f, n->izq, i + 1);
    } else {
        fprintf(f, "\t%d [style=invis, label=\"\"]\n", i + 1);
        fprintf(f, "\t{\n\t\tedge[style=invis]\n\t\t%d -- %d\n\t}\n", actual, i + 1);
        i++;
    }
	
    if(n->der) {
        fprintf(f, "\t%d -- %d\n", actual, i + 1);
        i = inorderToFile(f, n->der, i + 1);
    } else {
        fprintf(f, "\t%d [style=invis, label=\"\"]\n", i + 1);
        fprintf(f, "\t{\n\t\tedge[style=invis]\n\t\t%d -- %d\n\t}\n", actual, i + 1);
        i++;
    }

    return i;
}

void inorder(Node * n) {
	if(n->izq) inorder(n->izq);
	printf("%s ", n->label);
	if(n->der) inorder(n->der);
}

void escribirDotFile(FILE *f, Node *arbol, unsigned int i) {
    fflush(f);
    fprintf(f, "graph G {\n");
    fflush(f);
    inorderToFile(f, arbol, i);
    fflush(f);
    fprintf(f, "}");
    fflush(f);
}

void freeArbol(Node *n) {
    if(n == NULL)
        return;

    free(n->izq);
    free(n->der);

    free(n->label);
    free(n);
}

Node *copiarArbol(Node *root) {
    if(root == NULL)
        return root;

   Node *temp = (Node *)malloc(sizeof(Node));

   temp->label = root->label;
   temp->izq = copiarArbol(root->izq);
   temp->der = copiarArbol(root->der);

   return temp;
}