-module(testerSup). 
-behavior(supervisor). 
-author("GangChen"). 

-export([start/0,start/1,start_in_shell/1,start_link/1,init/1]). 

start()->
    start([]).
start(Arg)->
    spawn(fun() ->supervisor:start_link({local,?MODULE},?MODULE,Arg) end). 

start_in_shell(Arg)->
    {ok,Pid} = supervisor:start_link({local,?MODULE},?MODULE,Arg),
    % io:format("testerSup-12:~w ~n",[Pid]),
    unlink(Pid).

start_link(Arg) ->
    supervisor:start_link(?MODULE,Arg). 

getChildSpec(Arg)->
    case Arg of
        [] ->[];
        [A|B] -> [{A,{primeTest,start,[A]},permanent,10000,worker,[primeTest]}|getChildSpec(B)]
    end. 

init(Arg) ->
    ChildSpec = getChildSpec(Arg),
    {
        ok,
        {
            {one_for_one,3,10},ChildSpec
        }
    }. 
