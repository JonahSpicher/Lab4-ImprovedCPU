`include "regfile.v" // In order to use regfile.v, alu.v, and multiplexer.v
`include "memory.v"

module datapath(
  output [31:0] A_data,   //For jr
  output [31:0] imm_se,   // Sign Extended Immediate
  output zero,            // Zeros from ALU
  output c_out,           // Carryout from ALU
  output ofl,             // Overflow from ALU
  output [31:0] instr,
  input [4:0] rt,
  input [4:0] rs,
  input [4:0] rd,
  input Wren,
  input R_command,
  input I_command,
  input jl,
  input [2:0] ALUctrl,
  input [15:0] imm,
  input MemWr,
  input [31:0] PC,
  input MemtoReg,
  input clk,
  input reset
);

wire [31:0] A_data, B_data, reg_data, data_loop;
wire [4:0] regwrite_addr;
regfile reg_mem(.ReadData1(A_data), .ReadData2(B_data), .WriteData(reg_data), .ReadRegister1(rs), .ReadRegister2(rt), .WriteRegister(regwrite_addr), .RegWrite(Wren), .Clk(clk), .reset(reset));

// reg pc_data;
// assign pc_data = PC + 4;

fancymux regfile_writedata(.out(reg_data), .address(jl), .input0(data_loop), .input1(PC+1));
fancymux #(5) regfile_writeaddr(.out(regwrite_addr), .address(R_command), .input0(rt), .input1(rd));

sign_extend extender(.extended(imm_se), .short(imm));

wire [31:0] in_b;
fancymux alu_inputb(.out(in_b), .address(I_command), .input0(B_data), .input1(imm_se));

wire [31:0] res;
ALU alu(.result(res), .carryout(c_out), .zero(zero), .overflow(ofl), .operandA(A_data), .operandB(in_b), .command(ALUctrl));


wire [31:0] mem_output;
//wire [31:0] data_addr;
//fancymux data_addr_saver(.out(data_addr), .address(MemtoReg), .input0(32'd0), .input1(res));
// reg [31:0] data_addr;
// always @(*) begin
// if ((MemtoReg | MemWr)) begin
// data_addr = res;
// end
// else begin
// data_addr = 32'd0;
// end
// end
// reg [31:0] MemAddrCheck = 32'd0;
// always @(*)begin
// if (MemtoReg) begin
// MemAddrCheck = -32'd1;
// end
// else begin
// MemAddrCheck = 32'd0;
// end
// end

memory DataMem(.PC({PC[29:0], 2'b0}), .instruction(instr), .data_out(mem_output), .data_in(B_data), .data_addr(res), .clk(clk), .wr_en(MemWr));

fancymux d_out(.out(data_loop), .address(MemtoReg), .input0(res), .input1(mem_output));
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
