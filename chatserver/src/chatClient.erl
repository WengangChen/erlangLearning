-module (chatClient). 

-export([start/0,send/1]). 




start() ->
    io:format("111"),
    HostInNet = "localhost" ,
    {ok,Socket} = gen_tcp:connect(HostInNet,23333,[binary,{packet,4}]),
    % loop(). 
    io:format("~w~n",["123"]),
    Pid = spawn(fun () ->loop() end),
    Pid2 = spawn(fun () -> loopForSend(Socket) end),
    register(loopForSend,Pid2),
    gen_tcp:controlling_process(Socket,Pid).
     


loop() ->
    receive 
        {tcp,_Socket,Bin} ->
            Mes = binary_to_term(Bin),
            io:format("re:~p~n",Mes),
            loop();
        {tcp_closed,_Socket} ->
            io:format("closed")     
    end. 

loopForSend(Socket)->
    receive
        {send,Mes} ->
            io:format("Send:~p ~n ",Mes),
             Result = gen_tcp:send(Socket,term_to_binary(Mes)),
                    io:format("~w:~n",[Result]),
                    loopForSend(Socket)
    end. 

% waitForGetMessageForomServer(Listen) ->
%     {ok,Bin} = tcp:accept(Listen),
%     Mes = binary_to_term(Bin),
%     io:format("~w~n",[Mes]),
%     waitForGetMessageForomServer(Listen).


send(Mes)->
    loopForSend!{send,Mes}. 
