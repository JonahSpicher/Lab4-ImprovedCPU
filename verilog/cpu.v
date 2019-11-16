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
wire MEMWREN_ready;
// put forwardAE and forwardBE on a delay ?

memory Mem(.PC({PC[29:0], 2'b0}), .instruction(instr), .data_out(memOut), .data_in(memIn), .data_addr(memAddr), .clk(clk), .wr_en(MEMWREN_ready));

instructPart instruct(.ProgramCounter (PC), .rt (RT), .enable (1'b1), .Clk (clk),
                      .imm_se (IMM_SE), .zero (ZERO), .beq (BEQ),
                      .bne (BNE), .jctrl (J_CTRL), .jr_ctrl (JR_CTRL), .jl (JL), .jr (JR), .instruct (instr), .reset(reset));

LUT lut(.jrctrl (JR_CTRL), .Jctrl (J_CTRL), .beq (BEQ), .bne (BNE), .jl (JL),
        .Rctrl (R_CTRL), .Wren (WREN), .ALUctrl (ALU_CTRL), .Ictrl (I_CTRL), .MemWren (MEMWREN),
        .MemtoReg (MEMTOREG), .OP (instr[31:26]), .FUNCT (instr[5:0]));


wire [4:0] RT_ready, RS_ready, RD_ready, RT1;
wire WREN_ready, R_CTRL_ready, I_CTRL_ready, JL_ready, MEMTOREG_ready;
wire [15:0] imm_ready;
wire [2:0] ALU_CTRL_ready;
wire [31:0] PC_ready;
datapath DP(.A_data (JR), .imm_se (IMM_SE), .zero (ZERO), .c_out (C_OUT), .ofl (overflow),
            .memIn (memIn), .res (memAddr), .rt (RT1), .rt_write (RT_ready), .rs (RS_ready),
            .rd (RD_ready), .Wren (WREN_ready), .R_command (R_CTRL_ready), .I_command (I_CTRL_ready),
            .jl (JL_ready), .ALUctrl (ALU_CTRL_ready), .imm (imm_ready),
            .PC (PC_ready), .MemtoReg (MEMTOREG_ready), .memOut (memOut), .clk (clk), .reset(reset));


reg_bank pipes(.PC_ready(PC_ready), .RS_ready(RS_ready), .RT_1(RT1), .RT_ready(RT_ready), .RD_ready(RD_ready), .imm_ready(imm_ready), .Wren_ready(WREN_ready), .ALU_ctrl_ready(ALU_CTRL_ready),
              .MemtoReg_ready(MEMTOREG_ready), .MemWren_ready(MEMWREN_ready), .I_CTRL_ready(I_CTRL_ready), .R_CTRL_ready(R_CTRL_ready), .JL_ready(JL_ready), .PC(PC), .RS(instr[25:21]), .RT(RT), .RD(instr[15:11]), .imm(instr[15:0]),
              .Wren(WREN), .ALU_ctrl(ALU_CTRL), .MemtoReg(MEMTOREG), .MemWren(MEMWREN), .I_CTRL(I_CTRL), .R_CTRL(R_CTRL), .JL(JL), .clk(clk), .reset(reset));
endmodule
module reg_bank(
  output [31:0] PC_ready,
  output [4:0] RS_ready,
  output [4:0] RT_1,
  output [4:0] RT_ready,
  output [4:0] RD_ready,
  output [15:0] imm_ready,
  output Wren_ready,
  output [2:0] ALU_ctrl_ready,
  output MemtoReg_ready,
  output MemWren_ready,
  output I_CTRL_ready,
  output R_CTRL_ready,
  output JL_ready,
  input [31:0] PC,
  input [4:0] RS,
  input [4:0] RT,
  input [4:0] RD,
  input [15:0] imm,
  input Wren,
  input [2:0] ALU_ctrl,
  input MemtoReg,
  input MemWren,
  output I_CTRL,
  output R_CTRL,
  output JL,
  input clk,
  input reset
);
  // Add extra registers for three above forwarding
  //output stages of writeenable and regwrite for forwarding controls
  reg en = 1;
  wire [31:0] PC_1, PC_2, PC_3;
  register32 PC_IF_RF(.q(PC_1), .d(PC), .wrenable(en), .clk(clk), .reset(reset));
  register32 PC_RF_EX(.q(PC_2), .d(PC_1), .wrenable(en), .clk(clk), .reset(reset));
  register32 PC_EX_MEM(.q(PC_3), .d(PC_2), .wrenable(en), .clk(clk), .reset(reset));
  register32 PC_MEM_WB(.q(PC_ready), .d(PC_3), .wrenable(en), .clk(clk), .reset(reset));

  var_register #(5) RS_IF_RF(.q(RS_ready), .d(RS), .wrenable(en), .clk(clk), .reset(reset));

  wire [4:0] RT_1, RT_2, RT_3;
  var_register #(5) RT_IF_RF(.q(RT_1), .d(RT), .wrenable(en), .clk(clk), .reset(reset));
  var_register #(5) RT_RF_EX(.q(RT_2), .d(RT_1), .wrenable(en), .clk(clk), .reset(reset));
  var_register #(5) RT_EX_MEM(.q(RT_3), .d(RT_2), .wrenable(en), .clk(clk), .reset(reset));
  var_register #(5) RT_MEM_WB(.q(RT_ready), .d(RT_3), .wrenable(en), .clk(clk), .reset(reset));

  wire [4:0] RD_1, RD_2, RD_3;
  var_register #(5) RD_IF_RF(.q(RD_1), .d(RD), .wrenable(en), .clk(clk), .reset(reset));
  var_register #(5) RD_RF_EX(.q(RD_2), .d(RD_1), .wrenable(en), .clk(clk), .reset(reset));
  var_register #(5) RD_EX_MEM(.q(RD_3), .d(RD_2), .wrenable(en), .clk(clk), .reset(reset));
  var_register #(5) RD_MEM_WB(.q(RD_ready), .d(RD_3), .wrenable(en), .clk(clk), .reset(reset));

  var_register #(16) imm_IF_RF(.q(imm_ready), .d(imm), .wrenable(en), .clk(clk), .reset(reset));

  wire Wren0, Wren1, Wren2;
  register Wren_IF_RF(.q(Wren0), .d(Wren), .wrenable(en), .clk(clk));
  register Wren_RF_EX(.q(Wren1), .d(Wren0), .wrenable(en), .clk(clk));
  register Wren_EX_MEM(.q(Wren2), .d(Wren1), .wrenable(en), .clk(clk));
  register Wren_MEM_WB(.q(Wren_ready), .d(Wren2), .wrenable(en), .clk(clk));

  wire [2:0] ALU1;
  var_register #(3) ALU_IF_RF(.q(ALU1), .d(ALU_ctrl), .wrenable(en), .clk(clk), .reset(reset));
  var_register #(3) ALU_RF_EX(.q(ALU_ctrl_ready), .d(ALU1), .wrenable(en), .clk(clk), .reset(reset));

  wire MemtoReg0, MemtoReg1, MemtoReg2;
  register MemtoReg_IF_RF(.q(MemtoReg0), .d(MemtoReg), .wrenable(en), .clk(clk));
  register MemtoReg_RF_EX(.q(MemtoReg1), .d(MemtoReg0), .wrenable(en), .clk(clk));
  register MemtoReg_EX_MEM(.q(MemtoReg2), .d(MemtoReg1), .wrenable(en), .clk(clk));
  register MemtoReg_MEM_WB(.q(MemtoReg_ready), .d(MemtoReg2), .wrenable(en), .clk(clk));

  wire MemWren0, MemWren1, MemWren2;
  register MemWren_IF_RF(.q(MemWren0), .d(MemWren), .wrenable(en), .clk(clk));
  register MemWren_RF_EX(.q(MemWren1), .d(MemWren0), .wrenable(en), .clk(clk));
  register MemWren_EX_MEM(.q(MemWren2), .d(MemWren1), .wrenable(en), .clk(clk));
  register MemWren_MEM_WB(.q(MemWren_ready), .d(MemWren2), .wrenable(en), .clk(clk));

  register R_CTRL_IF_RF(.q(R_CTRL_ready), .d(R_CTRL), .wrenable(en), .clk(clk));

  register I_CTRL_IF_RF(.q(I_CTRL_ready), .d(I_CTRL), .wrenable(en), .clk(clk));

  wire JL0, JL1, JL2;
  register JL_IF_RF(.q(JL0), .d(JL), .wrenable(en), .clk(clk));
  register JL_RF_EX(.q(JL1), .d(JL0), .wrenable(en), .clk(clk));
  register JL_EX_MEM(.q(JL2), .d(JL1), .wrenable(en), .clk(clk));
  register JL_MEM_WB(.q(JL_ready), .d(JL2), .wrenable(en), .clk(clk));


endmodule
