% Ejercicio 1
matriz(F, C, M) :- length(M, F), columnas(M, C).
columnas(M, C) :- maplist(length_c(C), M).

length_c(C, Fila) :- length(Fila, C).

% Ejercicio 2
replicar(X, N, L) :-
	length(L, N),
	maplist(=(X), L).

% Ejercicio 3
%fila_a_columna(+M, -F, -R)
fila_a_columna([], [], []).
fila_a_columna([[HFila | TFila] | TMatriz], [HFila | Tcol], [TFila | TRes]) :- 
	fila_a_columna(TMatriz, Tcol, TRes).

transponer([[] | _], []).
transponer(M, [H | T]) :-
	fila_a_columna(M, H, Res),
	transponer(Res, T).

% Predicado dado armarNono/3
armarNono(RF, RC, nono(M, RS)) :-
	length(RF, F),
	length(RC, C),
	matriz(F, C, M),
	transponer(M, Mt),
	zipR(RF, M, RSFilas),
	zipR(RC, Mt, RSColumnas),
	append(RSFilas, RSColumnas, RS).

zipR([], [], []).
zipR([R|RT], [L|LT], [r(R,L)|T]) :- zipR(RT, LT, T).

% Ejercicio 4

% Caso Base: No hay celdas para pintar, se completan indefectiblemente con 'o'
% Caso recursivo con una única resitrccion: Se diferencia del segundo caso recursivo en que no hay que obligatoriamente completar con una 'o' al final.
% Caso recursivo con mas de una restricción: Se asigna una 'o' luego de cada bloque de pintadas para separar y hacer el backtracking luego. 
% Con el length de la cola mayor a 0 aseguramos mas de una restricción.

% APPROACH 1
% pintadasValidas(r([], L)) :- length(L, N), replicar(o, N, L).
% pintadasValidas(r([H], L)) :- length(L, N),
% 								N >= H,
% 								replicar(x, H, Pintadas),								 
% 								K is N - H,
% 								between(0, K, U), 
% 								V is K - U,
% 								replicar(o, U, Anterior),
% 								replicar(o, V, Posterior),	
% 								append(Anterior, Pintadas, L1),
% 								append(L1, Posterior, L).
% pintadasValidas(r([H | T], L)) :- length(L, N), length(T, Y), Y > 0,
% 										N >= H + 1,
% 										replicar(x, H, Pintadas),
% 										append(Pintadas, [o], Medio),
% 										K is N - H - 1, 
% 										between(0, K, U), 
% 										replicar(o, U, Anterior),
% 										append(Anterior, Medio, L1),									
% 										V is K - U, 
% 										length(Posterior, V), 
% 										pintadasValidas(r(T, Posterior)),
% 										append(L1, Posterior, L).	
% APPROACH 1

% APPROACH PRIME
pintadasValidas(r(Restricciones, L)) :- resolver(Restricciones, L).

resolver([], L) :- dejarVacio(L).
resolver([R|Rs], [o|Resto]) :- resolver([R|Rs], Resto).
resolver([R|Rs], L) :-
    pintarRestriccion(R, L, Resto), agregarSinPintar(Rs, Resto).

pintarRestriccion(0, L, L).
pintarRestriccion(N, [x|T], Resto) :- 
    N > 0, N1 is N - 1, 
    pintarRestriccion(N1, T, Resto).

agregarSinPintar([], L) :- dejarVacio(L).
agregarSinPintar([R|Rs], [o|Resto]) :- resolver([R|Rs], Resto).

dejarVacio([]).
dejarVacio([o|T]) :- dejarVacio(T).
% APPROACH PRIME

% APPROACH 2
pintadasValidas(r([], L)) :- dejarVacio(L).
pintadasValidas(r([R|RS], L)) :-
	length(L, N),
	between(0, N, Y),
	pintadasRec(r([R|RS], L), Y).

pintadasRec(r([], L), _) :- dejarVacio(L).
pintadasRec(r([R], L), SP) :- pintarRestriccion(R, L, SP, Ultimas), pintadasRec(r([], Ultimas), _).
pintadasRec(r([R|[RH|RT]], L), SP) :- pintarRestriccion(R, L, SP, Ultimas), 
	length(Ultimas, Resto), 
	between(1, Resto, Y),
	pintadasRec(r([RH|RT], Ultimas), Y).

pintarRestriccion(R, L, SP, Ultimas) :-
	length(L, N), R =< N,
	replicar(o, SP, NoPintadas),
	replicar(x, R, Pintadas),
	append(NoPintadas, Pintadas, Primeras),
	append(Primeras, Ultimas, L).

dejarVacio(L) :- length(L, N), replicar(o, N, L).
% APPROACH 2

% Ejercicio 5 
resolverNaive(nono(_, RSS)) :- maplist(pintadasValidas, RSS).

% Ejercicio 6
% Se genera el predicado auxiliar intersecar/2 para ir armando la fila/columna con las pintadas que están en todas las posibles soluciones válidas.
pintarObligatorias(r(R, L)) :- setof(L, pintadasValidas(r(R, L)), C), intersecarVariasListas(C, L).

