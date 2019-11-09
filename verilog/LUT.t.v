`include "LUT.v"

module testLUT ();
  reg[5:0] op;
  reg[5:0] funct;
  wire jrctrl;
  wire Jctrl;
  wire beq;
  wire bne;
  wire jl;
  wire Rctrl;
  wire Wren;
  wire[2:0] ALUctrl;
  wire Ictrl;
  wire MemWren;
  wire MemtoReg;

  LUT lut( .jrctrl (jrctrl), .Jctrl (Jctrl), .beq (beq), .bne (bne), .jl (jl), .Rctrl (Rctrl), .Wren (Wren), .ALUctrl (ALUctrl), .Ictrl (Ictrl), .MemWren (MemWren), .MemtoReg (MemtoReg), .OP (op), .FUNCT (funct));

  initial begin

  $display("OPP: LW | jrctrl Jctrl beq bne jl Rctrl Wren ALUctrl Ictrl MemWren MemtoReg | Expected Output"); //LW
  op=6'h23; #1000
  $display("%b  |    %b     %b    %b   %b   %b   %b    %b    %b      %b     %b        %b     | 0 0 0 0 0 0 1 000 1 0 1", op, jrctrl, Jctrl, beq, bne, jl, Rctrl, Wren, ALUctrl, Ictrl, MemWren, MemtoReg);
  $display("OPP: SW | jrctrl Jctrl beq bne jl Rctrl Wren ALUctrl Ictrl MemWren MemtoReg | Expected Output"); //SW
  op=6'h2b; #1000
  $display("%b  |    %b     %b    %b   %b   %b   %b    %b    %b      %b     %b        %b     | 0 0 0 0 0 0 0 000 1 1 0", op, jrctrl, Jctrl, beq, bne, jl, Rctrl, Wren, ALUctrl, Ictrl, MemWren, MemtoReg);
  $display("OPP: J | jrctrl Jctrl beq bne jl Rctrl Wren ALUctrl Ictrl MemWren MemtoReg | Expected Output"); //J
  op=6'h2; #1000
  $display("%b  |    %b     %b    %b   %b   %b   %b    %b    %b      %b     %b        %b     | 0 1 0 0 0 0 0 101 0 0 0", op, jrctrl, Jctrl, beq, bne, jl, Rctrl, Wren, ALUctrl, Ictrl, MemWren, MemtoReg);
  $display("OPP: BEQ | jrctrl Jctrl beq bne jl Rctrl Wren ALUctrl Ictrl MemWren MemtoReg | Expected Output"); //BEQ
  op=6'h4; #1000
  $display("%b  |    %b     %b    %b   %b   %b   %b    %b    %b      %b     %b        %b     | 0 0 1 0 0 0 0 001 0 0 0", op, jrctrl, Jctrl, beq, bne, jl, Rctrl, Wren, ALUctrl, Ictrl, MemWren, MemtoReg);
  $display("OPP: BNE | jrctrl Jctrl beq bne jl Rctrl Wren ALUctrl Ictrl MemWren MemtoReg | Expected Output"); //BNE
  op=6'h5; #1000
  $display("%b  |    %b     %b    %b   %b   %b   %b    %b    %b      %b     %b        %b     | 0 0 0 1 0 0 0 001 0 0 0", op, jrctrl, Jctrl, beq, bne, jl, Rctrl, Wren, ALUctrl, Ictrl, MemWren, MemtoReg);
  $display("OPP: XORI | jrctrl Jctrl beq bne jl Rctrl Wren ALUctrl Ictrl MemWren MemtoReg | Expected Output"); //XORI
  op=6'he; #1000
  $display("%b  |    %b     %b    %b   %b   %b   %b    %b    %b      %b     %b        %b     | 0 0 0 0 0 0 1 010 1 0 0", op, jrctrl, Jctrl, beq, bne, jl, Rctrl, Wren, ALUctrl, Ictrl, MemWren, MemtoReg);
  $display("OPP: ADDI | jrctrl Jctrl beq bne jl Rctrl Wren ALUctrl Ictrl MemWren MemtoReg | Expected Output"); //ADDI
  op=6'h8; #1000
  $display("%b  |    %b     %b    %b   %b   %b   %b    %b    %b      %b     %b        %b     | 0 0 0 0 0 0 1 000 1 0 0", op, jrctrl, Jctrl, beq, bne, jl, Rctrl, Wren, ALUctrl, Ictrl, MemWren, MemtoReg);
 $display("OPP: R_JR funct| jrctrl Jctrl beq bne jl Rctrl Wren ALUctrl Ictrl MemWren MemtoReg  | Expected Output"); //R_JR
  op=6'h0; funct=6'h08; #1000
  $display("%b    %b  |  %b    %b    %b   %b   %b    %b    %b      %b     %b       %b    %b      | 1 1 0 0 0 0 0 101 0 0 0", op, funct, jrctrl, Jctrl, beq, bne, jl, Rctrl, Wren, ALUctrl, Ictrl, MemWren, MemtoReg);
 $display("OPP: R_ADD funct| jrctrl Jctrl beq bne jl Rctrl Wren ALUctrl Ictrl MemWren MemtoReg | Expected Output"); //R_ADD
  op=6'h0; funct=6'h20; #1000
  $display("%b    %b  |  %b    %b    %b   %b   %b    %b    %b      %b     %b       %b    %b      | 0 0 0 0 0 1 1 000 0 0 0", op, funct, jrctrl, Jctrl, beq, bne, jl, Rctrl, Wren, ALUctrl, Ictrl, MemWren, MemtoReg);
 $display("OPP: R_SUB funct| jrctrl Jctrl beq bne jl Rctrl Wren ALUctrl Ictrl MemWren MemtoReg | Expected Output"); //R_SUB
  op=6'h0; funct=6'h22; #1000
  $display("%b    %b  |  %b    %b    %b   %b   %b    %b    %b      %b     %b       %b    %b      | 0 0 0 0 0 1 1 001 0 0 0", op, funct, jrctrl, Jctrl, beq, bne, jl, Rctrl, Wren, ALUctrl, Ictrl, MemWren, MemtoReg);
 $display("OPP: R_SLT funct| jrctrl Jctrl beq bne jl Rctrl Wren ALUctrl Ictrl MemWren MemtoReg | Expected Output"); //R_SLT
  op=6'h0; funct=6'h2a; #1000
  $display("%b    %b  |  %b    %b    %b   %b   %b    %b    %b      %b     %b       %b    %b      | 0 0 0 0 0 1 1 011 0 0 0", op, funct, jrctrl, Jctrl, beq, bne, jl, Rctrl, Wren, ALUctrl, Ictrl, MemWren, MemtoReg);
  
  end
endmodule
