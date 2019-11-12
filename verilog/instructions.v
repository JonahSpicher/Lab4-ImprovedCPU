`include "datapath.v"

module instructPart(
  output[31:0] ProgramCounter,
  output[4:0] rt,
  input enable,
  input Clk,
  input[31:0] imm_se,
  input zero,
  input beq,
  input bne,
  input jctrl,
  input jr_ctrl,
  input jl,
  input[31:0] jr,
  input [31:0] instruct,
  input reset
);
// todo: Make it pipelined, get stall inputs 

wire[31:0] intermediate; //intermediate wire

register32 PC(.q (ProgramCounter), .d (intermediate), .wrenable (enable), .clk(Clk), .reset(reset));

wire branchSel;
wire notZero;
wire beqRes;
wire bneRes;

//branch parts
and andgateBEQ(beqRes, beq, zero);
not notgate(notZero, zero);
and andgateBNE(bneRes, bne, notZero);
or orgate(branchSel, beqRes, bneRes);

wire[31:0] branchInput;
fancymux #(32) mux1(.out (branchInput), .address (branchSel), .input0 (32'b0), .input1 (imm_se));

//Adder
wire[31:0] sum;
assign sum = ProgramCounter + branchInput + 1;

//jump parts
wire[31:0] jumpOutput;
reg[31:0] concatenated;

//concatenate
always @(*) begin
concatenated = {ProgramCounter[31:26], instruct[25:0]};
end



fancymux #(32) mux2(.out (jumpOutput), .address (jr_ctrl), .input0 (concatenated), .input1 (jr));
fancymux #(32) mux3(.out (intermediate), .address (jctrl), .input0 (sum), .input1 (jumpOutput)); //input becoming output here

fancymux #(5) mux4(.out (rt), .address (jl), .input0 (instruct[20:16]), .input1 (5'd31));

endmodule
