%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 四月 2018 16:38
%%%-------------------------------------------------------------------
-module(handChat).
-author("Administrator").
-behaviour(gen_server).
%% API
-export([handle_call/3,handle_cast/2,init/1,code_change/3,terminate/2,handle_info/2]).

%%-------------------------------------------------------------------------------------------------------------------
handle_call({tryBindSocket, {LoopPid,KeepLivePid,Socket}},_From,Table) ->
  Reply = case catch ets:lookup(bindProcessToSocket,Socket) of
    [_] -> exist;
    [ ] -> ets:insert(bindProcessToSocket,{Socket,{LoopPid,KeepLivePid}}),ok;
    _ ->error
  end,
  {reply,Reply,Table};

handle_call({tryLogOut,{Socket}},_From,Table) ->
  Reply  = case catch ets:lookup(bindProcessToSocket,Socket) of
    [] ->already_logout;
    [Socket,{LoopPid,KeepLivePid}] -> logicChat:logOut(LoopPid,KeepLivePid,Socket)
  end,
  {reply,Reply,Table}.




%%----------------------------------------------------------------------------------------------------------------
handle_cast({logOut,{LoopPid,KeepLivePid,Socket}},Table) ->
  ets:delete(Table,Socket),
  LoopPid ! {logOut,Socket},
  KeepLivePid ! {logOut,Socket},
  {noreply,Table};

handle_cast({castMessage,{_Socket,Message}},Table) ->
  PersonList = ets:tab2list(Table),
  [LoopId!{castMessage,Message }|| {_Key,{LoopId,_KeepLiveId}}  <- PersonList ],
  {noreply,Table} .

%%---------------------------------------------------------------------------------------------------------------


init([]) ->
  Table  = ets:new(bindProcessToSocket,[public,named_table]),
  {ok,Table} .

%%---------------------------------------------------------------------------------------------------------------
handle_info(_Info,State) -> {norepley,State}.
terminate(_Reson,_State) -> ok.
code_change(_OldVersion,State,_Extra) ->{ok,State}.








