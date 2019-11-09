`include "decoders.v"

module decoder_harness();
wire [31:0] decoded_output;
wire [4:0] encoded_signal;
wire en, dutpassed, endtest;
reg begintest;


decoder1to32 DUT(.out(decoded_output), .enable(en), .address(encoded_signal));

decoder_tester testbench(.enable(en), .address(encoded_signal), .endtest(endtest), .result(decoded_output), .dutpassed(dutpassed), .begintest(begintest));

// Test harness asserts 'begintest' for 1000 time steps, starting at time 10
  initial begin
    $display("\n\nDevice: Decoder");
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


module decoder_tester(
    output reg enable,
    output reg [4:0] address,
    output reg endtest,
    input [31:0] result,
    output reg dutpassed,
    input begintest
);
reg failedFlag = 0;
reg [31:0] expected_out = 32'b0;


`define TEST(SIGNAL, EN, T_NUM) \
  address = SIGNAL; \
  enable = EN; \
  #1 \
  if (EN === 0) begin \
    if (result !== 32'd0) begin \
      $display("Enable Error"); \
      failedFlag = 1; \
    end \
  end \
  else begin \
    if (result[SIGNAL] !== 1'b1) begin \
      $display("Bad Result"); \
      expected_out[SIGNAL] = 1; \
      $display("Expected %b, got %b", expected_out, result); \
      expected_out[SIGNAL] = 0; \
      failedFlag = 1; \
    end \
  end \
  if (failedFlag) begin \
    dutpassed = 0; \
    $display("Test Case %d Failed:", T_NUM); \
  end




always @(posedge begintest) begin
  // $dumpfile("deocder.vcd");
  // $dumpvars;
  endtest = 0;
  dutpassed = 1;
  #10


  //Test calls
  `TEST(5'b11111, 1, 1)
  `TEST(5'b00101, 1, 2)
  `TEST(5'b00000, 1, 3)
  `TEST(5'b01011, 1, 4)
  `TEST(5'b10100, 1, 5)
  `TEST(5'b00010, 0, 6)
  `TEST(5'b11111, 0, 7)
  `TEST(5'b00000, 0, 8)
  `TEST(5'b01100, 0, 9)
  `TEST(5'b10011, 0, 10)

  endtest = 1;
end

endmodule
