%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 四月 2018 20:58
%%%-------------------------------------------------------------------
-module(primeJudge).
-author("Administrator").

%% API
-export([start/0,addJudgeNumber/1,test/2]).


start()->
  ets:new(childList,[public,named_table,ordered_set]),
  ets:new(judgeList,[public,named_table,ordered_set]),
  ets:new(judgeResult,[public,named_table,ordered_set]),
  isPrime_sup:start(childList),
  spawn(fun()-> loopForJudge() end ).

scanProcess(Now)->
  case Now of
    '$end_of_table' ->false;
    Other ->
      io:format("~w~n",[Other]),
      case prime_tester_server:isBusy(Other) of
        true -> Other;
        _ ->scanProcess(ets:next(childList,Now))
      end
  end.

loopForScanProcess()->
  case scanProcess(ets:first(childList)) of
    false ->loopForScanProcess();
    Other -> Other
  end.

test(Number,Re)->
  if
    Re == 0 ->true;
    true -> addJudgeNumber(Number),
      test(Number+1,Re-1)
  end.

addJudgeNumber(Number) ->
  ets:insert(judgeList,{now(),Number}).

loopForJudge()->
  try ets:first(judgeList) of
    '$end_of_table' ->
      loopForJudge();
      _Time ->
        Key = loopForScanProcess(),
        [{_K,V}] = ets:lookup(judgeList,Key),
        Ans = prime_tester_server:isPrime(Key,V),
        io:format("~p ~n",{V,Ans}),
        ets:insert(judgeResut,{V,Ans}),
        ets:remove(judgeList,_K),
        loopForJudge()
  catch
    throw: X ->X;
    exit : X ->X;
    error : X ->X
  end.