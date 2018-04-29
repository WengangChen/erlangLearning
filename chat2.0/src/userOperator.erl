
%%%--------------------------------------------------------------------------
%%%用于记录玩家的状态
%%%-------------------------------------------------------------------------

-module(userOperator). 
-author("GangChen"). 

-behavior(gen_server).

-export([intoChannel/2,
        intoTeam/2,
        intoGuild/2,
        leaveGuild/1,
        leaveTeam/1,
        createNewUser/1,
        deleteUser/1,
        getUserIdInChannel/1,
        getUserIdInGuild/1,
        getUserIdInTeam/1,
        getUserState/1]). 

-export([init/1,handle_call/3,handle_cast/2,code_change/3,handle_info/2,terminate/2]). 

% userId =  用户ID
% teamId:队伍编号
% channelId:频道
% guildId:公会编号
-record(user,{userId,teamId = 0,channelId = 1, guildId = 0}). 

start()->
    gen_server:start_link({local,?MODULE},?MODULE,[],[]).


intoChannel(UserId,ChannelId) when is_integer(ChannelId) ->
    if
        ChannelId >= 0 ->
            gen_server:call(?MODULE,{intoChannel,UserId,ChannelId}); 
        true ->
            {error,invalidChannelId}
    end;
intoChannel(_UserId,_ChannelId)->{error,invalidChannelId}. 


intoTeam(UserId,TeamId) when is_integer(TeamId) ->
    if
        TeamId >= 0 ->
            gen_server:call(?MODULE,{intoTeam,UserId,ChannelId});
        true ->
            {error,invalidTeamId}
    end;
intoTeam(_UserId,_TeamId)->{error,invalidTeamId}. 


intoGuild(UserId,GuildId) when is_integer(GuildId) ->
    if
        Guild >= 1 ->
            gen_server:call(?MODULE,{intoGuild,UserId,GuildId});
        true ->
            {error,invalidGuildId}
    end;
intoTeam(_UserId,_GuildId)->{error,invalidGuildId}. 


leaveGuild(UserId)->
    intoGuild(UserId,0). 

leaveTeam(UserId)->
    intoTeam(UserId,0). 

createNewUser(UserId)->
    gen_server:call(?MODULE,{createNewUser,UserId}). 

deleteUser(UserId,Reason)->
    gen_server:cast(?MODULE,{deleteUser,UserId,Reason}). 

getUserIdInChannel(ChannelId) when is_integer(ChannelId)->
    if
        ChannelId > 1->
            gen_server:call(?MODULE,{getUserIdInChannel,ChannelId});      
        true ->{error,invalidChannelId}
    end;
getUserIdInChannel(ChannelId)->{error,invalidChannelId}.      

getUserIdInGuild(GuildId) when is_integer(GuildId) ->
    if
        GuildId >= 0 ->
            gen_server:call(?MODULE,{getUserIdInGuild,GuildId});
        true ->
            {error,invalidGuildId}
    end;
getUserIdInGuild(_GuildId) ->{error,invalidGuildId}. 

getUserIdInTeam(TeamId) when is_integer(TeamId) ->
    if
        TeamId >= 0 ->
            gen_server:call(?MODULE,{getUserIdInTeam,TeamId});
        true ->
            {error,invalidTeamId}
    end;
getUserIdInTeam(_TeamId) -> {error,invalidTeamId}. 

getUserState(UserId)-> gen_server:call({getUserState,UserId}). 

