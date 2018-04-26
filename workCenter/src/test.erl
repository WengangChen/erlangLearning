-module(test). 
-author("GangChen"). 

-export([test/0]). 


test()->
    workSup:start(),
    workSup:startChild({10000,3}),
    workFsm:requestWork({io,format,["do job~n"]}),
    sleep(1000),
    workFsm:requestWork({io,format,["do job~n"]}),
    sleep(1000),
    workFsm:requestWork({io,format,["do job~n"]}),
    %---这里fsm应该是已经休息
    sleep(1000),
    workFsm:requestWork({io,format,["do job~n"]}),
    sleep(1000),
    io:format("lala~n"),
    sleep(7950),
    workFsm:requestWork({io,format,["do job~n"]}). 


sleep(Time)->
    receive 
        after Time ->ok 
    end. 