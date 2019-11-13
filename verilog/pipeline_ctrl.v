`include "regfile.v" // In order to use regfile.v, alu.v, and multiplexer.v
// Zero, imm_se have to be output from datapath at the same time in RF stage. beq and bne are delayed?
// JR gets delayed once, so JR_ctrl does too 
