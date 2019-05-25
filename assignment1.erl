%%%-------------------------------------------------------------------
%%% @author Doaa
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. May 2020 5:20 PM
%%%-------------------------------------------------------------------
-module(assignment1).
-author("Doaa").

%% API
-export([start_hospital/0,hospital/1,lookup/2,addPatient/2,tr/0]).
%-on_load(start_hospital/0).

start_hospital() ->
  register(hospitalP5,spawn(assignment1,hospital,[[]])),
  register(trPid5,spawn(assignment1,tr,[])).

hospital(Patients)->
  receive
    {newPatient,From,Name,Injury} ->
      case lookup(Name,Patients) of
        not_exist ->
%%          From!{ok,'patient added'},
          hospital([{Name,Injury}|Patients]),
          From!{ok,'patient added'};
%%        trPid5!{requestPriority,Name,Injury,From};
      _ ->
          From!{failed,'patient already exists'},
          hospital(Patients)
      end
  end.

lookup(_,[]) -> not_exist;
lookup(Name,[{Name,Value}|_]) -> Value;
lookup(Name,[_|T]) -> lookup(Name,T).

addPatient(Name,Injury)->
  hospitalP5!{newPatient,self(),Name,Injury},
  receive
    Reply -> Reply
  end.

tr()->
  receive
    {requestPriority,Name,Injury,From} ->
      From!{ok,'patient added'},
      hospitalP5!{priorityWasGiven,self(),Name,Injury,From,1}
  end.