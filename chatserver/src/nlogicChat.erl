-module(nlogicChat). 
-behaviour(gen_server). 

-export([start/0,leave/1,join/1,terminate/2,dealMsg/1,handle_call/3,handle_cast/2,handle_info/2,code_change/3,init/1]). 
% -record(message,{user=none,
%                 time=now(),
%                 type =1,
%                 mes ={}}). 

start()->
    io:format("nlogicChat,11:Pid:~w~n",[self()]),
    gen_server:start_link({local,?MODULE},?MODULE,[],[]). 


leave(Socket)->gen_server:call(?MODULE,{leave,Socket}).

join(Socket) ->gen_server:call(?MODULE,{join,Socket}). 

dealMsg(Msg) ->
    % io:format("nlogicChat:19~n"),
    gen_server:call(?MODULE,{dealMsg,Msg}). 

%%------------------------------------------------------------


init([])->
    % io:format("nlogicChat:27:Pid:~w~n",[self()]),
    {ok,[]}. 
%%------------------------------------------------------------
handle_call({join,Socket},_From,Table) ->
    % io:format("nlogicChat:31:Pid:~w~n",[self()]),
    io:format("~w join~n",[Socket]),
    NewTable =[Socket|Table],
    {reply,{ok},NewTable};

handle_call({leave,Socket},_From,Table) ->
    NewTable = Table --[Socket],
    io:format("~w leave ~n",[Socket]),
    {reply,{ok},NewTable};

handle_call({dealMsg,Msg},_From,Table)->
        DataDecode =binary_to_term(Msg),
        %  io:format("nlogicChat,40,~w ~n",[DataDecode]),
        {User,Time,Type,Message} = DataDecode,  
        Reply = case Type of
            1->{send,term_to_binary({User,Time,Message})};
            _->{error,{}}
        end,
        {reply,Reply,Table}. 

%%------------------------------------------------------------------


handle_cast(_Request,Table) ->{noreply,Table}. 


%%--------------------------------------------------------------------


code_change(_OldVsn,State,_Extra)->{ok,State}.

%%-------------------------------------------------------------------- 
terminate(_Reason,_State) ->ok. 

%%-------------------------------------------------------------------

handle_info(_Info,State)->{noreply,State}. 
