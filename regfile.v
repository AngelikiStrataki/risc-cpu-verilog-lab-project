module regfile (
 input wire clk,
 input wire [4:0] readReg1,
 input wire [4:0] readReg2,
 input wire [4:0] writeReg,
 input wire [31:0] writeData,
 input wire write,
 output reg [31:0] readData1,
 output reg [31:0] readData2
 );
 
 reg [31:0] registers [0:31]; // Πίνακας καταχωρητών
 integer i;
 
// Αρχικοποίηση των καταχωρητών με μηδενικά
  initial begin
    for (i = 0; i < 32; i=i+1) begin
      registers[i] = 32'b0;
    end
  end
  
 always @(posedge clk) begin
  // Διαβάζει τις τιμές από τα readReg1 και readReg2
  readData1 <= registers[readReg1];
  readData2 <= registers[readReg2];

  // Έλεγχος για εγγραφή
  if (write) begin
    // Έλεγχος αν η διεύθυνση εγγραφής δεν είναι ίδια με διευθύνσεις ανάγνωσης
    if ((writeReg != readReg1) && (writeReg != readReg2)) begin
      // Εγγραφή στον καταχωρητή στη διεύθυνση writeReg
      registers[writeReg] <= writeData;
    end
  end
end
 
 
 endmodule