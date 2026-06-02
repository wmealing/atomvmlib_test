atomtest
=====

An AtomVM application for the SparkFun Thing Plus ESP32-C6, reading temperature, pressure,
and humidity from a BME280 sensor connected via Qwiic (I2C).

## Hardware

- **Board**: SparkFun Thing Plus ESP32-C6
- **Sensor**: BME280 (temperature, pressure, humidity) connected via Qwiic connector
- **I2C pins**: SDA = GPIO6, SCL = GPIO7 (LP I2C bus, tied to Qwiic connector)
- **I2C address**: 0x77 (SparkFun BME280 Qwiic default)
- **Serial port**: `/dev/cu.usbmodem1101`

## Firmware

AtomVM v0.7.0-alpha.1 for ESP32-C6 is flashed at address `0x0`. The app AVM is flashed
at `0x250000` (the `main.avm` partition).

Flash AtomVM firmware (one-time):

    esptool --port /dev/cu.usbmodem1101 --baud 921600 write-flash 0x0 downloads/AtomVM-esp32c6-v0.7.0-alpha.1.img

## Build and Flash

    rebar3 atomvm packbeam
    rebar3 atomvm esp32_flash

## Monitor

The ESP32-C6 uses USB-Serial/JTAG which drops the connection on every reset.  I'm using
screen /dev/cu.usbmodem1101


## Application Structure

- `atomtest_app` — entry point, exports `start/0` which AtomVM calls on boot
- `atomtest_sup` — supervisor that starts the `mytest` gen_server
- `mytest` — gen_server that opens an I2C bus, starts the BME280 driver, and reads sensor data

## The issue

### AtomVM v0.7.0-alpha.1 I2C NIF bug

The I2C NIF crashes the entire VM (Load access fault / Guru Meditation Error) 

- I2C scanning (probing all addresses) is not possible without crashing
- Any wrong I2C address will crash the VM

### i2c_bus open_port crash

`i2c:open/1` in the firmware defaults to `open_port({spawn, "i2c"}, ...)` which crashes
the VM on ESP32-C6.


After any `rebar3 clean --all`, re-apply the patch manually or the crash will return.

### Qwiic / LP GPIO compatibility

The Qwiic connector on the SparkFun Thing Plus ESP32-C6 is wired to the LP I2C peripheral
(GPIO6/GPIO7). AtomVM uses the regular I2C0 peripheral via the GPIO matrix on those same
pins. The driver installs successfully but I2C communication is unconfirmed working —
currently under investigation.

## Dependencies

- `atomvm_lib` (git, pinned ref `e5ec024`) — provides `i2c_bus`, `bme280` drivers
- `atomvm_rebar3_plugin` (global) — provides `packbeam` and `esp32_flash` rebar3 tasks
