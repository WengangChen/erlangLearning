-module(logicTest). 
-author("GangChen"). 

-export([start/0]). 



start()->
    ets:new(answer,[named_table,public,ordered_set]),
    List = getIntegerAtomToLit(10),
    
    ManagerEmptyListPid = spawn(fun ()-> managerEmptyList(List) end),
    register(managerEmptyList,ManagerEmptyListPid),
    testerSup:start(List).


addQuest(Number)->
    














managerEmptyList(List)->
    receive 
        {setEmpty,Val}->
            io:format("logicTest-35: ~w is Empty~n",[Val]),
            managerEmptyList([Val|List]);
        {setBusy,Val}->
            io:format("logicTest-38: ~w is Busy~n",[Val]),
            managerEmptyList(List--[Val]);
        {getEmptyWorker,Pid}->
            [A|B] =List,
            io:format("logicTest-41: ~w can be use ~n",[A]),
            Pid! {emptyWorker,A},
            managerEmptyList(List)
    end.


















%----------------------------------------------------------------------------
integerToAtom(Number)->
    List = integer_to_list(Number),
    list_to_atom(List).



%--批量生成数字然后变成原子
getIntegerAtomToLit(Number) ->
    case Number of
        0 -> [];
        _Oth ->[integerToAtom(Number)|getIntegerAtomToLit(Number-1)]
    end. 
