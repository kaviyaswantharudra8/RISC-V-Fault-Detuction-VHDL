# Fault Detection and Injection in a Simplified RISC-V Processor

A VHDL-based project that demonstrates fault injection and observation in a simplified RISC-V processor datapath.

The design models a small RISC-V processor using VHDL and introduces controllable faults into important processor blocks. The effect of the injected fault can then be observed in simulation using waveform analysis.

## Overview

Modern processors must continue to operate reliably even when faults occur in internal hardware blocks.

This project demonstrates the basic concept of hardware fault analysis by injecting faults into different processor components and observing their effects on the datapath.

The processor contains:

- Program Counter
- Instruction Memory
- Register File
- Immediate Generator
- Control Unit
- ALU Control
- ALU
- Data Memory
- Multiplexers

The complete design is written in VHDL and verified using a VHDL testbench.

## Project Objectives

The main objectives are:

1. Design a simplified RISC-V processor datapath using VHDL.
2. Simulate normal processor operation.
3. Introduce a controllable fault-injection signal.
4. Observe the effect of faults on processor components.
5. Analyze the resulting waveform.
6. Demonstrate recovery after fault injection is removed.

## Architecture

The simplified processor follows the basic datapath:

Instruction Memory
        |
        v
Control Unit
        |
        v
Register File ----> Immediate Generator
        |                  |
        |                  v
        +---------------> MUX
                           |
                           v
                          ALU
                           |
                           v
                     Data Memory
                           |
                           v
                    Write-back MUX
                           |
                           v
                     Register File

The Program Counter provides the address for instruction fetching.

## Processor Components

### 1. Program Counter

The Program Counter stores the address of the current instruction.

During normal operation:

```text
PC(next) = PC + 4
