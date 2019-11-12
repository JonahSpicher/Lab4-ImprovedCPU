`define ADD 011101

`include "instructions.v"
//`include "datapath.v"
`include "LUT.v"
`include "memory.v"
// Todo:
// update datapath inputs and outputs, send stall input to other modules.
// Make it pipelined
// Preliminary test without stalling or forwarding
// Full testing
// Report
// Maybe new test benches if necessary (testing specific pipeline stuff)


module CPU(
  input clk,
  input reset
);

// from instructPart
wire[4:0] RT;
wire[4:0] RS;
wire[4:0] RD;
wire[31:0] PC;
wire[4:0] SHAMT;
wire[5:0] FUNCT;
wire[31:0] fetchedInstruct;
wire[15:0] IMM;

// from LUT
wire JR_CTRL;
wire J_CTRL, R_CTRL, I_CTRL;
wire BEQ;
wire BNE;
wire JL;
wire WREN;
wire[2:0] ALU_CTRL;
wire MEMWREN;
wire MEMTOREG;

//from datapath
wire[31:0] JR;
wire[31:0] IMM_SE;
wire ZERO;
wire overflow;
wire C_OUT;

wire [31:0] memIn, memAddr;

//from memory
wire [31:0] instr;
wire [31:0] memOut;

memory Mem(.PC({PC[29:0], 2'b0}), .instruction(instr), .data_out(memOut), .data_in(memIn), .data_addr(memAddr), .clk(clk), .wr_en(MEMWREN));

instructPart instruct(.ProgramCounter (PC), .rt (RT), .enable (1'b1), .Clk (clk),
                      .imm_se (IMM_SE), .zero (ZERO), .beq (BEQ),
                      .bne (BNE), .jctrl (J_CTRL), .jr_ctrl (JR_CTRL), .jl (JL), .jr (JR), .instruct (instr), .reset(reset));

LUT lut(.jrctrl (JR_CTRL), .Jctrl (J_CTRL), .beq (BEQ), .bne (BNE), .jl (JL),
        .Rctrl (R_CTRL), .Wren (WREN), .ALUctrl (ALU_CTRL), .Ictrl (I_CTRL), .MemWren (MEMWREN),
        .MemtoReg (MEMTOREG), .OP (instr[31:26]), .FUNCT (instr[5:0]));

datapath DP(.A_data (JR), .imm_se (IMM_SE), .zero (ZERO), .c_out (C_OUT), .ofl (overflow),
            .memIn (memIn), .res(memAddr), .rt (RT), .rs (instr[25:21]),
            .rd (instr[15:11]), .Wren (WREN), .R_command (R_CTRL), .I_command (I_CTRL),
            .jl (JL), .ALUctrl (ALU_CTRL), .imm (instr[15:0]),
            .PC (PC), .MemtoReg (MEMTOREG), .memOut(memOut), .clk (clk), .reset(reset));

endmodule

module reg_bank(
  output [31:0] PC_ready,
  output [4:0] RS_ready,
  output [4:0] RT_1,
  output [4:0] RT_ready,
  output [4:0] RD_ready.
  output [15:0] imm_ready,
  output Wren_ready,
  output [2:0] ALU_ctrl_ready,
  output MemtoReg_ready,
  output MemWren_ready,
  input [31:0] PC,
  input [4:0] RS,
  input [4:0] RT,
  input [4:0] RD.
  input [15:0] imm,
  input Wren,
  input [2:0] ALU_ctrl,
  input MemtoReg,
  input MemWren,
  input clk,
  input reset
);
  register32 PC_IF_RF(.q(PC_1), .d(PC), .wrenable(1'd1), .clk(clk), .reset(reset));
  register32 PC_RF_EX(.q(PC_2), .d(PC_1), .wrenable(1'd1), .clk(clk), .reset(reset));
  register32 PC_EX_MEM(.q(PC_3), .d(PC_2), .wrenable(1'd1), .clk(clk), .reset(reset));
  register32 PC_MEM_WB(.q(PC_ready), .d(PC_3), .wrenable(1'd1), .clk(clk), .reset(reset));

  var_register RS_IF_RF (#5)(.q(RS_ready), .d(RS), .wrenable(1'd1), .clk(clk), .reset(reset));

  var_register RT_IF_RF (#5)(.q(RT_1), .d(RT), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register RT_RF_EX (#5)(.q(RT_2), .d(RT_1), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register RT_EX_MEM (#5)(.q(RT_3), .d(RT_2), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register RT_MEM_WB (#5)(.q(RT_ready), .d(RT_3), .wrenable(1'd1), .clk(clk), .reset(reset));

  var_register RD_IF_RF (#5)(.q(RD_1), .d(RD), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register RD_RF_EX (#5)(.q(RD_2), .d(RD_1), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register RD_EX_MEM (#5)(.q(RD_3), .d(RD_2), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register RD_MEM_WB (#5)(.q(RD_ready), .d(RD_3), .wrenable(1'd1), .clk(clk), .reset(reset));

  var_register imm_IF_RF (#16)(.q(imm_ready), .d(imm), .wrenable(1'd1), .clk(clk), .reset(reset));

  var_register Wren_IF_RF (#16)(.q(Wren0), .d(Wren), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register Wren_RF_EX (#16)(.q(Wren1), .d(Wren0), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register Wren_EX_MEM (#16)(.q(Wren2), .d(Wren1), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register Wren_MEM_WB (#16)(.q(Wren_ready), .d(Wren2), .wrenable(1'd1), .clk(clk), .reset(reset));

  var_register ALU_IF_RF (#16)(.q(ALU1), .d(ALU_ctrl), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register ALU_RF_EX (#16)(.q(ALU_ctrl_ready), .d(ALU1), .wrenable(1'd1), .clk(clk), .reset(reset));

  var_register MemtoReg_IF_RF (#16)(.q(MemtoReg0), .d(MemtoReg), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register MemtoReg_RF_EX (#16)(.q(MemtoReg1), .d(MemtoReg0), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register MemtoReg_EX_MEM (#16)(.q(MemtoReg2), .d(MemtoReg1), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register MemtoReg_MEM_WB (#16)(.q(MemtoReg_ready), .d(MemtoReg2), .wrenable(1'd1), .clk(clk), .reset(reset));

  var_register MemWren_IF_RF (#16)(.q(MemWren0), .d(MemWren), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register MemWren_RF_EX (#16)(.q(MemWren1), .d(MemWren0), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register MemWren_EX_MEM (#16)(.q(MemWren2), .d(MemWren1), .wrenable(1'd1), .clk(clk), .reset(reset));
  var_register MemWren_MEM_WB (#16)(.q(MemWren_ready), .d(MemWren2), .wrenable(1'd1), .clk(clk), .reset(reset));


endmodule
