`include "datapath.v"

module instructPart(
  output[31:0] ProgramCounter,
  output[4:0] rt,
  input enable,
  input Clk,
  input[31:0] imm_se,
  input beq,
  input bne,
  input jctrl,
  input jr_ctrl,
  input jl,
  input[31:0] jr,
  input [31:0] instruct,
  input [31:0] B,
  input [31:0] mem_stage,
  input [31:0] data_loop,
  input [1:0] branchforwardA,
  input [1:0] branchforwardB,
  input load_stall,
  input reset
);
// todo: Make it pipelined, get stall inputs

wire[31:0] intermediate; //intermediate wire

register32 PC(.q (ProgramCounter), .d (intermediate), .wrenable (!load_stall), .clk(Clk), .reset(reset));

wire branchSel;
reg zero;
wire notZero;
wire beqRes;
wire bneRes;
wire [31:0] B_in, A_in ;

Multiplexer4input Abranch_forward(.out(A_in), .address(branchforwardA), .input0(jr), .input1(mem_stage), .input2(data_loop), .input3(32'd0));
Multiplexer4input Bbranch_forward(.out(B_in), .address(branchforwardB), .input0(B), .input1(mem_stage), .input2(data_loop), .input3(32'd0));

reg [31:0] res;
always @(*) begin
  res = A_in - B_in;
  if (res === 0) begin
    zero = 1;
  end
  else begin
  zero = 0;
  end
end

//branch parts
and andgateBEQ(beqRes, beq, zero);
not notgate(notZero, zero);
and andgateBNE(bneRes, bne, notZero);
or orgate(branchSel, beqRes, bneRes);

wire[31:0] branchInput;
reg [31:0] in0 = 32'd1;
fancymux #(32) mux1(.out (branchInput), .address (branchSel), .input0 (in0), .input1 (imm_se));

//Adder
reg[31:0] sum;
always @(*) begin
  sum = ProgramCounter + branchInput;
end

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
