-module(nlogicChat). 
-behaviour(gen_server). 

-export([start/0,leave/1,join/1,terminate/2,handle_call/3,handle_cast/2,handle_info/2,code_change/3,init/1]). 
% -record(message,{user=none,
%                 time=now(),
%                 type =1,
%                 mes ={}}). 

start()->
    gen_server:start_link({local,?MODULE},?MODULE,[],[]). 


leave(Socket)->gen_server:call(?MODULE,{leave,Socket}).

join(Socket) ->gen_server:call(?MODULE,{join,Socket}). 



%%------------------------------------------------------------


init([])->
    {ok,[]}. 
%%------------------------------------------------------------
handle_call({getTable},_From,Table)->{reply,Table,Table};
handle_call({join,Socket},_From,Table) ->
    io:format("~w join~n",[Socket]),
    NewTable =[Socket|Table],
    {reply,{ok},NewTable};

handle_call({leave,Socket},_From,Table) ->
    NewTable = Table --[Socket],
    io:format("~w leave ~n",[Socket]),
    {reply,{ok},NewTable}. 

%%------------------------------------------------------------------


handle_cast(_Request,Table) ->{noreply,Table}. 


%%--------------------------------------------------------------------


code_change(_OldVsn,State,_Extra)->{ok,State}.

%%-------------------------------------------------------------------- 
terminate(_Reason,_State) ->ok. 

%%-------------------------------------------------------------------

handle_info(_Info,State)->{noreply,State}. 
