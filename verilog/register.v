// Single-bit D Flip-Flop with enable
//   Positive edge triggered
module register
(
output reg	q,
input		d,
input		wrenable,
input		clk,
input reset
);
    initial begin
      q = 0; //maybe really bad
    end
    always @(posedge clk) begin
        if(reset) begin
          q <= 0;
        end
        else if(wrenable) begin
            q <= d;
        end
    end

endmodule

module register32
(
output reg [31:0] q,
input [31:0] d,
input wrenable,
input clk,
input reset
);
initial q = 0;

generate
genvar i;
for (i = 0; i<32; i = i + 1)
begin
  always @(posedge clk)
  begin
      if(reset) begin
        q <= 0;
      end
      else if(wrenable)
      begin
          q[i] <= d[i];
      end
  end
end
endgenerate
endmodule

module var_register
#(parameter width = 32)
(
output reg [width-1:0] q,
input [width-1:0] d,
input wrenable,
input clk,
input reset
);
initial q = 0;

generate
genvar i;
for (i = 0; i<width; i = i + 1)
begin
  always @(posedge clk)
  begin
      if(reset) begin
        q <= 0;
      end
      else if(wrenable)
      begin
          q[i] <= d[i];
      end
  end
end
endgenerate
endmodule

module register32zero
(
output reg [31:0] q,
input [31:0] d,
input wrenable,
input clk
);
initial q = 0;
generate
genvar i;
for (i = 0; i<32; i = i + 1)
begin
  always @(posedge clk)
  begin
      if(wrenable)
      begin
          q[i] <= 0;
      end
  end
end
endgenerate
endmodule
