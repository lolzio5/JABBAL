
//////////////////////////////////////////////////////////////////////////////////
// Company: JABBAL
// Engineers: Bon, Lol�zio, Ajay
// 
// Create Date: 16.05.2024 22:03:08
// Design Name: 
// Module Name: test_block_v
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: please work we beg
// 
//////////////////////////////////////////////////////////////////////////////////


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

// -------------------------------------------------------
// ---------------- FROM ED ------------------------------
// -------------------------------------------------------

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

//Read from the register file
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

assign s_axi_lite_awready = (writeState == AWAIT_WADD_AND_DATA || writeState == AWAIT_WADD);
assign s_axi_lite_wready = (writeState == AWAIT_WADD_AND_DATA || writeState == AWAIT_WDATA);
assign s_axi_lite_bvalid = (writeState == AWAIT_RESP);
assign s_axi_lite_bresp = (writeAddr < REG_FILE_SIZE) ? AXI_OK : AXI_ERR;

//Write to the register file, use a state machine to track address write, data write and response read events
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

// -------------------------------------------------------
// ---------------- OUR CODE -----------------------------
// -------------------------------------------------------


// -------------------------------------------------------
// ---------------- GRID INITIALISATION ------------------
// -------------------------------------------------------

// Pause flag, which controls to the calculation of the next grid
assign pause_flag = regfile[40];
// PAUSE = regfile[40];
// BRAM_A_WE = regfile[41];
assign BRAM_B_WE = regfile[42];


// Initialises the grid when read_flag is set to high, when data is to be retrieved from the registers and stored in BRAM.
reg [9:0] row_index;
assign init_write_enable = regfile[41];
reg [9:0] init_write_address;
reg init_done;
reg [1279:0] result_line;
reg [9:0] init_read_address;

always @(posedge out_stream_aclk) begin
    if (periph_resetn) begin
        init_write_address <= 10'd0;
        init_done <= 1'b0;
    end else if (init_write_enable) begin
        // Concatenates the whole line from the 40 registers
        result_line <= {regfile[0], regfile[1], regfile[2], regfile[3], 
                        regfile[4], regfile[5], regfile[6], regfile[7], 
                        regfile[8], regfile[9], regfile[10], regfile[11], 
                        regfile[12], regfile[13], regfile[14], regfile[15], 
                        regfile[16], regfile[17], regfile[18], regfile[19], 
                        regfile[20], regfile[21], regfile[22], regfile[23], 
                        regfile[24], regfile[25], regfile[26], regfile[27], 
                        regfile[28], regfile[29], regfile[30], regfile[31], 
                        regfile[32], regfile[33], regfile[34], regfile[35], 
                        regfile[36], regfile[37], regfile[38], regfile[39]};
        init_read_address <= init_write_address;
        init_write_address <= init_write_address + 10'd1;
        if (init_write_address == 10'd719) begin
            init_done <= 1'b1;
        end
    end
end

// -------------------------------------------------------
// ---------------- NEXT STATE CALCULATION ---------------
// -------------------------------------------------------

/**
wire [9:0] fetch_addr;
wire [9:0] calc_row;
wire [1279:0] fetch_mem;
wire [1279:0] top;
wire [1279:0] middle;
wire [1279:0] bottom;
wire valid;

always @(posedge out_stream_aclk and pause_flag==0) begin
    if(current_ram_flag) begin
         <= dout_line_A;
    end else begin
        top_line <= dout_line_B;
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

line_buffer buffer(
                 .calc_row(calc_row),
                 .clk(out_stream_aclk),
                 .fetch_addr(fetch_addr),
                 .fetch_mem(fetch_mem),
                 .top(top),
                 .middle(middle),
                 .bottom(bottom),
                 .valid(valid)
);
**/

// -------------------------------------------------------
// ---------------- OUTPUT LOGIC -------------------------
// -------------------------------------------------------

//BRAM register
reg [1279:0]    top_line;
reg [1279:0]    results_line;
reg             write;

assign c = 1'b0;

reg [X_WIDTH-1:0] x;
wire [Y_WIDTH-1:0] y;

wire first = (x == 0) & (y==0);
wire lastx = (x == X_SIZE - 1);
wire lasty = (y == Y_SIZE - 1);

wire ready;

reg [9:0] y_out_address;

always @(posedge out_stream_aclk) begin
    if(BRAM_B_WE) begin
        top_line <= dout_line_A;
    end else begin
        top_line <= dout_line_B;
    end

//    if((y==719) && (pause_flag==0)) begin
//        current_ram_flag=!current_ram_flag;
//    end

    write <= 1'b0;

    if(periph_resetn) begin
        if(ready) begin
            if(lastx) begin
                x <= 11'd0;
                if(lasty) begin
                    y_out_address <= 10'd0;
                end else begin
                    y_out_address <= y_out_address + 1'b1;
                end
            end else begin
                x <= x + 1'b1; 
            end

        end
    end else begin
        x <= 11'd0;
        y_out_address <= 10'd0;
    end

end

assign y = init_done ? y_out_address: init_read_address;

wire valid_int = 1'b1;
wire [4:0] current_reg;
wire state;

wire [10:0] inverted_x;

assign inverted_x = 11'd1279 - x;
assign state = top_line[inverted_x];

wire [1279:0] dout_line_A;
wire [1279:0] dout_line_B;

assign r = state * 8'hCB;
assign g = state * 8'h41;
assign b = state * 8'h6B;

packer pixel_packer(    .aclk(out_stream_aclk),
                        .aresetn(periph_resetn),
                        .r(r), .g(g), .b(b),
                        .eol(lastx), .in_stream_ready(ready), .valid(valid_int), .sof(first),
                        .out_stream_tdata(out_stream_tdata), .out_stream_tkeep(out_stream_tkeep),
                        .out_stream_tlast(out_stream_tlast), .out_stream_tready(out_stream_tready),
                        .out_stream_tvalid(out_stream_tvalid), .out_stream_tuser(out_stream_tuser) );
blk_mem_gen_0 blk_ram_A(
                 .addra(y),
                 .clka(out_stream_aclk),
                 .dina(results_line),
                 .douta(fetch_mem),
                 .ena(1),
                 .wea(write));
                 
blk_mem_gen_1 blk_ram_B(
                 .addra(y),
                 .clka(out_stream_aclk),
                 .dina(results_line),
                 .douta(dout_line_B),
                 .ena(1),
                 .wea(init_write_enable));
endmodule
