
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
    input           s_axi_lite_wvalid

);

localparam X_SIZE = 1280;
localparam Y_SIZE = 720;
parameter  REG_FILE_SIZE = 3;
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

reg [1079:0]                          regfile [REG_FILE_SIZE-1:0];
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


// Pause flag, which controls to the calculation of the next grid
assign pause_flag = regfile[2]

// Read flag, to initialise the grid
assign read_flag = regfile[1]

// States, initialise grid or do nothing
localparam IDLE = 2'b00, WRITE_1 = 2'b01, WRITE_2 = 2'b10;

// Initialises the grid when read_flag is set to high, when data is to be retrieved from the registers and stored in BRAM.

reg [9:0] row_index;
reg [1:0] init_state;
reg done;

always @(posedge s_axi_lite_aclk or posedge axi_resetn) begin
    if (axi_resetn) begin
        init_state <= IDLE;
        row_index_1<=0;
        row_index_2<=1;
        done<=0;
    end else begin
        case (init_state)
            IDLE: begin
                if (done==1) begin
                    init_state<=IDLE;
                end else if ((read_flag==1) && (done==0)) begin
                    init_state <= WRITE_1;
                end else if ((read_flag==0) && (done==0)) begin
                    init_state <= WRITE_2;
                end
            end
            WRITE_1: begin
                matrix[row_index] <= regfile[0]; // Write to the appropriate location in BRAM
                if (read_flag == 1) begin
                    row_index_1<=row_index_1+1
                    init_state <= WRITE_2;
                end
                if (row_index_1=719) begin
                    done<=1
                end
            end
            WRITE_2: begin
                matrix[row_index] <= regfile[0]; // Write to the appropriate location in BRAM
                if (read_flag == 0) begin
                    row_index_2<=row_index_2+1
                    init_state <=WRITE_1;
                end
                if (row_index_2=719) begin
                    done<=1
                end
            end
        endcase
    end
end

always @(posedge s_axi_lite_aclk or posedge axi_resetn) begin

end

assign s_axi_lite_awready = (writeState == AWAIT_WADD_AND_DATA || writeState == AWAIT_WADD);
assign s_axi_lite_wready = (writeState == AWAIT_WADD_AND_DATA || writeState == AWAIT_WDATA);
assign s_axi_lite_bvalid = (writeState == AWAIT_RESP);
assign s_axi_lite_bresp = (writeAddr < REG_FILE_SIZE) ? AXI_OK : AXI_ERR;

wire [9:0] row_addr;
wire [10:0] bit_index;
wire addr_valid, bit_valid;
reg [1279:0] ram_data_out;
wire state;

always @(posedge out_stream_aclk or posedge axi_resetn) begin
    if (pause_flag || axi_resetn) begin
        address_generator addr_gen (
            .clk(out_stream_aclk),
            .reset(axi_resetn),
            .row_addr(row_addr),
            .valid(addr_valid)
        );

        ram_data_out = ram[row_addr]; // Get the whole row

        bit_extractor bit_ext_inst (
            .clk(out_stream_aclk),
            .reset(axi_resetn),
            .row_data(ram_data_out),
            .bit_out(bit_out),
            .bit_index(bit_index),
            .valid(bit_valid)
        );

        state = ram_data_out[bit_index]
    end
end

wire valid_int = 1'b1;
wire [4:0] current_reg;
wire state;

wire [4:0] inverted_x_index;
assign inverted_x_index = 5'd31 - x_index;

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
