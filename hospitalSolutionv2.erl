%%%-------------------------------------------------------------------
%%% @author Doaa
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. May 2019 10:48 AM
%%%-------------------------------------------------------------------
-module(hospitalSolutionv2).
-author("Doaa").

%% API
-export([start/0,start_hospital/0,hospital/1,lookup/3,lookup/2,addPatient/2,tr/0,delete/2]).
start_hospital() ->
  register(hospitalPid29,spawn(hospitalSolutionv2,hospital,[[]])),
  register(trPid29,spawn(hospitalSolutionv2,tr,[])),
  register(providerPid29,spawn(hospitalSolutionv2,provider,[])),
  start().

start()->
  spawn(fun() ->
    ets:new(wat13, [set, public, named_table ,{write_concurrency, true}, {read_concurrency, true}]),
    receive
      _ -> ok
    end
        end).

hospital(Patients)->
  receive
    {addnewPatient,From,Name,InjuryType} ->
      case lookup(Name,InjuryType,Patients) of
        not_exist ->
          trPid29!{requestPriority,Name,InjuryType,From},
          hospital(Patients);
        _ ->
          From!{failed,'patient already exists'},
          hospital(Patients)
      end;
    {priorityWasGiven,_,Name,InjuryType,From,Priority}->
      From!{ok,'patient added'},
      io:format("~w : ~w~n",[Name,Priority]),
      hospital([{Name,InjuryType,Priority}|Patients]);

    {priorityProblem,_,From,Msg}->
      From!{Msg},
      hospital(Patients);
    {remove_patient,_,Name,InjuryType,Priority}->
      delete({Name,InjuryType,Priority},Patients),
      hospital(Patients)

  end.

delete(_,[]) -> [];
delete(X,[X|T])-> T;
delete(X,[Y|T])-> [Y|delete(X,T)].

lookup(_,_,[]) -> not_exist;
lookup(Name,InjuryType,[{Name,InjuryType,_}|_]) -> InjuryType;
lookup(Name,InjuryType,[_|T]) -> lookup(Name,InjuryType,T).


addPatient(Name,InjuryType)->

%%  YourTimeOut = 60000,
  hospitalPid29!{addnewPatient,self(),Name,InjuryType},
  receive

    Reply -> Reply
%%  after
%%    YourTimeOut -> exit(timeout)
  end.

lookup(_,[]) -> not_exist;
lookup(InjuryType,[{InjuryType,Priority}|_]) ->Priority ;
lookup(InjuryType,[_|T]) -> lookup(InjuryType,T).

tr()->
  Injuries=[{"heart attack",3},{"broken leg",1},{"broken arm",1},{"Chest pain",2},{"surgery",1},
    {"breathing problems",3}],
  receive
    {requestPriority,Name,Injury,From} ->
      case lookup(Injury,Injuries) of
        not_exist ->
          Msg="Medical state is not recognized, retry again from one of the following:
           heart attack, broken leg, Chest pain, surgery, breathing problems ..",
          hospitalPid29!{priorityProblem,self(),From,Msg},
          tr();
        Priority ->
          hospitalPid29!{priorityWasGiven,self(),Name,Injury,From,Priority},
          tr()
      end
  end.

