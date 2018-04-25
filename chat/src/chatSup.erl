-module(chatSup). 
-behavior(supervisor). 
-define(SERVER,?MODULE). 

-author("GangChen"). 

-export([start/0,init/1]). 


start()->
    supervisor:start_link({local,?SERVER},?MODULE,[]),
    supervisor:start_child(?SERVER,[]).  

init([])->
    Elem = {chatServer,{chatServer,start,[]},permanent,10000,worker,[chatServer]},
    Children = [Elem],
    SupFlag = {simple_one_for_one,10,10},
    {ok,{SupFlag,Children}}. 