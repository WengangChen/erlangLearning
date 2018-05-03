-module (rootSup). 
-author("GangChne"). 
-behavior (supervisor ).

-define (SERVER,?MODULE). 

-export([start/0,init/1]).


start()->
    supervisor:start_link({local,?SERVER},?MODULE,[]). 


init([])->
    Elem1 = {nameToPidMaps,{nameToPidMaps,start,[]},transient,brutal_kill,worker,[nameToPidMaps]},
    Elem2 = {userOperator,{userOperator,start,[]},transient,brutal_kill,worker,[userOperator]},
    Elem3 = {userSup,{userSup,start,[]},transient,brutal_kill,supervisor,[userSup]},
    Children =[Elem1, Elem2, Elem3 ], 
    SupFlag = {one_for_one,10,10},
    {ok,{SupFlag,Children}}. 