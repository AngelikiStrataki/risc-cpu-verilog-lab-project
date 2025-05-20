`timescale 1ns/1ps
`include "top_proc.v"
`include "ram.v"
`include "rom.v"

module top_proc_tb;

  // Signals
  reg clk;
  reg rst;
  wire [31:0] instr;
  wire [31:0] dReadData;
  wire [31:0] PC;
  wire [31:0] dAddress;
  wire [31:0] dWriteData;
  wire MemRead;
  wire MemWrite;
  wire [31:0] WriteBackData;
  wire addr[8:0];

  // Instantiate the top_proc module
  top_proc UUT (
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .dReadData(dReadData),
    .PC(PC),
    .dAddress(dAddress),
    .dWriteData(dWriteData),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .WriteBackData(WriteBackData)
  ); 
	
INSTRUCTION_MEMORY instruction_memory (
  .clk(clk),
  .addr(UUT.PC[8:0]),  // Use only the least significant 9 bits
  .dout(instr)
);
DATA_MEMORY data_memory (
  .clk(clk),
  .we(UUT.MemWrite),
  .addr(UUT.dAddress[8:0]),  // Use only the least significant 9 bits
  .din(UUT.dWriteData),
  .dout(dWriteData)
);

	initial begin
		#30 clk=1'b0;
	end
	
	initial begin
		rst=1'b1;
		#40 rst=1'b0;
	end
	
  always begin
   #10 clk = ~clk; // Toggle clock every half period
  end

  // Stimulus
  initial begin
	$dumpfile("simulation.vcd");
   $dumpvars(0, top_proc_tb);
    // Finish simulation
   #2800 $finish;
  end

endmodule
