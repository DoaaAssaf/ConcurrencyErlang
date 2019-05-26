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
-export([start_hospital/0,hospital/0,lookup/2,add_patient/2,triage/0,medical_provider/0,delete_priority/1]).

%%spawn the 3 processes the main hospital process, the triage process, and the medical providers one
%%and start the ETS table process
start_hospital() ->
  register(hospital,spawn(hospitalV4,hospital,[])),
  register(triage,spawn(hospitalV4,triage,[])),  
  register(medical_provider,spawn(hospitalV4,medical_provider,[])),
  start_patient_table().


%create the ETS table. its name is patient_table with some options
%%the most important option is  write_concurrency && read_concurrency that allows
%% many process to access the shared resource
start_patient_table()->
  spawn(fun() ->
    ets:new(patient_table, [set, public, named_table ,{write_concurrency, true}, {read_concurrency, true}]),
    receive
      _ -> ok
    end
   end).


hospital()->
  receive
    {addnewPatient,From,Name,Medical_status} ->
      %%  if we can't find the patient name in our table (the lookup ETS function will return empty list in this case)
      %% we will send it to the artiage process to give him his priority value
      %% , otherwise we will response wih the failed message
      case ets:lookup(patient_table,Name) of
        [] ->
          triage!{requestPriority,self(),Name,Medical_status,From},
          hospital();
        [_] ->
          From!{failed,'patient already exists!'},
          hospital()
      end;
    {priorityWasGiven,_,From}->
      %% just for test the patients queue and the health prividers service
      %%  we can send back all the patients in our table we can use the following
       From!{ets:match(patient_table, '$1')},
%%      From!{done,'the patient data was inserted successfully!'},
      hospital();

    %% if we couldn't find the injury type in our list, the triage will return error message
    %% this message will be sent back to the user
    {priorityProblem,_,From,Msg}->
      From!{Msg},
      hospital()
  end.



add_patient(Name,Medical_status)->
  hospital!{addnewPatient,self(),Name,Medical_status},
  receive
    Reply -> Reply
  end.


%%lookup function to find the medical state priority from a predefined list of
%%injuries that the user can insert
lookup(_,[]) -> not_exist;
lookup(Medical_status,[{Medical_status,Priority}|_]) ->Priority ;
lookup(Medical_status,[_|T]) -> lookup(Medical_status,T).



triage()->
  %% the predefined list from the available medical states form the user to insert
  Medical_status_list=[{"heart attack",3},{"broken leg",1},{"broken arm",1},{"Chest pain",2},{"surgery",1},
    {"breathing problems",3}],
  receive
    {requestPriority,_,Name,Medical_status,From} ->
      case lookup(Medical_status,Medical_status_list) of
        not_exist ->
          Msg="Medical state is not recognized, retry again from one of the following:
           heart attack, broken leg, Chest pain, surgery, breathing problems ..",
          hospital!{priorityProblem,self(),From,Msg},
          triage();
        Priority ->
          hospital!{priorityWasGiven,self(),From},
          ets:insert(patient_table, {Name,Medical_status,Priority}),
          triage()
      end
  end.

%% to simulate the real-life situation
%% the health provider will call this function to sleep and run after a random time
%% then delete the highest priority medical status which is 3 in our case then 2 then 1 recursively

delete_priority(Priority)->
  if Priority == 1 ->
    timer:sleep(round(timer:seconds(rand:uniform()+2))),
    ets:match_delete(patient_table, {'$1', '$2', Priority});
    true ->
      timer:sleep(round(timer:seconds(rand:uniform()+4))),
      ets:match_delete(patient_table, {'$1', '$2',Priority}),
      delete_priority(Priority-1)
  end.


medical_provider()-> delete_priority(3),
medical_provider().
