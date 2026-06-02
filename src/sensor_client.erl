-module(sensor_client).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    erlang:send_after(1000, self(), tick),
    {ok, #{}}.

handle_info(tick, State) ->
    case bme280_server:get_reading() of
        {ok, {Temp, Pressure, Humidity}} ->
            io:format("Temp: ~.2f C, Pressure: ~.2f hPa, Humidity: ~.2f%~n",
                      [Temp, Pressure, Humidity]);
        {error, Reason} ->
            io:format("Read error: ~p~n", [Reason])
    end,
    erlang:send_after(1000, self(), tick),
    {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.

handle_call(_Request, _From, State) -> {reply, ok, State}.
handle_cast(_Msg, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
