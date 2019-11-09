//------------------------------------------------------------------------------
// Test harness validates hw4testbench by connecting it to various functional
// or broken register files, and verifying that it correctly identifies each
//------------------------------------------------------------------------------

`include "regfile.v"

module hw4testbenchharness();

  wire[31:0]	ReadData1;	// Data from first register read
  wire[31:0]	ReadData2;	// Data from second register read
  wire[31:0]	WriteData;	// Data to write to register
  wire[4:0]	ReadRegister1;	// Address of first register to read
  wire[4:0]	ReadRegister2;	// Address of second register to read
  wire[4:0]	WriteRegister;  // Address of register to write
  wire		RegWrite;	// Enable writing of register when High
  wire		Clk;		// Clock (Positive Edge Triggered)

  reg		begintest;	// Set High to begin testing register file
  wire  	endtest;    	// Set High to signal test completion
  wire		dutpassed;	// Indicates whether register file passed tests

  // Instantiate the register file being tested.  DUT = Device Under Test
  regfile DUT
  (
    .ReadData1(ReadData1),
    .ReadData2(ReadData2),
    .WriteData(WriteData),
    .ReadRegister1(ReadRegister1),
    .ReadRegister2(ReadRegister2),
    .WriteRegister(WriteRegister),
    .RegWrite(RegWrite),
    .Clk(Clk)
  );

  // Instantiate test bench to test the DUT
  hw4testbench tester
  (
    .begintest(begintest),
    .endtest(endtest),
    .dutpassed(dutpassed),
    .ReadData1(ReadData1),
    .ReadData2(ReadData2),
    .WriteData(WriteData),
    .ReadRegister1(ReadRegister1),
    .ReadRegister2(ReadRegister2),
    .WriteRegister(WriteRegister),
    .RegWrite(RegWrite),
    .Clk(Clk)
  );

  // Test harness asserts 'begintest' for 1000 time steps, starting at time 10
  initial begin
    $display("\n\nDevice: Register File");
    begintest=0;
    #10;
    begintest=1;
    #1000;
  end

  // Display test results ('dutpassed' signal) once 'endtest' goes high
  always @(posedge endtest) begin
    $display("DUT passed?: %b", dutpassed);
  end

endmodule


//------------------------------------------------------------------------------
// Your HW4 test bench
//   Generates signals to drive register file and passes them back up one
//   layer to the test harness. This lets us plug in various working and
//   broken register files to test.
//
//   Once 'begintest' is asserted, begin testing the register file.
//   Once your test is conclusive, set 'dutpassed' appropriately and then
//   raise 'endtest'.
//------------------------------------------------------------------------------

module hw4testbench
(
// Test bench driver signal connections
input	   		begintest,	// Triggers start of testing
output reg 		endtest,	// Raise once test completes
output reg 		dutpassed,	// Signal test result

// Register File DUT connections
input[31:0]		ReadData1,
input[31:0]		ReadData2,
output reg[31:0]	WriteData,
output reg[4:0]		ReadRegister1,
output reg[4:0]		ReadRegister2,
output reg[4:0]		WriteRegister,
output reg		RegWrite,
output reg		Clk
);

  // Initialize register driver signals
  initial begin

    WriteData=32'd0;
    ReadRegister1=5'd0;
    ReadRegister2=5'd0;
    WriteRegister=5'd0;
    RegWrite=0;
    Clk=0;
  end
  integer i;
  reg all_same;

  // Once 'begintest' is asserted, start running test cases
  always @(posedge begintest) begin
    // $dumpfile("reg.vcd");
    // $dumpvars;
    endtest = 0;
    dutpassed = 1;
    #10

  // Test Case 0:
  // Decoder test
  WriteRegister = 5'd31;
  WriteData = 32'd503;
  RegWrite = 1;
  ReadRegister1 = 5'd0;
  ReadRegister2 = 5'd1;
  #5 Clk=1; #5 Clk=0;	// Generate single clock pulse

  // Verify expectations and report test result
  RegWrite = 0;
  all_same = 1;
  for (i = 1; i<32; i = i + 1)
  begin
    ReadRegister1 = i;
    if(ReadData1 !== 503) begin
      all_same = 0;
    end
  end
  if (all_same === 1) begin
    $display("Test case 0 failed.\nDecoder broken, all registers written to.\n");
    dutpassed = 0;
  end

  #5 Clk=1; #5 Clk=0;	// Generate single clock pulse
  // Basic Read-Write Tests
  // Test Case 1:
  //   Write '42' to register 2, verify with Read Ports 1 and 2
  //   Tests basic functionality, also a positive enable case
  WriteRegister = 5'd2;
  WriteData = 32'd42;
  RegWrite = 1;
  ReadRegister1 = 5'd2;
  ReadRegister2 = 5'd2;
  #5 Clk=1; #5 Clk=0;	// Generate single clock pulse

  // Verify expectations and report test result
  if((ReadData1 !== 42) || (ReadData2 !== 42)) begin
    dutpassed = 0;	// Set to 'false' on failure
    $display("Test Case 1 Failed. \nBasic Failure, other tests will fail.\n");
  end

  // Test Case 2:
  //   Write '15' to register 2, verify with Read Ports 1 and 2
  //   Change input value, just a little more basic testing.
  WriteRegister = 5'd2;
  WriteData = 32'd15;
  RegWrite = 1;
  ReadRegister1 = 5'd2;
  ReadRegister2 = 5'd2;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 15) || (ReadData2 !== 15)) begin
    dutpassed = 0;
    $display("Test Case 2 Failed. \nBasic Failure, other tests will fail.\n");
  end


  // Enable Testing
  // Test Case 3:
  //   Write '10' to register 2 with enable off, should still read 15
  RegWrite = 0;
  WriteRegister = 5'd2;
  WriteData = 32'd10;
  ReadRegister1 = 5'd2;
  ReadRegister2 = 5'd2;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 === 10) || (ReadData2 === 10)) begin
    dutpassed = 0;
    $display("Test Case 3 Failed. \nRegWrite was off but data was still written\n");
  end

  // Register Zero Test
  // Test Case 4:
  //   Write '10' to register 0, read register 0. Should output 0.
  RegWrite = 1;
  WriteRegister = 5'd0;
  WriteData = 32'd10;
  ReadRegister1 = 5'd0;
  ReadRegister2 = 5'd0;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 0) || (ReadData2 !== 0)) begin
    dutpassed = 0;
    $display("Test Case 4 Failed. \nRegister 0 contained data\n");
  end

  // Simultaneous Multiple Register Testing
  // Test Case 5:
  //   Write '27' to register 1, then writes 192 to register 3. Reads registers 1 and 3.
  RegWrite = 1;
  WriteRegister = 5'd1;
  WriteData = 32'd27;
  ReadRegister1 = 5'd1;
  ReadRegister2 = 5'd3;
  #5 Clk=1; #5 Clk=0;

  WriteRegister = 5'd3;
  WriteData = 32'd192;
  #5 Clk=1; #5 Clk=0;

  if((ReadData1 !== 27) || (ReadData2 !== 192)) begin
    dutpassed = 0;
    $display("Test Case 5 Failed. \nFailed to write/read separate registers.\n");
  end

  // Test Case 6: Check all registers for correct output
  RegWrite = 1;

  for (i = 0; i<32; i = i + 1)
  begin
    WriteRegister = i;
    WriteData = i;
    #5 Clk=1; #5 Clk=0;
  end

  //Example breaking it, uncomment to demonstrate
  // WriteRegister = 5;
  // WriteData = 7;
  // #5 Clk=1; #5 Clk=0;
  //
  // WriteRegister = 14;
  // WriteData = 20;
  // #5 Clk=1; #5 Clk=0;


  RegWrite = 0;
  for (i = 0; i<32; i = i + 1)
  begin
    ReadRegister1 = i;
    if(ReadData1 !== i) begin
    dutpassed = 0;
    $display("Test Case 6: Loop found register with wrong value. \nBad register:%d \nData was intended for register:%d\n", i, ReadData1);
  end
  end


  // Decoder address testing


  // All done!  Wait a moment and signal test completion.
  #5
  endtest = 1;

end

endmodule
