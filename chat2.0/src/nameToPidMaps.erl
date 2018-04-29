-module(nameToPidMaps). 
-author("GangChen"). 
-behavior(gen_server). 

-export([start/0,insert/2,remove/2,getPidFormUserName/1]). 
-export([init/1,handle_call/3,handle_cast/2,code_change/3,handle_info/2,terminate/2]).


start()->
    gen_server:start_link({local,?MODULE},?MODULE,[],[]). 

insert(User,Pid)->
    gen_server:cast(?MODULE,{insert, User,Pid}).

remove(user,User)->
    gen_server:cast(?MODULE,{removeUser,User}); 

remove(pid,Pid)->
    gen_server:cast(?MODULE,{removePid,Pid}). 

getPidFormUserName(UserList) when is_list(UserList)->
    gen_server:call(?MODULE,{getPidFormUserName,UserList});
getPidFormUserName(UserName)->
    getPidFormUserName([UserName]).  


%%----------------------------------------------------------------------------------

init([])->
    {ok,ets:new(table,[named_table])}. 
%------------------------------------------------------------------------------------
handle_call({getPidFormUserName,UserList},_From,Table)->
    Reply = catch pGetPidFormUserName(UserList,Table,[]),
    {reply,Reply,Table}. 

%------------------------------------------------------------------------------------
hanlde_cast({insert,User,Pid},Table)->
    ets:insert(Table,{User,Pid}),
    {noreply,Table};

handle_cast({removeUser,User},Table)->
    ets:delete(Table,User),
    {noreply,Table};
handle_cast({removePid,Pid},Table) ->
    ets:match_delete(Table,{'_',Pid}),
    {noreply,Table}. 



%----------------------------------------------------------------

pGetPidFormUserName([],Table,Ans)->
    {ok,Ans};
pGetPidFormUserName(UserList,Table,Ans)->
    [A|Re] = UserList,
    case catch ets:lookup(Table,A) of
        []->
            pGetPidFormUserName(Re,Table,Ans);
        [{_Name,Pid}]->
            pGetPidFormUserName(Re,Table,[Pid|Ans]);
        Oth -> {error,Oth}
    end. 
