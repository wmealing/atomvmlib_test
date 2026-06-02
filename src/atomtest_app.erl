%%%-------------------------------------------------------------------
%% @doc atomtest public API
%% @end
%%%-------------------------------------------------------------------

-module(atomtest_app).

-behaviour(application).

-export([start/0, start/2, stop/1]).

start() ->
    atomtest_sup:start_link(),
    receive after infinity -> ok end.

start(_StartType, _StartArgs) ->
    atomtest_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
