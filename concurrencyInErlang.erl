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
