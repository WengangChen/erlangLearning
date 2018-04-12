%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%% 通用的东西
%%% @end
%%% Created : 12. 四月 2018 14:02
%%%-------------------------------------------------------------------
-module(universal).
-author("Administrator").

%% API
-export([sleep/1]).


sleep(Time)->
  receive
    after Time->
      ok
  end.

