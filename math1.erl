%%%-------------------------------------------------------------------
%%% @author Doaa
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. May 2019 5:03 PM
%%%-------------------------------------------------------------------
-module('math1').
-author("Doaa").

%% API
-export([square/1,temp_convert/1,fib/1,factorial/1,count/1,reverse1/1,qsort/1,printInt/1,exists/2,delete/2,sum/1,average/1,maximum/2,sum_max/2,max_grade/1]).
%square a number%
square(X) -> X*X.

%temperature from f to c%
temp_convert(F)->5*(F-32)/9.

%fibonacci%
fib(0) -> 0;
fib(1) -> 1;
fib(N) -> fib(N-1)+fib(N-2).


%find factorial%
factorial(0) -> 1;
factorial(N) -> N * factorial(N-1).


%reverse an array%
reverse1([])->[];
reverse1([H|T])->reverse1(T)++[H].

%quick sort%
qsort([]) -> [];
qsort([Pivot|T]) -> qsort([X || X <- T, X < Pivot]) ++ [Pivot] ++ qsort([X || X <- T, X >= Pivot]).

%prints integers in an array%
printInt([]) -> [];
printInt([H|T]) when is_integer(H)-> io:fwrite("~p~n is an integer",[H]),[H|printInt(T)];
printInt([_|T]) -> printInt(T).

%delete element from list%
delete(_,[]) -> [];
delete(X,[X|T])-> T;
delete(X,[Y|T])-> [Y|delete(X,T)].


%check if element exists in a list%
exists([H|_],X) when H=:=X ->  io:fwrite("element exists");
exists([],_)->  io:fwrite("element NOT found");
exists([H|T],X) -> [H|exists(T,X)].


%count the elements  in an array%
count([]) -> 0;
count([_|L])-> 1+ count(L).


%the sum of an list%
sum([])->0;
sum([X|L])-> X + sum(L).


%the average of a list#
average(L1)-> sum(L1)/count(L1).

%find the max of a list%
maximum(Max,[])->Max;
maximum(Max,[H|T]) when H>Max ->maximum(H,T);
maximum(Max,[_|T])->maximum(Max,T).

%given two lists, finds the higher value of each of them and returns their sum.%
sum_max([],[])->0;
sum_max([H|T],[H2|T2])-> maximum(H,T)+maximum(H2,T2).

%find max grade from a list of students' grades %
max_grade([H|T])-> max_grade(H,T).
max_grade(Max,[])-> Max;
max_grade({_,MaxGrade},[{Name,Grade}|T]) when Grade>MaxGrade -> max_grade({Name,Grade},T);
max_grade(Max,[_|T])-> max_grade(Max,T).
