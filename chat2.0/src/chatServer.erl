-module(chatServer). 
-behavior(gen_server). 
-author("GangChen"). 

-export([start/0,
        join/1,
        logout/1,
        sendMsg/1,
        sendMsg/2,
        getOnlineUser/1,
        sendMsgToUser/2,
        sendMsgToUserList/2,
        init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2,code_change/3]). 

start()->
    {ok,Pid} = gen_server:start_link({local, ?MODULE}, ?MODULE,[],[]),
    Pid.  

join(Name)->
    gen_server:call(?MODULE,{join,Name}). 

logout(Name)->
    gen_server:call(?MODULE,{logout,Name}). 

sendMsg(Msg) -> 
    sendMsg(Msg,{'_','_'}). 

sendMsgToUser(Msg,User)->
    gen_server:call(?MODULE,{sendMsgToUser,{Msg,User}}). 

sendMsgToUserList(Msg,UserList)->
    gen_server:call(?MODULE,{sendMsgToUserList,{Msg,UserList}}). 

sendMsg(Msg,Pattern) ->
    gen_server:call(?MODULE,{send,{Msg,Pattern}}). 

getOnlineUser(Pattern)->
    gen_server:call(?MODULE,{getOnlineUser,Pattern}). 


%%-----------------------------------------------------------
%%          gen_server callBack
%%-----------------------------------------------------------

init([])->
    {ok,ets:new(userTable,[named_table,public])}. 

handle_call({join,Name},From,Table)->
    {FromPid,_Ref} = From,
    Reply = case ets:lookup(Table,Name) of
    []->
        io:format("~w join,his Pid = ~w . ~n",[Name,FromPid]),
        ets:insert(Table,{Name,FromPid}),
        success;
    _Oth -> io:format("~w already join ~n",[Name]),
            ets:insert(Table,{Name,FromPid}),
            alreadyJoin
    end,
    {reply,{Reply},Table};

handle_call({logout,Name},_From,Table)->
    Reply = case ets:lookup(Table,Name) of
    [] -> 
        io:format("~w is offline ~n",[Name]),
        offline;
    _Oth ->
        io:format("~w logout success ~n",[Name]),
        ets:delete(Table,Name),
        success
    end,
    {reply,{Reply},Table};

handle_call({send,{Msg,Pattern}},From,Table)->
    {FromPid,_Ref} = From,
    List = ets:match_object(Table,Pattern),
    Reply = try List of
                [] -> noOne;
                _Oth -> 
                    [{SenderName,FromPid}] = ets:match_object(Table,{'_',FromPid}),
                    % [io:format("sc-76:Elem:~w~n",[Elem])||Elem<-List],
                    [Pid!{SenderName,calendar:local_time(),Msg}||{_Name,Pid}<-List],
                    ok
            catch
                _:_ -> errorinCastMsg
            end,
    {reply,{Reply},Table};

handle_call({sendMsgToUser,{Msg,User}},From,Table) ->
    {FromPid,_Ref} = From,
    % io:format("cs-86:~w FromPid :~w~n",[ets:lookup(Table,User),FromPid]),
    Reply = case catch ets:lookup(Table,User) of
            [] -> noSuchUser;
            [{User,Pid}] -> 
                % io:format("cs-89:1 Pid:~w ~n",[Pid]),
                [{SenderName,FromPid}] = ets:match_object(Table,{'$1',FromPid}),
                Pid!{SenderName,calendar:local_time(),Msg},
                ok;
            _Oth ->err
    end,
    {reply,{Reply},Table};

handle_call({sendMsgToUserList,{Msg,UserList}},From,Table)->
    {FromPid,_Ref} = From,
    [{SenderName,FromPid}] = ets:match_object(Table,{'$1',FromPid}),
    SendFailList = sendMsgToUserNameList({SenderName,calendar:local_time(),Msg},UserList,Table,[]),
    Reply = case SendFailList of
        err -> {err,some_error_in_lookup_in_table};
        Oth-> {ok,Oth}
    end,
    {reply,Reply,Table};


handle_call({getOnlineUser,Pattern},_From,Table)->
    MatchList = ets:match_object(Table,Pattern),
    % io:format("sc-100 :List:~w ~n",[List]),
    List= [UserName||{UserName,_Pid}<-MatchList],
    {reply,{List},Table}. 

%---------------------------------

handle_cast(_Request,Table)->{noreply,Table}. 

handle_info(_Info,Table)->{noreply,Table}.

terminate(_Reason,_State) ->ok. 

code_change(_OldVsn,State,_Extra) ->{ok,State}. 




%%--------------------------------------------------------
%% private function
%%--------------------------------------------------------
%给消息和需要发送的用户列表，全部发送过去,并且返回发送失败的人
sendMsgToUserNameList(_Msg,[],_Table,SendFailList)->
    SendFailList;
sendMsgToUserNameList(Msg,UserNameList,Table,SendFailList)->
    [Now|Remain] = UserNameList,
    case catch ets:lookup(Table,Now) of
        [{Now,Pid}] ->
            Pid !Msg,
            sendMsgToUserNameList(Msg,Remain,Table,SendFailList);
        %查不到这个人
        []->
            sendMsgToUserNameList(Msg,Remain,Table,[Now|SendFailList]);
        _Oth->
            err
    end. 
