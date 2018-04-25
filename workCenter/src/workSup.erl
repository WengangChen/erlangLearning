-module(workSup).
-behavior(supervisor). 
-author("GangChen"). 

-define (SERVER,?MODULE). 

-export([start/0,init/1,startChild/1]). 

start()->
    supervisor:start_link({local, ?SERVER},?MODULE,[]). 

startChild({SleepTime,LimitsTimes})->
    supervisor:start_child(?SERVER,[{SleepTime,LimitsTimes}]). 

init([])->
    Elem={workFsm,{workFsm,start,[]},permanent,brutal_kill,worker,[workFsm]},
    Children = [Elem],
    SupFlag = {simple_one_for_one,10,10},
    {ok,{SupFlag,Children}}. 


