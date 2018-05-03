-module(userSup). 
-behavior(supervisor). 
-define(SERVER,?MODULE). 

-author("GangChen"). 

-export([start/0,startChild/1,init/1]). 


start()->
    supervisor:start_link({local,?SERVER},?MODULE,[]).

startChild(UserName) ->
    supervisor:start_child(?SERVER,[UserName]).   

init([])->
    Elem = {nChatServer,{nChatServer,login,[]},temporary,brutal_kill,worker,[nChatServer]},
    Children = [Elem],
    SupFlag = {simple_one_for_one,10,10},
    {ok,{SupFlag,Children}}. 