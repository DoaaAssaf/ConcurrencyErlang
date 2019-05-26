%%%-------------------------------------------------------------------
%%% @author Doaa
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. May 2019 10:48 AM
%%%-------------------------------------------------------------------
-module(hospitalV4).
-author("Doaa").

%% API
-export([start/0,start_hospital/0,hospital/0,lookup/2,addPatient/2,triage/0,provider/0]).
start_hospital() ->
  register(hospital,spawn(hospitalV4,hospital,[])),
  register(tr,spawn(hospitalV4,triage,[])),
  register(provider,spawn(hospitalV4,provider,[])),
  start().

start()->
  spawn(fun() ->
    ets:new(wat, [set, public, named_table ,{write_concurrency, true}, {read_concurrency, true}]),
    receive
      _ -> ok
    end
   end).

hospital()->
  receive
    {addnewPatient,From,Name,InjuryType} ->
      case ets:lookup(wat,Name) of
        [] ->
          tr!{requestPriority,self(),Name,InjuryType,From},
          ets:insert(wat, {Name,InjuryType,0}),
          hospital();
        [_] ->
          From!{failed,'patient exists'},
          hospital()
      end;
    {priorityWasGiven,_,From}->
      From!{ets:match(wat, '$1')},
      hospital();

    {priorityProblem,_,From,Msg}->
      From!{Msg},
      hospital()
  end.

addPatient(Name,InjuryType)->
  hospital!{addnewPatient,self(),Name,InjuryType},
  receive
    Reply -> Reply
  end.

lookup(_,[]) -> not_exist;
lookup(InjuryType,[{InjuryType,Priority}|_]) ->Priority ;
lookup(InjuryType,[_|T]) -> lookup(InjuryType,T).

triage()->
  Injuries=[{"heart attack",3},{"broken leg",1},{"broken arm",1},{"Chest pain",2},{"surgery",1},
    {"breathing problems",3}],
  receive
    {requestPriority,_,Name,Injury,From} ->
      case lookup(Injury,Injuries) of
        not_exist ->
          Msg="Medical state is not recognized, retry again from one of the following:
           heart attack, broken leg, Chest pain, surgery, breathing problems ..",
          hospital!{priorityProblem,self(),From,Msg},
          triage();
        Priority ->
          hospital!{priorityWasGiven,self(),From},
          ets:insert(wat, {Name,Injury,Priority}),
          triage()
      end
  end.

provider()->
   timer:sleep(round(timer:seconds(rand:uniform()+3))),
   ets:match_delete(wat, {'$1', '$2', 3}),
  provider(),
  timer:sleep(round(timer:seconds(rand:uniform()+1))),
  ets:match_delete(wat, {'$1', '$2', 2}),
  provider(),
  timer:sleep(round(timer:seconds(rand:uniform()+2))),
  ets:match_delete(wat, {'$1', '$2', 1}).