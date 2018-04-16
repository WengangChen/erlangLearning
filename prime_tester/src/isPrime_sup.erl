%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 四月 2018 17:58
%%%-------------------------------------------------------------------
-module(isPrime_sup).
-author("Administrator").
-behaviour(supervisor).
%% API
-export([start/1, init/1, integerToAtom/1]).

start(ChildList) ->
  spawn(fun() -> supervisor:start_link({local, ?MODULE}, ?MODULE, _Arg = [ChildList]) end).
%%  io:format("IsPrime Pid:~w~n",[Pid]),
%%  is_list(setProcessList(4)).

integerToAtom(Number) -> list_to_atom(integer_to_list(Number)).


setProcessList(0,_ChildList) -> [];
setProcessList(Number,ChildList) ->
  TmpAtom = integerToAtom(Number),
  ets:insert(ChildList,{TmpAtom,Number}),
  [{integerToAtom(Number), {prime_tester_server, start_link, [integerToAtom(Number)]}, permanent, 10000, worker, [prime_tester_server]}
    | setProcessList(Number - 1,ChildList)].



init([ChildList]) ->
%%  io:format("~w~n",setProcessList(4)),
  TmpList = setProcessList(10,ChildList),
%%  io:format("List:~w~n",[TmpList]),
  {
    ok,
    {
      {one_for_one, 3, 10},
      TmpList
%%      [{ke2,{prime_tester_server,start_link,[ke2]},permanent,10000,worker,[prime_tester_server]},{ke1,{prime_tester_server,start_link,[ke1]},permanent,10000,worker,[prime_tester_server]}]
    }
  }.



