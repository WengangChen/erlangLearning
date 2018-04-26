-module(test). 

-export([test/0]). 


test()->
    dailySup:start(),
    {Date,_Time} = calendar:local_time(),
    StartTime = {Date,{17,0,0}},
    EndTime = {{2018,4,28},{23,59,59}},
    dailySup:startChild(StartTime,EndTime),
    dailyFsm:doneStage(). 