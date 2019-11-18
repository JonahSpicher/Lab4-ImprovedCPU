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

memory Mem(.PC({PC[29:0], 2'b0}), .instruction(instr), .data_out(memOut), .data_in(memIn), .data_addr(memAddr), .clk(clk), .wr_en(MEMWREN_ready));
wire [31:0] B;
wire jr_ctrl_ready, beq_ready, bne_ready;
instructPart instruct(.ProgramCounter (PC), .rt (RT), .enable (1'b1), .Clk (clk),
                      .imm_se (IMM_SE), .beq (beq_ready),
                      .bne (bne_ready), .jctrl (J_CTRL), .jr_ctrl (jr_ctrl_ready), .jl (JL), .jr (JR), .instruct (instr), .B(B), .reset(reset));

LUT lut(.jrctrl (JR_CTRL), .Jctrl (J_CTRL), .beq (BEQ), .bne (BNE), .jl (JL),
        .Rctrl (R_CTRL), .Wren (WREN), .ALUctrl (ALU_CTRL), .Ictrl (I_CTRL), .MemWren (MEMWREN),
        .MemtoReg (MEMTOREG), .OP (instr[31:26]), .FUNCT (instr[5:0]));


wire [4:0] RT_ready, RS_ready, RD_ready, RT1, regwrite_addr;
wire WREN_ready, R_CTRL_ready, I_CTRL_ready, JL_ready, MEMTOREG_ready, load_stall;
wire [15:0] imm_ready;
wire [2:0] ALU_CTRL_ready;
wire [31:0] PC_ready;
wire [1:0] forwardAE, forwardBE, forwardAE_ready, forwardBE_ready;
datapath DP(.A_data (JR), .B_data(B), .imm_se (IMM_SE), .zero (ZERO), .c_out (C_OUT), .ofl (overflow),
            .memIn (memIn), .res (memAddr), .regwrite_addr(regwrite_addr), .rt (RT1), .rt_write (RT_ready), .rs (RS_ready),
            .rd (RD_ready), .Wren (WREN_ready), .R_command (R_CTRL_ready), .I_command (I_CTRL_ready),
            .jl (JL_ready), .ALUctrl (ALU_CTRL_ready), .imm (imm_ready),
            .PC (PC_ready), .MemtoReg (MEMTOREG_ready), .memOut (memOut), .forwardAE(forwardAE_ready), .forwardBE(forwardBE_ready), .clk (clk), .reset(reset), .load_stall(!load_stall));

wire WREN2, WREN1, MEMTOREG1, prev_MEMTOREG, nextR_CTRL, firstR_CTRL;
wire [4:0] next_regwrite_addr, first_regwrite_addr, nextRD, nextRT, firstRD, firstRT;
reg_bank pipes(.PC_ready(PC_ready), .RS_ready(RS_ready), .RT_1(RT1), .RT_ready(RT_ready), .nextRT(nextRT), .firstRT(firstRT), .RD_ready(RD_ready), .nextRD(nextRD), .firstRD(firstRD), .imm_ready(imm_ready),
              .Wren_ready(WREN_ready), .Wren2(WREN2), .ALU_ctrl_ready(ALU_CTRL_ready), .MemtoReg_ready(MEMTOREG_ready),
              .MemtoReg1(MEMTOREG1), .prevMemtoReg(prev_MEMTOREG), .MemWren_ready(MEMWREN_ready),
              .I_CTRL_ready(I_CTRL_ready), .R_CTRL_ready(R_CTRL_ready), .nextR_CTRL(nextR_CTRL), .firstR_CTRL(firstR_CTRL), .JL_ready(JL_ready), .forwardAE_ready(forwardAE_ready),
              .forwardBE_ready(forwardBE_ready), .jr_ctrl_ready(jr_ctrl_ready), .beq_ready(beq_ready), .bne_ready(bne_ready), .PC(PC),
              .RS(instr[25:21]), .RT(RT), .RD(instr[15:11]), .imm(instr[15:0]), .Wren(WREN), .ALU_ctrl(ALU_CTRL), .MemtoReg(MEMTOREG),
              .MemWren(MEMWREN), .I_CTRL(I_CTRL), .R_CTRL(R_CTRL), .JL(JL), .forwardAE(forwardAE), .forwardBE(forwardBE),
              .jr_ctrl(JR_CTRL), .beq(BEQ), .bne(BNE), .clk(clk), .reset(reset), .load_stall(load_stall));

fancymux #(5) next_regwrite_finder(.out(next_regwrite_addr), .address(nextR_CTRL), .input1(nextRD), .input0(nextRT));
fancymux #(5) first_regwrite_finder(.out(first_regwrite_addr), .address(firstR_CTRL), .input1(firstRD), .input0(firstRT));

pipelineCtrl forwardstuff(.forwardAE(forwardAE), .forwardBE(forwardBE), .load_stall(load_stall), .wren(WREN_ready), .nextwren(WREN2),
                          .firstwren(WREN1), .prevMemtoReg(prev_MEMTOREG), .MemtoReg(MEMTOREG_ready), .nextMemtoReg(MEMTOREG1), .rs(RS_ready), .rt(RT1),
                          .writeRegister(regwrite_addr), .nextWriteRegister(next_regwrite_addr), .firstWriteRegister(first_regwrite_addr));


endmodule
module reg_bank(
  output [31:0] PC_ready,
  output [4:0] RS_ready,
  output [4:0] RT_1,
  output [4:0] RT_ready,
  output [4:0] nextRT,
  output [4:0] firstRT,
  output [4:0] RD_ready,
  output [4:0] nextRD,
  output [4:0] firstRD,
  output [15:0] imm_ready,
  output Wren_ready,
  output Wren2,
  output Wren1,
  output [2:0] ALU_ctrl_ready,
  output MemtoReg_ready,
  output MemtoReg1,
  output prevMemtoReg,
  output MemWren_ready,
  output I_CTRL_ready,
  output R_CTRL_ready,
  output nextR_CTRL,
  output firstR_CTRL,
  output JL_ready,
  output [1:0] forwardAE_ready,
  output [1:0] forwardBE_ready,
  output jr_ctrl_ready,
  output beq_ready,
  output bne_ready,
  input [31:0] PC,
  input [4:0] RS,
  input [4:0] RT,
  input [4:0] RD,
  input [15:0] imm,
  input Wren,
  input [2:0] ALU_ctrl,
  input MemtoReg,
  input MemWren,
  input I_CTRL,
  input R_CTRL,
  input JL,
  input [1:0] forwardAE,
  input [1:0] forwardBE,
  input jr_ctrl,
  input beq,
  input bne,
  input clk,
  input reset,
  input load_stall
);
  // Add extra registers for three above forwarding
  //output stages of writeenable and regwrite for forwarding controls
  reg en = 1;
  wire [31:0] PC_1, PC_2, PC_3;
  register32 PC_IF_RF(.q(PC_1), .d(PC), .wrenable(!load_stall), .clk(clk), .reset(reset));
  register32 PC_RF_EX(.q(PC_2), .d(PC_1), .wrenable(!load_stall), .clk(clk), .reset(reset));
  register32 PC_EX_MEM(.q(PC_3), .d(PC_2), .wrenable(en), .clk(clk), .reset(reset));
  register32 PC_MEM_WB(.q(PC_ready), .d(PC_3), .wrenable(en), .clk(clk), .reset(reset));

  var_register #(5) RS_IF_RF(.q(RS_ready), .d(RS), .wrenable(!load_stall), .clk(clk), .reset(reset));

  wire [4:0] RT_1;
  var_register #(5) RT_IF_RF(.q(RT_1), .d(RT), .wrenable(!load_stall), .clk(clk), .reset(reset));
  var_register #(5) RT_RF_EX(.q(firstRT), .d(RT_1), .wrenable(!load_stall), .clk(clk), .reset(reset));
  var_register #(5) RT_EX_MEM(.q(nextRT), .d(firstRT), .wrenable(en), .clk(clk), .reset(reset));
  var_register #(5) RT_MEM_WB(.q(RT_ready), .d(nextRT), .wrenable(en), .clk(clk), .reset(reset));

  wire [4:0] RD_1;
  var_register #(5) RD_IF_RF(.q(RD_1), .d(RD), .wrenable(!load_stall), .clk(clk), .reset(reset));
  var_register #(5) RD_RF_EX(.q(firstRD), .d(RD_1), .wrenable(!load_stall), .clk(clk), .reset(reset));
  var_register #(5) RD_EX_MEM(.q(nextRD), .d(firstRD), .wrenable(en), .clk(clk), .reset(reset));
  var_register #(5) RD_MEM_WB(.q(RD_ready), .d(nextRD), .wrenable(en), .clk(clk), .reset(reset));

  var_register #(16) imm_IF_RF(.q(imm_ready), .d(imm), .wrenable(!load_stall), .clk(clk), .reset(reset));

  wire Wren0;
  register Wren_IF_RF(.q(Wren0), .d(Wren), .wrenable(!load_stall), .clk(clk));
  register Wren_RF_EX(.q(Wren1), .d(Wren0), .wrenable(!load_stall), .clk(clk));
  register Wren_EX_MEM(.q(Wren2), .d(Wren1), .wrenable(en), .clk(clk));
  register Wren_MEM_WB(.q(Wren_ready), .d(Wren2), .wrenable(en), .clk(clk));

  wire [2:0] ALU1;
  var_register #(3) ALU_IF_RF(.q(ALU1), .d(ALU_ctrl), .wrenable(!load_stall), .clk(clk), .reset(reset));
  var_register #(3) ALU_RF_EX(.q(ALU_ctrl_ready), .d(ALU1), .wrenable(!load_stall), .clk(clk), .reset(reset));

  wire MemtoReg0, MemtoReg1;
  register MemtoReg_IF_RF(.q(MemtoReg0), .d(MemtoReg), .wrenable(!load_stall), .clk(clk));
  register MemtoReg_RF_EX(.q(MemtoReg1), .d(MemtoReg0), .wrenable(!load_stall), .clk(clk));
  register MemtoReg_EX_MEM(.q(MemtoReg_ready), .d(MemtoReg1), .wrenable(en), .clk(clk));
  register MemtoReg_extra(.q(prevMemtoReg), .d(MemtoReg_ready), .wrenable(en), .clk(clk));

  wire MemWren0, MemWren1, MemWren2;
  register MemWren_IF_RF(.q(MemWren0), .d(MemWren), .wrenable(!load_stall), .clk(clk));
  register MemWren_RF_EX(.q(MemWren1), .d(MemWren0), .wrenable(!load_stall), .clk(clk));
  register MemWren_EX_MEM(.q(MemWren2), .d(MemWren1), .wrenable(en), .clk(clk));
  register MemWren_MEM_WB(.q(MemWren_ready), .d(MemWren2), .wrenable(en), .clk(clk));

  wire R_CTRL1, R_CTRL2, R_CTRL3;
  register R_CTRL_IF_RF(.q(R_CTRL1), .d(R_CTRL), .wrenable(!load_stall), .clk(clk));
  register R_CTRL_RF_EX(.q(firstR_CTRL), .d(R_CTRL1), .wrenable(!load_stall), .clk(clk));
  register R_CTRL_EX_MEM(.q(nextR_CTRL), .d(firstR_CTRL), .wrenable(en), .clk(clk));
  register R_CTRL_MEM_WB(.q(R_CTRL_ready), .d(nextR_CTRL), .wrenable(en), .clk(clk));

  register I_CTRL_IF_RF(.q(I_CTRL_ready), .d(I_CTRL), .wrenable(!load_stall), .clk(clk));

  wire JL0, JL1, JL2;
  register JL_IF_RF(.q(JL0), .d(JL), .wrenable(!load_stall), .clk(clk));
  register JL_RF_EX(.q(JL1), .d(JL0), .wrenable(!load_stall), .clk(clk));
  register JL_EX_MEM(.q(JL2), .d(JL1), .wrenable(en), .clk(clk));
  register JL_MEM_WB(.q(JL_ready), .d(JL2), .wrenable(en), .clk(clk));

  var_register #(2) forwardAE_delay(.q(forwardAE_ready), .d(forwardAE), .wrenable(!load_stall), .clk(clk), .reset(reset));
  var_register #(2) forwardBE_delay(.q(forwardBE_ready), .d(forwardBE), .wrenable(!load_stall), .clk(clk), .reset(reset));

  register jrctrl_delay(.q(jr_ctrl_ready), .d(jr_ctrl), .wrenable(load_stall), .clk(clk));

  register beq_delay(.q(beq_ready), .d(beq), .wrenable(!load_stall), .clk(clk));
  register bne_delay(.q(bne_ready), .d(bne), .wrenable(!load_stall), .clk(clk));



endmodule
