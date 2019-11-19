/* Multiplexers: Contains four multiplexers. The first is a simple 2 bit mux, which
is used to construct an 8 bit mux. These are leftover from the ALU, and could be
replaced by fancymux if this ever seems necessary. The third is fancymux, a multiplexer
that takes two inputs of parameterized length. The final one takes 32 inputs, each
32 bits long. Used for regfile.v.
*/
module Multiplexer2bit
(
    output out,
    input address,
    input in0, in1
);
/*
A simple 2 bit multiplexer.
*/
    wire nA;
    wire passed0, passed1;
    not addr_inv(nA, address);
    nand nand0(passed0, in0, nA);
    nand nand1(passed1, in1, address);
    nand collect(out, passed0, passed1);


endmodule



module Multiplexer8bit // Used by the ALU
(
  output out,
  input [2:0] address,
  input in0, in1, in2, in3, in4, in5, in6, in7
  );
  /*
  Uses a bunch of 2 bit multiplexers to build an 8 bit multiplexer. Organized in
  brackets, where each layer cuts out half of the inputs.
  */
  wire passed01, passed23, passed45, passed67;
  Multiplexer2bit l0m0(passed01, address[0], in0, in1);
  Multiplexer2bit l0m1(passed23, address[0], in2, in3);
  Multiplexer2bit l0m2(passed45, address[0], in4, in5);
  Multiplexer2bit l0m3(passed67, address[0], in6, in7);

  wire final_top, final_bottom;
  Multiplexer2bit l1m0(final_top, address[1], passed01, passed23);
  Multiplexer2bit l1m1(final_bottom, address[1], passed45, passed67);

  Multiplexer2bit l2m0(out, address[2], final_top, final_bottom);


endmodule



module fancymux
#(parameter width = 32)
(
output[width-1:0] out,
input address,
input [width-1:0] input0,
input [width-1:0] input1
);

  wire[1:0] mux[width-1:0];
  assign mux[0] = input0;
  assign mux[1] = input1;

  assign out = address ? input1 : input0;
endmodule

module Multiplexer4input
(
    output [31:0] out,
    input [1:0] address,
    input [31:0] input0, input1, input2, input3
);
  wire[31:0] mux[3:0];			// Create a 2D array of wires
  assign mux[0] = input0;   // I tried to do this with a generate loop and I could not get it to work
  assign mux[1] = input1;
  assign mux[2] = input2;
  assign mux[3] = input3;
  assign out = mux[address];	// Connect the output of the array

endmodule

module mux32to1by32 // Used by regfile
(
output[31:0]  out,
input[4:0]    address,
//input[31:0]   inputs
input[31:0]   input0, input1, input2, input3, input4, input5, input6, input7,
input8, input9, input10, input11, input12, input13, input14, input15,
input16, input17, input18, input19, input20, input21, input22, input23,
input24, input25, input26, input27, input28, input29, input30, input31
);


  wire[31:0] mux[31:0];			// Create a 2D array of wires
  assign mux[0] = input0;   // I tried to do this with a generate loop and I could not get it to work
  assign mux[1] = input1;
  assign mux[2] = input2;
  assign mux[3] = input3;
  assign mux[4] = input4;
  assign mux[5] = input5;
  assign mux[6] = input6;
  assign mux[7] = input7;
  assign mux[8] = input8;
  assign mux[9] = input9;
  assign mux[10] = input10;
  assign mux[11] = input11;
  assign mux[12] = input12;
  assign mux[13] = input13;
  assign mux[14] = input14;
  assign mux[15] = input15;
  assign mux[16] = input16;
  assign mux[17] = input17;
  assign mux[18] = input18;
  assign mux[19] = input19;
  assign mux[20] = input20;
  assign mux[21] = input21;
  assign mux[22] = input22;
  assign mux[23] = input23;
  assign mux[24] = input24;
  assign mux[25] = input25;
  assign mux[26] = input26;
  assign mux[27] = input27;
  assign mux[28] = input28;
  assign mux[29] = input29;
  assign mux[30] = input30;
  assign mux[31] = input31;

  assign out = mux[address];	// Connect the output of the array
endmodule
