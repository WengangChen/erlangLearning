-module(test). 

-export([start/0,checkPrime/1,test/0]). 
start()->
    primeTest:start(name1).

checkPrime(Number)-> 
    Ans = primeTest:checkPrime(name1,Number),
    io:format("test-8: result:~w ~n",[Ans]). 







test()->
    receive 
        after 2000->io:format("timeOut~n")
    end. 