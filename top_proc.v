`include "datapath.v"

module top_proc (
    input wire clk,
    input wire rst,
    input [31:0] instr,
    input [31:0] dReadData,
    output [31:0] PC,
    output [31:0] dAddress,
    output wire [31:0] dWriteData,
    output reg MemRead,
    output reg MemWrite,
    output reg [31:0] WriteBackData
);

parameter [31:0] INITIAL_PC = 32'h00400000;
reg [3:0] ALUCtrl;
reg ALUSrc, RegWrite, MemToReg, loadPC, PCSrc;
wire Zero;
parameter  IF=3'b000, ID=3'b001, EX=3'b010, MEM=3'b011, WB=3'b100;
reg [2:0] current_state, next_state;

// Datapath
datapath U1 (
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .PC(PC),
    .dAddress(dAddress),
    .dReadData(dReadData),
    .dWriteData(dWriteData),
    .ALUCtrl(ALUCtrl),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .MemToReg(MemToReg),
    .loadPC(loadPC),
    .PCSrc(PCSrc),
    .Zero(Zero)
);

// FSM
always @(posedge clk) begin
	if (rst) begin
		current_state <= IF;
	end
	else begin
		current_state <= next_state;
	end
end

always @(current_state) begin
	case (current_state)
		IF: begin
			MemRead=1'b0;
			MemWrite=1'b0;
			RegWrite=1'b0;
			loadPC=1'b0;
			MemToReg= 1'b0;
		end
		ID: begin 
			MemRead=1'b0;
			MemWrite=1'b0;
			RegWrite=1'b0;
			loadPC=1'b0;
			MemToReg= 1'b0;
		end
		EX: begin 
			MemRead=1'b0;
			MemWrite=1'b0;
			RegWrite=1'b0;
			loadPC=1'b0;
			MemToReg= 1'b0;
		end
		MEM: begin 
			MemRead=(instr[6:0]==7'b0000011) ? 1'b1 : 1'b0;//LOAD
			MemWrite=(instr[6:0]==7'b0100011) ? 1'b1 : 1'b0;//STORE
			RegWrite=1'b0;
			loadPC=1'b0;
			MemToReg= 1'b0;
		end
		WB: begin
			MemRead=1'b0;
			MemWrite=1'b0;
			RegWrite=(instr[6:0]==7'b0100011) ? 1'b0 : 1'b1;//STORE,BRANCH
			loadPC=1'b1;
			MemToReg=(instr[6:0]==7'b0000011) ? 1'b1 : 1'b0;//LOAD
		end
		default: begin 
			MemRead=1'b0;
			MemWrite=1'b0;
			RegWrite=1'b0;
			loadPC=1'b0;
			MemToReg= 1'b0;
		end
	endcase
end

always @(current_state) begin
	case (current_state)
		IF: begin
			next_state=ID;
		end
		ID: begin
			next_state=EX;
		end
		EX: begin
			next_state=MEM;
		end
		MEM: begin
			next_state=WB;
		end
		WB: begin
			next_state=IF;
		end
		default: begin
			next_state=IF;
		end
	endcase
end
		

		
		
		
// ALUCtrl
always @* begin
    case (instr[6:0])
        7'b0000011: ALUCtrl = 4'b0010; // LW
        7'b0100011: ALUCtrl = 4'b0010; // SW
        7'b1100011: ALUCtrl = 4'b0110; // BEQ
        // 7'b0010011:					
        default: // Υπόλοιπες εντολές
            case (instr[14:12])
                3'b010: ALUCtrl = 4'b0110; // Κωδικός SLT
                3'b100: ALUCtrl = 4'b1101; // Κωδικός XOR
                3'b110: ALUCtrl = 4'b0001; // Κωδικός OR
                3'b111: ALUCtrl = 4'b0000; // Κωδικός AND			  
                3'b001: ALUCtrl = 4'b1001; // Κωδικός SLL
                default: // Υπόλοιπες εντολές
                    case (instr[31:25])
                        7'b0100000: ALUCtrl = 4'b1010; // Κωδικός SRA
                        7'b0000000: ALUCtrl = 4'b1000; // Κωδικός SRL
                        default: ALUCtrl = 4'b0000; // Προεπιλεγμένη περίπτωση AND
						  endcase
            endcase
    endcase
end


// ALUSrc
always @* begin
    case (instr[6:0])
        7'b0000011: ALUSrc = 1'b1; // Load
        7'b0100011: ALUSrc = 1'b1; // Store
        7'b0010011: ALUSrc = 1'b1; // ALU Immediate
        default: ALUSrc = 1'b0; // Οι υπόλοιπες περιπτώσεις χρησιμοποιούν το readData2
    endcase
end


//PCSrc
always @* begin
    case (instr[6:0])
        7'b1100011: // Κατάσταση "BEQ"
            if (Zero == 1)
                PCSrc = 1; // Τίθεται σε 1 όταν η εντολή είναι "BEQ" και το Zero είναι 1
            else
                PCSrc = 0;
        default: PCSrc = 0; // Άλλες καταστάσεις
    endcase
end

endmodule
