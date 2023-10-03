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
FILE* tokens;  // Muestra la entrada que genera los tokens

// Alias de tipo para las estructuras usadas
typedef struct _token TOKEN;
typedef struct _nodo NODO;
typedef struct _lista LISTA;
typedef struct _lista_T LISTA_T;

// Estructura generada al identificar un componente lexico valido
struct _token{
    int clase; // Tipo de tabla a la que pertenece
    int valor; // Posicion que ocupa en la tabla
    TOKEN* siguiente; // Siguiente token en orden
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

// Estructura para almacenar los tokens
struct _lista_T {
    TOKEN* head; // Apunta el primer token
    TOKEN* tail; // Apunta al ultimo token
};

// Arreglo que guarda las tablas generadas
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
 8 - Constantes cadenas"
 9 - Operadores sobre cadenas
*********************************/

// Estructura que guarda los tokens generados
LISTA_T* tokens_L;

// Prototipos de funciones
LISTA* crearLista(int clase);
NODO* crearNodo(char* cad, int valor);
TOKEN* crearToken(int clase, int valor);

int esVacia(LISTA* lista);
void buscaNombre(int clase);

void agregarEntrada(LISTA* lista, char* cad);

void verificarEntrada(LISTA* lista, char* cad);

void generarToken(int clase, int valor);
void generarTablas();
int encontrarValor(LISTA* lista, char* cad);

void imprimirTokens();
void imprimirLista(LISTA* lista);
void imprimirTablas();

void liberarMemoria();
void vaciarLista(LISTA* lista);
void vaciarTokens();

// Variables de apoyo
int contador_cadenas = 0; 

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
{oparit}    {fprintf(salida,"\n%s - Clase 0, operador aritmetico", yytext);
                                    // Cadena auxiliar para validar entrada
                                    char* c_aux = (char*) malloc(sizeof(char)*yyleng);
                                    
                                    // Copia de entrada a cadena
                                    strncpy(c_aux, yytext, yyleng);
                                    c_aux[yyleng] = '\0';

                                    // Se genera token con el ascii leido
                                    generarToken(0, (int) *c_aux);}

{oplog}     {fprintf(salida,"\n%s - Clase 1, operador logico", yytext);
                                    // Cadena auxiliar para validar entrada
                                    char* c_aux = (char*) malloc(sizeof(char)*yyleng);
                                   
                                    // Copia de entrada a cadena
                                    strncpy(c_aux, yytext, yyleng);
                                    c_aux[yyleng] = '\0';
                                   
                                    // Encuentra velor del identificador en la tabla
                                    int val = encontrarValor(listas[1], c_aux);
                                   
                                    // Genera token usando valor
                                    generarToken(1,val);}

{oprel}     {fprintf(salida,"\n%s - Clase 2, operador relacional", yytext);
                                    // Cadena auxiliar para validar entrada
                                    char* c_aux = (char*) malloc(sizeof(char)*yyleng);
                                   
                                    // Copia de entrada a cadena
                                    strncpy(c_aux, yytext, yyleng);
                                    c_aux[yyleng] = '\0';
                                   
                                    // Encuentra velor del identificador en la tabla
                                    int val = encontrarValor(listas[2], c_aux);
                                   
                                    // Genera token usando valor
                                    generarToken(2,val);}

{consnum}   {fprintf(salida,"\n%s - Clase 3, constante numerica entera", yytext);
                                    // Cadena auxiliar para validar entrada
                                    char* c_aux = (char*) malloc(sizeof(char)*yyleng);
                                    
                                    // Copie de entrada a cadena
                                    strncpy(c_aux, yytext, yyleng);
                                    c_aux[yyleng] = '\0';
                                    
                                    // Verifica si es signado
                                    if(c_aux[0] == '(')
                                    {   
                                        // Omite el primer parentesis
                                        c_aux[0] = c_aux[1];
                                        c_aux[1] = '0';

                                        // Si es positivo, omite el signo
                                        if(c_aux[0] == '+')
                                            c_aux[0] = '0';
                                        
                                        // Omite el segundo parentesis
                                        c_aux[yyleng-1] = '.';
                                    }
                                    
                                    // Genera el token usando la cadena
                                    generarToken(3, atoi(c_aux));}

{palres}    {fprintf(salida,"\n%s - Clase 4, palabra reservada", yytext);
                                    // Cadena auxiliar para validar entrada
                                    char* c_aux = (char*) malloc(sizeof(char)*yyleng);
                                   
                                    // Copia de entrada a cadena
                                    strncpy(c_aux, yytext, yyleng);
                                    c_aux[yyleng] = '\0';
                                   
                                    // Encuentra velor del identificador en la tabla
                                    int val = encontrarValor(listas[4], c_aux);
                                   
                                    // Genera token usando valor
                                    generarToken(4,val);}

{ident}     {fprintf(salida,"\n%s - Clase 5, identificador", yytext);
                                   // Cadena auxiliar para validar entrada
                                   char* c_aux = (char*) malloc(sizeof(char)*yyleng);
                                   
                                   // Copia de entrada a cadena
                                   strncpy(c_aux, yytext, yyleng);
                                   c_aux[yyleng] = '\0';
                                   
                                   // Verifica si el identificador existe
                                   verificarEntrada(listas[5], c_aux);

                                   // Encuentra velor del identificador en la tabla
                                   int val = encontrarValor(listas[5], c_aux);
                                   
                                   // Genera token usando valor
                                   generarToken(5,val);}

{simbesp}   {fprintf(salida,"\n%s - Clase 6, simbolo especial", yytext);
                                    // Cadena auxiliar para validar entrada
                                    char* c_aux = (char*) malloc(sizeof(char)*yyleng);
                                    
                                    // Copia de entrada a cadena
                                    strncpy(c_aux, yytext, yyleng);
                                    c_aux[yyleng] = '\0';
                                    
                                    // Se genera token con el ascii leido
                                    generarToken(6, (int) *c_aux);}

{opasig}    {fprintf(salida,"\n%s - Clase 7, operdador de asignacion", yytext);
                                    // Cadena auxiliar para validar entrada
                                    char* c_aux = (char*) malloc(sizeof(char)*yyleng);
                                   
                                    // Copia de entrada a cadena
                                    strncpy(c_aux, yytext, yyleng);
                                    c_aux[yyleng] = '\0';
                                   
                                    // Encuentra velor del identificador en la tabla
                                    int val = encontrarValor(listas[7], c_aux);
                                   
                                    // Genera token usando valor
                                    generarToken(7,val);}

{cadena}    {fprintf(salida,"\n%s - Clase 8, constante cadena", yytext);
                                    // Cadena auxiliar para validar entrada
                                    char* c_aux = (char*) malloc(sizeof(char)*yyleng);
                                    
                                    // Copia de entrada a cadena
                                    strncpy(c_aux, yytext, yyleng);
                                    c_aux[yyleng] = '\0';
                                    
                                    // Se agrega la cadena a la tabla
                                    agregarEntrada(listas[8], c_aux);
                                    
                                    // Se genera el token para su referencia
                                    generarToken(8,contador_cadenas);
                                    
                                    // El contador de cadenas aumetna
                                    contador_cadenas++;}

{opcad}     {fprintf(salida,"\n%s - Clase 9, operador de cadenas", yytext);
                                    // Cadena auxiliar para validar entrada
                                    char* c_aux = (char*) malloc(sizeof(char)*yyleng);
                                   
                                    // Copia de entrada a cadena
                                    strncpy(c_aux, yytext, yyleng);
                                    c_aux[yyleng] = '\0';
                                   
                                    // Encuentra velor del identificador en la tabla
                                    int val = encontrarValor(listas[9], c_aux);
                                   
                                    // Genera token usando valor
                                    generarToken(9,val);}

{espacio}   { }
.           {fprintf(errores,"Elemento no reconocido: %s\n", yytext);}

%%

main()
{
    // Se inicia la lista de tokens
    tokens_L = (LISTA_T*) malloc(sizeof(LISTA_T));
    tokens_L -> head = tokens_L -> tail = NULL;

    // Abre flujo de datos
    salida = fopen("salida.txt", "w");
    tokens = fopen("tokens.txt", "w");
    errores = fopen("errores.txt", "w"); 

    // Coloca tabla en estado inicial
    generarTablas();
    
    // Inicia analis lexico
    yylex();
    
    // Guarda el estado final de las tablas
    imprimirTablas();

    // Guarda la secuencia de tokens en un archivo
    imprimirTokens();
    printf("\n");
    
    // Libera el espacio usado
    liberarMemoria();
    
    // Cierra el flujo de datos
    fclose(salida);
    fclose(tokens);
    fclose(errores);

    system("clear");
    printf("\nAnalisis terminao\n");
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

// Reserva espaco para el token a partir de los datos leidos
TOKEN* crearToken(int clase, int valor)
{
    TOKEN* nuevo_token = (TOKEN*) malloc(sizeof(TOKEN));
    nuevo_token -> clase = clase;
    nuevo_token -> valor = valor;
    nuevo_token -> siguiente = NULL;
    return nuevo_token;
}

// Agrega el token a la coleccion
void generarToken(int clase, int valor)
{
    // Reserva el espacio para los nuevos datos
    TOKEN* token_aux = crearToken(clase, valor);
    
    // Cuando no hay tokens
    if(tokens_L -> head == NULL)
    {
        // Se le colocan ambas referencias
        tokens_L -> head = token_aux;
        tokens_L -> tail = token_aux;
    }
    // Cuando hay un token
    else if (tokens_L -> head == tokens_L -> tail)
    {
        // El nuevo token se mueve al final
        tokens_L -> tail = token_aux;

        // Se encadena con el inicio
        tokens_L -> head -> siguiente = token_aux;
    }
    // Cuando hay 2 o mas tokens
    else
    {
        // El nuevo token se mueve al final
        tokens_L -> tail -> siguiente = token_aux;

        // El nuevo token se mueve al final
        tokens_L -> tail = token_aux;
    }
}

// Guarda la secuencia de tokens en un archivo
void imprimirTokens()
{
    // Nodo auxiliar que recorrera la lista
    TOKEN* token_aux = tokens_L -> head;

    // Se detiene al pasar todos los tokens
    while(token_aux != NULL)
    {
        fprintf(tokens,"(%i, %i)\n", token_aux -> clase, token_aux -> valor);
        fflush(tokens);
        token_aux = token_aux -> siguiente;
    }
}

// Determina si la lista cuenta con elementos
int esVacia(LISTA* lista)
{
    if(lista -> head == NULL)
        return 1;
    
    return 0;
}

// Verifica si una entrada pertenece a una tabla
void verificarEntrada(LISTA* lista, char* cad)
{
    // Una lista vacia no verifica
    if(esVacia(lista))
    {
        agregarEntrada(lista, cad);
        return;
    }

    // Bandera para verificar coincidencia
    int existe = 0;
    
    // Nodo de apoyo para verificar
    NODO* nodo_aux = lista -> head;

    while(nodo_aux != NULL)
    {
        // Realiza la comparacion con el id en la entrada
        if(!strcmp(nodo_aux -> cad, cad))
        {
            existe = 1;
            break;
        }

        // Nos desplazamos en la tabla
        nodo_aux = nodo_aux -> siguiente;
    }

    // Si se encendio la bandera, el elemento ya existe
    if(existe)
        return;
    
    // Si no se encendio, es un nuevo elemento
    agregarEntrada(lista, cad);
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

    // Agregado de elementos en la tabla 7  
    agregarEntrada(listas[7], "=");
    agregarEntrada(listas[7], "+=");
    agregarEntrada(listas[7], "-=");
    agregarEntrada(listas[7], "*=");
    agregarEntrada(listas[7], "/=");
    agregarEntrada(listas[7], "%=");

    // Agregado de elementos en la tabla 9
    agregarEntrada(listas[9], "&");
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
        // Omitimos las clases sin registros
        if (i == 0|i == 3|i == 6)
            continue;

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
        case 1:
            fprintf(tablas,"Operadores logicos\n");
            break;
        case 2:
            fprintf(tablas,"Operadores relacionales\n");
            break;
        case 4:
            fprintf(tablas,"Palabras reservadas\n");
            break;
        case 5:
            fprintf(tablas,"Identificadores\n");
            break;
        case 7:
            fprintf(tablas,"Operadores de asignacion\n");
            break;
        case 8:
            fprintf(tablas,"Constantes cadenas\n");
            break;
        case 9:
            fprintf(tablas,"Operadores sobre cadenas\n");
            break;
    }    
}

// Encuentra el valor de una entrada de la tabla
int encontrarValor(LISTA* lista, char* cad)
{
    // Nodo de apoyo a las comparaciones
    NODO* nodo_aux = lista -> head;

    // Evita buscar en tablas vacias
    if(nodo_aux == NULL)
        return -1;
    
    while (nodo_aux != NULL)
    {
        if(!strcmp(nodo_aux -> cad, cad))
            return nodo_aux -> valor;

        nodo_aux = nodo_aux -> siguiente;
    }

    // No hubo coincidencias
    return -1;
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
        
        // Libera el espacio de los tokens
        vaciarTokens();
    }
}

