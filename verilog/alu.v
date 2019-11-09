`include "adder-1bit.v"
`include "multiplexer.v"
`define ADD  3'd0 // Not used here but useful to see
`define SUB  3'd1
`define XOR  3'd2
`define SLT  3'd3
`define AND  3'd4
`define NAND 3'd5
`define NOR  3'd6
`define OR   3'd7

module ALU
(
output[31:0]  result,
output        carryout,
output        zero,
output        overflow,
input[31:0]   operandA,
input[31:0]   operandB,
input[2:0]    command
);
/*
The main module. Takes the specified inputs, returning specified outputs.
Runs inputs through each sub module, then uses multiplexers to select which operation to use.
 */
  // A few small controls need to be set up
  wire sub, overflow_and_carryout, slt_on, fourth_row, nc0;
  //ALUcontrolLUT controls(sub, overflow_and_carryout, slt_on, command);
  nand check_3(fourth_row, command[0], command[1]); // Checks if the command bit has a remainder of 3 when divided by four (or is in the fourth row of the truth table)
  nor top_half(slt_on, fourth_row, command[2]); // Checks to make sure output is in top half of the truth table (not doing or)

  nor ofl_check(overflow_and_carryout, command[2], command[1]); // command[0] can be either 0 or 1, but higher than 0 or 1 and its rejected

  not inv_c0(nc0, command[0]); // Gets sub by ensuring C0 is on and C2 is off, or that neither C0 is off or C2 is on.
  nor sub_check(sub, command[2], nc0);


  generate // Multiplexers for each output bit according to what the desired output is.
  genvar i;
  for (i = 0; i<32; i = i + 1)
  begin
    Multiplexer8bit mux(result[i], command, add_result[i], add_result[i], xor_result[i], slt_result[i], and_result[i], nand_result[i], nor_result[i], or_result[i]);
  end
  endgenerate

  // This portion connects each sub module, initializing necessary variables before they're called
  wire [31:0] add_result;
  wire overflow_tripped;
  add add_module(add_result, carryout, overflow, overflow_tripped, operandA, operandB, overflow_and_carryout, sub);
  wire [31:0] xor_result;
  bitwise_xor xor_module(xor_result, operandA, operandB);
  wire [31:0] slt_result;
  slt slt_module(slt_result, add_result, overflow_tripped, slt_on);
  wire [31:0] and_result;
  wire [31:0] nand_result;
  bitwise_and and_module(and_result, nand_result);
  bitwise_nand nand_module(nand_result, operandA, operandB);
  wire [31:0] or_result;
  wire [31:0] nor_result;
  bitwise_or or_module(or_result, nor_result);
  bitwise_nor nor_module(nor_result, operandA, operandB);
  //Finally, check to see if zero is on with a 32 input NOR monstrosity
  // I am so sorry this wasn't supposed to be this way
  nor zero_check(zero, result[31], result[30], result[29], result[28], result[27], result[26], result[25], result[24], result[23], result[22], result[21], result[20], result[19], result[18], result[17], result[16], result[15], result[14], result[13], result[12], result[11], result[10], result[9], result[8], result[7], result[6], result[5], result[4], result[3], result[2], result[1], result[0]);
endmodule

module add
(
  output[31:0]  add_result,
  output        carryout,
  output        overflow,
  output        overflow_tripped,       // Sent to SLT for calculation, doesn't output
  input[31:0]   operandA,
  input[31:0]   operandB,
  input         overflow_and_carryout,  // A control flag that tells this module whether to turn these outputs on
  input         sub                     // Subtracts when this is 1, otherwise adds
);
/*
The add module combines addition and subtraction (its output is also used for SLT)
It is built as a ripple carry adder. The adder checks whether or not overflow
and carryout are supposed to be turned on before doing so.
*/
wire [31:0] filteredB; //Stored b after it is flipped (if sub is 1)
wire [31:0] carrys;    //Stores carry bits
wire carryout_tripped, overflow_tripped; // Carryout and Overflow results, but might not actually be output

// First, the first 1 bit adder, different because it takes sub
xor first_b_subtraction(filteredB[0], sub, operandB[0]); //Flip B if sub is true
structuralFullAdder first_bit_adder(add_result[0], carrys[1], operandA[0], filteredB[0], sub); // Add the first bits with sub as Cin

generate // Then loop through all the middle adders, which are the same
genvar i;
for (i = 1; i<31; i = i + 1)
begin
  xor b_subtraction(filteredB[i], sub, operandB[i]);
  structuralFullAdder bit_adder(add_result[i], carrys[i+1], operandA[i], filteredB[i], carrys[i]);
end
endgenerate
// Then make the last one, which gives carryout
xor last_b_subtraction(filteredB[31], sub, operandB[31]);
structuralFullAdder last_bit_adder(add_result[31], carryout_tripped, operandA[31], filteredB[31], carrys[31]);

// Check overflow by comparing last two carry bits
xor overflow_calc(overflow_tripped,carrys[31],carryout_tripped);


and check_overflow(overflow, overflow_tripped, overflow_and_carryout); //Only set overflow to true if adding or subtracting
//Same process for carryout
and check_carryout(carryout, carryout_tripped, overflow_and_carryout);
endmodule

module bitwise_xor
(
  output[31:0]  xor_result,
  input[31:0]   operandA,
  input[31:0]   operandB
);
/*
Very straightforward, just compare each bit with an XOR gate.
*/

generate
genvar i;
for (i = 0; i<32; i = i + 1)
begin
  xor xor_bits(xor_result[i], operandA[i], operandB[i]);
end
endgenerate
endmodule

module slt
(
  output [31:0] slt_result,
  input[31:0]   add_result,
  input         overflow_tripped,
  input slt_on
);
//Uses results from add to get slt
xor slt_comparison(slt_result[0], add_result[31], overflow_tripped); //sign of difference XOR overflow, gives A<B unless overflow

// Then it has to fill the rest of results with 0's.
generate
genvar i;
for (i = 1; i<32; i = i + 1)
begin
  not slt_filler(slt_result[i], slt_on); //All ones when slt is off but that doesn't matter.
end
endgenerate
endmodule

module bitwise_and
(
  output[31:0]  and_result,
  input[31:0]   nand_result
);
/*
Flips NAND result. Better than flipping AND result, because one less inverter
*/
generate
genvar i;
for (i = 0; i<32; i = i + 1)
begin
  not and_bits(and_result[i], nand_result[i]);
end
endgenerate
endmodule

module bitwise_nand
(
  output[31:0]  nand_result,
  input[31:0]   operandA,
  input[31:0]   operandB
);
/*
Straightforward bitwise comparison of bits
*/

generate
genvar i;
for (i = 0; i<32; i = i + 1)
begin
  nand nand_bits(nand_result[i], operandA[i], operandB[i]);
end
endgenerate
endmodule

module bitwise_nor
(
  output[31:0]  nor_result,
  input[31:0]   operandA,
  input[31:0]   operandB
);
/*
Straightforward bitwise comparison of each input with NOR gates
*/
generate
genvar i;
for (i = 0; i<32; i = i + 1)
begin
  nor nor_bits(nor_result[i], operandA[i], operandB[i]);
end
endgenerate
endmodule

module bitwise_or
(
  output[31:0]  or_result,
  input[31:0]   nor_result
);
/*
Just like and, flips NOR bits.
*/
generate
genvar i;
for (i = 0; i<32; i = i + 1)
begin
  not or_bits(or_result[i], nor_result[i]);
end
endgenerate
endmodule
