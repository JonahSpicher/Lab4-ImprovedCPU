`include "regfile.v" // In order to use regfile.v, alu.v, and multiplexer.v
// Zero, imm_se have to be output from datapath at the same time in RF stage. beq and bne are delayed?

module pipelineCtrl(
  output reg[1:0] forwardAE, //need to add muxes in datapath
  output reg[1:0] forwardBE,
  output reg load_stall,
  output reg[1:0] branchforwardA,
  output reg[1:0] branchforwardB,
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
  input [4:0] firstWriteRegister,
  input bne,
  input beq,
  input stop_stall
);
/*
This module attempts to handle forwarding controls. It has some issues with branch
forwarding, and needs a more elegant solution.

Some notes on some confusion notation: for a given variable (say, writeRegister),
writeRegister refers to the value being used at the current time (which is writeRegister_ready
in cpu.v). nextWriteRegister refers to whatever is one clock cycle away from being
writeRegister, and prevWriteRegister refers to what was writeRegister one cycle ago.
Most confusingly, firstWriteRegister refers to what will be writeRegister in two
cycles, so named because when the chart is drawn out, it is the furthest to the right
(kind of. Honestly it was just a bad name Im sorry).
*/

always @(*) begin
    // Using register that hasnt been written to yet, instr 1 2 and 3 are hazards
    if ((bne | beq) & (rs === firstWriteRegister) & (rs !== 0) & (rt === nextWriteRegister) & (rt !== 0)) begin //One and two
      branchforwardA = 2'b01;
      forwardAE = 2'b00;
      branchforwardB = 2'b01;
      forwardBE = 2'b00;
      if (stop_stall) begin
        load_stall = 0;
      end else begin
        load_stall = 1;
      end
    end else if ((bne | beq) & (rs === firstWriteRegister) & (rs !== 0) & (rt === writeRegister) & (rt !== 0)) begin //One and three
      branchforwardA = 2'b01;
      forwardAE = 2'b00;
      branchforwardB = 2'b10;
      forwardBE = 2'b00;
      if (stop_stall) begin
        load_stall = 0;
      end else begin
        load_stall = 1;
      end
      //Figure out what this needs to be
    end else if ((bne | beq) & (rt === firstWriteRegister) & (rt !== 0) & (rs === nextWriteRegister) & (rs !== 0)) begin //One and two
      branchforwardB = 2'b01;
      forwardBE = 2'b00;
      branchforwardA = 2'b01;
      forwardAE = 2'b00;
      if (stop_stall) begin
        load_stall = 0;
      end else begin
        load_stall = 1;
      end
    end else if((bne | beq) & (rt === firstWriteRegister) & (rt !== 0) & (rs === writeRegister) & (rs !== 0)) begin //One and three
      branchforwardB = 2'b01;
      forwardBE = 2'b00;
      branchforwardA = 2'b10;
      forwardAE = 2'b00;
      if (stop_stall) begin
        load_stall = 0;
      end else begin
        load_stall = 1;
      end
    end else begin
      //A
      if ((bne | beq) & (rs === firstWriteRegister) & (rs !== 0)) begin //One above branch forwarding DOESNT WORK IF MULTIPLE FORWARDS
        branchforwardA = 2'b01;
        forwardAE = 2'b00;
        if (stop_stall) begin
          load_stall = 0;
        end else begin
          load_stall = 1;
        end
      end else if ((bne | beq) & (rs === nextWriteRegister) & (rs !== 0)) begin //Two above branch forwarding
        branchforwardA = 2'b01;
        forwardAE = 2'b00;
        //load_stall = 0;
      end else if ((bne | beq) & (rs === writeRegister) & (rs !== 0)) begin //Three above branch forwarding
        branchforwardA = 2'b10;
        forwardAE = 2'b00;
        //load_stall = 0;
      end else if ((MemtoReg) & (rs === nextWriteRegister) & (rs !== 0)) begin // For load forwarding 2 above, from WB to EX
        forwardAE = 2'b10;
        branchforwardA = 2'b00;
        load_stall = 0;
      end else if ((prevMemtoReg) & (rs === writeRegister) & (rs !== 0)) begin // For load forwarding three above, from extra reg to EX
        forwardAE = 2'b01;
        branchforwardA = 2'b00;
        load_stall = 0;
      end else if ((nextMemtoReg) & (rs === firstWriteRegister) & (rs !== 0)) begin // For load forwarding one above, from WB to EX
        forwardAE = 2'b10;
        branchforwardA = 2'b00;
        load_stall = 1;
      end else if ((wren) & (rs === writeRegister) & (rs !== 0)) begin // Check instruction three above for hazard, from extra reg after WB to EX
        forwardAE = 2'b01;
        branchforwardA = 2'b00;
        load_stall = 0;
      end else if ((nextwren) & (rs === nextWriteRegister) & (rs !== 0)) begin // Check instruction two above for hazard from WB to EX
        forwardAE = 2'b10;
        branchforwardA = 2'b00;
        load_stall = 0;
      end else if ((firstwren) & (rs === firstWriteRegister) & (rs !== 0)) begin //Check instruction one above for hazard, from MEM to EX
        forwardAE = 2'b11;
        branchforwardA = 2'b00;
        load_stall = 0;
      end else begin // No hazards
        forwardAE = 2'b00;
        branchforwardA = 2'b00;
        load_stall = 0;
      end

      //B
      if ((bne | beq) & (rt === firstWriteRegister) & (rt !== 0)) begin
        branchforwardB = 2'b01;
        forwardBE = 2'b00;
        if (stop_stall) begin load_stall = 0; end
        else begin load_stall = 1; end
      end else if ((bne | beq) & (rt === nextWriteRegister) & (rt !== 0)) begin
        branchforwardB = 2'b01;
        forwardBE = 2'b00;
        //load_stall = 0;
      end else if ((bne | beq) & (rt === writeRegister) & (rt !== 0)) begin
        branchforwardB = 2'b10;
        forwardBE = 2'b00;
        //load_stall = 0;
      end else if ((MemtoReg) & (rt === nextWriteRegister) & (rt !== 0)) begin // For load forwarding 2 above, from WB to EX
        forwardBE = 2'b10;
        branchforwardB = 2'b00;
        load_stall = 0;
      end else if ((prevMemtoReg) & (rt === writeRegister) & (rt !== 0))begin // For load forwarding three above, from extra reg to EX
        forwardBE = 2'b01;
        branchforwardB = 2'b00;
        load_stall = 0;
      end else if ((nextMemtoReg) & (rt === firstWriteRegister) & (rt !== 0))begin // For load forwarding one above, from WB to EX
        forwardBE = 2'b10;
        branchforwardB = 2'b00;
        load_stall = 1;
      end else if ((wren) & (rt === writeRegister) & (rt !== 0)) begin // Check instruction three above for hazard, from extra reg after WB to EX
        forwardBE = 2'b01;
        branchforwardB = 2'b00;
        load_stall = 0;
      end else if ((nextwren) & (rt === nextWriteRegister) & (rt !== 0)) begin // Check instruction two above for hazard from WB to EX
        forwardBE = 2'b10;
        branchforwardB = 2'b00;
        load_stall = 0;
      end else if ((firstwren) & (rt === firstWriteRegister) & (rt !== 0)) begin //Check instruction one above for hazard, from MEM to EX
        forwardBE = 2'b11;
        branchforwardB = 2'b00;
        load_stall = 0;
      end else begin // No hazards
        forwardBE = 2'b00;
        branchforwardB = 2'b00;
        load_stall = 0;
      end
end
end
endmodule
