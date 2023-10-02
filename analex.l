%{
/*
    Programa :
    
        Analizador lexico para un lenguaje determinado
    
    Desarollado por:

        Espadas Rodriguez Anthony Jonathan - 421033621
        Santiago Martinez Ricardo          - 318187251

    Asignatura:                     Ciclo escolar:

        Compiladores                    2024-1

    Profesora:

        M.C. Laura Sandoval Montaño
*/    

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// Archivos para indicar estado del analisis
FILE* salida;  // Archivo con los tokens generados
FILE* errores; // Registro de errores encontrados
FILE* tablas;  // Visualiza el estado final de las tablas

// Alias de tipo para las estructuras usadas
typedef struct _token TOKEN;
typedef struct _nodo NODO;
typedef struct _lista LISTA;

// Estructura generada al identificar un componente lexico valido
struct _token{
    int clase; // Tipo de tabla a la que pertenece
    int valor; // Posicion que ocupa en la tabla
};

// Estructura para guardar valores en las tablas
struct _nodo{
    char* cad; // Simbolo que representa
    int valor; // Posicion en la tabla
    NODO* siguiente; // Apuntado al siguiente elemento
};

// Estructura para generar las tablas
struct _lista{
    int clase;  // Clase de elementos que contiene
    NODO* head; // Primer elemento de la tabla
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
NODO* crearNodo(char* cad, int valor);
int esVacia(LISTA* lista);
void agregarEntrada(LISTA* lista, char* cad);
void imprimirLista(LISTA* lista);
void generarTablas();
void imprimirTablas();
void buscaNombre(int clase);
void liberarMemoria();
void vaciarLista(LISTA* lista);


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
{oparit}    {fprintf(salida,"\n%s - Clase 0, operador aritmetico", yytext);}
{oplog}     {fprintf(salida,"\n%s - Clase 1, operador logico", yytext);}
{oprel}     {fprintf(salida,"\n%s - Clase 2, operador relacional", yytext);}
{consnum}   {fprintf(salida,"\n%s - Clase 3, constante numerica entera", yytext);}
{palres}    {fprintf(salida,"\n%s - Clase 4, palabra reservada", yytext);}
{ident}     {fprintf(salida,"\n%s - Clase 5, identificador", yytext);}
{simbesp}   {fprintf(salida,"\n%s - Clase 6, simbolo especial", yytext);}
{opasig}    {fprintf(salida,"\n%s - Clase 7, operdador de asignacion", yytext);}
{cadena}    {fprintf(salida,"\n%s - Clase 8, constante cadena", yytext);}
{opcad}     {fprintf(salida,"\n%s - Clase 9, operador de cadenas", yytext);}
%%

main()
{
    // Abre flujo de datos
    salida = fopen("salida.txt", "w"); 
    // Coloca tabla en estado iniciañ
    generarTablas();
    // Inicia analis lexico
    yylex();
    // Guarda el estado final de las tablas
    imprimirTablas();
    printf("\n");
    // Libera el espacio usado
    liberarMemoria();
    // Cierra el flujo de datos
    fclose(salida);
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
NODO* crearNodo(char* cad, int valor)
{

    NODO* nuevo_nodo  = (NODO*) malloc(sizeof(NODO)); // Reserva memoria
    nuevo_nodo -> cad = cad; // Coloca simbolo
    nuevo_nodo -> valor = valor; // Indica valor correspondiente
    nuevo_nodo -> siguiente = NULL;
    return nuevo_nodo;  

}

// Determina si la lista cuenta con elementos
int esVacia(LISTA* lista)
{
    if(lista -> head == NULL)
        return 1;
    
    return 0;
}

// Agrega una entrada a la tabla
void agregarEntrada(LISTA* lista, char* cad)
{
    int valor = 0;

    // Caso para lista vacia
    if(esVacia(lista))
    {
        lista -> head = crearNodo(cad, valor);
    }
    else
    {
        // Nodo auxiliar el recorrido
        NODO* nodo_aux = lista -> head;
        
        // Por cada elemento recorrido, el valor en la tabla aumenta
        valor++;

        // Recorre hasta el ultimo elemento
        for(; nodo_aux -> siguiente != NULL; nodo_aux = nodo_aux -> siguiente)
            valor++;

        // Se coloca el nodo cuando se llega el final
        nodo_aux -> siguiente = crearNodo(cad, valor);
    }

}

// Coloca todas las tablas en su estado inicial
void generarTablas()
{
    // Reserva la memoria para cada lista
    for(int i = 0; i < 10; i++)
    {
        listas[i] = crearLista(i);
    }

    // Agregado de elementos en la tabla 0
    agregarEntrada(listas[0], "+");
    agregarEntrada(listas[0], "-");
    agregarEntrada(listas[0], "/");
    agregarEntrada(listas[0], "*");
    agregarEntrada(listas[0], "%");

    // Agregado de elementos en la tabla 1
    agregarEntrada(listas[1], "&&");
    agregarEntrada(listas[1], "||");
    agregarEntrada(listas[1], "!");

    // Agregado de elementos en la tabla 2
    agregarEntrada(listas[2], "==");
    agregarEntrada(listas[2], "!=");
    agregarEntrada(listas[2], ">");
    agregarEntrada(listas[2], "<");
    agregarEntrada(listas[2], ">=");
    agregarEntrada(listas[2], "<=");

    // Agregado de elementos en la tabla 4
    agregarEntrada(listas[4], "assinado");
    agregarEntrada(listas[4], "caso");
    agregarEntrada(listas[4], "enquanto");
    agregarEntrada(listas[4], "fazer");
    agregarEntrada(listas[4], "flutuador");
    agregarEntrada(listas[4], "inteiro");
    agregarEntrada(listas[4], "para");
    agregarEntrada(listas[4], "quebrar");
    agregarEntrada(listas[4], "retorno");
    agregarEntrada(listas[4], "se");
    agregarEntrada(listas[4], "trocar");

    // Agregado de elementos en la tabla 6
    agregarEntrada(listas[6], "(");
    agregarEntrada(listas[6], ")");
    agregarEntrada(listas[6], "{");
    agregarEntrada(listas[6], "}");
    agregarEntrada(listas[6], ";");
    agregarEntrada(listas[6], ",");
    agregarEntrada(listas[6], "[");
    agregarEntrada(listas[6], "]");
    agregarEntrada(listas[6], ":");
    agregarEntrada(listas[6], "*");

    // Agregado de elementos en la tabla 7
    agregarEntrada(listas[7], "=");
    agregarEntrada(listas[7], "+=");
    agregarEntrada(listas[7], "-=");
    agregarEntrada(listas[7], "*=");
    agregarEntrada(listas[7], "/=");
    agregarEntrada(listas[7], "%=");

    // Agregado de elementos en la tabla 9
    agregarEntrada(listas[9], "$");
    agregarEntrada(listas[9], "like");
}

// Coloca todas las tablas en su estado inicial
void imprimirTablas()
{
    // Abrimos flujo de datos
    tablas = fopen("tablas.txt","w");

    // Recore el arreglo de listas para imprimirlas
    for(int i = 0; i < 10; i++)
    {
        // Tomamos la tabla
        LISTA* aux = listas[i];
        // Imprimimos su encabezado
        fprintf(tablas,"\nTabla %i - ", aux -> clase);
        buscaNombre(aux -> clase);
        fprintf(tablas,"Valor\tSimbolo\n");
        // Imprimimos sus elementos
        imprimirLista(listas[i]);
    }

    // Cerramos flujo de datoss
    fclose(tablas);
}

// Impreme todos los nodos de una lista
void imprimirLista(LISTA* lista)
{
    // Se omiten las listas sin elementos
    if(esVacia(lista))
        return;
    
    // Si hay almenos uno, se continua
    NODO* nodo_aux = lista -> head;
    
    // Imprime el valor de cada nodo y se recorre
    while(nodo_aux != NULL)
    {
        fprintf(tablas,"%i\t\t%s\n", nodo_aux -> valor, nodo_aux -> cad);
        nodo_aux = nodo_aux -> siguiente;
    }
        
}

// Imprime cadena correspondiente a tabla
void buscaNombre(int clase)
{
    switch(clase)
    {
        case 0:
            fprintf(tablas,"Operadores aritmeticos\n");
            break;
        case 1:
            fprintf(tablas,"Operadores logicos\n");
            break;
        case 2:
            fprintf(tablas,"Operadores relacionales\n");
            break;
        case 3:
            fprintf(tablas,"Constantes numericas enteras\n");
            break;
        case 4:
            fprintf(tablas,"Palabras reservadas\n");
            break;
        case 5:
            fprintf(tablas,"Identificadores\n");
            break;
        case 6:
            fprintf(tablas,"Simbolos especiales\n");
            break;
        case 7:
            fprintf(tablas,"Operadores de asugnacion\n");
            break;
        case 8:
            fprintf(tablas,"Constantes cadenas\n");
            break;
        case 9:
            fprintf(tablas,"Operadores sobre cadenas\n");
            break;
    }    
}

// Libera la memoria reservada para el programa
void liberarMemoria()
{
    // Recorre el arreglo de listas
    for (int i = 0; i < 10; i++)
    {
        // Libera todos los nodos
        vaciarLista(listas[i]);
        // Libera el espacio de la lista
        free(listas[i]);
        // Pierde al referencia
        listas[i] = NULL;
    }
}

// Elimina todos los nodos de una lista
void vaciarLista(LISTA* lista)                            
{
    NODO* kamikaze = lista -> head;             // Se posiciona al inicio de la lista   
    
    while (kamikaze != NULL)                    // Continuara mientras haya nodos en la lista
    {
        lista -> head = kamikaze -> siguiente;  // Se desplaza el inicio de la lista
        kamikaze -> siguiente = NULL;           // Se pierde la referencia a la lista
        free(kamikaze);                         // Se libera el espacio reservado
        kamikaze = lista -> head;               // Regresamos al inicio de la lista        
    };
};

