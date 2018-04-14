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
  {ok, Listen} = gen_tcp:listen(23333, [binary, {packet, 4}, {reuseaddr, true}, {active, true}]),
  {ok, Socket} = gen_tcp:accept(Listen),
  spawn(fun() -> tryBindSocket(Socket) end),
  listener().

tryBindSocket(Socket) ->
  KeepLivePid  = spawn(fun ()->loopkeepLive(Socket) end),
  Result = logicChat:tryBindSocket(self(),KeepLivePid, Socket),
  case Result of
    ok ->
      loop(Socket,KeepLivePid);
    _ -> KeepLivePid ! stop,
      error
  end.


%%接收对象
loop(Socket,KeepLivePid) ->
  receive
    {tcp, Socket, Bin} ->
      Mes = binary_to_term(Bin),
      case Mes of
        {message, _Message} -> keepLive(KeepLivePid,Socket),
          logicChat:castMessage(Socket, _Message), _Message;
        %%用聊天服务器干别的事用的
        {keeplive, _Message} -> keepLive(KeepLivePid,Socket);
        {logOut,_Message} -> logicChat:tryLogOut(Socket)
      end,
      loop(Socket,KeepLivePid);

    {sentMessage, Message} ->
      {ok, Addr} = inet:peername(Socket),
      %%链接
      case Addr of
        %%有ip的
        {IpAddr, PortNumber} ->
          State = try gen_tcp:connect(IpAddr, PortNumber, [binary, {packet, 4}]) of
                    {ok, Result} -> {ok, Result};
                    {err, _Result} -> throw(err)
                  catch
                    throw:err -> {error, connect_error};
                    throw: X -> {error, X};
                    exit: X -> {error, X};
                    error :X -> {error, X}
                  end,

          %%发送
          case State of
            {ok, _} -> gen_tcp:send(term_to_binary(Message));
            _Oth -> _Oth
          end

      end,
      loop(Socket,KeepLivePid);

    _ -> stop
  end.


%%用于保持心跳的
keepLive(KeepLivePid,Socket) -> KeepLivePid ! {keepLive,Socket}.


loopkeepLive(Socket) ->
  receive
    {keepLive, Socket} -> loopkeepLive(Socket);
    _ ->stop
  after 30000 -> logicChat:tryLogOut(Socket)
  end .
