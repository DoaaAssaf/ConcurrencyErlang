%%%-------------------------------------------------------------------
%%% @author Doaa
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. May 2019 10:48 AM
%%%-------------------------------------------------------------------
-module(hospitalSolution).
-author("Doaa").

%% API
-export([start_hospital/0,hospital/1,lookup/3,addPatient/2]).
start_hospital() ->
  register(hospitalPid5,spawn(hospitalSolution,hospital,[[]])).

hospital(Patients)->
  receive
    {addnewPatient,From,Name,InjuryType} ->
      case lookup(Name,InjuryType,Patients) of
        not_exist ->
          From!{ok,'patient added'},
          hospital([{Name,InjuryType}|Patients]);
        _ ->
          From!{failed,'patient already exists'},
          hospital(Patients)
      end
  end.

lookup(_,_,[]) -> not_exist;
lookup(Name,InjuryType,[{Name,InjuryType}|_]) -> InjuryType;
lookup(Name,InjuryType,[_|T]) -> lookup(Name,InjuryType,T).


addPatient(Name,InjuryType)->
  YourTimeOut = 10000,
  hospitalPid5!{addnewPatient,self(),Name,InjuryType},
  receive
    Reply -> Reply
  after
    YourTimeOut -> exit(timeout)
  end.
