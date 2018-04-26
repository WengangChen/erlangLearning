-module(dailyFsm). 
-author("GangChen"). 

-record(state,{beginTime,endTime,nowStage,endStage}). 

-export([start/2,doneStage/0,init/1,prepare/2,active/2,done/2]). 


start(BeginTime,EndTime)->
    gen_fsm:start_link({local,?MODULE},?MODULE,[BeginTime,EndTime],[]). 


doneStage()->
    gen_fsm:send_event(?MODULE,{doneStage}).





init([BeginTime,EndTime])->
    NowTime = calendar:local_time(),
    NowSec = dateTimeToSec(NowTime),
    BeginSec = dateTimeToSec(BeginTime),
    EndSec = dateTimeToSec(EndTime),
    if 
        BeginSec > NowSec ->
            io:format("prepare~n"),
            {ok,prepare,#state{beginTime = BeginSec,endTime = EndSec,nowStage = 0,endStage = 2},(BeginSec-NowSec)*1000}; 
        EndSec =< NowSec ->
            io:format("end Daily~n"),
            {ok,done,#state{beginTime = BeginSec,endTime = EndSec,nowStage = 0,endStage = 2}};
        true ->
            {Date,_Time} = NowTime,
            TodayEndTime = {Date,{23,59,59}},
            TodayEndTimeToSec = dateTimeToSec(TodayEndTime),
            {ok,active,#state{beginTime=BeginSec,endTime = EndSec,nowStage = 0,endStage =2},(TodayEndTimeToSec-NowSec)*1000}
    end. 



prepare({doneStage},State)->
    io:format("daliyFsm-37:no start now ~n"),
    NowTime = calendar:local_time(),
    NowSec = dateTimeToSec(NowTime),
    BeginSec = State#state.beginTime,
    {next_state,prepare,State,(BeginSec-NowSec)*1000};

prepare(timeout,State)->
    io:format("daliyFsm-47:daily active~n"),
    NowTime = calendar:local_time(),
    NowSec = dateTimeToSec(NowTime),
    {Date,_Time} = NowTime,
    TodayEndTime = {Date,{23,59,59}},
    TodayEndTimeToSec = dateTimeToSec(TodayEndTime),
    {next_state,active,State,(TodayEndTimeToSec-NowSec)*1000}. 


active({doneStage},State)->
    NowTime = calendar:local_time(),
    NowSec = dateTimeToSec(NowTime),
    {Date,_Time} = NowTime,
    TodayEndTime = {Date,{23,59,59}},
    TodayEndTimeToSec = dateTimeToSec(TodayEndTime),
    RemainTimeToday = TodayEndTimeToSec-NowSec,
    case State#state.nowStage +1 of
        NewStage when NewStage == State#state.endStage ->
                    io:format("dailyFsm-65:Daliy Finish~n"),
                    NewState = State#state{nowStage = NewStage},
                    {next_state,active,NewState,RemainTimeToday*1000};
        NewStage  when NewStage < State#state.endStage ->
                io:format("dailyFsm-69:Stage Done~n"),
                NewState = State#state{nowStage = NewStage},
                {next_state,active,NewState,RemainTimeToday*1000};
        _Oth ->
                io:format("dailyFsm-69:Today Already Finish~n"),
                {next_state,active,State,RemainTimeToday*1000}   
    end;

active(timeout,State)->
    NowTime = calendar:local_time(),
    NowSec = dateTimeToSec(NowTime),
    {Date,_Time} = NowTime,
    TodayEndTime = {Date,{23,59,59}},
    TodayEndTimeToSec = dateTimeToSec(TodayEndTime),
    RemainTimeToday = TodayEndTimeToSec-NowSec,
    if
        NowSec<State#state.endTime ->
            io:format("dailyFsm-86:Daily Reflash~n"),
            NewState = State#state{nowStage = 0},
            {next_state,active,NewState,RemainTimeToday*10000};
        %%活动结束
        true ->
            io:format("dailyFsm-91:Daily Done~n"),
            {next_state,done,State}
    end.

done(_Request,State)->
    io:format("dailyFsm-96:Daily already done ~n"),
    {next_state,done,State}.  

















%%------------------------------------------------------------------------------

dateTimeToSec(DateTime)->
    calendar:datetime_to_gregorian_seconds(DateTime). 