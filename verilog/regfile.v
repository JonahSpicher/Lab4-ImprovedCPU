//------------------------------------------------------------------------------
// MIPS register file
//   width: 32 bits
//   depth: 32 words (reg[0] is static zero register)
//   2 asynchronous read ports
//   1 synchronous, positive edge triggered write port
//------------------------------------------------------------------------------
`include "decoders.v"
`include "register.v"
`include "alu.v" // In order to use multiplexer.v

module regfile
(
output[31:0]	ReadData1,	// Contents of first register read
output[31:0]	ReadData2,	// Contents of second register read
input[31:0]	WriteData,	// Contents to write to register
input[4:0]	ReadRegister1,	// Address of first register to read
input[4:0]	ReadRegister2,	// Address of second register to read
input[4:0]	WriteRegister,	// Address of register to write
input		RegWrite,	// Enable writing of register when High
input		Clk, // Clock (Positive Edge Triggered)
input reset		
);

  // These two lines are clearly wrong.  They are included to showcase how the
  // test harness works. Delete them after you understand the testing process,
  // and replace them with your actual code.
  // assign ReadData1 = 15;
  // assign ReadData2 = 15;
  wire [31:0] reg_select;
  decoder1to32 addr_decode(.out(reg_select), .enable(RegWrite), .address(WriteRegister));
  wire [31:0] register_outputs[31:0];
  register32zero first_reg(.q(register_outputs[0]), .d(WriteData), .wrenable(reg_select[0]), .clk(Clk));
  generate
  genvar i;
  for (i = 1; i<32; i = i + 1)
  begin
    register32 first_reg(.q(register_outputs[i]), .d(WriteData), .wrenable(reg_select[i]), .clk(Clk), .reset(reset));
  end
  endgenerate

  //mux32to1by32 mux1(.out(ReadData1), .address(ReadRegister1), .inputs(register_outputs));
  mux32to1by32 mux1(.out(ReadData1), .address(ReadRegister1),
  .input0(register_outputs[0]), .input1(register_outputs[1]), .input2(register_outputs[2]), .input3(register_outputs[3]),
  .input4(register_outputs[4]), .input5(register_outputs[5]), .input6(register_outputs[6]), .input7(register_outputs[7]),
  .input8(register_outputs[8]), .input9(register_outputs[9]), .input10(register_outputs[10]), .input11(register_outputs[11]),
  .input12(register_outputs[12]), .input13(register_outputs[13]), .input14(register_outputs[14]), .input15(register_outputs[15]),
  .input16(register_outputs[16]), .input17(register_outputs[17]), .input18(register_outputs[18]), .input19(register_outputs[19]),
  .input20(register_outputs[20]), .input21(register_outputs[21]), .input22(register_outputs[22]), .input23(register_outputs[23]),
  .input24(register_outputs[24]), .input25(register_outputs[25]), .input26(register_outputs[26]), .input27(register_outputs[27]),
  .input28(register_outputs[28]), .input29(register_outputs[29]), .input30(register_outputs[30]), .input31(register_outputs[31]));

  mux32to1by32 mux2(.out(ReadData2), .address(ReadRegister2), .input0(register_outputs[0]), .input1(register_outputs[1]), .input2(register_outputs[2]), .input3(register_outputs[3]),
  .input4(register_outputs[4]), .input5(register_outputs[5]), .input6(register_outputs[6]), .input7(register_outputs[7]),
  .input8(register_outputs[8]), .input9(register_outputs[9]), .input10(register_outputs[10]), .input11(register_outputs[11]),
  .input12(register_outputs[12]), .input13(register_outputs[13]), .input14(register_outputs[14]), .input15(register_outputs[15]),
  .input16(register_outputs[16]), .input17(register_outputs[17]), .input18(register_outputs[18]), .input19(register_outputs[19]),
  .input20(register_outputs[20]), .input21(register_outputs[21]), .input22(register_outputs[22]), .input23(register_outputs[23]),
  .input24(register_outputs[24]), .input25(register_outputs[25]), .input26(register_outputs[26]), .input27(register_outputs[27]),
  .input28(register_outputs[28]), .input29(register_outputs[29]), .input30(register_outputs[30]), .input31(register_outputs[31]));


endmodule
