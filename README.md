# Digital-Counter-using-Verilog-and-FPGA
A Verilog-based digital stopwatch for FPGA with millisecond accuracy. It uses an FSM for control (start, pause, reset) and counters for timekeeping, displaying minutes, seconds, and milliseconds on six 7-segment displays. A modular design for learning digital logic and HDL.

A digital stopwatch implemented in Verilog HDL, designed for FPGA boards. The design uses a Finite State Machine (FSM) for control, a timing counter for generating 1 ms ticks from a 50 MHz clock, and six 7-segment displays for showing minutes, seconds, and milliseconds.

Features

FSM-based control with three states:

RESET → clears time

RUN → stopwatch counting

PAUSE → stopwatch halted

Supports both hard reset (asynchronous) and soft reset (synchronous).

Accurate 1 ms resolution using clock division and counters.

6-digit display output (mm:ss:ms) using BCD counting.

Modular design:

stopwatch.v – top-level module

stopwatch_fsm.v – finite state machine for control

dec_7seg.v – BCD to 7-segment decoder
