-module(i2c_scan).
-export([scan/0]).

scan() ->
    io:format("Opening I2C NIF...~n"),
    I2C = i2c:open_nif([{sda, 6}, {scl, 7}, {clock_speed_hz, 400000}]),
    io:format("I2C opened: ~p~n", [I2C]),
    io:format("Scanning I2C bus (SDA=6, SCL=7)...~n"),
    Found = lists:foldl(fun(Addr, Acc) ->
        case i2c:read_bytes(I2C, Addr, 1) of
            {ok, _} ->
                io:format("Found device at 0x~2.16.0B~n", [Addr]),
                [Addr | Acc];
            _ ->
                Acc
        end
    end, [], lists:seq(16#08, 16#77)),
    i2c:close(I2C),
    case Found of
        [] -> io:format("No devices found.~n");
        _  -> io:format("Scan complete. Found ~p device(s).~n", [length(Found)])
    end.
