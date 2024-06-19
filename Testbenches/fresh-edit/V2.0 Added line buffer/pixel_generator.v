module pixel_generator(
input           out_stream_aclk,
input           s_axi_lite_aclk,
input           axi_resetn,
input           periph_resetn,

//Stream output
output [31:0]   out_stream_tdata,
output [3:0]    out_stream_tkeep,
output          out_stream_tlast,
input           out_stream_tready,
output          out_stream_tvalid,
output [0:0]    out_stream_tuser, 

//AXI-Lite S
input [AXI_LITE_ADDR_WIDTH-1:0]     s_axi_lite_araddr,
output          s_axi_lite_arready,
input           s_axi_lite_arvalid,

input [AXI_LITE_ADDR_WIDTH-1:0]     s_axi_lite_awaddr,
output          s_axi_lite_awready,
input           s_axi_lite_awvalid,

input           s_axi_lite_bready,
output [1:0]    s_axi_lite_bresp,
output          s_axi_lite_bvalid,

output [31:0]   s_axi_lite_rdata,
input           s_axi_lite_rready,
output [1:0]    s_axi_lite_rresp,
output          s_axi_lite_rvalid,

input  [31:0]   s_axi_lite_wdata,
output          s_axi_lite_wready,
input           s_axi_lite_wvalid

);

localparam X_SIZE = 1280;
localparam Y_SIZE = 720;

localparam X_WIDTH = $clog2(X_SIZE);
localparam Y_WIDTH = $clog2(Y_SIZE);

parameter  REG_FILE_SIZE = 43;
localparam REG_FILE_AWIDTH = $clog2(REG_FILE_SIZE);
parameter  AXI_LITE_ADDR_WIDTH = 8;

localparam AWAIT_WADD_AND_DATA = 3'b000;
localparam AWAIT_WDATA = 3'b001;
localparam AWAIT_WADD = 3'b010;
localparam AWAIT_WRITE = 3'b100;
localparam AWAIT_RESP = 3'b101;

localparam AWAIT_RADD = 2'b00;
localparam AWAIT_FETCH = 2'b01;
localparam AWAIT_READ = 2'b10;

localparam AXI_OK = 2'b00;
localparam AXI_ERR = 2'b10;

reg [31:0]                          regfile [REG_FILE_SIZE-1:0];
reg [REG_FILE_AWIDTH-1:0]           writeAddr, readAddr;
reg [31:0]                          readData, writeData;
reg [1:0]                           readState = AWAIT_RADD;
reg [2:0]                           writeState = AWAIT_WADD_AND_DATA;


//BRAM register
reg [1279:0]    top_line;
reg [1279:0]    results_line;
reg             write;

assign c = 1'b0;

reg [X_WIDTH-1:0] x;
reg [Y_WIDTH-1:0] y;

wire first = (x == 0) & (y==0);
wire lastx = (x == X_SIZE - 1);
wire lasty = (y == Y_SIZE - 1);

wire ready;

//main
always @(posedge out_stream_aclk) begin
    if(regfile[1]) begin
        top_line <= dout_line_A;
    end else if(regfile[2]) begin
        top_line <= dout_line_B;
    end else if(regfile[3] || regfile[42]) begin
        top_line <= dout_line_A2;
    end else begin
        top_line <= dout_line_B2;
    end

    write <= 1'b0;

    if(periph_resetn) begin
        if(ready) begin
            if(lastx) begin
                x <= 11'd0;
                if(lasty) begin
                    y <= 10'd0;
                end else begin
                    y <= y + 1'b1;
                end
            end else begin
                x <= x + 1'b1; 
            end

        end
    end else begin
        x <= 11'd0;
        y <= 10'd0;
    end

end

always @(posedge s_axi_lite_aclk) begin
    
    readData <= regfile[readAddr];

    if (!axi_resetn) begin
    readState <= AWAIT_RADD;
    end

    else case (readState)

        AWAIT_RADD: begin
            if (s_axi_lite_arvalid) begin
                readAddr <= s_axi_lite_araddr[2+:REG_FILE_AWIDTH];
                readState <= AWAIT_FETCH;
            end
        end

        AWAIT_FETCH: begin
            readState <= AWAIT_READ;
        end

        AWAIT_READ: begin
            if (s_axi_lite_rready) begin
                readState <= AWAIT_RADD;
            end
        end

        default: begin
            readState <= AWAIT_RADD;
        end

    endcase
end

assign s_axi_lite_arready = (readState == AWAIT_RADD);
assign s_axi_lite_rresp = (readAddr < REG_FILE_SIZE) ? AXI_OK : AXI_ERR;
assign s_axi_lite_rvalid = (readState == AWAIT_READ);
assign s_axi_lite_rdata = readData;

