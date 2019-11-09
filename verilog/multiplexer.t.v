`include "multiplexer.v"

module multiplexer_harness();
  wire dutpassed1, dutpassed2, dutpassed3, dutpassed4, endtest1, endtest2, endtest3;
  reg begintest1, begintest2, begintest3;

  wire addr, out, in0, in1;
  Multiplexer2bit DUT1(.out(out), .address(addr), .in0(in0), .in1(in1));
  Two_bit_tester testbench1(.address(addr), .endtest(endtest1), .mux_in({in1, in0}), .dutpassed(dutpassed1), .mux_out(out), .begintest(begintest1));

  wire [2:0] addr_8;
  wire out_8, in0_8, in1_8, in2_8, in3_8, in4_8, in5_8, in6_8, in7_8;
  Multiplexer8bit DUT2(.out(out_8), .address(addr_8), .in0(in0_8), .in1(in1_8), .in2(in2_8), .in3(in3_8), .in4(in4_8), .in5(in5_8), .in6(in6_8), .in7(in7_8));
  Eight_bit_tester testbench2(.address(addr_8), .endtest(endtest2), .mux_in({in7_8, in6_8, in5_8, in4_8, in3_8, in2_8, in1_8, in0_8}), .dutpassed(dutpassed2), .mux_out(out_8), .begintest(begintest2));

  wire addr_f;
  wire [31:0] out_f, in0_f, in1_f;
  fancymux DUT3(.out(out_f), .address(addr_f), .input0(in0_f), .input1(in1_f));
  Two_input_tester testbench3(.address(addr_f), .endtest(endtest3), .mux_in0(in0_f), .mux_in1(in1_f), .dutpassed(dutpassed3), .mux_out(out_f), .begintest(begintest3));

// Test harness asserts 'begintest' for 1000 time steps, starting at time 10, for each successive test
  initial begin
    $display("\n\nDevice: Two bit Multiplexer");
    begintest1=0;
    begintest2=0;
    begintest3=0;
    #10;
    begintest1=1;
    #1000;
    $display("\nDevice: Eight bit Multiplexer");
    begintest1=0;
    begintest2=1;
    #1000;
    $display("\nDevice: Two input, Variable width Multiplexer");
    begintest2=0;
    begintest3=1;
    #1000;
  end

  // Display test results ('dutpassed' signal) once 'endtest' goes high
  always @(posedge endtest1) begin
    $display("DUT1 passed?: %b", dutpassed1);
  end
  always @(posedge endtest2) begin
    $display("DUT2 passed?: %b", dutpassed2);
  end
  always @(posedge endtest3) begin
    $display("DUT3 passed?: %b", dutpassed3);
    $finish();
  end

endmodule

// This one is hilariously overkill
module Two_bit_tester(
    output reg address,
    output reg endtest,
    output reg  [1:0] mux_in,
    output reg dutpassed,
    input mux_out,
    input begintest
);


`define TEST1(ADDR, IN) \
  address = ADDR; \
  mux_in = IN; \
  address = ADDR; \
  #1 \
  if (mux_out !== mux_in[(ADDR)]) begin \
    if (mux_out === mux_in[!(ADDR)]) begin \
      $display("Got opposite address"); \
    end \
    dutpassed = 0; \
    $display("Test Case %d Failed:", IN); \
  end
always @(posedge begintest) begin
  // $dumpfile("mux-2bit.vcd");
  // $dumpvars;
  endtest = 0;
  dutpassed = 1;
  #10
  //Test calls
  `TEST1(0, 2'b00)
  `TEST1(0, 2'b01)
  `TEST1(0, 2'b10)
  `TEST1(0, 2'b11)
  `TEST1(1, 2'b00)
  `TEST1(1, 2'b01)
  `TEST1(1, 2'b10)
  `TEST1(1, 2'b11)

  endtest = 1;
end

endmodule


module Eight_bit_tester(
    output reg [2:0] address,
    output reg endtest,
    output reg  [7:0] mux_in,
    output reg dutpassed,
    input mux_out,
    input begintest
);


`define TEST2(ADDR, IN, TNUM) \
  address = ADDR; \
  mux_in = IN; \
  address = ADDR; \
  #1 \
  if (mux_out !== mux_in[(ADDR)]) begin \
    dutpassed = 0; \
    $display("Test Case %d Failed:", TNUM); \
  end
always @(posedge begintest) begin
  // $dumpfile("mux-8bit.vcd");
  // $dumpvars;
  endtest = 0;
  dutpassed = 1;
  #10
  //Test calls
  `TEST2(3'd0, 8'b01010101, 1)
  `TEST2(3'd1, 8'b01010101, 2)
  `TEST2(3'd2, 8'b01010101, 3)
  `TEST2(3'd3, 8'b01010101, 4)
  `TEST2(3'd4, 8'b01010101, 5)
  `TEST2(3'd5, 8'b01010101, 6)
  `TEST2(3'd6, 8'b01010101, 7)
  `TEST2(3'd7, 8'b01010101, 8)
  `TEST2(3'd0, 8'b00001111, 9)
  `TEST2(3'd1, 8'b00001111, 10)
  `TEST2(3'd2, 8'b00001111, 11)
  `TEST2(3'd3, 8'b00001111, 12)
  `TEST2(3'd4, 8'b00001111, 13)
  `TEST2(3'd5, 8'b00001111, 14)
  `TEST2(3'd6, 8'b00001111, 15)
  `TEST2(3'd7, 8'b00001111, 16)

  endtest = 1;
end

endmodule


module Two_input_tester(
    output reg address,
    output reg endtest,
    output reg  [31:0] mux_in0,
    output reg  [31:0] mux_in1,
    output reg dutpassed,
    input [31:0] mux_out,
    input begintest
);
reg failedFlag = 0;

`define TEST3(ADDR, IN0, IN1, TNUM) \
  address = ADDR; \
  mux_in0 = IN0; \
  mux_in1 = IN1; \
  address = ADDR; \
  #1 \
  if (((mux_out !== mux_in0) && ((ADDR)) === 0) || ((mux_out !== mux_in1) && ((ADDR)) === 1)) begin \
    failedFlag = 1; \
    if (((mux_out === mux_in0) && ((ADDR)) === 1) || ((mux_out === mux_in1) && ((ADDR)) === 0)) begin \
      $display("Got opposite address"); \
    end \
    dutpassed = 0; \
    $display("Test Case %d Failed:", TNUM); \
  end
always @(posedge begintest) begin
  // $dumpfile("mux-2input.vcd");
  // $dumpvars;
  endtest = 0;
  dutpassed = 1;
  #10
  //Test calls
  `TEST3(0, 32'd119, 32'd64, 1)
  `TEST3(0, 32'd95873, 32'd1, 1)
  `TEST3(0, 32'd22, 32'd344522, 1)
  `TEST3(0, 32'd1898734, 32'd5473826, 1)

  `TEST3(1, 32'd11, 32'd6, 1)
  `TEST3(1, 32'd19, 32'd4, 1)
  `TEST3(1, 32'd9, 32'd36, 1)
  `TEST3(1, 32'd119, 32'd5564, 1)

  endtest = 1;
end

endmodule
