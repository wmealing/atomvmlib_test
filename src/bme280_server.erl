-module(bme280_server).

-behaviour(gen_server).

-export([start_link/0, get_reading/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {bme280}).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

get_reading() ->
    gen_server:call(?SERVER, get_reading).

init([]) ->
    {ok, Bus} = i2c_bus:start(#{sda => 6, scl => 7, freq_hz => 100000}),
    case bme280:start(Bus, [{address, 16#77}]) of
        {ok, Ref} ->
            io:format("BME280 ready~n"),
            {ok, #state{bme280=Ref}};
        {error, Reason} ->
            io:format("BME280 init failed: ~p~n", [Reason]),
            {stop, bme280_not_found}
    end.

handle_call(get_reading, _From, State) ->
    Reply = bme280:take_reading(State#state.bme280),
    {reply, Reply, State};
handle_call(_Request, _From, State) ->
    {reply, {error, unknown_request}, State}.

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
