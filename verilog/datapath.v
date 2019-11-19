`include "pipeline_ctrl.v" // In order to get regfile.v, alu.v, and multiplexer.v, register.v

module datapath(
  output [31:0] A_data,   //For jr
  output [31:0] B_data,
  output [31:0] imm_se,   // Sign Extended Immediate
  output c_out,           // Carryout from ALU
  output ofl,             // Overflow from ALU
  output [31:0] memIn,          // For memory stores
  output [31:0] res,             // ALU result
  output [4:0] regwrite_addr,
  output [31:0] data_loop,
  input [4:0] rt,
  input [4:0] rt_write,
  input [4:0] rs,
  input [4:0] rd,
  input Wren,
  input R_command,
  input I_command,
  input jl,
  input [2:0] ALUctrl,
  input [15:0] imm,
  input [31:0] PC,
  input MemtoReg,
  input [31:0] memOut,
  input [1:0] forwardAE,
  input [1:0] forwardBE,
  input clk,
  input reset,
  input load_stall
);
wire [31:0] reg_data,  A_in;
wire zero;

// Register file. Outputs got to registers to delay until EX stage.
regfile reg_mem(.ReadData1(A_data), .ReadData2(B_data), .WriteData(reg_data), .ReadRegister1(rs), .ReadRegister2(rt), .WriteRegister(regwrite_addr), .RegWrite(Wren), .Clk(clk), .reset(reset));
register32 A_RF_EX(.q(A_in), .d(A_data), .wrenable(load_stall), .clk(clk), .reset(reset));


fancymux regfile_writedata(.out(reg_data), .address(jl), .input0(data_loop), .input1(PC+1)); //For JaL
fancymux #(5) regfile_writeaddr(.out(regwrite_addr), .address(R_command), .input0(rt_write), .input1(rd)); // Write input is either RD or RT depending on instruction

sign_extend extender(.extended(imm_se), .short(imm));

wire [31:0] sel_b, B_in;
fancymux alu_inputb(.out(sel_b), .address(I_command), .input0(B_data), .input1(imm_se)); //Chooses either immediate or Reg[RT]

register32 B_RF_EX(.q(B_in), .d(sel_b), .wrenable(load_stall), .clk(clk), .reset(reset));

wire [31:0] memIn_stored;
register32 MemIn_RF_EX(.q(memIn_stored), .d(B_data), .wrenable(load_stall), .clk(clk), .reset(reset));
register32 MemIn_EX_MEM(.q(memIn), .d(memIn_stored), .wrenable(1'd1), .clk(clk), .reset(reset));

wire [31:0] calc_res;
wire [31:0] late_input, ALU_in1, ALU_in2;
//Forwarding multiplexers
Multiplexer4input Aforward_sel(.out(ALU_in1), .address(forwardAE), .input0(A_in), .input1(late_input), .input2(data_loop), .input3(res));
Multiplexer4input Bforward_sel(.out(ALU_in2), .address(forwardBE), .input0(B_in), .input1(late_input), .input2(data_loop), .input3(res));

//Execute stage, does its math
ALU alu(.result(calc_res), .carryout(c_out), .zero(zero), .overflow(ofl), .operandA(ALU_in1), .operandB(ALU_in2), .command(ALUctrl));
register32 Res_EX_MEM(.q(res), .d(calc_res), .wrenable(1'd1), .clk(clk), .reset(reset));

wire [31:0] mem_output, data_out;

fancymux d_out(.out(data_out), .address(MemtoReg), .input0(res), .input1(memOut));
register32 dLoop_MEM_WB(.q(data_loop), .d(data_out), .wrenable(1'd1), .clk(clk), .reset(reset));

register32 extra_forward(.q(late_input), .d(data_loop), .wrenable(1'd1), .clk(clk), .reset(reset));
endmodule


module sign_extend
(
  output reg [31:0] extended,
  input [15:0] short
);
/*
Pretty simple, does sign extending.
*/
always @(*) begin
  extended[31:0] <= { {16{short[15]}}, short[15:0] };
end
endmodule
