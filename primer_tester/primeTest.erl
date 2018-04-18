-module(primeTest) . 

-author("GangChen"). 

-behavior(gen_server). 

-export([start/1,checkPrime/2,init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2,code_change/3]). 


start(Name)->
    % Name = tag1,
    Pid = gen_server:start_link({local,Name},?MODULE,[],[]),
    io:format("PrimeTest-12:Pid:~w name:~w ~n ",[Pid,Name]),
    Pid. 


checkPrime(Name,Number)-> gen_server:call(Name,{checkPrime,Number}).

%%------------------------------------------------------------------------------------ 


init([])->{ok,empty}. 

%%------------------------------------------------------------------------------------------

handle_call({checkPrime,_Number},_From,State)->
    io:format("primeTest-27:Pid:~w~n",[self()]),
    {reply,true,State}. 


%%--------------------------------------------------------------------------------------

handle_cast(_Request,State) ->{noreply,State}. 

%%--------------------------------------------------------------------------------------

handle_info(_Info,State) ->{noreply,State}. 

%%-------------------------------------------------------------------------------------

terminate(_Reason,_State) ->ok. 

%%-------------------------------------------------------------------------------------

code_change(_OldVsn,State,_Extra) ->{ok,State}. 