-module(nchatClient). 
% -record(message,{user=none,
%                 time=now(),
%                 type =1,
%                 mes ={}}).

-export([start/0,send/1]). 

start()->
    {ok,Socket} = gen_tcp:connect("localhost",23333,[binary,{packet,4}]),
    Pid = spawn(fun () ->loopForRec() end),
    Pid2 = spawn(fun () ->manager(Socket) end),
    register(manager,Pid2),
    gen_tcp:controlling_process(Socket,Pid). 


manager(Socket) ->
    receive
        {send,Mes}->
            gen_tcp:send(Socket,term_to_binary(Mes)),
            manager(Socket)
    end. 

loopForRec() ->
    receive
        {tcp,_Socket,Bin}->
            % io:format("432"),
            Mes = binary_to_term(Bin),
            {User,Time,_Type,Msg} =Mes,
            io:format("re:~w~n",[{User,Time,Msg}]),
            loopForRec();
        {tpc_closed,_Socket}->
            io:format("tcp closed~n")
    end. 



send(Msg)->
    NewMsg ={self(),now(),1,Msg},
    % NewMsg = #message{user=self(),time=now(),type=1,mes=Msg},
    io:format("~w~n ",[NewMsg]),
    manager!{send,NewMsg}. 