intersecarVariasListas([A], A).
intersecarVariasListas([H, T | TS], S) :- 
	intersecarDosListas(H, T, G), intersecarVariasListas([G | TS], S).

% IntersecarDos/3 hace una intersección en un par de listas. 
intersecarDosListas(L1, L2, LS) :- maplist(combinarCelda, L1, L2, LS).

% Predicado dado combinarCelda/3
combinarCelda(A, B, _) :- var(A), var(B).
combinarCelda(A, B, _) :- nonvar(A), var(B).
combinarCelda(A, B, _) :- var(A), nonvar(B).
combinarCelda(A, B, A) :- nonvar(A), nonvar(B), A = B.
combinarCelda(A, B, _) :- nonvar(A), nonvar(B), A \== B.

% Ejercicio 7
deducir1Pasada(nono(_, RSS)) :- maplist(pintarObligatorias, RSS).

% Predicado dado
cantidadVariablesLibres(T, N) :- term_variables(T, LV), length(LV, N).

% Predicado dado
deducirVariasPasadas(NN) :-
	NN = nono(M,_),
	cantidadVariablesLibres(M, VI), % VI = cantidad de celdas sin instanciar en M en este punto
	deducir1Pasada(NN),
	cantidadVariablesLibres(M, VF), % VF = cantidad de celdas sin instanciar en M en este punto
	deducirVariasPasadasCont(NN, VI, VF).

% Predicado dado
deducirVariasPasadasCont(_, A, A). % Si VI = VF entonces no hubo más cambios y frenamos.
deducirVariasPasadasCont(NN, A, B) :- A =\= B, deducirVariasPasadas(NN).

% Ejercicio 8
restriccionConMenosLibres(nono(_, RSS), r(RS1, R)) :-	
												cantidadLibresNoNulas(r(RS1, R), RSS, CMin),
												not((
													cantidadLibresNoNulas((r(_, _)), RSS, C), 
													C < CMin
												)).

cantidadLibresNoNulas(r(RS1, R), RSS, C) :- 
	member((r(RS1, R)), RSS), 
	cantidadVariablesLibres(R, C), 
	C > 0.

% Ejercicio 9
% Aca aplicamos recursión y el predicado not para armar clausulas disjuntas con el "esSolucion", en este caso, corta la búsqueda y si, no es solución continúa backtrackeando. 
% Se utiliza el cut para no generar multiples soluciones iguales. por ejemplo, sin el cut puesto ahí, generaba 6457 soluciones para el nonograma que debía devolver tan sólo 36 soluciones. 
resolverDeduciendo(NN) :- deducirVariasPasadas(NN), resolverDeduciendoRec(NN).

resolverDeduciendoRec(NN) :- esSolucion(NN).
resolverDeduciendoRec(NN) :- not(esSolucion(NN)),
								restriccionConMenosLibres(NN, R), ! ,
								pintadasValidas(R),
								resolverDeduciendo(NN).


% es Solucion cuando no tiene variables libres, es decir, todas las celdas de la matriz estan asignadas.
esSolucion(nono(_, RSS)) :- 
    maplist(sinVariablesLibres, RSS).
sinVariablesLibres(r(_, F)) :- 
    cantidadVariablesLibres(F, 0).

% Ejercicio 10

