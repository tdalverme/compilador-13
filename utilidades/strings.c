#include "strings.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *getNombreFormateado(char *nombre) {
    char *nombre_sin_espacios = (char *)malloc(strlen(nombre) + 1);
    
    strcpy(nombre_sin_espacios, nombre);

    replaceAll(nombre_sin_espacios, ' ', '_');        
    nombre_sin_espacios = removeAll(nombre_sin_espacios, '\"');

    snprintf(nombre_sin_espacios, strlen(nombre_sin_espacios) + 2, "_%s", nombre);

    return nombre_sin_espacios;
}

char *replaceAll(char *str, char oldChar, char newChar)
{
    int i = 0;
    char *aux = strdup(str);

    while(aux[i] != '\0')
    {
        if(aux[i] == oldChar)
        {
            aux[i] = newChar;
        }

        i++;
    }

    return aux;
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