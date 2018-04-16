%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 四月 2018 17:00
%%%-------------------------------------------------------------------
-module(prime_tester_server).
-author("Administrator").
-behaviour(gen_server).
%% API
-export([start_link/1,isPrime/2,init/1,handle_info/2,handle_cast/2,handle_call/3,code_change/3,terminate/2,isBusy/1]).

start_link(Name) ->
  io:format("1~n"),
  spawn(fun () -> loop(empty)end ),
  io:format("2~n"),
  Pid = gen_server:start_link({local,Name},?MODULE,[],[]),
  io:format("~w ~n",[Pid]) .
%%%%  register(Name,_Pid),
%%  io:format("1111").


isBusy(Name) ->gen_server:call(Name,{isBusy}).

isPrime(Name,Number) ->gen_server:call(Name,{isPrime,{Number}}).

loop(State)->
  receive
    {getState,From} ->
      From! {From,State},
      loop(State);
    {setBusy} ->loop(busy);
    {setEmpty}->loop(empty)
  end.

sleep(Time) ->
  receive
    after Time ->stop
  end.


%%%----------------------------------------------------------------------------------
init([]) -> {ok,empty}.

handle_call({isBusy},From,State)->
  io:format("1handle_call,isBusy~n"),
  self() ! {getState,From},
  io:format("2handle_call,isBusy~n"),
  receive
    {From,State}->
      case catch State of
        empty -> {reply,true,State};
        busy  -> {reply,false,State};
        _    ->{reply,err,State}
      end
  end;

handle_call({isprime,_Number},_From,_State)->
  self() ! {setBusy},
  sleep(100),
  Ans = true,
  self() !{setEmpty},
  {reply,Ans,_State}.

handle_cast(_Request,_State) -> {noreply,_State}.

handle_info(_Info,State) -> {noreply,State}.

code_change(_OldVsn,State,_Extra) ->{ok,State}.

terminate(_Reason,_State) -> ok.


