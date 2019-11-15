`include "pipeline_ctrl.v"

module testPipeCtrl();
  reg wren;
  reg[4:0] rs;
  reg[4:0] rt;
  reg[31:0] readData1;
  reg[31:0] readData2;
  reg[4:0] writeRegister; 
  reg[31:0] writeBack;
  wire[1:0] forwardAE;
  wire[1:0] forwardBE;

pipelineCtrl smallTest(.forwardAE(forwardAE), .forwardBE(forwardBE), .wren(wren), .rs(rs), .rt(rt), .readData1(readData1), .readData2(readData2), .writeRegister(writeRegister), .writeBack(writeBack));

initial begin
  $display("wren rs rt R1 R2 WriteReg WriteBack | FAE FBE"); 
  wren = 1; rs=5'b0; rt=5'b11111; readData1=32'b0; readData2=32'b0; writeRegister=5'b0; writeBack= 32'b1;  #1000
  $display("%b  %b  %b  %b  %b  %b  %b  %b  %b", wren, rs, rt, readData1, readData2, writeRegister, writeBack, forwardAE, forwardBE); 
  $display("wren rs rt R1 R2 WriteReg WriteBack | FAE FBE"); 

end 
endmodule