always @(posedge s_axi_lite_aclk) begin

    if (!axi_resetn) begin
        writeState <= AWAIT_WADD_AND_DATA;
    end

    else case (writeState)

        AWAIT_WADD_AND_DATA: begin  //Idle, awaiting a write address or data
            case ({s_axi_lite_awvalid, s_axi_lite_wvalid})
                2'b10: begin
                    writeAddr <= s_axi_lite_awaddr[2+:REG_FILE_AWIDTH];
                    writeState <= AWAIT_WDATA;
                end
                2'b01: begin
                    writeData <= s_axi_lite_wdata;
                    writeState <= AWAIT_WADD;
                end
                2'b11: begin
                    writeData <= s_axi_lite_wdata;
                    writeAddr <= s_axi_lite_awaddr[2+:REG_FILE_AWIDTH];
                    writeState <= AWAIT_WRITE;
                end
                default: begin
                    writeState <= AWAIT_WADD_AND_DATA;
                end
            endcase        
        end

        AWAIT_WDATA: begin //Received address, waiting for data
            if (s_axi_lite_wvalid) begin
                writeData <= s_axi_lite_wdata;
                writeState <= AWAIT_WRITE;
            end
        end

        AWAIT_WADD: begin //Received data, waiting for address
            if (s_axi_lite_awvalid) begin
                writeAddr <= s_axi_lite_awaddr[2+:REG_FILE_AWIDTH];
                writeState <= AWAIT_WRITE;
            end
        end

        AWAIT_WRITE: begin //Perform the write
            regfile[writeAddr] <= writeData;
            writeState <= AWAIT_RESP;
        end

        AWAIT_RESP: begin //Wait to send response
            if (s_axi_lite_bready) begin
                writeState <= AWAIT_WADD_AND_DATA;
            end
        end

        default: begin
            writeState <= AWAIT_WADD_AND_DATA;
        end
    endcase
end
assign s_axi_lite_awready = (writeState == AWAIT_WADD_AND_DATA || writeState == AWAIT_WADD);
assign s_axi_lite_wready = (writeState == AWAIT_WADD_AND_DATA || writeState == AWAIT_WDATA);
assign s_axi_lite_bvalid = (writeState == AWAIT_RESP);
assign s_axi_lite_bresp = (writeAddr < REG_FILE_SIZE) ? AXI_OK : AXI_ERR;

wire valid_int = 1'b1;

wire [4:0] current_reg;
wire state;

wire [10:0] inverted_x;
assign inverted_x = 11'd1279 - x;

assign state = top_line[inverted_x];


wire [7:0] r, g, b;
wire [1279:0] dout_line_A;
wire [1279:0] dout_line_A2;
wire [1279:0] dout_line_B;
wire [1279:0] dout_line_B2;

wire [Y_WIDTH-1:0]  fetch_addr_line;
wire [X_SIZE-1:0]  fetch_mem_line;

assign r = 8'hCB;
assign g = state * 8'h41;
assign b = state * 8'h6B;

packer pixel_packer(    
                        .aclk(out_stream_aclk),
                        .aresetn(periph_resetn),
                        .r(r), .g(g), .b(b),
                        .eol(lastx), .in_stream_ready(ready), .valid(valid_int), .sof(first),
                        .out_stream_tdata(out_stream_tdata), .out_stream_tkeep(out_stream_tkeep),
                        .out_stream_tlast(out_stream_tlast), .out_stream_tready(out_stream_tready),
                        .out_stream_tvalid(out_stream_tvalid), .out_stream_tuser(out_stream_tuser) );
                        
blk_mem_gen_0 blk_ram_A(
                 .addra(fetch_addr_line),
                 .clka(out_stream_aclk),
                 .dina(results_line),
                 .douta(dout_line_A),
                 .ena(1),
                 .wea(write),
                 .addrb(y),
                 .clkb(out_stream_aclk),
                 .dinb(results_line),
                 .doutb(dout_line_A2),
                 .enb(1),
                 .web(write));
                 
blk_mem_gen_1 blk_ram_B(
                 .addra(y),
                 .clka(out_stream_aclk),
                 .dina(results_line),
                 .douta(dout_line_B),
                 .ena(1),
                 .wea(write),
                 .addrb(y),
                 .clkb(out_stream_aclk),
                 .dinb(results_line),
                 .doutb(dout_line_B2),
                 .enb(1),
                 .web(write));

line_buffer buffer(
    .clk(out_stream_aclk),
    .calc_row(y), // FROM line iterator `

    // Fetching stuff
    .fetch_addr(fetch_addr_line), // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  TO read BRAM
    .fetch_mem(fetch_mem_line),   // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! FROM read BRAM

    // Buffers
    .top(top),    // TO parallel_next_state
    .middle(middle), // TO parallel_next_state
    .bottom(bottom), // TO parallel_next_state
    
    // New
    .calc_flag_in(calc_flag_1),         // FROM line_iterator 
    .valid_set(valid_set),           // TO parallel_next_state AND line_iterator
    .calc_row_out(calc_row_2),  // TO parallel_next_state 
    .calc_flag_out(calc_flag_2));        // TO parallel_next_state



 
endmodule
