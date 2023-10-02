%{
/*
    Programa :
    
        Analizador lexico para un lenguaje determinado
    
    Desarollado por:

        Espadas Rodriguez Anthony Jonathan - 421033621
        Santiago Martinez Ricardo          - 

    Asignatura:                     Ciclo escolar:

        Compiladores                    2024-1

    Profesora:

        M.C. Laura Sandoval Montaño
*/    

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// Archivos para indicar estado del analisis
FILE* salida;
FILE* errores;
FILE* tablas;

// Alias de tipo para las estructuras usadas
typedef struct _token TOKEN;
typedef struct _nodo NODO;
typedef struct _lista LISTA;

// Estructura generada al identificar un componente lexico valido
struct _token{
    int clase;
    int valor;
};

// Estructura para guardar valores en las tablas
struct _nodo{
    char* cad;
    int valor;
    NODO* siguiente;
};

// Estructura para generar las tablas
struct _lista{
    int clase;
    NODO* head;
};

// Variables de apoyo en la ejecucion
LISTA* listas[10];

/*********************************
 0 - Operadaores aritmeticos
 1 - Operadores logicos
 2 - Operadores relacionales
 3 - Constantes numericas enteras
 4 - Palabras reservadas
 5 - Identificadores
 6 - Simbolos especiales
 7 - Operadores de asignacion
 8 - Constantes cadenas
 9 - Operadores sobre cadenas
*********************************/

// Encabezado de funciones
LISTA* crearLista(int clase);
void generarTablas();
void imprimirTablas();
void buscaNombre(int clase);


%}

dig     [0-9]
let     [a-zA-Z]
espacio " "|\n|\t
signo   [\-+]
oparit  {signo}|[*/%]
simbesp [\(\)\{\};,\[\]:#]
palres  assinado|caso|enquanto|fazer|flutuador|inteiro|para|quebrar|retorno|se|trocar
ident   _{let}({let}|{dig}|_)*
num     {dig}+
consnum {num}|\({signo}{num}\)
cadena  \"[^\"]*\"
oprel   [<>]|[<>!=]=
oplog   !|(&|\|){2}
opcad   &|like
opasig  {oparit}?=

%%
{oparit}    {printf("\n%s - Clase 0, operador aritmetico", yytext);}
{oplog}     {printf("\n%s - Clase 1, operador logico", yytext);}
{oprel}     {printf("\n%s - Clase 2, operador relacional", yytext);}
{consnum}   {printf("\n%s - Clase 3, constante numerica entera", yytext);}
{palres}    {printf("\n%s - Clase 4, palabra reservada", yytext);}
{ident}     {printf("\n%s - Clase 5, identificador", yytext);}
{simbesp}   {printf("\n%s - Clase 6, simbolo especial", yytext);}
{opasig}    {printf("\n%s - Clase 7, operdador de asignacion", yytext);}
{cadena}    {printf("\n%s - Clase 8, constante cadena", yytext);}
{opcad}     {printf("\n%s - Clase 9, operador de cadenas", yytext);}
%%

main()
{
    generarTablas();
    imprimirTablas();
    yylex();
    printf("\n");
    return 0;
}

// Almacena el espacio para una lista
LISTA* crearLista(int clase)
{
    LISTA* nueva_lista = (LISTA*) malloc(sizeof(LISTA)); // Reserva el espacio
    nueva_lista -> head = NULL; // No asigna inicio
    nueva_lista -> clase = clase; // Asigna la clase
    return nueva_lista; // Devuelve la direccion
}

// Almacena espacio para un nodo
NODO* crearNodo(char* cad, int valor, NODO* siguiente)
{

    NODO* nuevo_nodo  = (NODO*) malloc(sizeof(NODO));
    nuevo_nodo -> cad = cad;
    nuevo_nodo -> valor = valor;
    nuevo_nodo -> siguiente = siguiente;
    return nuevo_nodo;  

}

// Coloca todas las tablas en su estado inicial
void generarTablas()
{
    // Reserva la memoria para cada lista
    for(int i = 0; i < 10; i++)
    {
        listas[i] = crearLista(i);
    }


}

// Coloca todas las tablas en su estado inicial
void imprimirTablas()
{

    for(int i = 0; i < 10; i++)
    {
        LISTA* aux = listas[i];
        printf("\nTabla %i - ", aux -> clase);
        buscaNombre(aux -> clase);
    }

}

// Imprime cadena correspondiente a tabla
void buscaNombre(int clase)
{
    switch(clase)
    {
        case 0:
            printf("Operadores aritmeticos\n");
            break;
        case 1:
            printf("Operadores logicos\n");
            break;
        case 2:
            printf("Operadores relacionales\n");
            break;
        case 3:
            printf("Constantes numericas enteras\n");
            break;
        case 4:
            printf("Palabras reservadas\n");
            break;
        case 5:
            printf("Identificadores\n");
            break;
        case 6:
            printf("Simbolos especiales\n");
            break;
        case 7:
            printf("Operadores de asugnacion\n");
            break;
        case 8:
            printf("Constantes cadenas\n");
            break;
        case 9:
            printf("Operadores sobre cadenas\n");
            break;
    }    
}
