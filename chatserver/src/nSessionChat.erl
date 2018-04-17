-module(nSessionChat). 


-export([start/0]).

start()->
  nlogicChat:start(),
  spawn(fun() -> listener() end ),
  ok.


%%监听客户端发过来的信息
listener() ->
  {ok, Listen} = gen_tcp:listen(23333, [binary, {packet, 4}, {reuseaddr, true}, {active, false}]),
  Pid = spawn(fun() -> managerFun([]) end),
  register(manager,Pid),
  doAccept(Listen).


doAccept(Listen) ->
  {ok,Socket} = gen_tcp:accept(Listen),
   manager!{join,Socket},

  spawn(fun() ->listenClient(Socket) end),
  doAccept(Listen). 




managerFun(Table) ->
    receive
        {join,Socket} ->
            nlogicChat:join(Socket),
            managerFun([Socket|Table]);
        {leave,Socket} ->
            nlogicChat:leave(Socket),
            managerFun(Table--[Socket]);

        % {data,Data}->
        %     [gen_tcp:send(Socket,Data)||Socket<-Table],
        %     managerFun(Table)
        {data,Data} ->
          DataDecode =binary_to_term(Data),
          % io:format("~w ~n",[DataDecode]),
          {User,Time,_Type,Msg} = DataDecode,  
          FixData = term_to_binary({User,Time,Msg}),
          [gen_tcp:send(Socket,FixData)||Socket<-Table],
          managerFun(Table)
  end. 

listenClient(Socket) ->
  case gen_tcp:recv(Socket,0) of
    {ok,Data} ->
      manager!{data,Data},
      listenClient(Socket);
    {error,closed} ->
      manager!{leave,Socket}
  end.
