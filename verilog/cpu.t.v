`include "cpu.v"

//------------------------------------------------------------------------
// Simple real CPU testbench sequence
//------------------------------------------------------------------------

module cpu_test ();

    reg clk;
    reg reset;

    wire test_failed1;
    wire test_triggered1;
    reg start1 = 1;
    wire test_failed2;
    wire test_triggered2;
    reg start2 = 0;
    wire test_failed3;
    wire t3_1, t3_2, t3_3, t3_4;
    reg start3 = 0;
    reg dutpassed = 1;

    // Clock generation
    initial clk=0;
    always #1 clk = !clk;

    // Instantiate fake CPU
    CPU real_cpu(.clk(clk), .reset(reset));
    test1_tester mult_trigger(.test_failed(test_failed1), .test_triggered(test_triggered1), .regwrite_addr(real_cpu.DP.regwrite_addr), .reg_data(real_cpu.DP.reg_data), .start(start1), .clk(clk));
    test2_tester lcm_trigger(.test_failed(test_failed2), .test_triggered(test_triggered2), .regwrite_addr(real_cpu.DP.regwrite_addr), .reg_data(real_cpu.DP.reg_data), .start(start2), .clk(clk));
    test3_tester exp_trigger(.test_failed(test_failed3), .t1_trig(t3_1), .t2_trig(t3_2), .t3_trig(t3_3), .t4_trig(t3_4), .regwrite_addr(real_cpu.DP.regwrite_addr), .reg_data(real_cpu.DP.reg_data), .start(start3), .clk(clk));

    // Filenames for memory images and VCD dump file
    reg [1023:0] mem_text_fn;
    reg [1023:0] mem_data_fn;
    reg [1023:0] dump_fn;
    reg init_data = 1;      // Initializing .data segment is optional
    reg done_flag = 0;
    // Test sequence
    initial begin
      $display("\n\nDevice: CPU");
      // $dumpfile("cpu.vcd");
      // $dumpvars();





      $readmemh("../asm-in-use/mult.dat", real_cpu.Mem.mem);
      $display("\nTest 1: Multiply (Basic arithmetic, branching, jumps)");





      # 300 if (!test_triggered1) begin
        $display("Timed out, moving to next test");
      end

      $readmemh("../asm-in-use/lcm.dat", real_cpu.Mem.mem);
      //Assert reset pulse
      reset = 0; #1;
    	reset = 1; #5;
    	reset = 0; #1;


      start1 = 0;
      start2 = 1;

      $display("\nTest 2: Least Common Multiple (Includes SLT, more instructions)");

      # 300 if (!test_triggered2) begin
        $display("Timed out, moving to next test");
      end





    $readmemh("../asm-in-use/exp.dat", real_cpu.Mem.mem);
    //Assert reset pulse
    start2 = 0;
    start3 = 1;
    reset = 0; #1;
    reset = 1; #5;
    reset = 0; #1;

    $display("\nTest 3: Exponentials (includes rescursion, use of memory)");

    # 5000 if (!t3_4) begin
      $display("Timed out, finished.");
    end

   if (test_failed1 || test_failed2 || test_failed3) begin
    dutpassed = 0;
  end
  $display("DUT passed: %b", dutpassed);
	 $finish();
   end

endmodule


module test1_tester(
  output reg test_failed,
  output reg test_triggered,
  input [4:0] regwrite_addr,
  input [31:0] reg_data,
  input start,
  input clk
  );
  initial test_failed = 0;
  initial test_triggered = 0;
  always @(posedge clk) begin
    if ((regwrite_addr === 5'd2) && !(test_triggered) && start) begin
      test_triggered = 1;
      if (reg_data !== 32'd25) begin
        $display("Multiply got bad result, found %d on register $v0", real_cpu.DP.reg_data);
        test_failed = 1;
      end
      else begin
        $display("Multiply test successful.");
      end
    end
  end
endmodule


module test2_tester(
  output reg test_failed,
  output reg test_triggered,
  input [4:0] regwrite_addr,
  input [31:0] reg_data,
  input start,
  input clk
  );
  initial test_failed = 0;
  initial test_triggered = 0;
  always @(posedge clk) begin
    if ((regwrite_addr === 5'd2) && !(test_triggered) && start) begin
      test_triggered = 1;
      if (reg_data !== 32'd12) begin
        $display("LCM got bad result, found %d on register $v0", real_cpu.DP.reg_data);
        test_failed = 1;
      end
      else begin
        $display("LCM test successful.");
      end
    end
  end
endmodule

module test3_tester(
  output reg test_failed,
  output reg t1_trig,
  output reg t2_trig,
  output reg t3_trig,
  output reg t4_trig,
  input [4:0] regwrite_addr,
  input [31:0] reg_data,
  input start,
  input clk
  );
  initial test_failed = 0;
  initial t1_trig = 0;
  initial t2_trig = 0;
  initial t3_trig = 0;
  initial t4_trig = 0;
  always @(posedge clk) begin
    if ((regwrite_addr === 5'd16) && !(t1_trig) && start) begin

      t1_trig = 1;
      if (reg_data !== 32'd1) begin
        $display("Exponential Test got bad result, found %d on register $s0", real_cpu.DP.reg_data);
        test_failed = 1;
      end
      else begin
        $display("Exponential Test 1 successful.");
      end
    end
    if ((regwrite_addr === 5'd17) && !(t2_trig) && t1_trig) begin
      t2_trig = 1;
      if (reg_data !== 32'd12) begin
        $display("Exponential Test got bad result, found %d on register $s1", real_cpu.DP.reg_data);
        test_failed = 1;
      end
      else begin
        $display("Exponential Test 2 successful.");
      end
    end
    if ((regwrite_addr === 5'd18) && !(t3_trig) && t2_trig) begin
      t3_trig = 1;
      if (reg_data !== 32'd9) begin
        $display("Exponential Test got bad result, found %d on register $s2", real_cpu.DP.reg_data);
        test_failed = 1;
      end
      else begin
        $display("Exponential Test 3 successful.");
      end
    end
    if ((regwrite_addr === 5'd19) && !(t4_trig) && t3_trig) begin
      t4_trig = 1;
      if (reg_data !== 32'd64) begin
        $display("Exponential Test got bad result, found %d on register $s3", real_cpu.DP.reg_data);
        test_failed = 1;
      end
      else begin
        $display("Exponential Test 4 successful.");
      end
    end
  end
endmodule
