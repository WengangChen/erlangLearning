-module(logicChat). 
-author("GangChen"). 

-export([start/0,
        login/1,
        logout/1,
        intoChannel/2,
        intoGuild/2,
        intoTeam/2,
        leaveGuild/1,
        leaveTeam/1,
        sendMsgToChannel/2,
        sendMsgToTeam/2,
        sendMsgToGuild/2,
        getMsg/1    ]). 
% userId =  用户ID
% teamId:队伍编号
% channelId:频道
% guildId:公会编号
-record(user,{userId,teamId = 0,channelId = 1, guildId = 0}). 

start()->
    userSup:start(),
    nameToPidMaps:start(),
    userOperator:start(). 

login(User)->
    Result = userSup:startChild(User),
    % io:format("logic-29:Result~w~n",[Result]),
    {ok,Pid} = Result,
    nameToPidMaps:insert(User,Pid),
    userOperator:createNewUser(Pid). 

intoChannel(UserName,ChannelId)->
    List = nameToPidMaps:getPidFormUserName(UserName),
    case List of
        {error,Reason}->{error,Reason};
        {ok,[Pid]} ->userOperator:intoChannel(Pid,ChannelId);
        {ok,_Oth}->{error,notExactlyOne}
    end. 

intoTeam(UserName,TeamId)->
    List = nameToPidMaps:getPidFormUserName(UserName),
    case List of
        {error,Reason}->{error,Reason};
        {ok,[Pid]} ->userOperator:intoTeam(Pid,TeamId);
        {ok,_Oth}->{error,notExactlyOne}
    end. 

intoGuild(UserName,GuildId)->
    List = nameToPidMaps:getPidFormUserName(UserName),
    case List of
        {error,Reason}->{error,Reason};
        {ok,[Pid]} ->userOperator:intoGuild(Pid,GuildId);
        {ok,_Oth}->{error,notExactlyOne}
    end. 

leaveTeam(UserName)->
    intoTeam(UserName,0). 

leaveGuild(UserName)->
    intoGuild(UserName,0).


logout(UserName)->
    List = nameToPidMaps:getPidFormUserName(UserName),
    case List of
        {error,Reason}->{error,Reason};
        {ok,[Pid]} ->nChatServer:stop(Pid);
        {ok,_Oth}->{error,notExactlyOne}
    end. 

sendMsgToChannel(From,Msg)->
    List = nameToPidMaps:getPidFormUserName(From),
    case List of
        {error,Reason}->
            {error,Reason};
        {ok,[Pid]} ->
            case catch userOperator:getUserState(Pid) of
                {ok,UserState} when is_record(UserState,user)->
                    ChannelId = UserState#user.channelId,
                    Result = userOperator:getUserIdInChannel(ChannelId),
                    case Result of
                        {ok,PidList} ->
                            nChatServer:sendMsg(Pid,{From,channel,Msg},PidList);
                        Err ->{error,Err}
                    end;
                Oth ->{error,Oth}
            end;    
        {ok,_Oth}->
            {error,notExactlyOne}
    end. 


sendMsgToTeam(From,Msg)->
    List = nameToPidMaps:getPidFormUserName(From),
    case List of
        {error,Reason}->
            {error,Reason};
        {ok,[Pid]} ->
            case catch userOperator:getUserState(Pid) of
                {ok,UserState} when is_record(UserState,user)->
                    TeamId = UserState#user.teamId,
                    if 
                        TeamId /= 0->
                            Result = userOperator:getUserIdInTeam(TeamId),
                            case Result of
                                {ok,PidList} ->
                                    nChatServer:sendMsg(Pid,{From,team,Msg},PidList);
                                Err ->{error,Err}
                            end;
                        true ->{error,noInTeam}
                    end;
                Oth ->{error,Oth}
            end;    
        {ok,_Oth}->
            {error,notExactlyOne}
    end. 
 
sendMsgToGuild(From,Msg)->
    List = nameToPidMaps:getPidFormUserName(From),
    % io:format("logic-122~w~n",[List]),
    case List of
        {error,Reason}->
            {error,Reason};
        {ok,[Pid]} ->
            % io:format("logic-127 :~w~n",[userOperator:getUserState(Pid)]),
            case catch userOperator:getUserState(Pid) of
                {ok,UserState} when is_record(UserState,user)->
                    % io:format("lalal~n"),
                    GuildId = UserState#user.guildId,
                    if
                        GuildId /= 0 ->
                            Result = userOperator:getUserIdInGuild(GuildId),
                            % io:format("logic-135:Result ~w ~n",[Result]),
                            case Result of
                                {ok,PidList} ->
                                    % io:format("logic-138:Result1 ~w ~n",[Result]),
                                    nChatServer:sendMsg(Pid,{From,guild,Msg},PidList);
                                    % io:format("logic-140:Result2 ~w ~n",[Result]);
                                Err ->{error,Err}
                            end;
                        true ->{error,noInGuild}
                    end;
                Oth ->{error,Oth}
            end;    
        {ok,_Oth}->
            {error,notExactlyOne}
    end. 
 
getMsg(UserName)->
    % io:format("logicChat-152:UserName:~w~n",[UserName]),
    List = nameToPidMaps:getPidFormUserName(UserName),
    % io:format("logicChat-153:getMsgList:~w~n",[List]),
    case List of
        {error,Reason}->
        {error,Reason};
        {ok,[Pid]} ->
            nChatServer:getMsg(Pid);
        {ok,_Oth}->
            {error,notExactlyOne}
    end. 