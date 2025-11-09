# Ejercicio 12: Reversibilidad

Indicar si el predicado replicar/3 es reversible en el segundo argumento. En concreto se pide analizar si
replicar(+Elem,-N,-Lista) funciona correctamente.

---
---

## Respuesta:

Partamos de la funcionalidad de replicar/3 dada por consigna:

> **Ejercicio 2: replicar/3**
>
> Definir el predicado replicar(+Elem, +N,-Lista) es cierto cuando Lista es una lista de longitud N, donde cada elemento es igual a Elem.
>

```prolog
?- replicar(x, 3, L).

L = [x, x, x].
```

Luego, si replicar/3 fuera reversible en el segundo argumento entonces este predicado debe instanciar todas las listas posibles (con cualquier longitud) donde todos sus elementos son iguales a Elem.

Ahora bien, presentemos nuestra definición de replicar/3:

```prolog
replicar(_, 0, []).  
replicar(X, N, [X | T]) :- 
	length([X | T], N), 
    N > 0,
	M is N-1,
	replicar(X, M, T).
```

Analicemos la reversibilidad del segundo argumento (N), en el caso en que este viene instanciado y en el caso en que no:

- ### **N está instanciada:** 

    Si N está instanciada entonces replicar/3 debe cumplir que instancie en L la lista de tamaño N donde todos sus elementos son Elem.

    En nuestra definición de replicar/3 forzamos que el tamaño de la lista L (tratada como [X | T] aprovechando la unificación nativa de prolog para que nuestra lista L contenga al elemento Elem como cabeza) sea igual al tamaño del N instanciado por la definición de length/2, luego verificamos que N no era negativo usando el operador '>' (lo cual es válido porque N estaba instanciado), luego realizamos una asignación
    ```prolog
    M is N-1,
    ```
    que es válida porque -nuevamente- N estaba instanciado, y finalmente hacemos un llamado recursivo con: el elemento que queremos en cada posición, el M instanciado y la cola de la lista que queremos instanciar; esto va a hacer un llamado recursivo sobre la cola de lista donde habrá nuevamente un segundo argumento instanciado y donde (por la unificación nativa de prolog) el primer elemento de la cola de L deberá ser Elem; paulatinamente prolog logrará unificar a L con
    ```prolog
    replicar(_, 0, []).
    ```
    (pues siempre decrementamos al largo de lista) y se construirá (gracias a la serie de unificaciones realizadas de forma nativa) la lista de largo N (refiriendonos al N dado antes de cualquier recursión) donde todos sus elementos son Elem.
    
    #### Conclusión 1: la definición de replicar/3 para N instanciado **no falla**.

    #### Conclusión 2: la definición de replicar/3 para N instanciado **es correcta**.

- ### **N no está instanciada:**

    Si N no está instanciado entonces replicar/3 debe cumplir que instancie todas las listas posibles (con cualquier longitud finita) donde todos sus elementos son iguales a Elem.

    Como N no está instanciada entonces la definción de replicar/3 debe encargarse de instanciarla en todos los valores posibles, de este modo obtendríamos la generación que buscamos.

    Veamos entonces que en 
    ```prolog
    length([X | T], N),
    ```
    estamos instanciando a N en todos los valores enteros posibles ¿por qué? porque el predicado length/2 es reversible en su segundo argumento, el cual -si no viene instanciado- instancia en él todos los valores posibles enteros tales que la lista del primer argumento tenga la longitud del segundo argumento. Luego de esta forma logramos una correcta instanciación de N, seguidamente podemos realizar todas las operaciones y asignaciones que deseemos haciendo uso del N instanciado como en el ítem anterior. Notemos que para cada instanciación de N haremos un llamado recursivo que podrá unificar con el caso del ítem anterior (el cuál ya verificamos que la definición es correcta y no falla).

    Es prudente comentar que si nuestra definción de replicar/3 fuera la siguiente:

    ```prolog
    replicar(_, 0, []).  
    replicar(X, N, [X | T]) :- 
        N > 0,              %
        length([X | T], N), % hicimos swap entre estos dos literales.
        M is N-1,
        replicar(X, M, T).
    ```
    entonces nuestra definición de replicar/3 no sería reversible porque fallaría al intentar validar
    ```prolog
    N > 0,
    ```
    pues N no estaría instanciado y el motor aritmético de prolog no podría realizar la operacion correctamente y devolvería una falla.

    Finalmente, al instanciar en N un valor y realizar los llamados recursivos, se instanciará en el tercer argumento de replicar/3 la lista de tamaño N donde cada elemento es Elem; y de este modo para cada valor de N entero mayor a cero posible (N perteneciente a: el conjunto de los números naturales unión con el conjunto que contiene como único elemento al número cero).

    #### Conclusión 1: la definición de replicar/3 para N no instanciada **no falla**.

    #### Conclusión 2: la definición de replicar/3 para N no instanciada **es correcta**.

De este modo podemos concluir que **nuestra definición de replicar/3 es reversible en su segundo argumento**.
