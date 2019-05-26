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
-export([start/0,loop/0,area/2,loop1/0,echo/0,sendMsg/2]).


%%calculate the square area of a shape
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



%%if the process receives the message "ping", returns "pong" and otherwise returns "pang".
echo() ->
  spawn(concurrencyInErlang,loop1,[]).

loop1() ->
  receive
    {From,Msg} when Msg=:="Ping" ->
      io:format("Msg ~w : ~w~n",[From,Msg]),
      From!"pong",
      loop();
    {From,Msg}->
      io:format("Msg ~w : ~w~n",[From,Msg]),
      From!"pang",
      loop()
  end.

sendMsg(Pid,Msg) ->
  Pid!{self(),Msg},
  receive
    Reply -> Reply
  end.
