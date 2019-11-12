`define ADD 011101

`include "instructions.v"
//`include "datapath.v"
`include "LUT.v"
// Todo:
// Do all test benches:
  //multiplexers
// Fix concatenate

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
            .B_data (memIn), .res(memAddr), .rt (RT), .rs (instr[25:21]),
            .rd (instr[15:11]), .Wren (WREN), .R_command (R_CTRL), .I_command (I_CTRL),
            .jl (JL), .ALUctrl (ALU_CTRL), .imm (instr[15:0]),
            .PC (PC), .MemtoReg (MEMTOREG), .memOut(memOut), .clk (clk), .reset(reset));

endmodule
