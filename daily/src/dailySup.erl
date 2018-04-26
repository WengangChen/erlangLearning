-module(dailySup). 
-authot("GangChen"). 
-behavior(supervisor). 

-define (SERVER,?MODULE). 

-export([start/0,startChild/2,init/1]).


start()->
    supervisor:start_link({local,?SERVER},?MODULE,[]). 


startChild(BeginTime,EndTIme)->
    supervisor:start_child(?SERVER,[BeginTime,EndTIme]). 



init([]) ->
    Elem = {dailyFsm,{dailyFsm,start,[]},temporary,brutal_kill,worker,[dailyFsm]},
    Child= [Elem],
    SupFlag = {simple_one_for_one,10,10},
    {ok,{SupFlag,Child}}. 
     