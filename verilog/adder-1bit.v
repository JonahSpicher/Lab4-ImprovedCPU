// Adder circuit
`define AND2 and
`define AND3 and
`define NAND2 nand
`define NAND3 nand
`define OR2 or
`define OR3 or
`define NOR2 nor
`define NOR3 nor
`define XOR2 xor
`define XOR3 xor
`define NOT1 not

module structuralFullAdder
(
    output sum,
    output carryout,
    input a,
    input b,
    input carryin
);
    wire axorb, naxorb, ncarryin, tsum, bsum;
    `XOR2 xor_ab(axorb, a, b);
    `XOR2 xor_carry(sum, axorb, carryin);

    wire ab, aorb, bcarry;
    `NAND2 and_ab(ab, a, b);
    `OR2 or_ab(aorb, a, b);
    `NAND2 and_cin(bcarry, aorb, carryin);
    `NAND2 or_cout(carryout, bcarry, ab);

endmodule
