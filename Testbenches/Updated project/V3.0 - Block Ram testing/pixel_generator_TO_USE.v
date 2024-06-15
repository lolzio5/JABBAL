
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
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
// Additional Comments:
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
input           s_axi_lite_wvalid,



//BRAM request bram address and recieve bram data
output [10:0] bram_zero_A_addr,
input [2047:0] bram_zero_A_requested_data,
//BRAM write data to port A
output [2047:0] bram_zero_A_write_data, 
//BRAM write Flag
output          write_en


);

localparam X_SIZE = 640;
localparam Y_SIZE = 480;
parameter  REG_FILE_SIZE = 24;
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


//BRAM assign
assign top_line = bram_zero_A_requested_data;
assign bram_zero_A_addr = bram_zero_A_addr_reg;
assign write_en = 1'b0;
assign ena = 1'b0;
assign results_line = 2048'b0
//BRAM register
reg [2047:0]    top_line;
reg [2047:0]    results_line;
reg [10:0]      bram_zero_A_addr_reg;

//BRAM operation
always @(posedge s_axi_lite_aclk)begin
    if(bram_zero_A_addr_reg < 2048'd1080 )begin
        bram_zero_A_addr_reg <= bram_zero_A_addr_reg + 1'b1; //incr addr
    end else begin
        bram_zero_A_addr_reg <= 2048'b0;
    end
end

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

// Simulation purposes only
// initial begin
//     regfile[0] = 32'b00011100011101101100110101101100;
//     regfile[1] = 32'b01101101010011101111111110101100;
//     regfile[2] = 32'b01000101011000010101101000010111;
//     regfile[3] = 32'b00100000111101010101100011110011;
//     regfile[4] = 32'b01000000000110001100100001100100;
//     regfile[5] = 32'b11010100111001100100111110000010;
//     regfile[6] = 32'b01011110101100001010010110001101;
//     regfile[7] = 32'b10101001011100111100110011110011;
//     regfile[8] = 32'b01111111011000101100100111110001;
//     regfile[9] = 32'b10010011110101111110101111101010;
//     regfile[10] = 32'b00010100110010011110100000100101;
//     regfile[11] = 32'b10011010001000001010000010100000;
//     regfile[12] = 32'b00111101010111111000100101011111;
//     regfile[13] = 32'b11000000000111011100000011110010;
//     regfile[14] = 32'b00011101010110100010000001110111;
//     regfile[15] = 32'b00001100011111011101111110010011;
//     regfile[16] = 32'b10111101111101100010101010000011;
//     regfile[17] = 32'b10010111011110101010110010010111;
//     regfile[18] = 32'b11010100001011100001100100100101;
//     regfile[19] = 32'b00101100110011101110011010100100;
//     regfile[20] = 32'b01101100000000011110100111000111;
//     regfile[21] = 32'b11010000001110101000111111010011;
//     regfile[22] = 32'b01111011000111001110111100011110;
//     regfile[23] = 32'b11101000101110110100000110111000;
// end



assign s_axi_lite_awready = (writeState == AWAIT_WADD_AND_DATA || writeState == AWAIT_WADD);
assign s_axi_lite_wready = (writeState == AWAIT_WADD_AND_DATA || writeState == AWAIT_WDATA);
assign s_axi_lite_bvalid = (writeState == AWAIT_RESP);
assign s_axi_lite_bresp = (writeAddr < REG_FILE_SIZE) ? AXI_OK : AXI_ERR;



reg [9:0] x;
reg [8:0] y;
reg [4:0] x_index;
reg [4:0] y_index;

reg [4:0] x_count;
reg [4:0] y_count;

wire first = (x == 0) & (y==0);
wire lastx = (x == X_SIZE - 1);
wire lasty = (y == Y_SIZE - 1);

wire ready;

always @(posedge out_stream_aclk) begin
    if (periph_resetn) begin
        if (ready) begin
            if (lastx) begin
                x <= 9'd0;
                x_count <= 5'd0;
                x_index <= 5'd0;
        
                if (lasty) begin
                    y <= 9'd0;
                    y_count <= 0;
                    y_index <= 0;

                end
                else begin
                    y <= y + 1;
                    if (y_count == 5'd19) begin
                        y_count <= 0;
                        y_index <= y_index + 1;
                    end
                    else begin
                        y_count <= y_count + 1;
                    end
                end
            end
            else begin
                x <= x + 9'd1;
                if (x_count == 5'd19) begin
                        x_count <= 0;
                        x_index <= x_index + 1;
                    end
                    else begin
                        x_count <= x_count + 1;
                    end
            end
        end
    end
    else begin
        x <= 0;
        y <= 0;
        x_count <= 0;
        x_index <= 0;
        y_count <= 0;
        y_index <= 0;

    end
end

wire valid_int = 1'b1;

wire [4:0] current_reg;
wire state;

// assign state = regfile[y_index][x_index];
wire [4:0] inverted_x_index;
assign inverted_x_index = 5'd31 - x_index;
// assign current_reg = regfile[y_index];
// assign state = current_reg[x_index];
//assign state = regfile[y_index][inverted_x_index];

//BRAM x y coordinate
assign state = top_line[inverted_x_index];


wire [7:0] r, g, b;

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

 
endmodule
