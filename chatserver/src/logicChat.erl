%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 四月 2018 17:47
%%%-------------------------------------------------------------------
-module(logicChat).
-author("Administrator").


%% API
-export([start/0,castMessage/2,tryBindSocket/3,tryLogOut/1,logOut/3]).

start()->
%%  io:format("1232"),
  gen_server:start_link({local,charServer},handChat,[],[]).
%%  io:format("1233").


%%%
%%%
%%%
castMessage(Socket,Message) -> gen_server:cast(charServer,{castMessage,{Socket,Message}}).


%%% return -> ok | error | exist
%%%
%%% @doc
%%% loopPid：session用于分析的pid，
%%% keepLivePid: 保持心跳用的pid，
%%% @end

tryBindSocket(LoopPid,KeepLivePid,Socket)-> gen_server:call(chatServer,{tryBindSocket,{LoopPid,KeepLivePid,Socket}}).

%%%  @doc
%%% 必须定义Log Out，
%%% @end

tryLogOut(Socket) -> gen_server:call(chatServer,{tryLogOut,{Socket}}).

%%%  @doc
%%%尽量不要用logOut,用tryLogOut 。
%%% @end

logOut(LoopPid,KeepLivePid,Socket) -> gen_server:cast(chatServer,{logOut,{LoopPid,KeepLivePid,Socket}}).


