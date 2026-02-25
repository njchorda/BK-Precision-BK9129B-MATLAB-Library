# BK9129B — MATLAB Serial Driver

A MATLAB class for controlling the **BK Precision 9129B Triple-Output DC Power Supply** over a serial connection. Provides a clean interface for setting voltages, current limits, reading live measurements, and managing instrument state — all via SCPI commands.

---

## Requirements

- MATLAB R2021a or later (uses `serialport`)
- [Instrument Control Toolbox](https://www.mathworks.com/products/instrument.html)
- BK Precision 9129B connected via USB-to-serial or RS-232

---

## Installation

1. Copy `BK9129B.m` into your MATLAB working directory or add it to your path.
2. Connect the instrument and identify its serial port (e.g. `COM3` on Windows, `/dev/ttyUSB0` on Linux).

---

## Quick Start
**NOTE:** You can call the constructor without a serial port, however the function findAddress() returns a list of all available serial ports. If the BK9129B is the only serial device connected, this is not an issue, but if there are multiple then you need to specify the serial port.

```matlab
% Specify a port manually
ps = BK9129B('COM3');

% Enable output
ps.setOutput(true);

% Set channel voltages (Ch1 = 5V, Ch2 = 3.3V, Ch3 = 12V)
ps.setVoltage(5, 3.3, 12);

% Set current limits (A)
ps.setCurrentLimit(1.0, 0.5, 2.0);

% Read back live measurements
[V1, V2, V3] = ps.getMeasuredVoltage();
[I1, I2, I3] = ps.getMeasuredCurrent();
[P1, P2, P3] = ps.getMeasuredPower();

fprintf('Ch1: %.3f V, %.3f A, %.3f W\n', V1, I1, P1);

% Clean up
ps.deInit();
```

---

## API Reference

### Constructor

```matlab
obj = BK9129B()          % Auto-detect serial port
obj = BK9129B(portName)  % e.g. BK9129B('COM4')
```

Opens a 9600-baud serial connection, puts the instrument into remote mode, resets it, and zeros all channel voltages.

---

### Output Control

| Method | Description |
|---|---|
| `setOutput(bool)` | Enable (`true`) or disable (`false`) all outputs |

---

### Voltage & Current

| Method | Description |
|---|---|
| `setVoltage(v1)` | Set channel 1 voltage only |
| `setVoltage(v1, v2)` | Set channels 1 and 2; pass `[]` to leave a channel unchanged |
| `setVoltage(v1, v2, v3)` | Set all three channels; pass `[]` to skip any channel |
| `setCurrentLimit(i1, ...)` | Same signature as `setVoltage` but for current limits (A) |
| `[V1,V2,V3] = getSetVoltage()` | Query the programmed (set-point) voltages |
| `[I1,I2,I3] = getSetCurrent()` | Query the programmed current limits |

---

### Measurements

| Method | Description |
|---|---|
| `[V1,V2,V3] = getMeasuredVoltage()` | Read live output voltages from all channels |
| `[I1,I2,I3] = getMeasuredCurrent()` | Read live output currents from all channels |
| `[P1,P2,P3] = getMeasuredPower()` | Read live output power from all channels |

---

### Instrument Management

| Method | Description |
|---|---|
| `reset()` | Send `*RST`, zero all voltages and current limits |
| `selfTest()` | Run instrument self-test (`*TST?`) and report result |
| `setLocal()` | Return instrument to local (front-panel) control |
| `sendCommand(cmd)` | Send a raw SCPI command; returns response string for queries, `0` otherwise |
| `bool = deInit()` | Return to local, reset, and close the serial connection |

### Static Methods

| Method | Description |
|---|---|
| `BK9129B.findAddress()` | Returns a list of available serial ports via `serialportlist` |

---

## Notes

- `setVoltage` and `setCurrentLimit` both accept `[]` as a placeholder to leave a channel at its current value without re-querying unnecessarily.
- `deInit()` returns `1` on success and `0` if the port was already closed.
- The instrument is automatically placed in **remote mode** (`SYST:REM`) on construction and returned to **local mode** on `deInit()`.
- Baud rate is fixed at **9600**.

---

## License

MIT — see [LICENSE](LICENSE) for details.
