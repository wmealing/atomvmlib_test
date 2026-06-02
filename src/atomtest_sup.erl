%%%-------------------------------------------------------------------
%% @doc atomtest top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(atomtest_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    io:format("I AM SUPERVISOR~n"), 
    SupFlags = #{
        strategy => one_for_all,
        intensity => 0,
        period => 1
    },
    ChildSpecs = [
        #{id => bme280_server,
          start => {bme280_server, start_link, []},
          restart => permanent, shutdown => 2000,
          type => worker, modules => [bme280_server]},
        #{id => sensor_client,
          start => {sensor_client, start_link, []},
          restart => permanent, shutdown => 2000,
          type => worker, modules => [sensor_client]}
    ],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
