-module(test). 
-author("GangChen"). 

-export([test/0]).

test()->
    chatSup:start(),
    PidList = createUser(10,[]),
    sleep(1000),
    [A|Oth] =PidList,
    [B|_Oth1] = Oth,
    A!{send,"this is A"},
    sleep(1000),
    B!{sendToUser,"hello A",1},
    sleep(1000),
    A!{logout},
    B!{sendToUser,"hello A",1},
    sleep(1000),
    io:format("getOnlieUser: ~w ~n",[chatServer:getOnlineUser({'_','_'})]),
    sleep(1000),
    B!{sendToUserList,"I am B",[1,2,3,4,5]},
    sleep(1000),    
    B!{logout}.  



createUser(0,NameList)-> NameList;

createUser(NameNumber,NameList)->
    Pid = spawn(fun() ->userAction(NameNumber)end),
    Pid ! {join},
    createUser(NameNumber-1,[Pid|NameList]). 



userAction(UserName) ->
    receive 
        {join} ->
            % io:format("t-31:my pid = ~w ~n",[self()]),
            chatServer:join(UserName),
            userAction(UserName);
        {send,Msg} ->
            chatServer:sendMsg(Msg),
            userAction(UserName);
        {sendToUser,Msg,User}->
            chatServer:sendMsgToUser(Msg,User),
            userAction(UserName);
        {send,Msg,Pattern}->
            chatServer:sendMsg(Msg,Pattern),
            userAction(UserName);
        {logout}->
            chatServer:logout(UserName);
        {sendToUserList,Msg,UserList}->
            chatServer:sendMsgToUserList(Msg,UserList);
        {From,Time,Msg} ->
            io:format("~w receive Msg:From:~w     Time:~w     Message: ~s ~n",[UserName,From,Time,Msg]),
            userAction(UserName);
        Oth ->io:format("~w err ~n",[Oth]),
            userAction(UserName)
    end. 



sleep(Time)->
    receive
        after Time ->ok
    end. 