%%------------------------------------------------------------------------------------
%% gen_server callback
%%------------------------------------------------------------------------------------
init([])->
    {ok,ets:new(user,[named_table,{keypos,#user.userId}])}. 
%------------------------------------------------------------------------------------
handle_call({intoChannel,UserId,ChannelId},_From,Table)->   
    Reply = case catch ets:lookup(Table,UserId) of
            [] ->
                {error,noSuchUser};
            [_User] ->
                ets:update_elem(Table,UserId,{#user.channelId,ChannelId}),
                {ok,UserId};
            Oth ->
                {error,Oth}
        end,
    {reply,Reply,Table};

handle_call({intoTeam,UserId,TeamId},_From,Table)->
    Reply = case  catch ets:lookup(Table,UserId) of
            [] ->
                {error,noSuchUser};
            [_User] ->
                ets:update_elem(Table,UserId,{#user.teamId,TeamId}),
                {ok,UserId};
            Oth ->
                {error,Oth}
        end,
    {reply,Reply,Table};

handle_call({intoGuild,UserId,GuildId},_From,Table)->
    Reply = case  catch ets:lookup(Table,UserId) of
            [] ->
                {error,noSuchUser};
            [_User] ->
                ets:update_elem(Table,UserId,{#user.guildId,GuildId}),
                {ok,UserId};
            Oth ->
                {error,Oth}
        end,
    {reply,Reply,Table};

handle_call({createNewUser,UserId},_From,Table)->
    Reply = case  catch ets:lookup(Table,UserId) of
            [] ->
                User = #user{userId = UserId},
                ets:insert(Table,User),
                {ok,UserId};
            [_User] ->
                {error,userExist};
            Oth ->
                {error,Oth}
        end,
    {reply,Reply,Table};


handle_call({getUserIdInChannel,ChannelId},_From,Table)->
    %% match出来的结果是[[value1],[value2]],
    MatchResult = ets:match(Table,#user{userId = '$1',teamId = '_',channelId = ChannelId,guildId = '_'}),
    % 去除掉一层中括号
    Reply = case catch [Value||Elem<-MatchResult,Value<-Elem] of 
                {'EXIT',Reason} ->
                    {error,Reason};
                Oth ->
                    {ok,Oth}
        end,
    {reply,Reply,Table};

handle_call({getUserIdInGuild,GuildId},_From,Table)->
    %% match出来的结果是[[value1],[value2]],
    MatchResult = ets:match(Table,#user{userId = '$1',teamId = '_',channelId = '_',guildId = GuildId}),
    % 去除掉一层中括号
    Reply = case catch [Value||Elem<-MatchResult,Value<-Elem] of 
                {'EXIT',Reason} ->
                    {error,Reason};
                Oth ->
                    {ok,Oth}
        end,
    {reply,Reply,Table};
    
handle_call({getUserIdInTeam,TeamId},_From,Table)->
    %% match出来的结果是[[value1],[value2]],
    MatchResult = ets:match(Table,#user{userId = '$1',teamId = TeamId,channelId = '_',guildId = '_'}),
    % 去除掉一层中括号
    Reply = case catch [Value||Elem<-MatchResult,Value<-Elem] of 
                {'EXIT',Reason} ->
                    {error,Reason};
                Oth ->
                    {ok,Oth}
        end,
    {reply,Reply,Table};
handle_call({getUserState,UserId},_From,Table) ->
    Reply = case catch ets:lookup(Table,#user.userId = UserId) of
                []->{error,noSuchUserInUserOperator};
                [R] when is_record(R) -> {ok,R};
                _Oth ->{error,_Oth}
        end,
    {reply,Reply,Table}. 
    
%---------------------------------------------------------------------------
handle_cast({deleteUser,UserId,Reason},Table)->
    case catch ets:lookup(Table，#user.userId = UserId) of
        [_]->UserId!{stop,Reason};
        [] ->noSuchUser;
        _Oth ->_Oth
    end,
    ets:delete(Table,#user.userId = UserId),
    {noreply,Table} . 
%---------------------------------------------------------------------------
handle_info(_Info,Table)->
    {noreply,Table}. 
%---------------------------------------------------------------------------
terminate(_Reason,_Table)-> ok. 
%--------------------------------------------------------------------------
code_change(_OldVsn,Table,_Extra) ->{ok,Tbale}. 
%---------------------------------------------------------------------------
