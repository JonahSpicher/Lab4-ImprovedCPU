`include "pipeline_ctrl.v" // In order to get regfile.v, alu.v, and multiplexer.v, register.v

module datapath(
  output [31:0] A_data,   //For jr
  output [31:0] imm_se,   // Sign Extended Immediate
  output zero,            // Zeros from ALU
  output c_out,           // Carryout from ALU
  output ofl,             // Overflow from ALU
  output [31:0] memIn,          // For memory stores
  output [31:0] res,             // ALU result
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
  input clk,
  input reset
);
// todo: add pipeline_ctrl module, outputs and inputs, make it pipelined
wire [31:0] reg_data, data_loop, B_data, A_in;
wire [4:0] regwrite_addr;
regfile reg_mem(.ReadData1(A_data), .ReadData2(B_data), .WriteData(reg_data), .ReadRegister1(rs), .ReadRegister2(rt), .WriteRegister(regwrite_addr), .RegWrite(Wren), .Clk(clk), .reset(reset));
register32 A_RF_EX(.q(A_in), .d(A_data), .wrenable(1'd1), .clk(clk), .reset(reset));


fancymux regfile_writedata(.out(reg_data), .address(jl), .input0(data_loop), .input1(PC+1));
fancymux #(5) regfile_writeaddr(.out(regwrite_addr), .address(R_command), .input0(rt_write), .input1(rd));

sign_extend extender(.extended(imm_se), .short(imm));

wire [31:0] sel_b, B_in;
fancymux alu_inputb(.out(sel_b), .address(I_command), .input0(B_data), .input1(imm_se));

register32 B_RF_EX(.q(B_in), .d(sel_b), .wrenable(1'd1), .clk(clk), .reset(reset));

wire [31:0] memIn_stored;
register32 MemIn_RF_EX(.q(memIn_stored), .d(B_data), .wrenable(1'd1), .clk(clk), .reset(reset));
register32 MemIn_EX_MEM(.q(memIn), .d(memIn_stored), .wrenable(1'd1), .clk(clk), .reset(reset));

wire [31:0] calc_res;
ALU alu(.result(calc_res), .carryout(c_out), .zero(zero), .overflow(ofl), .operandA(A_in), .operandB(B_in), .command(ALUctrl));
register32 Res_EX_MEM(.q(res), .d(calc_res), .wrenable(1'd1), .clk(clk), .reset(reset));

wire [31:0] mem_output, data_out;

fancymux d_out(.out(data_out), .address(MemtoReg), .input0(res), .input1(memOut));
register32 dLoop_MEM_WB(.q(data_loop), .d(data_out), .wrenable(1'd1), .clk(clk), .reset(reset));
endmodule


module sign_extend
(
  output reg [31:0] extended,
  input [15:0] short
);
always @(*) begin
  extended[31:0] <= { {16{short[15]}}, short[15:0] };
end
endmodule
