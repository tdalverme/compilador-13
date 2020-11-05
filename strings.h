#include <stdio.h>
#include <stdlib.h>

#define SIN_VALOR "VALOR_NULO"

void replaceAll(char *, char, char);
char *removeAll(char *, char);
char *getNombreFormateado(char *);


char *getNombreFormateado(char *nombre) {
    char * nombre_sin_espacios = (char *)malloc(strlen(nombre) + 2);

    nombre_sin_espacios[0] = '_';
    nombre_sin_espacios[1] = '\0';
    nombre_sin_espacios = strcat(nombre_sin_espacios, nombre);

    // CAMBIA ESPACIOS POR '_'
    replaceAll(nombre_sin_espacios, ' ', '_');        
    
    // ELIMINA COMILLAS
    nombre_sin_espacios = removeAll(nombre_sin_espacios, '\"');

    // AGREGA UN '_' AL COMIENZO

    return nombre_sin_espacios;
}

void replaceAll(char *str, char oldChar, char newChar)
{
    int i = 0;

    while(str[i] != '\0')
    {
        if(str[i] == oldChar)
        {
            str[i] = newChar;
        }

        i++;
    }
}

char *removeAll(char *str, char toRemove)
{
    char * aux = (char *)malloc(strlen(str) + 1);
    strcpy(aux, str);

    int i = 0;
    int j = 0;

    while(str[i] != '\0')
    {
        if(str[i] != toRemove) {
            aux[j++] = str[i];
        }

        i++;
    }

    aux[j] = '\0';

    return aux;
}