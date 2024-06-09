`timescale 1ns / 1ps
module state_mem_tb;

reg clk = 0;

always #5 clk = !clk;
integer i = 0;
always #10 i = i++;

wire state;

state_mem s1 (clk, 10'd140 , 9'd21 ,state);
  initial begin
   $dumpfile("testmem.vcd");
   $dumpvars(0,state_mem_tb);
     # 400 $finish;
  end

endmodule

