`timescale 1ns / 1ps
module streamer_tb;

reg clk = 0;
reg rst = 0;
always #5 clk = !clk;
integer i = 0;
integer f;
always #10 i = i++;

wire [31:0] data;
wire [3:0] keep;
wire last, valid, user;

test_streamer s1 (clk, rst, data, keep, last, 1'b1, valid, user);

  initial begin
  #20 rst = 1;
   $dumpfile("test.vcd");
   $dumpvars(0,streamer_tb);
     # 3500000 $finish;
  end

  initial begin
      f = $fopen("word_stream.txt", "w");
  end

  always @(posedge clk) begin
      $fwrite(f,"%x", data);
      $fwrite(f,".");
      $fwrite(f,"%b", valid);
      $fwrite(f,"%b",user);
      $fwrite(f,"\n");
  end

endmodule

