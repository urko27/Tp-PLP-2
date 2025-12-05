# Ejercicio 12: Reversibilidad

Indicar si el predicado replicar/3 es reversible en el segundo argumento. En concreto se pide analizar si
replicar(+Elem,-N,-Lista) funciona correctamente.

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
replicar(X, N, L) :-
	length(L, N),
	maplist(=(X), L).
```

Analicemos la reversibilidad del segundo argumento N, en el caso en que este no viene instanciado:

- ### **N no está instanciada:**

    Si N no está instanciado entonces replicar/3 debe cumplir que instancie todas las listas posibles (con cualquier longitud finita) donde todos sus elementos son iguales a Elem.

    Como N no está instanciada entonces la definción de replicar/3 debe encargarse de instanciarla en todos los valores posibles, de este modo obtendríamos la generación que buscamos.

    Veamos entonces que en 
    ```prolog
    length(L, N)
    ```
    estamos instanciando en N todos los valores enteros posibles ¿por qué? porque el predicado length/2 es reversible en sus dos argumentos.
    <br>
    <br>
    Cuando ninguno de los argumentos están instanciados, se empiezan a generar soluciones y Prolog entra en un modo de enumeración infinita unificando L con N con todas las posibles longitudes de lista, empezando por 0.

    Podemos pensar la definicion de length de la siguiente manera:
    ```prolog
    length([], 0).
    length([_|T], N) :-
        length(T, N0),
        N is N0 + 1.
    ```

    Por lo tanto, Prolog primero va a entrar en el primer caso e instanciar L en la lista vacía y N en 0. 
    <br>
    Al pedirle la siguiente solución va a entrar en el segundo caso. Al entrar en el segundo caso unifica L con una lista que contiene por lo menos un elemento **[ _ | T ]**, y hace el llamado recursivo, que en este caso va a caer en el caso base y T va a unificar con la lista vacía y N0 con 0. De esta manera el siguiente resultado será N = 1, y L la lista de un elemento con una variable sin instanciar.
    <br><br>
    Mientras sigamos pidiendo soluciones este proceso se va repitiendo agregando un nivel más de recursión en cada solución. De esta manera N se va incrementando en 1, y el tamaño de la lista también en 1 agregando una variable sin instanciar.

    Volviendo al predicado replicar, ya vimos que con L y N sin instanciar, length empieza a generar listas de tamaño creciente empezando desde cero, con variables sin instanciar en sus elementos. Luego se ejecuta el maplist, y a cada variable sin instanciar se le asigna el valor Elem que si esta instanciado.

    #### Conclusión 1: la definición de replicar/3 para N no instanciada **no falla**.

    #### Conclusión 2: la definición de replicar/3 para N no instanciada **es correcta**.

De este modo podemos concluir que **nuestra definición de replicar/3 es reversible en su segundo argumento**.
