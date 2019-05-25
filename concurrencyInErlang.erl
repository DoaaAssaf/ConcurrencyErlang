%%%-------------------------------------------------------------------
%%% @author Doaa
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. May 2019 5:03 PM
%%%-------------------------------------------------------------------
-module('concurrencyInErlang').
-author("Doaa").

%% API
-export([demo1/0,start/0,loop/0,area/2,loop1/0,echo/0,sendMsg/2,loop3/2,loop3/3,pause/0,stop/0,continue/0]).


generate_exception(1) -> a;
generate_exception(2) -> throw(a);
generate_exception(3) -> exit(a);
generate_exception(4) -> {'EXIT', a};
generate_exception(5) -> erlang:error(a).

demo1() ->
  [catcher(I) || I <- [1,2,3,4,5]].
catcher(N) ->
  try generate_exception(N) of
    Val -> {N, normal, Val}
  catch
    throw:X -> {N, caught, thrown, X};
    exit:X -> {N, caught, exited, X};
    error:X -> {N, caught, error, X}
  end.

start() -> spawn(fun loop/0).

area(Pid, What) ->
  rpc(Pid, What).

rpc(Pid, Request) ->
  Pid ! {self(), Request},
  receive
    {Pid, Response} ->
      Response
  end.

loop() ->
  receive
    {From, {rectangle, Width, Ht}} ->
      From ! {self(),Width * Ht},
      loop();
    {From, {circle, R}} ->
      From ! {self(), 3.14159 * R * R},
      loop();
    {From, Other} ->
      From ! {self(),{error,Other}},
      loop()
  end.

echo() ->
  spawn(concurrencyInErlang,loop1,[]).

loop1() ->
  receive
    {From,Msg} when Msg=:="Ping" ->
      io:format("Mensagem de ~w : ~w~n",[From,Msg]),
      From!"pong",
      loop();
    {From,Msg}->
      io:format("Mensagem de ~w : ~w~n",[From,Msg]),
      From!"pang",
      loop()
  end.

sendMsg(Pid,Msg) ->
  Pid!{self(),Msg},
  receive
    Reply -> Reply
  end.




start_bank() ->
  register(banco,spawn(aula2,servidor,[[]])).

servidor(Contas)->
  receive
    {nova_conta,From,Nome,Montante} ->
      case lookup(Nome,Contas) of
        nao_existe ->
          From!{ok,'conta criada'},
          servidor([{Nome,Montante}|Contas]);
        _ ->
          From!{nao_existe,'conta ja existe'},
          servidor(Contas)
      end;

    {depositar,From,Nome,Montante} ->
      case lookup(Nome,Contas) of
        nao_existe ->
          From!{nao_existe,'conta nao existe'},
          servidor(Contas);
        _ ->
          From!ok,
          servidor(add(Nome,Montante,Contas))
      end;

    {consultar,From,Nome} ->
      case lookup(Nome,Contas) of
        nao_existe ->
          From!{nao_existe,'conta nao existe'},
          servidor(Contas);
        Montante ->
          From!{saldo,Montante},
          servidor(Contas)
      end;

    {levantar,From,Nome,Montante} ->
      case lookup(Nome,Contas) of
        nao_existe ->
          From!{nao_existe,'conta nao existe'},
          servidor(Contas);
        Saldo when Saldo >= Montante ->
          From!{ok,Saldo-Montante},
          servidor(add(Nome,-Montante,Contas));
        _ ->
          From!{nao_existe,'saldo insuficiente'},
          servidor(Contas)
      end
  end.

add(Nome,Montante,[{Nome,Saldo}|T]) -> [{Nome,Saldo+Montante}|T];
add(Nome,Montante,[H|T]) -> [H|add(Nome,Montante,T)].

lookup(_,[]) -> nao_existe;
lookup(Nome,[{Nome,Saldo}|_]) -> Saldo;
lookup(Nome,[_|T]) -> lookup(Nome,T).



abrir_conta(Nome,Montante) ->
  banco!{nova_conta,self(),Nome,Montante},
  receive
    Reply -> Reply
  end.

depositar(Nome,Montante) ->
  banco!{depositar,self(),Nome,Montante},
  receive
    Reply -> Reply
  end.

consultar(Nome) ->
  banco!{consultar,self(),Nome},
  receive
    Reply -> Reply
  end.

levantar(Nome,Montante) ->
  banco!{levantar,self(),Nome,Montante},
  receive
    Reply -> Reply
  end.




loop3(M,S,pause) ->
  io:format("Cronometro parado.~n"),
  receive
    continue ->
      loop3(M,S+1);
    stop ->
      io:format("Cronometro a zero.~n")
  end.

% Quando chega aos 60 segundos
loop3(M,60) ->
  loop3(M+1,0);

% Incrementa o contador a cada segundo que passa
loop3(M,S) ->
  io:format("~w:~w~n",[M,S]),
  receive
    stop ->
      io:format("Cronometro a zero.~n");
    pause ->
      loop3(M,S,pause)
  after 1000 ->
    loop3(M,S+1)
  end.


% Desliga o cron�metro
stop() ->
  clock!stop,
  unregister(clock).

% Para o cron�metro
pause() ->
  clock!pause,
  ok.

% Continua a contagem
continue() ->
  clock!continue,
  ok.
