`include "alu.v"
`include "calc_enc.v"

module calc (
	input  clk, btnc, btnl, btnu, btnr, btnd,
	input [0:15] sw,
	output reg [0:15] led
	);
	
	reg [0:15] accumulator;
	
// Σύνδεση της εισόδου του accumulator με τα 16 χαμηλότερα bit της εξόδου της ALU
  wire [31:0] op1_extended;
  wire [31:0] op2_extended;
  assign op1_extended = {{16{accumulator[15]}}, accumulator};
  assign op2_extended = {{16{sw[15]}}, sw};
  
  // Σύνδεση των εισόδων της ALU με τα κατάλληλα σήματα
  wire [31:0] result;
  wire zero;
  wire [3:0] alu_op;
  
  
  // Σύνδεση του calc_enc.v
  calc_enc calc_enc_inst (
    .btnl(btnl),
    .btnc(btnc),
    .btnr(btnr),
    .alu_op(alu_op)
  );
  
  
  // Κώδικας για τον έλεγχο της ALU
  alu alu_inst (
    .op1(op1_extended),
    .op2(op2_extended),
    .alu_op(alu_op),
    .zero(zero),
    .result(result)
  );
	
  always @(posedge clk) begin
    // Αν η είσοδος btnu είναι ενεργή, μηδενίζει τον accumulator
  if (btnu) begin
       accumulator <= 16'b0;
		 end
 
  end
	
	always @(posedge btnd) begin
	accumulator <= result[15:0];
	// Συνδέει την τιμή του accumulator με τις εξόδους LED
	led <= accumulator;
	end
	
	
endmodule