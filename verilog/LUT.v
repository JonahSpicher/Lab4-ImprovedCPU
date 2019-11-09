`define LW 6'h23
`define SW 6'h2b
`define J 6'h2
`define JaL 6'h3
`define BEQ 6'h4
`define BNE 6'h5
`define XORI 6'he
`define ADDI 6'h8
`define R 6'h0

`define R_JR 6'h08
`define R_ADD 6'h20
`define R_SUB 6'h22
`define R_SLT 6'h2a

module LUT (
  output reg jrctrl,
  output reg Jctrl,
  output reg beq,
  output reg bne,
  output reg jl,
  output reg Rctrl,
  output reg Wren,
  output reg[2:0] ALUctrl,
  output reg Ictrl,
  output reg MemWren,
  output reg MemtoReg,
  input[5:0] OP,
  input [5:0] FUNCT
);

always @(OP or FUNCT) begin
  case(OP)
  `LW: begin
   jrctrl = 0;
   Jctrl = 0;
   beq = 0;
   bne = 0;
   jl = 0;
   Rctrl = 0;
   Wren = 1;
   ALUctrl = 3'd0;
   Ictrl = 1;
   MemWren = 0;
   MemtoReg = 1;
  end
  `SW: begin
   jrctrl = 0;
   Jctrl = 0;
   beq = 0;
   bne = 0;
   jl = 0;
   Rctrl = 0;
   Wren = 0;
   ALUctrl = 3'd0;
   Ictrl = 1;
   MemWren = 1;
   MemtoReg = 0;
  end
  `J: begin
   jrctrl = 0;
   Jctrl = 1;
   beq = 0;
   bne = 0;
   jl = 0;
   Rctrl = 0;
   Wren = 0;
   ALUctrl = 3'd5; // Sets to NAND when it doesn't matter because NAND is faster I guess
   Ictrl = 0;
   MemWren = 0;
   MemtoReg = 0;
  end
  `JaL: begin
   jrctrl = 0;
   Jctrl = 1;
   beq = 0;
   bne = 0;
   jl = 1;
   Rctrl = 0;
   Wren = 1;
   ALUctrl = 3'd5;
   Ictrl = 0;
   MemWren = 0;
   MemtoReg = 0;
  end
  `BEQ: begin
   jrctrl = 0;
   Jctrl = 0;
   beq = 1;
   bne = 0;
   jl = 0;
   Rctrl = 0;
   Wren = 0;
   ALUctrl = 3'd1;
   Ictrl = 0;
   MemWren = 0;
   MemtoReg = 0;
  end
  `BNE: begin
  jrctrl = 0;
  Jctrl = 0;
  beq = 0;
  bne = 1;
  jl = 0;
  Rctrl = 0;
  Wren = 0;
  ALUctrl = 3'd1;
  Ictrl = 0;
  MemWren = 0;
  MemtoReg = 0;
  end
  `XORI: begin
  jrctrl = 0;
  Jctrl = 0;
  beq = 0;
  bne = 0;
  jl = 0;
  Rctrl = 0;
  Wren = 1;
  ALUctrl = 3'd2;
  Ictrl = 1;
  MemWren = 0;
  MemtoReg = 0;
  end
  `ADDI: begin
  jrctrl = 0;
  Jctrl = 0;
  beq = 0;
  bne = 0;
  jl = 0;
  Rctrl = 0;
  Wren = 1;
  ALUctrl = 3'd0;
  Ictrl = 1;
  MemWren = 0;
  MemtoReg = 0;
  end
  `R: begin
  beq = 0;
  bne = 0;
  jl = 0;
  Ictrl = 0;
  MemWren = 0;
  MemtoReg = 0;
  case(FUNCT)
   `R_JR: begin jrctrl = 1; Jctrl = 1; Rctrl = 0; Wren = 0; ALUctrl = 3'd5; end
   `R_ADD: begin jrctrl = 0; Jctrl = 0; Rctrl = 1; Wren = 1; ALUctrl = 3'd0; end
   `R_SUB: begin jrctrl = 0; Jctrl = 0; Rctrl = 1; Wren = 1; ALUctrl = 3'd1; end
   `R_SLT: begin jrctrl = 0; Jctrl = 0; Rctrl = 1; Wren = 1; ALUctrl = 3'd3; end
   endcase
  end
  default: begin
  jrctrl = 0;
  Jctrl = 0;
  beq = 0;
  bne = 0;
  jl = 0;
  Rctrl = 0;
  Wren = 0;
  ALUctrl = 3'd0;
  Ictrl = 0;
  MemWren = 0;
  MemtoReg = 0;
  end
 endcase
end
endmodule
