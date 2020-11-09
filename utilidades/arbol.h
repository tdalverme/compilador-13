#ifndef ARBOL_H
#define ARBOL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct sNodo  
{ 
  char *label; 
  struct sNodo *izq; 
  struct sNodo *der; 
} Node;

int inorderToFile(FILE *, Node *, int);
Node *crearNodo(char *);
Node *crear_hoja(char *);
Node *crear_nodo(char *, Node *izq, Node *);
int inorderToFile(FILE *, Node *, int);
void inorder(Node *);
void escribirDotFile(FILE *, Node *, int);

#endif