## Simple UART in VHDL
This is a UART module built from basic digital building blocks such as counters, debouncers, RAM, and state machines.  

## Motivation
This project exists to show how digital systems can be built up from simple modules, and as an exercise in VHDL programming.  It was originally intended to be implemented on the Arty board with an Artix-7 FPGA.
 
## How it Works:
Below is the top level block diagram for the UART:

![Alt text](UART_block.png?raw=true "UART Block Diagram")

The design operates as follows:<br />
1.) RAM State Machine reads data from the UART Receiver FIFO anytime that the receiver FIFO is not empty.<br />
2.) Each byte read is written to RAM and the address counter is incremented.<br />
3.) Whenever the BUTTON1 is pressed, the state machine resets the address counter, reads each RAM address and writes the data byte to the UART Transmitter FIFO.<br />
4.) RAM state machine pauses reading from the RAM when the UART Transmitter FIFO is full.<br />
5.) After the entire contents of the RAM is transmitted, the state machine resets the RAM address counter and waits until more data is available in the UART Receiver FIFO.

## How to get up and running
In Vivado,  import all .vhd files as design sources.  Add a constraints file for your board.  If using the Arty, add the constraints included here (UART_constraints.xdc) <br /> <br />
Synthesize and implement! <br />
Use a serial terminal program like Uterm to communicate over USB.  <br />
Type into terminal to send ascii characters to the Arty UART.  <br />
Press Button1 on Arty board (or whatever digital input specified in .xdc) to receive the data back! <br />
