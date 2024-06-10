`timescale 1ns / 1ps
module streamer_tb;

reg clk = 0;
reg rst = 0;
always #5 clk = !clk;
integer i = 0;
integer f;
always #10 i = i++;

// wire [31:0] data;
// wire [3:0] keep;
// wire last, valid, user;

wire [31:0] dataOut;
wire [3:0] keep;
wire last, valid, user;

reg [7:0] writeAdd = 0;
reg [31:0] writeData = 0;
reg writeAddValid = 0, writeValid = 0;
wire writeAddReady, writeReady;

reg [7:0] readAdd = 0;
wire readAddReady;
reg readAddValid = 0;

wire [31:0] readData;
reg readReady = 0;
wire [1:0] readResp;
wire readValid;

reg respReady = 0;
wire [1:0] respData;
wire respValid;

pixel_generator p1 (
  .out_stream_aclk(clk),
  .s_axi_lite_aclk(clk),
  .axi_resetn(rst),
  .periph_resetn(rst),

//Stream output
  .out_stream_tdata(dataOut),
  .out_stream_tkeep(keep),
  .out_stream_tlast(last),
  .out_stream_tready(1'b1),
  .out_stream_tvalid(valid),
  .out_stream_tuser(user), 

//AXI-Lite S
  .s_axi_lite_araddr(readAdd),
  .s_axi_lite_arready(readAddReady),
  .s_axi_lite_arvalid(readAddValid),

  .s_axi_lite_awaddr(writeAdd),
  .s_axi_lite_awready(writeAddReady),
  .s_axi_lite_awvalid(writeAddValid),

  .s_axi_lite_bready(respReady),
  .s_axi_lite_bresp(respData),
  .s_axi_lite_bvalid(respValid),

  .s_axi_lite_rdata(readData),
  .s_axi_lite_rready(readReady),
  .s_axi_lite_rresp(readResp),
  .s_axi_lite_rvalid(readValid),

  .s_axi_lite_wdata(writeData),
  .s_axi_lite_wready(writeReady),
  .s_axi_lite_wvalid(writeValid));

// test_streamer s1 (clk, rst, data, keep, last, 1'b1, valid, user);

  initial begin
  #20 rst = 1;
   $dumpfile("test.vcd");
   $dumpvars(0,streamer_tb);
      // # 1600 $finish;
     # 3500000 $finish;
  end

  initial begin
      f = $fopen("word_stream.txt", "w");
  end

  always @(posedge clk) begin
      $fwrite(f,"%x", dataOut);
      $fwrite(f,".");
      $fwrite(f,"%b", valid);
      $fwrite(f,"%b",user);
      $fwrite(f,"\n");
  end

endmodule