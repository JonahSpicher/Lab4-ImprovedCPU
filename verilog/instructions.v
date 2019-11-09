`include "datapath.v"

module instructPart(
  output[31:0] instructionCode, //PC
  output[4:0] rt,
  input enable,
  input Clk,
  input[31:0] imm_se,
  input zero,
  input MemWren,
  input beq,
  input bne,
  input jctrl,
  input jr_ctrl,
  input jl,
  input[31:0] jr,
  input [31:0] actual_instruct,
  input reset
);

wire[31:0] intermediate; //intermediate wire

register32 PC(.q (instructionCode), .d (intermediate), .wrenable (enable), .clk(Clk), .reset(reset));

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
assign sum = instructionCode + branchInput + 1;

//jump parts
wire[31:0] jumpOutput;
reg[31:0] concatenated;
//reg[25:0] jaddr;

//concatenate
always @(*) begin
concatenated = {instructionCode[31:26], actual_instruct[25:0]};
end



fancymux #(32) mux2(.out (jumpOutput), .address (jr_ctrl), .input0 (concatenated), .input1 (jr));
fancymux #(32) mux3(.out (intermediate), .address (jctrl), .input0 (sum), .input1 (jumpOutput)); //input becoming output here
//assign inputCode = intermediate;

//instrcution fetch
//wire[31:0] actualInstruct;
// wire[31:0] writeBackFake;
// wire[31:0] fakeAddress;
// wire[31:0] fakeInput;

// memory IF(.PC (instructionCode), .instruction (actualInstruct), .data_out (writeBackFake), .data_in (fakeInput), .data_addr (fakeAddress), .clk (Clk), .wr_en (MemWren));

//part of instructuion decode

// reg [15:0] imm;
// reg [5:0] funct;
// reg [4:0] shamt;
// reg [4:0] rd;
// reg [4:0] rs;
//
// always @(*) begin
// jaddr = actualInstruct[25:0];
// //wire [15:0] imm = actualInstruct[15:0];
//
// imm = actualInstruct[15:0];
// //wire [5:0] funct = actualInstruct[5:0];
//
// funct = actualInstruct[5:0];
// // wire [4:0] shamt = actualInstruct[10:6];
//
// shamt = actualInstruct[10:6];
// // wire [4:0] rd = actualInstruct[15:11];
//
// rd = actualInstruct[15:11];
//
// rs = actualInstruct[25:21];
// end



wire [4:0] rt;
fancymux #(5) mux4(.out (rt), .address (jl), .input0 (actual_instruct[20:16]), .input1 (5'd31));

endmodule
