`include "regfile.v" // In order to use regfile.v, alu.v, and multiplexer.v
// Zero, imm_se have to be output from datapath at the same time in RF stage. beq and bne are delayed?
// JR gets delayed once, so JR_ctrl does too

module pipelineCtrl(
  output reg[1:0] forwardAE, //need to add muxes in datapath
  output reg[1:0] forwardBE,
  input wren,
  input nextwren,
  input[4:0] rs,
  input[4:0] rt,
  input[31:0] readData1,
  input[31:0] readData2,
  input[4:0] writeRegister, //need to make this a wire & output in datapath
  input[4:0] nextWriteRegister
  input[31:0] writeBack,
  input clk
  //more stuff
);

// forward execution
always @(*) begin
    // Using register that hasnt been written to yet, instr 1 2 and 3 are hazards
    if ((MemtoReg) & (rs == nextWriteRegister)) begin // For load forwarding 2 above, from MEM mux to EX
      forwardAE = 3'b100;
    end else if ((PrevMemtoReg) & (rs == WriteRegister))begin // For load forwarding three above, from extra reg to EX
      forwardAE = 3'b001;
    end else if ((nextMemtoReg) & (rs == firstWriteRegister))begin // For load forwarding one above, from extra reg to EX
      forwardAE = 3'b010;
      //Also need to stall
    end else if ((wren == 1) & (rs == writeRegister)) begin // Check instruction three above for hazard, from extra reg after WB to EX
      forwardAE = 3'b001; // Change this setting?
    end else if ((nextwren == 1) & (rs == nextWriteRegister)) begin // Check instruction two above for hazard from WB to EX
      forwardAE = 3'b010;
    end else if ((firstwren == 1) & (rs == firstWriteRegister)) begin //Check instruction one above for hazard, from MEM to EX
      forwardAE = 3'b011;

    end else begin // No hazards
      forwardAE = 3'b000;
    end
end

always @(*) begin
  if ((MemtoReg) & (rt == nextWriteRegister)) begin // For load forwarding 2 above, from MEM mux to EX
    forwardBE = 3'b100;
  end else if ((PrevMemtoReg) & (rt == WriteRegister))begin // For load forwarding three above, from extra reg to EX
    forwardBE = 3'b010;
  end else if ((nextMemtoReg) & (rt == firstWriteRegister))begin // For load forwarding one above, from WB to EX
    forwardBE = 3'b001;
  //Also need to stall
  end if ((wren == 1) & (rt == writeRegister)) begin // Check instruction three above for hazard
    forwardBE = 3'b001; // Change this setting?
  end else if ((nextwren == 1) & (rt == nextWriteRegister)) begin // Check instruction two above for hazard
    forwardBE = 3'b010;
  end else if ((firstwren == 1) & (rt == firstWriteRegister)) begin //Check instruction one above for hazard from MEM to EX
    forwardBE = 3'b011;
  end else begin
    forwardBE = 3'b000;
  end
end

endmodule
