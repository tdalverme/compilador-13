#include "strings.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *getNombreFormateado(char *nombre) {
    char *nombre_sin_espacios = (char *)malloc(strlen(nombre));
    
    replaceAll(nombre, ' ', '_');        
    nombre = removeAll(nombre, '\"');

    snprintf(nombre_sin_espacios, strlen(nombre) + 2, "_%s", nombre);

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