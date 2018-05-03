-module(nChatServer). 
-author("GangChen").

-export([]). 

-behavior(gen_server). 

%%%定义消息类型
-record(userMsg,{form,
                msgType,
                time=calendar:local_time(),
                infomation}). 


-export([login/1,sendMsg/3,getMsg/1,stop/1]). 

-export([init/1,handle_call/3,handle_cast/2,code_change/3,handle_info/2,terminate/2]). 


login(User)->
    % io:format("nchat -21: lalal~n"),
    Result = gen_server:start_link({local,User},?MODULE,[],[]),
    % io:format("nchat-23:Result ~w~n",[Result]),
    Result.  

sendMsg(User,{Sender,Type,Msg},ReceiveList)->
    gen_server:call(User,{sendMsg,{Sender,Type,Msg},ReceiveList}). 

getMsg(User)->
    gen_server:call(User,{getMsg}). 

stop(User)->
    gen_server:cast(User,{stop}). 


%%--------------------------------------------------------------------------------
%%       gen_server:callbcak
%%-------------------------------------------------------------------------------

init([])->
    case catch userOperator:createNewUser(self()) of
        {ok,_} ->
            {ok,queue:new()};
        {error,Reason}->
            {stop,Reason};
        _Oth ->
            {stop,_Oth}
    end. 

%--------------------------------------------------------------
handle_call({sendMsg,{Sender,Type,Msg},ReceiveList},_From,_MsgBox)->
    % io:format("nChat-52~n"),
    FixMsg = fixMsg(Sender,Type,Msg),
    Result  = [Pid ! FixMsg ||Pid<-ReceiveList,is_pid(Pid)],
    % io:format("nChat-55 Result:~w~n",[Result]),
    {reply,{ok,length(Result)},_MsgBox};
handle_call({getMsg},_From,MsgBox)->
    case catch queue:out(MsgBox) of
        {{value,Msg},NewQueue}->
            {reply,{ok,Msg},NewQueue};
        {empty,_}->
            {reply,{error,noMsg},MsgBox};
        Oth ->
            {reply,{error,Oth},MsgBox}
    end.  
                
                    
%----------------------------------------------------------------
handle_cast({stop},_MsgBox)->
    {stop,normal,_MsgBox}. 

%----------------------------------------------------

%---接受到信息全部放到箱子里面
handle_info(Info,MsgBox) when is_record(Info,userMsg)->
    % io:format("1234~n"),
    NewMsgBox =  queue:in(Info,MsgBox),
    {noreply,NewMsgBox};
handle_info({stop,Reason},_MsgBox)->
    % io:format("12345~n"),
    {stop,Reason};
handle_info(_Info,MsgBox) ->
    % io:format("123456~n"),
    {noreply,MsgBox}. 
%--------------------------------------------------------------
terminate(_Reason,_MsgBox)->
    io:format("nChat-87:Reason:~w~n",[_Reason]),
    userOperator:deleteUser(self(),_Reason),
    nameToPidMaps:remove(pid,self()), 
    ok. 
%---------------------------------------------------------------
code_change(_OldVsn,State,_Extra)->{ok,State}. 


%%---------------------------------------------------------------
%%              private_function
%%---------------------------------------------------------------

fixMsg(Sender,Type,Msg)->
    #userMsg{form = Sender, msgType = Type ,infomation = Msg}. 

