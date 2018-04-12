%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%  任务中心
%%% @end
%%% Created : 12. 四月 2018 14:04
%%%-------------------------------------------------------------------
-module(newTry).
-author("Administrator").
-behaviour(gen_server).

%% API
-export([terminate/2,start_link/0,add_job/1,handle_call/3,handle_cast/2,handle_info/2,code_change/3,init/1]).


%%%------------------------------------------------------------------
%%% export区域
%%%------------------------------------------------------------------
start_link() ->
  %%一个用于存没分配的job,一个存正在进行的工作
%%  ets:new(job,[named_table,public]),
%%  ets:new(runningJob,[named_table,public]),
  spawn(fun()->circleForId(?MODULE,0 ) end),                   %初始化计数器
  {ok, Pid} = gen_server:start_link(?MODULE,[],[]),
  io:format("1223~n"),
  erlang:register(aaaa, Pid),
  true.

add_job(F) ->
  gen_server:call(?MODULE,{add_job,F}).




%%%--------------------------------------------------------------------------
% 用于写gen_server的模板
%%%-----------------------------------------------------------------------------

init([]) -> {ok,ets:new(job,[named_table,public])}.

%%%Job和runningJob为两个ets
handle_call({add_job,F},_From,Tab) ->
%%  io:format("0111111111~n"),
%%  Reply=123,
  Reply = case ets:lookup(Tab,F) of
            [] ->
              NewId = newId(?MODULE),
              ets:insert(Tab,{NewId,F}),
              NewId;
            [_] -> work_exist
          end,
  {reply,Reply,Tab}.




handle_cast(_Msg,State) -> {noreply,State}.
handle_info(_Info,State) -> {noreply,State}.
terminate(_Reason,_State) ->ok.
code_change(_oldVison,State,_Extra) -> {ok,State}.









%%%------------------------------------------------------------------------
%%%       内置函数，特殊用途
%%%
%%%------------------------------------------------------------------------

circleForId(Pid,X)->
  receive
    {getNewID}->
      Pid ! {workid,X},
      circleForId(Pid,X)
  end.

newId(Pid)->
  Pid ! {getNewID},
  receive
    {workid,X} -> X
  end.











