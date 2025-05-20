# risc-cpu-verilog-lab-project

# RISC CPU Design – Verilog Lab Project 🧠🔧

## Overview
This repository contains the implementation of a simple **RISC-based processor architecture** using Verilog, developed as part of a laboratory course in **Digital Systems**. It includes components such as an ALU, datapath, register file, finite state machine (FSM), and full system simulation through testbenches.

> 📘 **Note:** The full project report is written in Greek.

---

## 🧱 Module Breakdown

### ⚙️ Exercise 1: ALU Design
- **File:** `alu.v`
- Implements an Arithmetic Logic Unit that performs arithmetic and logical operations.
- Operations are controlled by a 4-bit input signal `alu_op`.

---

### 🧮 Exercise 2: Calculator with Encoder
- **Files:**
  - `calc.v`: A simple calculator design using the ALU.
  - `calc_enc.v`: Encodes button inputs (`btnl`, `btnc`, `btnr`) into a 4-bit `alu_op`.
  - `calc_tb.v`: Testbench that simulates button presses and generates waveform (VCD) output.

---

### 💾 Exercise 3: Register File
- **File:** `regfile.v`
- Implements a register file with read/write access and hazard handling.
- Prevents simultaneous read/write to the same register.

---

### 🔄 Exercise 4: Datapath
- **File:** `datapath.v`
- Models the data path of the processor including:
  - Register file
  - ALU
  - Instruction and data buses
  - PC (Program Counter)

---

### 🧠 Exercise 5: Full Processor (Top-Level)
- **Files:**
  - `top_proc.v`: Integrates datapath and FSM (control logic) into a full RISC CPU model.
  - `top_proc_tb.v`: Testbench for the full processor.
  - `ram.v`, `rom.v`: Simulated instruction/data memory modules (used in testbench).

---

## 🧪 How to Simulate

1. Use a Verilog simulator like **ModelSim**, **Vivado**, or **Icarus Verilog**.
2. Compile the relevant module (e.g. `top_proc.v`) with its testbench (`top_proc_tb.v`).
3. Run simulation and analyze waveform with VCD output.

Example (Icarus Verilog):

```bash
iverilog -o sim top_proc.v top_proc_tb.v alu.v datapath.v regfile.v calc.v calc_enc.v
vvp sim
gtkwave simulation.vcd
