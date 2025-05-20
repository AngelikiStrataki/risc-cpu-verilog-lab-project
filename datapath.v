`include "regfile.v"
`include "alu.v"

module datapath (
	input clk,
	input rst,
	input [31:0] instr,
	input PCSrc,
	input ALUSrc,
	input RegWrite,
	input MemToReg,
	input [3:0] ALUCtrl,
	input loadPC,
	output reg [31:0] PC,
	output wire Zero,
	output reg [31:0] dAddress,
	output reg [31:0] dWriteData,
	input [31:0] dReadData,
	output reg [31:0] WriteBackData
);

parameter WIDTH = 32;
parameter [WIDTH-1:0] INITIAL_PC = 32'h00400000;
reg [31:0] branch_offset;

  //Register File
  reg [4:0] readReg1;
  reg [4:0] readReg2;
  reg [4:0] writeReg;
  regfile  U1 (
    .readReg1(readReg1),
    .readReg2(readReg2),
    .writeReg(writeReg)
  );
  always @* begin
    {readReg1, readReg2, writeReg} = instr[24:7];
  end
  
  //assign {readReg1, readReg2, writeReg} = instr[24:7];// Λογική αποκωδικοποίησης εντολής για καθορισμό διευθύνσεων καταχωρητών
 
  

	
  //Immediate Generation
  reg [31:0] immediate;
  always @* begin
    case (instr[6:0])
		7'b0100011: begin //S-Type
			readReg1=instr[19:15];
			readReg2=instr[24:20];
			writeReg=0;
			//RegWrite=0; //Not write back
			immediate = {{7{instr[31]}}, instr[31:25], instr[11:7]};
		end
		7'b0110011: begin//R-Type
			readReg1=instr[19:15];
			readReg2=instr[24:20];
			writeReg=instr[11:7];
			//RegWrite=1;
		end	
		7'b0010011: begin//I-Type
			readReg1=instr[19:15];
			readReg2=0;
			writeReg=instr[11:7];
			//RegWrite=1;
			immediate = {{20{instr[31]}}, instr[31:20]};
		end
		default: begin//B-Type
			readReg1=instr[19:15];
			readReg2=instr[24:20];
			writeReg=0;
			//RegWrite=0; //Not write back
			immediate = {{7{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:7]};
		end
	endcase
  end
	
	//assign writeReg = RegWrite;// Σύνδεση του σήματος εγγραφής με τον έλεγχο RegWrite
  

  //Branch Target
  always @* begin
  if (loadPC && PCSrc) begin
    branch_offset <= PC + (immediate << 1);// Υπολογισμός branch_offset με μετατόπιση αριστερά κατά 1
  end
  end
 
 
//	Program Counter (PC)
 always @(posedge clk or posedge rst) begin
   if (rst) begin
		PC <= INITIAL_PC; // Αρχικοποίηση στην κατάσταση αρχικής κατάστασης
	end else begin
		 if (loadPC) begin  // Έλεγχος εάν χρειάζεται να γίνει ενημέρωση του PC
			if (PCSrc) begin  //Έλεγχος πηγής του PC (PCSrc)
				PC <= PC + branch_offset;  // PC <= ... (υπολογισμός branch_offset) για τις διακλαδώσεις				
			end else begin
				PC <= PC + 4;  //Επόμενη τιμή
		end
      end
    end
  end	

  

  //ALU
  wire [31:0] readData1;
  wire [31:0] readData2;
  regfile U2 (
	.readData1(readData1),
	.readData2(readData2)
	);
  wire [31:0] op2_mux_output;
  assign op2_mux_output = (ALUSrc) ? immediate : readData2;
  wire [31:0] alu_result;
  alu U3 (
    .op1(readData1),
    .op2(op2_mux_output),
    .alu_op(ALUCtrl),
    .zero(Zero),
    .result(alu_result)
  );
  
  
  //Write Back
  wire [31:0] mux_output;  // Πολυπλέκτης για την επιλογή μεταξύ ALU και μνήμης
  assign mux_output = (MemToReg) ?  dReadData: alu_result;
  regfile U4 (
	.writeData(mux_output)  // Σύνδεση της έξοδου του πολυπλέκτη με την είσοδο writeData του αρχείου καταχωρητών
  );
  //assign WriteBackData = mux_output;  // Σύνδεση των δεδομένων που γράφονται στους καταχωρητές με την έξοδο
  always @(posedge clk) begin
    if (RegWrite) begin
        WriteBackData <= mux_output; // Σύνδεση των δεδομένων που γράφονται στους καταχωρητές με την έξοδο
    end
  end
  
endmodule