%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 四月 2018 8:51
%%%-------------------------------------------------------------------
-module(sessionChat).
-author("Administrator").

-record(message,{user=none,Time=now(),mes ={}}). 

%% API
-export([start/0]).

start()->
  logicChat:start(),
%%  io:format("1231"),
  spawn(fun() -> listener() end ),
%%  io:format("1231"),
  ok.


%%监听客户端发过来的信息
listener() ->
%%  Port = random:uniform(999)+4000,
  {ok, Listen} = gen_tcp:listen(23333, [binary, {packet, 4}, {reuseaddr, true}, {active, false}]),
  Pid = spawn(fun() -> managerFun([]) end),
  register(manager,Pid),
  doAccept(Listen).


doAccept(Listen) ->
  {ok,Socket} = gen_tcp:accept(Listen),
  manager!{join,Socket},
  % io:format("~w join ~n",[Socket]),
  % tryBindSocket(Socket),
  spawn(fun() ->listenClient(Socket) end),
  doAccept(Listen). 




managerFun(SocketList) ->
  receive
    {join,Socket} ->
      io:format("~w join ~n",[Socket]),
      managerFun([Socket|SocketList]);
    {leave,Socket} ->
      io:format("~w leave ~n",[Socket]),
      managerFun(SocketList--[Socket]);
    {data,Data} ->
      cast(Data,SocketList),
      managerFun(SocketList)
  end. 

% tryBindSocket(Socket) ->
%   KeepLivePid  = spawn(fun ()->loopkeepLive(Socket) end),
%   spawn(fun() -> listenClient(Socket) end),  
% % io:format("123321"),
%   {ok} = logicChat:tryBindSocket(Socket,KeepLivePid). 
%   % io:format("Bind result : ~w ~n",[Result]),



listenClient(Socket) ->
  case gen_tcp:recv(Socket,0) of
    {ok,Data} ->
      manager!{data,Data},
      listenClient(Socket);
    {error,closed} ->
      manager!{leave,Socket}
  end.



cast(Data,SocketList)->[gen_tcp:send(Socket,Data)||Socket<-SocketList]. 