// Elimina todos los nodos de una lista
void vaciarLista(LISTA* lista)                            
{
    // Se posiciona al inicio de la lista   
    NODO* kamikaze = lista -> head;
    
    // Continuara mientras haya nodos en la lista
    while (kamikaze != NULL)                    
    {
        // Se desplaza el inicio de la lista
        lista -> head = kamikaze -> siguiente;  
        
        // Se pierde la referencia a la lista
        kamikaze -> siguiente = NULL;           
        
        // Se libera el espacio reservado
        free(kamikaze);                         
        
        // Regresamos al inicio de la lista
        kamikaze = lista -> head;                       
    };
};

// Libera el espacio reservado para los tokens
void vaciarTokens()
{
    // Nodo auxiliar que recorrera la lista
    TOKEN* token_aux = tokens_L -> head; 

    // Se detiene al pasar todos los tokens
    while(token_aux != NULL)
    {
        // Desplazamos el incio de la lista
        tokens_L -> head = token_aux -> siguiente;

        // Perdemos la referenica del token
        token_aux -> siguiente = NULL;

        // Liberamos el espacio del token
        free(token_aux);

        // Se recorre el nodo auxiliar
        token_aux = tokens_L -> head;
    }

    // Delvemos la lista al estado inicial
    tokens_L -> head = NULL;
    tokens_L -> tail = NULL;
};