`include "alu.v"
`define ADD  3'd0
`define SUB  3'd1
`define XOR  3'd2
`define SLT  3'd3
`define AND  3'd4
`define NAND 3'd5
`define NOR  3'd6
`define OR   3'd7

module alu_harness();

wire [31:0] res;
wire [31:0] opA, opB;
wire [2:0] cmd;
wire ofl, zero, cout, dutpassed, endtest;
reg begintest;

ALU DUT(.result(res), .carryout(cout), .zero(zero), .overflow(ofl), .operandA(opA), .operandB(opB), .command(cmd));

alu_tester tester(.dutpassed(dutpassed), .operandA(opA), .operandB(opB), .alu_command(cmd), .endtest(endtest), .result(res), .zero(zero), .ofl(ofl), .cout(cout), .begintest(begintest));

// Test harness asserts 'begintest' for 1000 time steps, starting at time 10
  initial begin
    $display("\n\nDevice: ALU");
    begintest=0;
    #10;
    begintest=1;
    #1000;
  end

  // Display test results ('dutpassed' signal) once 'endtest' goes high
  always @(posedge endtest) begin
    $display("DUT passed?: %b", dutpassed);
    $finish();
  end

endmodule


module alu_tester
(
  output reg dutpassed,
  output reg [31:0] operandA,
  output reg [31:0] operandB,
  output reg [2:0] alu_command,
  output reg endtest,
  input [31:0] result,
  input zero,
  input ofl,
  input cout,
  input begintest
);
  reg failedFlag = 0;

`define TEST(A, B, CMD, RES, OFL, COUT, T_NUM, DESCR) \
  failedFlag = 0; \
  operandA = A; \
  operandB = B; \
  alu_command = CMD; \
  #1 \
  if (ofl !== (OFL))  begin \
    $display("Overflow Error."); \
    failedFlag = 1; \
  end \
  if ((result === 32'd0) === (zero === 1'd0)) begin \
    $display("Zero flag Error."); \
    failedFlag = 1; \
  end \
  if ((result !== (RES))) begin \
    $display("Bad Result."); \
    $display("Got: %h \nShould have gotten: %h", result, RES); \
    failedFlag = 1; \
  end \
  if (cout !== (COUT)) begin \
    $display("Carry-out Error."); \
    failedFlag = 1; \
  end \
  if (failedFlag) begin \
    dutpassed = 0; \
    $display("Test Case %d Failed:", T_NUM); \
    $display(DESCR); \
  end



