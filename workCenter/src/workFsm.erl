-module (workFsm). 
-behavior(gen_fsm). 
-author("GangChen"). 

-record(state,{workHasDoneCount,sleepTime,limitsTimes,startRestTime = infinite}). 


-export([start/1,requestWork/1]).
-export([init/1,work/2,rest/2]).  
-export([handle_event/3,code_change/4,terminate/3,handle_info/3,handle_sync_event/4]). 

start({SleepTime,LimitsTimes})->
    gen_fsm:start_link({local,?MODULE},?MODULE,[{SleepTime,LimitsTimes}],[]). 


requestWork({Module,Func,Args})->
    gen_fsm:send_event(?MODULE,{doWork,{Module,Func,Args}}). 


work({doWork,{Module,Func,Args}},State)->
    apply(Module,Func,Args),
    case State#state.workHasDoneCount +1 of
        Times when Times == State#state.limitsTimes ->
            NewState = State#state{workHasDoneCount = 0,startRestTime = getNowMiniSecondStamp()},
            {next_state,rest,NewState,State#state.sleepTime};
        Oth ->
            NewState = State#state{workHasDoneCount = Oth},
            {next_state,work,NewState}
    end.


rest({doWork,{_Module,_Func,_Args}},State)->
    io:format("work center ~w need to Rest~n",[self()]),
    HasRestTime = getNowMiniSecondStamp()-State#state.startRestTime,
    {next_state,rest,State,State#state.sleepTime-HasRestTime}; 
rest(timeout,State)->
    {next_state,work,State}.  
            
    
    
init([{SleepTime,LimitsTimes}])->
        {ok,work,#state{workHasDoneCount = 0,
                        sleepTime= SleepTime,
                        limitsTimes = LimitsTimes}}.


code_change(_OldVsn,State,Data,_Extra)->
    {ok,State,Data}. 

handle_event(Event, StateName, Data) ->
        {stop, {shutdown, {unexpected, Event, StateName}}, Data}.
        
terminate(_Reason, _State, _Data) -> ok.        

handle_info(_Info,State,Data) ->
    {next_state,State,Data}.

handle_sync_event(stop,_From,_State,Data)->
    {stop,normal,ok,Data}. 



%%----------------------------------------------------------------------------------
%% 私有函数
%%---------------------------------------------------------------------------------


getNowMiniSecondStamp()->
    {MegaSec,Sec,MircorSec} =os:timestamp(),
    MegaSec*1000000000+Sec*1000+MircorSec div 1000. 