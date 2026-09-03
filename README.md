# ⚡ Fault Injection and Detection Analysis in a Simplified RISC-V Processor

![VHDL](https://img.shields.io/badge/Language-VHDL-blue)
![RISC-V](https://img.shields.io/badge/Architecture-RISC--V-red)
![GHDL](https://img.shields.io/badge/Simulator-GHDL-orange)
![EDA Playground](https://img.shields.io/badge/Simulation-EDA%20Playground-green)
![Digital Design](https://img.shields.io/badge/Domain-Digital%20Design-purple)
![Status](https://img.shields.io/badge/Status-Working-success)

A VHDL-based project demonstrating **fault injection, fault propagation, and fault detection analysis** in a simplified RISC-V processor datapath.

> **Note:** The current version performs fault injection and waveform-based fault observation. Dedicated automatic fault-detection logic is planned as a future enhancement.

## 📌 Overview

This project models a small RISC-V processor using VHDL and studies how faults introduced into processor blocks affect the datapath.

The main flow is:

```text
Normal Operation
      ↓
Fault Injection
      ↓
Fault Propagation
      ↓
Fault Observation
      ↓
Fault Removed
      ↓
Recovery
```

## 🎯 Objectives

- Design a simplified RISC-V processor using VHDL.
- Simulate normal processor operation.
- Inject controlled faults into processor blocks.
- Observe fault propagation through the datapath.
- Analyze simulation waveforms.
- Study recovery after fault removal.
- Provide a base for future automatic fault detection and fault tolerance.

## 🏗️ Architecture

```text
                 +----------------+
                 | Program Counter|
                 +-------+--------+
                         |
                         v
                 +---------------+
                 | Instruction   |
                 | Memory        |
                 +-------+-------+
                         |
                         v
                 +---------------+
                 | Control Unit  |
                 +-------+-------+
                         |
              +----------+----------+
              |                     |
              v                     v
       +-------------+       +-------------+
       | Register    |       | Immediate   |
       | File        |       | Generator   |
       +------+------+       +------+------+
              |                     |
              +----------+----------+
                         |
                         v
                    +---------+
                    |   MUX   |
                    +----+----+
                         |
                         v
                    +---------+
                    |   ALU   |
                    +----+----+
                         |
                         v
                    +---------+
                    |  Data   |
                    | Memory  |
                    +----+----+
                         |
                         v
                    +---------+
                    |  MUX    |
                    |Writeback|
                    +----+----+
                         |
                         v
                   Register File
```

## 🧩 Modules

| Module | Function |
|---|---|
| `PC` | Stores and updates the program counter |
| `IM` | Instruction memory |
| `RF` | Register file |
| `IMM` | Immediate generator |
| `CU` | Main control unit |
| `ALUCTRL` | ALU control |
| `ALU` | Arithmetic and logical operations |
| `DM` | Data memory |
| `MUX` | Datapath selection |
| `CPU` | Top-level processor |
| `tb_CPU` | Simulation testbench |

## ⚙️ Fault Injection

The design uses:

```text
fi
```

### Normal

```text
fi = 0
```

### Fault injection

```text
fi = 1
```

During fault injection, predefined fault signatures are generated:

| Block | Fault Value |
|---|---|
| Program Counter | `DEADBEEF` |
| Instruction Memory | `FFFFFFFF` |
| Register File | `BAD0BAD0` |
| ALU | `0BADD00D` |
| Data Memory | `DEADDEAD` |
| MUX | `EEEEEEEE` |

These values make the injected fault easy to identify in the waveform.

## 🔍 Fault Detection Concept

The current implementation demonstrates **fault injection and fault observation**.

For example:

```text
Normal ALU Result
       ↓
Fault Injection
       ↓
  0BADD00D
       ↓
Observed in waveform
```

A future automatic detector can compare expected and actual values:

```text
Expected Value ───┐
                  ├──> Comparator ───> fault_detected
Actual Value ─────┘
```

This will convert the current fault-analysis system into an automatic fault-detection system.

# 🧪 Simulation

### Tools

- VHDL
- GHDL
- EDA Playground
- Waveform Viewer

## ⏱️ Simulation Timing

The testbench uses a **10 ns clock period**:

```text
Clock LOW  = 5 ns
Clock HIGH = 5 ns
Period     = 10 ns
Frequency  = 100 MHz
```

The complete simulation is divided into several phases:

| Time | `rst` | `fi` | State |
|---:|:---:|:---:|---|
| `0–15 ns` | `1` | `0` | Reset |
| `15–45 ns` | `0` | `0` | Normal operation |
| `45–65 ns` | `0` | `1` | Fault injection |
| `65–85 ns` | `0` | `0` | Recovery |
| `85–95 ns` | `1` | `0` | Reset |
| `95–125 ns` | `0` | `0` | Normal operation |
| `125 ns` | — | — | Simulation ends |

### Timing Diagram

```text
Time(ns)  0        15             45        65        85    95             125
          |--------|--------------|---------|---------|-----|---------------|

rst       █████████                __________________█████___________________
          RESET                    NORMAL              RESET      NORMAL

fi        _________________________██████████_______________________________
                                   FAULT

State     RESET       NORMAL      FAULT     RECOVERY   RESET      NORMAL
```

## 🔄 Simulation Phases

### 1. Reset — 0 to 15 ns

```text
rst = 1
fi  = 0
```

The processor is initialized.

The Program Counter is cleared:

```text
PC = 00000000
```

The register file and data memory are also reset.

### 2. Normal Operation — 15 to 45 ns

```text
rst = 0
fi  = 0
```

The processor operates normally.

The Program Counter advances by:

```text
PC = PC + 4
```

Instructions are fetched and processed through the datapath.

### 3. Fault Injection — 45 to 65 ns

```text
rst = 0
fi  = 1
```

This is the main fault-analysis interval.

The predefined fault signatures appear in the corresponding blocks:

```text
PC  → DEADBEEF
IM  → FFFFFFFF
RF  → BAD0BAD0
ALU → 0BADD00D
DM  → DEADDEAD
MUX → EEEEEEEE
```

These values should be visible in the waveform.

### 4. Recovery — 65 to 85 ns

```text
rst = 0
fi  = 0
```

The fault injection is removed.

The processor returns to its normal datapath behavior.

### 5. Second Reset — 85 to 95 ns

```text
rst = 1
fi  = 0
```

The processor is reset again and the PC returns to zero.

### 6. Final Normal Operation — 95 to 125 ns

```text
rst = 0
fi  = 0
```

The processor resumes normal operation.

This provides a second normal-operation interval for comparison with the first one.

## 📊 Waveform Analysis

Important signals include:

```text
clk
rst
fi
pc
ins
d1
d2
imm
alu_y
mem_d
wb_d
```

The most important signal is:

```text
fi
```

The waveform should show:

```text
NORMAL          FAULT             RECOVERY

fi = 0          fi = 1            fi = 0
   |               |                  |
   v               v                  v

normal values → fault signatures → normal values
```

## 🖼️ Simulation Result

Place the waveform screenshot at:

```text
simulation/waveform.png
```

Then include it in the README:

```markdown
![Simulation Waveform](simulation/waveform.png)
```

## 📁 Repository Structure

```text
riscv-fault-detection/
│
├── README.md
│
├── src/
│   └── design.vhd
│
├── tb/
│   └── testbench.vhd
│
├── simulation/
│   └── waveform.png
│
└── docs/
    └── block_diagram.png
```

## ▶️ How to Run

### EDA Playground

1. Select **VHDL**.
2. Select **GHDL**.
3. Put `design.vhd` in the Design section.
4. Put `testbench.vhd` in the Testbench section.
5. Set the top entity to:

```text
tb_CPU
```

6. Run the simulation.
7. Open the waveform viewer.
8. Add the important internal signals.
9. Observe normal, fault, and recovery intervals.

### GHDL

```bash
ghdl -a src/design.vhd
ghdl -a tb/testbench.vhd
ghdl -e tb_CPU
ghdl -r tb_CPU
```

For a waveform:

```bash
ghdl -r tb_CPU --wave=wave.ghw
```

## 📚 Instructions

The instruction memory contains a small demonstration sequence:

```text
00500093
00A00113
002081B3
00302023
00002203
```

The processor supports a limited set of operations including immediate arithmetic, register arithmetic, load, and store behavior.

It is intentionally a simplified RISC-V implementation rather than a complete ISA implementation.

## ⚠️ Limitations

- Simplified RISC-V processor.
- Limited instruction support.
- Complete branch execution is not implemented.
- One global fault-injection signal is currently used.
- Fault values are predefined for demonstration.
- Automatic hardware fault detection is not yet implemented.
- No redundancy or error-correction mechanism is currently included.

## 🚀 Future Improvements

### Individual Fault Injection

Replace the global signal with:

```text
fi_pc
fi_im
fi_rf
fi_alu
fi_dm
fi_mux
```

This allows each block to be tested independently.

### Automatic Fault Detector

Add comparator-based detection:

```text
Expected Result
       |
       v
   Comparator ───> fault_detected
       ^
       |
Actual Result
```

### Hardware Implementation

The design can be implemented on an FPGA using:

- Switches for fault injection
- LEDs for fault status
- LCD for displaying fault information

### Fault-Tolerant Design

Future versions can investigate:

- Redundant computation
- Triple Modular Redundancy
- Watchdog circuits
- Error detection codes
- Error correction
- Recovery mechanisms

### Extended RISC-V Support

Add:

- Branch instructions
- Jump instructions
- More ALU operations
- Additional load/store instructions

## 🎓 Academic Relevance

This project combines:

- Digital Electronics
- VLSI Design
- Computer Architecture
- RISC-V Architecture
- RTL Design
- VHDL
- Functional Verification
- Fault Analysis

## 📌 Conclusion

This project demonstrates a simplified RISC-V processor implemented in VHDL and provides a controlled environment for studying hardware faults.

The simulation demonstrates:

```text
Normal Operation
       ↓
Fault Injection
       ↓
Fault Observation
       ↓
Recovery
```

The distinctive fault signatures make it possible to identify abnormal behavior in the simulated processor datapath.

The project provides a foundation for developing a more advanced **automatic fault-detection and fault-tolerant RISC-V processor**.

## 👤 Author

**Kavi Yaswanth Arudra**

VLSI / Digital Design Project

## ⭐ Highlights

- ✔️ Simplified RISC-V datapath
- ✔️ Modular VHDL RTL design
- ✔️ Fault injection
- ✔️ Fault propagation analysis
- ✔️ Normal/fault/recovery simulation
- ✔️ GHDL compatible
- ✔️ EDA Playground compatible
- ✔️ Suitable for FPGA extension
- ✔️ Extendable to automatic fault detection
