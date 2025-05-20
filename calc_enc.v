module calc_enc (
    input btnl,
    input btnc,
	 input btnr,
    output reg [3:0]alu_op
);

always @* begin
	alu_op[0]=((~btnr) & btnl) | ((btnl ^ btnc) & btnr);
	alu_op[1]=(btnr & btnl) | ((~btnl) & (~btnc));
	alu_op[2]=((btnr & btnl) | (btnr ^ btnl)) & (~btnc);
	alu_op[3]=(((~btnr) & btnc) | (~(btnr ^ btnc))) & btnl;
end

endmodule