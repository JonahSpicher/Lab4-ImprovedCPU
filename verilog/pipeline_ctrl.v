`include "regfile.v" // In order to use regfile.v, alu.v, and multiplexer.v
// Zero, imm_se have to be output from datapath at the same time in RF stage. beq and bne are delayed?
// JR gets delayed once, so JR_ctrl does too 

module pipelineCtrl(
  output reg[1:0] forwardAE, //need to add muxes in datapath
  output reg[1:0] forwardBE,
  input wren,
  input[4:0] rs,
  input[4:0] rt,
  input[31:0] readData1,
  input[31:0] readData2,
  input[4:0] writeRegister, //need to make this a wire & output in datapath
  input[31:0] writeBack
  //more stuff
);

// forward execution
always @(wren) begin
    if ((wren == 1) & (rs == writeRegister)) begin
      forwardAE = 2'b10;
    end else if ((wren == 1) & (readData1 == writeBack)) begin
      forwardAE = 2'b01;
    end else begin 
      forwardAE = 2'b00;
    end
end

always @(wren) begin
    if ((wren == 1) & (rt == writeRegister)) begin
      forwardBE = 2'b10;
    end else if ((wren == 1) & (readData2 == writeBack)) begin
      forwardBE = 2'b01;
    end else begin 
      forwardBE = 2'b00;
    end
end

endmodule 
