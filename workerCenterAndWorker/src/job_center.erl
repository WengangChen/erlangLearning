%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%  任务中心
%%% @end
%%% Created : 12. 四月 2018 14:04
%%%-------------------------------------------------------------------
-module(job_center).
-author("Administrator").
-behaviour(gen_server).

%% API
-export([terminate/2, start_link/0, add_job/1, work_wanted/0, job_done/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, init/1]).


%%%------------------------------------------------------------------
%%% export区域
%%%------------------------------------------------------------------
start_link() ->
%%  spawn(fun()->circleForId(?MODULE,0 ) end),                   %初始化计数器
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
%%  io:format("~p~n"),

add_job(F) ->
  io:format("123"),
  gen_server:call(?MODULE, {add_job, F}),
  io:format("123").

work_wanted() ->
  gen_server:call(?MODULE, {work_wanted}).


job_done(Number) ->
  gen_server:call(?MODULE, {job_done, Number}).


%%%--------------------------------------------------------------------------
% 用于写gen_server的模板
%%%-----------------------------------------------------------------------------
-record(count, {state = 0}).
init([]) ->
  io:format("1111"),
  ets:new(job, [ordered_set,named_table, public]),
  ets:new(runningJob, [ordered_set,named_table, public]),
  io:format("1111"),
  ets:new(lastWorkTime, [ordered_set,named_table, public]),
  {ok, #count{state = 0}}.


%%%job和runningJob为两个ets
handle_call({add_job, F}, _From, State) ->
  #count{state = NewId} = State,
  ets:insert(job, {NewId, F}),
  Reply = ok,
  {reply, Reply, #count{state = NewId + 1}};




handle_call({work_wanted}, From, State) ->
%%
  {Pid,_} = From,
  io:format("Pid~w~n",[Pid]),
  Value = ets:lookup(lastWorkTime,Pid),
  io:format("Key:Value:~w~n",[Value]),
  Reply = case Value of
            [] ->
              case ets:first(job) of
                '$end_of_table' -> no;
                _Other -> Work = ets:lookup(job, ets:first(job)),
                  ets:insert(runningJob, {ets:first(job), now()}),
                  ets:delete(job, ets:first(job)),
                  Work
              end;
            [_] -> need_do_rest
          end,

  {reply, Reply, State};


handle_call({job_done, Number}, _From, State) ->
  Reply = case ets:lookup(runningJob, Number) of
            [] -> no_such_job;
            [_] ->
%%              io:format("123"),
              {Pid , _X} = _From,
              ets:delete(runningJob, Number),
              %%记录最后一个人的完成时间,
              ets:insert(lastWorkTime, {Pid, now()}),
              %%休息10秒
              spawn(fun() -> workerRest(Pid, 100000) end),
              ok
          end,
  {reply, Reply, State}.


handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) ->
%%  io:format("Reason:~p~n", _Reason),
  ok.
code_change(_oldVison, State, _Extra) -> {ok, State}.


%%%------------------------------------------------------------------------
%%%       内置函数，特殊用途
%%%
%%%------------------------------------------------------------------------


workerRest(Pid, Time) ->
  io:format("~w~n", [Pid]),
  receive
  after Time ->
    ets:delete(lastWorkTime, Pid)
  end.

%%弃用
%%circleForId(Pid, X) ->
%%  receive
%%    {getNewID} ->
%%      Pid ! {workid, X},
%%      circleForId(Pid, X)
%%  end.
%%
%%newId(Pid) ->
%%  Pid ! {getNewID},
%%  receive
%%    {workid, X} -> X
%%  end.











