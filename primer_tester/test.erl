-module(test). 

-export([start/0,checkPrime/1]). 
start()->
    primeTest:start(name1).

checkPrime(Number)-> 
    Ans = primeTest:checkPrime(name1,Number),
    io:format("test-8: result:~w ~n",[Ans]). 