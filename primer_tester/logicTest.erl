-module(logicTest). 
-author("GangChen"). 

-export([test/0,start/0,addQuest/1,delQuest/1,setBusy/1,setEmpty/1,print/0]). 


test()->
    start(),
    addQuest(123),
    addQuest(123),
    addQuest(123),
    addQuest(123),
    addQuest(123),
    addQuest(123),
    addQuest(123),
    addQuest(123),
    addQuest(123),
    addQuest(123),
    addQuest(123),
    addQuest(123),
    addQuest(123),
    addQuest(123),
    print(). 


start()->
    ets:new(answer,[named_table,public,ordered_set]),
    List = getIntegerAtomToLit(10),
    ManagerEmptyListPid = spawn(fun ()-> managerEmptyList([]) end),
    register(managerEmptyList,ManagerEmptyListPid),
    ManagerQuestListPid = spawn(fun () -> managerQuestList([]) end),  
    register(managerQuestList,ManagerQuestListPid),
    % io:format("logicTest-start :managerEmptyListPid:~w  managerQuestListPid:~w ~n",[ManagerEmptyListPid,ManagerQuestListPid]),
    spawn(fun () ->loopForWork() end),
    % io:format("Pid1:~w ,Pid2:~w~n",[whereis(managerEmptyList),whereis(managerQuestList)]),
    testerSup:start_in_shell(List). 
    % io:format("Pid1:~w ,Pid2:~w~n",[whereis(managerEmptyList),whereis(managerQuestList)]). 
    

addQuest(Number)->
    
    % io:format("Pid1:~w ,Pid2:~w~n",[whereis(managerEmptyList),whereis(managerQuestList)]),
    if 
        is_integer(Number) ->
            managerQuestList!{addQuest,Number},
            true; 
        true ->err
    end. 

delQuest(Number)->
    if
        is_integer(Number) ->
            managerQuestList! {delQuest,Number};
        true -> err
    end. 

setEmpty(WorkerName)->
    io:format("logicTest-setEmpty:~w ~n",[WorkerName]),
    managerEmptyList !{setEmpty,WorkerName}. 

setBusy(WorkerName) ->
    managerEmptyList !{setBusy,WorkerName}. 


%%-----------------阻塞等待获取空闲进程
waitForGetEmptyWorker()->
    managerEmptyList !{ getEmptyWorker,self()},
    receive
        {emptyWorker,A} ->A;
        {allBusy} ->
            sleep(1000),
            waitForGetEmptyWorker()
    end. 

waitForGetQuest()->
    managerQuestList ! {getQuest,self()},
    receive
        {quest,A}-> A;
        {noQuest} ->sleep(1000),
        waitForGetQuest()
    end. 


loopForWork() ->
%%----------阻塞----------------------
    Worker = waitForGetEmptyWorker(), 
    % io:format("logicTest-loopForWork:Worker = ~w ~n",[Worker]),
    Quest = waitForGetQuest(),
    % io:format("logicTest-loopForWork:Quest = ~w ~n",[Quest]),
    spawn(fun () -> work(Worker,Quest)end),
    % io:format("logicTest-loopForWork:Pid = ~w ~n",[Pid]),
    loopForWork(). 


%%-------执行一次----------
work(Worker,Quest) ->
    io:format("logicTest-work:Prepare to Work ,Worker:~w Quest :~w ~n",[Worker,Quest]),
  %%---模拟运行过程的时间---
    sleep(2000),
    Result = primeTest:checkPrime(Worker,Quest),

    io:format("logicTest-work:Work Done~n"),
    io:format("logicTest-work : Prime :~w , Result : ~w ,Worker :~w ~n",[Quest,Result,Worker]),
    setEmpty(Worker),
    io:format("logicTest_work:finishSetEmpty.~n").  
   

print()->
    managerEmptyList!{test},
    managerQuestList! {test}. 



managerQuestList(List) ->
    % io:format("logicTest-managerQuestList:start~n"),
    receive    
        {addQuest,Val} ->
            io:format("logicTest-managerQuestList,Quest ~w add ~n",[Val]),
            managerQuestList([Val|List]);
        {delQuest,Val} ->
            io:format("logicTest-managerQuestList:Quest ~w delete ~n",[Val]),
            managerEmptyList(List--[Val]);
%--------------------测试用      
        {test} -> 
            % io:format("11111~n"),
            io:format("logicTest-managerQuestList:test ~w ~n",[List]),
            managerQuestList(List);
        %--------------为了保证不被别的获取，直接get的时候就把他设置为busy了
        {getQuest,Pid} ->
            case List of
                [] ->Pid!{noQuest},managerQuestList(List);
                [A|_B] ->
                    io:format("logicTest-managerQuestList:Quest ~w has been get~n",[A]),
                    Pid!{quest,A},
                    managerQuestList(List--[A])
            end
    end.






managerEmptyList(List)->
    receive 
        {setEmpty,Val}->
            io:format("logicTest-: ~w is Empty~n",[Val]),
            managerEmptyList([Val|List]);
        {setBusy,Val}->
            io:format("logicTest-: ~w is Busy~n",[Val]),
            managerEmptyList(List--[Val]);
        %%--------------为了保证不被别的获取，直接get的时候就把他设置为busy了
        {getEmptyWorker,Pid}->
            case List of
                [] ->Pid !{allBusy},managerEmptyList(List);
                [A|_B] ->
                    io:format("logicTest-: ~w can be use ~n",[A]),
                    Pid! {emptyWorker,A},
                    managerEmptyList(List--[A]);
                _ ->
                    io:format("logicTest-managerEmptyList:quit~n"),
                    io:format("logicTest-managerEmptyList:Now List:~w~n",[List]),
                    err
            end;
        {test} ->
            io:format("LogicTest-managerEmptyList:Now List:~w~n",[List]),
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

sleep(Time) ->
    receive
        after Time ->timeout    
    end. 