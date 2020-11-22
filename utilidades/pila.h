#include <stdio.h>
#include <stdlib.h>

#define MAX 30

struct stack {
  int items[MAX];
  int top;
};
typedef struct stack st;

void createEmptyStack(st *s);

// Check if the stack is full
int isfull(st *);

// Check if the stack is empty
int isempty(st *);

// Add elements into stack
void pushStack(st *, int);

// Remove element from stack
int popStack(st *);

int verTope(st *);

// Print elements of stack
void printStack(st *);