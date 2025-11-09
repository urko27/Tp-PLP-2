% Ejercicio 1
matriz(F, C, M) :- append([], M, _), length(M, F), columnas(M, C).

columnas([], _).
columnas([H|T], C) :- length(H, C), columnas(T, C).

% Ejercicio 2
% Preguntar porque sucede el ; en la implementacion actual, 
% vs la implementacion con funcion auxiliar.
% replicar(X, N, L) :- append([], L, _), length(L, N), todosX(X, L).

% todosX(_, []).
% todosX(X, [X|T]) :- todosX(X, T).

replicar(_, 0, []).  
replicar(X, N, [X | T]) :-
	length([X | T], N),
	N > 0,
	M is N-1,
	replicar(X, M, T).

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

pintadasValidas(r([], L)) :- length(L, N), replicar(o, N, L).

pintadasValidas(r([H], L)) :- 	length(L, N),
								N >= H,
								replicar(x, H, Pintadas),								 
								K is N - H,
								between(0, K, U), 
								V is K - U,
								replicar(o, U, Anterior),
								replicar(o, V, Posterior),	
								append(Anterior, Pintadas, L1),
								append(L1, Posterior, L).

pintadasValidas(r([H | T], L)) :- 		length(L, N), length(T, Y), Y > 0,
										N >= H + 1,
										replicar(x, H, Pintadas),
										append(Pintadas, [o], Medio),
										K is N - H - 1, 
										between(0, K, U), 
										replicar(o, U, Anterior),
										append(Anterior, Medio, L1),									
										V is K - U, 
										length(Posterior, V), 
										pintadasValidas(r(T, Posterior)),
										append(L1, Posterior, L).	

											
% Ejercicio 5
resolverNaive(nono(_, [])).
resolverNaive(nono(M, [r(R, Fila) | RSS])) :- 
								pintadasValidas(r(R, Fila)),
								resolverNaive(nono(M, RSS)). 

% Ejercicio 6
pintarObligatorias(r(R, L)) :- 	setof(L, pintadasValidas(r(R, L)), C),
								intersectar(C, L).
							
intersectar([A], A).
intersectar([H, T | TS], S) :-  cruzar(H, T, G), intersectar([ G | TS], S).								

cruzar([], [], []).
cruzar([X | T1], [Y | T2], [Z | T]) :- combinarCelda(X, Y, Z), cruzar(T1, T2, T).

% Predicado dado combinarCelda/3
combinarCelda(A, B, _) :- var(A), var(B).
combinarCelda(A, B, _) :- nonvar(A), var(B).
combinarCelda(A, B, _) :- var(A), nonvar(B).
combinarCelda(A, B, A) :- nonvar(A), nonvar(B), A = B.
combinarCelda(A, B, _) :- nonvar(A), nonvar(B), A \== B.

% Ejercicio 7
deducir1Pasada(nono(_, [])).
deducir1Pasada(nono(M, [r(L, R) | RS])) :- pintarObligatorias(r(L, R)), deducir1Pasada(nono(M, RS)).

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
												member((r(RS1, R)), RSS),
												cantidadVariablesLibres(R, CantMin),  
												CantMin > 0, 
												not((	
														member((r(_, Restriccion)), RSS),
														cantidadVariablesLibres(Restriccion, Cant), 
														Cant > 0,
														Cant < CantMin)).

% Ejercicio 9
resolverDeduciendo(NN) :- deducirVariasPasadas(NN), resolverDeduciendoRec(NN).
	%setof(NN, (deducirVariasPasadas(NN), resolverDeduciendoRec(NN)), Res).

resolverDeduciendoRec(NN) :-	esSolucion(NN).

resolverDeduciendoRec(NN) :-	not(esSolucion(NN)),
								restriccionConMenosLibres(NN, R), ! ,
								pintadasValidas(R),
								resolverDeduciendo(NN).

esSolucion(nono(_, [])).
esSolucion(nono(M, [r(_, F) | T])) :- 	not((cantidadVariablesLibres(F, N), N > 0)), 
										esSolucion(nono(M, T)).


% Ejercicio 10
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
deduciblesSinBacktrack(N) :- between(0, 14, N), nn(N, NN), resolverDeduciendo(NN).