always @(posedge begintest) begin
  // $dumpfile("alu.vcd");
  // $dumpvars;
  endtest = 0;
  dutpassed = 1;
  #10
  // A, B, CMD, RES, OFL, COUT, T_NUM, DESCR
  //Addition tests
  `TEST(32'd1, 32'd1, `ADD, 32'd1+32'd1, 0, 0, 1, "Addition, no carry or overflow\n")
  `TEST(32'd18927, 32'd2897, `ADD, 32'd18927+32'd2897, 0, 0, 2, "Addition, no carry or overflow\n")
  `TEST(-32'd17, 32'd5, `ADD, -32'd17 + 32'd5, 0, 0, 3, "Addition to negative number, no carry or overflow\n")
  `TEST(32'd10, -32'd4, `ADD, 32'd10 + -32'd4, 0, 1, 4, "Addition with carry out, no overflow\n")
  `TEST(-32'd1, 32'h1, `ADD, -32'd1 + 32'h1, 0, 1, 5, "Addition with carry out, no overflow\n")
  `TEST(32'h7fffffff, 32'h1, `ADD, 32'h7fffffff + 32'h1, 1, 0, 6, "Addition with overflow, no carryout\n")
  `TEST(-32'd1, 32'h80000000, `ADD, -32'd1 + 32'h80000000, 1, 1, 7, "Addition, carry and overflow\n")

  //Subtraction tests, uses "-" to ensure accuracy
  `TEST(-32'd6, -32'd2, `SUB, -32'd6 - -32'd2, 0, 0, 8, "Subtraction, no carry out or overflow\n")
  `TEST(32'd6, 32'd10, `SUB, 32'd6 - 32'd10, 0, 0, 9, "Subtraction, no carry out or overflow\n")
  `TEST(32'd6, 32'd2, `SUB, 32'd6 - 32'd2, 0, 1, 10, "Subtraction with carry out\n")
  `TEST(32'h7fffffff, -32'd1, `SUB, 32'h7fffffff - -32'd1, 1, 0, 11, "Subtraction with overflow\n")
  `TEST(-32'd2147483600, 32'd5682, `SUB, -32'd2147483600 - 32'd5682, 1, 1, 12, "Subtraction with overflow and carry out\n")

  //XOR tests
  `TEST(32'd5, 32'd2, `XOR, 32'd5^32'd2, 0, 0, 13, "XOR test\n")
  `TEST(32'd19273, 32'd4432, `XOR, 32'd19273^32'd4432, 0, 0, 14, "XOR test\n")
  `TEST(-32'd1, 32'd1902983, `XOR, -32'd1^32'd1902983, 0, 0, 15, "XOR test\n")
  `TEST(32'd100, 32'd100, `XOR, 32'd100^32'd100, 0, 0, 16, "XOR test\n")

  //SLT tests
  `TEST(32'd5, 32'd186, `SLT, 32'd5 < 32'd186, 0, 0, 17, "Positive < Positive, true\n")
  `TEST(32'd19273, 32'd4432, `SLT, 32'd19273 < 32'd4432, 0, 0, 18, "Positive < Positive, false\n")
  `TEST(-32'd450, -32'd34, `SLT, -32'd450 < -32'd34, 0, 0, 19, "Negative < Negative, true\n")
  `TEST(-32'd1, -32'd1902983, `SLT, -32'd1 < -32'd1902983, 0, 0, 20, "Negative < Negative, false\n")
  `TEST(-32'd1, 32'd1902983, `SLT, (-1 < 1902983), 0, 0, 21, "Negative < Positive\n")
  `TEST(32'd1, -32'd983, `SLT, (1 < -983), 0, 0, 22, "Positive < Negative\n")

  //AND tests
  `TEST(32'd5, 32'd2, `AND, 32'd5&32'd2, 0, 0, 23, "AND test\n")
  `TEST(32'd19273, 32'd4432, `AND, 32'd19273&32'd4432, 0, 0, 24, "AND test\n")
  `TEST(-32'd1, 32'd1902983, `AND, -32'd1&32'd1902983, 0, 0, 25, "AND test\n")
  `TEST(32'd100, 32'd100, `AND, 32'd100&32'd100, 0, 0, 26, "AND test\n")

  //NAND tests
  `TEST(32'd5, 32'd2, `NAND, ~(32'd5&32'd2), 0, 0, 27, "NAND test\n")
  `TEST(32'd19273, 32'd4432, `NAND, ~(32'd19273&32'd4432), 0, 0, 28, "NAND test\n")
  `TEST(-32'd1, 32'd1902983, `NAND, ~(-32'd1&32'd1902983), 0, 0, 29, "NAND test\n")
  `TEST(32'd100, 32'd100, `NAND, ~(32'd100&32'd100), 0, 0, 30, "NAND test\n")

  //NOR tests
  `TEST(32'd5, 32'd2, `NOR, ~(32'd5|32'd2), 0, 0, 31, "OR test\n")
  `TEST(32'd19273, 32'd4432, `NOR, ~(32'd19273|32'd4432), 0, 0, 32, "OR test\n")
  `TEST(-32'd1, 32'd1902983, `NOR, ~(-32'd1|32'd1902983), 0, 0, 33, "OR test\n")
  `TEST(32'd100, 32'd100, `NOR, ~(32'd100|32'd100), 0, 0, 34, "OR test\n")

  //OR tests
  `TEST(32'd5, 32'd2, `OR, 32'd5|32'd2, 0, 0, 35, "OR test\n")
  `TEST(32'd19273, 32'd4432, `OR, 32'd19273|32'd4432, 0, 0, 36, "OR test\n")
  `TEST(-32'd1, 32'd1902983, `OR, -32'd1|32'd1902983, 0, 0, 37, "OR test\n")
  `TEST(32'd100, 32'd100, `OR, 32'd100|32'd100, 0, 0, 38, "OR test\n")

  endtest = 1;


  end
endmodule
