#ifndef ASSEMBLER_H
#define ASSEMBLER_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lista.h"
#include "arbol.h"

void generar_assembler(Node *, FILE *, FILE*);
void generar_codigo(Node *, FILE *);
void generar_codigo_inicial(FILE *);
void generar_codigo_final(FILE *);
void generar_codigo_data(FILE *);
Node *getSubarbolMasIzq(Node *, FILE *);
int tieneHijos(Node *);
void copiar_arch(FILE *, FILE *);

#endif