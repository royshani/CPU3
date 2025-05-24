CPU Lab 3

This project implements a simplified multi-cycle CPU architecture in VHDL. The design separates control and datapath logic, integrates memory-mapped instruction and data memory, and supports essential operations including ALU arithmetic, memory access, and control flow instructions.

Project Overview
The architecture is composed of:

A Datapath that integrates the ALU, Register File, Program Counter, and tri-state data buses.

A Control Unit that decodes instructions and orchestrates execution via a finite state machine (FSM).

Separate instruction (ITCM) and data (DTCM) memories, both accessible by CPU or testbench.

Support for simulation through a structured testbench, enabling automated input/output via memory text files.

The processor executes instructions in multiple cycles, with fine-grained control over each internal operation such as fetching, decoding, executing, memory access, and writeback.
1. top.vhd

Function: Top-level integration of the Datapath and ControlUnit modules.

Data Flow:

Routes external testbench inputs to Datapath.

Connects ALU flags and opcode to ControlUnit.

Control Signals:

done_o is set by ControlUnit through status_bits.

2. Datapath.vhd

Function: datapath integrates the ALU, register file, instruction memory (ITCM), data memory (DTCM), and instruction register (IR). It leverages tri-state bidirectional buffers to manage the shared data bus (bus B) and supports both processor-driven and testbench-driven memory interactions. The design provides modular flexibility for testbench control and full CPU simulation.

Data Flow:

Fetches instructions from ProgMem, executes operations via ALU, stores results to dataMem.

Register File (RF), Immediate Registers, Program Counter Logic (PCLogic), and ALU coordinate execution.

Control Signals:

Includes ALUFN_i, PCsel_i, Ain_i, RF_WregEn_i, IRin_i, Imm1_in_i, etc.

3. ControlUnit.vhd

Function: Generates the FSM state signals and routes control signals to ControlLines.

Data Flow:

Takes opcode, ALU flags, clk, ena, rst.

Control Signals:

state_i into ControlLines, outputs all control lines for Datapath.

4. ControlLines.vhd

Function: Generates micro-operation control signals based on FSM state and opcode.

Data Flow:

Uses case conditions to decode the current state and determine control values.

Control Signals:

Output lines like ALUFN_o, Ain_o, DTCM_wr_o, IRin_o, etc.

5. StateLogic.vhd

Function: FSM that steps through states of instruction execution.

Data Flow:

Advances on rising clock edges.

Control Signals:

state_o is used by ControlLines.

6. IR.vhd (Instruction Register)

Function: Parses and decodes the fetched instruction.

Data Flow:

Extracts opcode, imm, register addresses.

Control Signals:

IRin_i enables register load.

7. PCLogic.vhd

Function: Handles program counter updates and branching.

Data Flow:

Calculates PC+1 or PC+imm.

Control Signals:

Controlled by PCin_i, PCsel_i.

8. RF.vhd (Register File)

Function: Holds general-purpose registers.

Data Flow:

Reads/writes using addresses from IR, data from bus_a.

Control Signals:

RF_WregEn_i, RF_addr_rd_i, RF_addr_wr_i, etc.

9. GenericRegister.vhd

Function: Generic n-bit register with clocked input.

Data Flow:

Used for IR, PC, and intermediate storage.

10. FA.vhd (Full Adder)

Function: Basic 1-bit full adder used for arithmetic operations.

Data Flow:

Used in PCLogic and ALU.

11. ALU_main.vhd

Function: Arithmetic and logic operations on inputs A and B.

Data Flow:

Controlled by i_ctrl opcode.

Control Signals:

Output flags: cflag, zflag, nflag.

12. BidirPin.vhd

Function: Simulates a tri-state data bus.

Data Flow:

Transfers data from one module to a shared bus.

Control Signals:

en enables data flow from Dout to IOpin.

13. BidirPinBasic.vhd

Function: Basic alternative to BidirPin, used in debugging.

14. progMem.vhd

Function: Instruction memory.

Data Flow:

Takes address from PCLogic, data from testbench.

15. dataMem.vhd

Function: Data memory used for store/load.

Data Flow:

Accessed by Datapath via muxed address/data/control lines.

16. aux_package.vhd

Function: Contains all component declarations for global reuse.

Contents:

Components: FA, GenericRegister, IR, etc.

Testbench

File: tb_top.vhd

Initializes ProgMem and DataMem from text files.

Monitors done_o to determine when execution is complete.

Extracts DTCM contents and writes back to file.

Build and Simulation Notes

Load all files into ModelSim (or equivalent).

Compile in dependency order: aux_package.vhd, FA.vhd, GenericRegister.vhd, ..., top.vhd, tb_top.vhd.

Run simulation for at least 4010 ns or until done_o = '1'.

Input/output text files are expected in:

./datapath_code/ITCMinit.txt
./datapath_code/DTCMinit.txt
./datapath_code/DTCMcontent.txt

Supported Instructions

ADD, SUB, AND, OR, XOR

MOV, LD, ST

JMP, JC, JNC, NOP

Each operation is decomposed into FSM states, with timing and control managed by ControlUnit and ControlLines.