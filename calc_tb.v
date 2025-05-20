`timescale 1ns/1ps
`include "calc.v"

module calc_tb;

  reg clk, btnc, btnl, btnr, btnu, btnd;
  reg [15:0] sw;
  wire [15:0] led;

  // Εισαγωγή του calc module
  calc uut (
    .clk(clk),
    .btnc(btnc),
    .btnl(btnl),
    .btnr(btnr),
    .btnu(btnu),
    .btnd(btnd),
    .sw(sw),
    .led(led)
  );

  initial
    begin
    clk=1'b0;
  end
  // Παραγωγή σήματος ρολογιού
  always begin
    clk = 0;
    #10 clk = ~clk;
  end
  
  
  // Δημιουργία των παραμέτρων ελέγχου
  reg [15:0] expected_result;
  reg [15:0] previous_value;
  
  // Αρχικές τιμές εισόδων
  initial begin
   btnc = 0; btnl = 0; btnr = 0; btnu = 0; btnd = 0;
   sw = 16'h0000;
    expected_result = 16'h0000;
    previous_value = 16'h0000;
   #10;
	btnu = 1;
	#10;
	btnu = 0;
	#10;
  end
   always begin
    #95 btnd = ~btnd;
    #3  btnd = ~btnd;
end
 
	 
  // Υπορουτίνα ελέγχου
  task test
    (input btnl, btnc, btnr,
    input [15:0] previous_value,
    input [15:0] sw,
    input operation,
    input [15:0] expected_result); begin

	 //#50; // Περίμενε μέχρι να συγκλίνουν οι τιμές
	 calc_tb.btnc = btnc;
    calc_tb.btnl = btnl;
    calc_tb.btnr = btnr;
    calc_tb.sw = sw;
   #45;
	 #2;
    end
    endtask

  initial begin
   $dumpfile("simulation.vcd");
   $dumpvars(0, calc_tb);
   #50 test(0, 1, 1, 16'h0, 16'h1234, "ALUOP_OR", 16'h1234);
   #50 test(0, 1, 0, 16'h1234, 16'h0ff0, "ALUOP_AND", 16'h0230);
   #50 test(0, 0, 0, 16'h0230, 16'h324f, "ALUOP_ADD", 16'h347f);
   #50 test(0, 0, 1, 16'h347f, 16'h2d31, "ALUOP_SUB", 16'h074e);
   #50 test(1, 0, 0, 16'h074e, 16'hffff, "ALUOP_XOR", 16'hf8b1);
   #50 test(1, 0, 1, 16'hf8b1, 16'h7346, "ALUOP_LT", 16'h0001);
   #50 test(1, 1, 0, 16'h0001, 16'h0004, "ALUOP_SLL", 16'h0010);
   #50 test(1, 1, 1, 16'h0010, 16'h0004, "ALUOP_SRA", 16'h0001);
   #50 test(1, 0, 1, 16'h0001, 16'hffff, "ALUOP_LT", 16'h0000);
	$finish;
  end

	 
endmodule