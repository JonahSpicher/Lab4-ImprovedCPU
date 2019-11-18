`include "regfile.v" // In order to use regfile.v, alu.v, and multiplexer.v
// Zero, imm_se have to be output from datapath at the same time in RF stage. beq and bne are delayed?

module pipelineCtrl(
  output reg[1:0] forwardAE, //need to add muxes in datapath
  output reg[1:0] forwardBE,
  output reg load_stall,
  input wren,
  input nextwren,
  input firstwren,
  input prevMemtoReg,
  input MemtoReg,
  input nextMemtoReg,
  input[4:0] rs,
  input[4:0] rt,
  input[4:0] writeRegister, //need to make this a wire & output in datapath
  input[4:0] nextWriteRegister,
  input [4:0] firstWriteRegister
);

// forward execution
always @(*) begin
    // Using register that hasnt been written to yet, instr 1 2 and 3 are hazards
    if ((MemtoReg) & (rs === nextWriteRegister) & (rs !== 0)) begin // For load forwarding 2 above, from WB to EX
      forwardAE = 2'b10;
      load_stall = 0;
    end else if ((prevMemtoReg) & (rs === writeRegister) & (rs !== 0)) begin // For load forwarding three above, from extra reg to EX
      forwardAE = 2'b01;
      load_stall = 0;
    end else if ((nextMemtoReg) & (rs === firstWriteRegister) & (rs !== 0)) begin // For load forwarding one above, from WB to EX
      forwardAE = 2'b10;
      load_stall = 1;
    end else if ((wren) & (rs === writeRegister) & (rs !== 0)) begin // Check instruction three above for hazard, from extra reg after WB to EX
      forwardAE = 2'b01;
      load_stall = 0;
    end else if ((nextwren) & (rs === nextWriteRegister) & (rs !== 0)) begin // Check instruction two above for hazard from WB to EX
      forwardAE = 2'b10;
      load_stall = 0;
    end else if ((firstwren) & (rs === firstWriteRegister) & (rs !== 0)) begin //Check instruction one above for hazard, from MEM to EX
      forwardAE = 2'b11;
      load_stall = 0;
    end else begin // No hazards
      forwardAE = 2'b00;
      load_stall = 0;
    end
end

always @(*) begin
    // Using register that hasnt been written to yet, instr 1 2 and 3 are hazards
    if ((MemtoReg) & (rt === nextWriteRegister) & (rt !== 0)) begin // For load forwarding 2 above, from WB to EX
      forwardBE = 2'b10;
      load_stall = 0;
    end else if ((prevMemtoReg) & (rt === writeRegister) & (rt !== 0))begin // For load forwarding three above, from extra reg to EX
      forwardBE = 2'b01;
      load_stall = 0;
    end else if ((nextMemtoReg) & (rt === firstWriteRegister) & (rt !== 0))begin // For load forwarding one above, from WB to EX
      forwardBE = 2'b10;
      load_stall = 1;
    end else if ((wren) & (rt === writeRegister) & (rt !== 0)) begin // Check instruction three above for hazard, from extra reg after WB to EX
      forwardBE = 2'b01;
      load_stall = 0;
    end else if ((nextwren) & (rt === nextWriteRegister) & (rt !== 0)) begin // Check instruction two above for hazard from WB to EX
      forwardBE = 2'b10;
      load_stall = 0;
    end else if ((firstwren) & (rt === firstWriteRegister) & (rt !== 0)) begin //Check instruction one above for hazard, from MEM to EX
      forwardBE = 2'b11;
      load_stall = 0;
    end else begin // No hazards
      forwardBE = 2'b00;
      load_stall = 0;
    end
end

endmodule
