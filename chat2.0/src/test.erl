-module(test). 
-author("GangChen"). 


-export([test/0]).

test()-> 
    rootSup:start(),
    createUser(10),
    logicChat:intoTeam('1',1),
    logicChat:intoTeam('2',1),
    logicChat:intoTeam('3',1),
    io:format("test-12~n"),
    logicChat:intoChannel('3',2),
    logicChat:intoChannel('4',2),
    io:format("test-14~n"),
    logicChat:intoGuild('4',3),
    logicChat:intoGuild('5',3),
    logicChat:intoGuild('6',3),
    io:format("test-18~n"),
    logicChat:sendMsgToTeam('1',"This is Team 1"),
    sleep(1000),
    io:format("----------------------------------------------------------------~n"),
    logicChat:sendMsgToChannel('3',"This is Channel 2"),
    sleep(1000),
    io:format("----------------------------------------------------------------~n"),
    logicChat:sendMsgToGuild('5',"This is Guild 3"),
    sleep(1000),
    io:format("----------------------------------------------------------------~n"),
    logicChat:leaveTeam('3'),
    logicChat:sendMsgToTeam('1',"This is Team 1"),
    sleep(1000),
    io:format("----------------------------------------------------------------~n"),
    logicChat:leaveGuild('6'),
    % sleep(1000),
    logicChat:sendMsgToGuild('5',"This is Guild 3"),
    sleep(1000),
    io:format("----------------------------------------------------------------~n"),
    % Result = logicChat:getMsg('5'),
    % io:format("test-24:Result ~w ~n",[Result]),
    io:format("done~n").  



createUser(0) ->ok;
createUser(Number)->
    Name = integer_to_atom(Number),
    logicChat:login(Name),
    sleep(100),
    spawn(fun () -> loopForGetMsg(Name) end),
    createUser(Number-1). 

loopForGetMsg(User)->
    case logicChat:getMsg(User) of
        {ok,Msg}->
            io:format("User  ~w get Msg :~w ~n",[User,Msg]),
            sleep(100),
            loopForGetMsg(User);
        _Oth ->
            sleep(100),
            loopForGetMsg(User)
    end. 
    

































%----------------------------------------------------
sleep(Time)->
    receive 
        after Time ->ok
    end. 

integer_to_atom(Number)->
    List = integer_to_list(Number),
    list_to_atom(List). 