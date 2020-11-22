// Stack implementation in C
#include "pila.h"

int count = 0;

void createEmptyStack(st *s) {
  s->top = -1;
}

// Check if the stack is full
int isfull(st *s) {
  if (s->top == MAX - 1)
    return 1;
  else
    return 0;
}

// Check if the stack is empty
int isempty(st *s) {
  if (s->top == -1)
    return 1;
  else
    return 0;
}

// Add elements into stack
void pushStack(st *s, int newitem) {
  if (isfull(s)) {
    printf("STACK FULL");
  } else {
    s->top++;
    s->items[s->top] = newitem;
  }
  count++;
}

// Remove element from stack
int popStack(st *s) {
  int res;
  
  if (isempty(s)) {
    printf("\n STACK EMPTY \n");
  } else {
    res = s->items[s->top];
    s->top--;
  }
  count--;
  
  return res;
}

// Print elements of stack
void printStack(st *s) {
  printf("Stack: ");
  for (int i = 0; i < count; i++) {
    printf("%d ", s->items[i]);
  }
  printf("\n");
}

int verTope(st *s) {
  if (isempty(s)) {
    printf("\n STACK EMPTY \n");
  }
  
  return s->items[s->top];
}