% Encontramos todas las soluciones posibles, y verificamos que haya una sola.
solucionUnica(NN) :- findall(NN, resolverDeduciendo(NN), L), length(L, 1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              %
%    Ejemplos de nonogramas    %
%        NO MODIFICAR          %
%    pero se pueden agregar    %
%                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fáciles
nn(0, NN) :- armarNono([[1],[2]],[[],[2],[1]], NN).
nn(1, NN) :- armarNono([[4],[2,1],[2,1],[1,1],[1]],[[4],[3],[1],[2],[3]], NN).
nn(2, NN) :- armarNono([[4],[3,1],[1,1],[1],[1,1]],[[4],[2],[2],[1],[3,1]], NN).
nn(3, NN) :- armarNono([[2,1],[4],[3,1],[3],[3,3],[2,1],[2,1],[4],[4,4],[4,2]], [[1,2,1],[1,1,2,2],[2,3],[1,3,3],[1,1,1,1],[2,1,1],[1,1,2],[2,1,1,2],[1,1,1],[1]], NN).
nn(4, NN) :- armarNono([[1, 1], [5], [5], [3], [1]], [[2], [4], [4], [4], [2]], NN).
nn(5, NN) :- armarNono([[], [1, 1], [], [1, 1], [3]], [[1], [1, 1], [1], [1, 1], [1]], NN).
nn(6, NN) :- armarNono([[5], [1], [1], [1], [5]], [[1, 1], [2, 2], [1, 1, 1], [1, 1], [1, 1]], NN).
nn(7, NN) :- armarNono([[1, 1], [4], [1, 3, 1], [5, 1], [3, 2], [4, 2], [5, 1], [6, 1], [2, 3, 2], [2, 6]], [[2, 1], [1, 2, 3], [9], [7, 1], [4, 5], [5], [4], [2, 1], [1, 2, 2], [4]], NN).
nn(8, NN) :- armarNono([[5], [1, 1], [1, 1, 1], [5], [7], [8, 1], [1, 8], [1, 7], [2, 5], [7]], [[4], [2, 2, 2], [1, 4, 1], [1, 5, 1], [1, 8], [1, 7], [1, 7], [2, 6], [3], [3]], NN).
nn(9, NN) :- armarNono([[4], [1, 3], [2, 2], [1, 1, 1], [3]], [[3], [1, 1, 1], [2, 2], [3, 1], [4]], NN).
nn(10, NN) :- armarNono([[1], [1], [1], [1, 1], [1, 1]], [[1, 1], [1, 1], [1], [1], [ 1]], NN).
nn(11, NN) :- armarNono([[1, 1, 1, 1], [3, 3], [1, 1], [1, 1, 1, 1], [8], [6], [10], [6], [2, 4, 2], [1, 1]], [[2, 1, 2], [4, 1, 1], [2, 4], [6], [5], [5], [6], [2, 4], [4, 1, 1], [2, 1, 2]], NN).
nn(12, NN) :- armarNono([[9], [1, 1, 1, 1], [10], [2, 1, 1], [1, 1, 1, 1], [1, 10], [1, 1, 1], [1, 1, 1], [1, 1, 1, 1, 1], [1, 9], [1, 2, 1, 1, 2], [2, 1, 1, 1, 1], [2, 1, 3, 1], [3, 1], [10]], [[], [9], [2, 2], [3, 1, 2], [1, 2, 1, 2], [3, 11], [1, 1, 1, 2, 1], [1, 1, 1, 1, 1, 1], [3, 1, 3, 1, 1], [1, 1, 1, 1, 1, 1], [1, 1, 1, 3, 1, 1], [3, 1, 1, 1, 1], [1, 1, 2, 1], [11], []], NN).
nn(13, NN) :- armarNono([[2], [1,1], [1,1], [1,1], [1], [], [2], [1,1], [1,1], [1,1], [1]], [[1], [1,3], [3,1,1], [1,1,3], [3]], NN).
nn(14, NN) :- armarNono([[1,1], [1,1], [1,1], [2]], [[2], [1,1], [1,1], [1,1]], NN).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              %
%    Predicados auxiliares     %
%        NO MODIFICAR          %
%                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%! completar(+S)
%
% Indica que se debe completar el predicado. Siempre falla.
completar(S) :- write("COMPLETAR: "), write(S), nl, fail.

%! mostrarNono(+NN)
%
% Muestra una estructura nono(...) en pantalla
% Las celdas x (pintadas) se muestran como ██.
% Las o (no pintasdas) se muestran como ░░.
% Las no instanciadas se muestran como ¿?.
mostrarNono(nono(M,_)) :- mostrarMatriz(M).

%! mostrarMatriz(+M)
%
% Muestra una matriz. Solo funciona si las celdas
% son valores x, o, o no instanciados.
mostrarMatriz(M) :-
	M = [F|_], length(F, Cols),
	mostrarBorde('╔',Cols,'╗'),
	maplist(mostrarFila, M),
	mostrarBorde('╚',Cols,'╝').

mostrarBorde(I,N,F) :-
	write(I),
	stringRepeat('══', N, S),
	write(S),
	write(F),
	nl.

stringRepeat(_, 0, '').
stringRepeat(Str, N, R) :- N > 0, Nm1 is N - 1, stringRepeat(Str, Nm1, Rm1), string_concat(Str, Rm1, R).

%! mostrarFila(+M)
%
% Muestra una lista (fila o columna). Solo funciona si las celdas
% son valores x, o, o no instanciados.
mostrarFila(Fila) :-
	write('║'),
	maplist(mostrarCelda, Fila),
	write('║'),
	nl.

mostrarCelda(C) :- nonvar(C), C = x, write('██').
mostrarCelda(C) :- nonvar(C), C = o, write('░░').
mostrarCelda(C) :- var(C), write('¿?').

% Predicados auxiliares para analisis.
tam(N, (F, C)) :- nn(N, nono(M, _)), matriz(F, C, M).
tamanios(N, (F, C)) :- between(0, 14, N), tam(N, (F, C)).
solucionesUnicas(N) :- between(0, 14, N), nn(N, NN), solucionUnica(NN).

casillerosInstanciados([]).
casillerosInstanciados([H | T]) :- nonvar(H), casillerosInstanciados(T).

todasInstanciadas([]).
todasInstanciadas([H | T]) :- casillerosInstanciados(H), todasInstanciadas(T).
deduciblesSinBacktrack(N) :- between(0, 14, N), nn(N, NN), deducirVariasPasadas(NN), NN = nono(M,_), todasInstanciadas(M).