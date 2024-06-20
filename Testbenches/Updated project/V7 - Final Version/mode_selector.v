module mode_selector #(
    parameter X_SIZE = 1280,
    parameter Y_SIZE =720,
    parameter X_WIDTH = 11,
    parameter Y_WIDTH = 10
) (
    input                   clk,
    input                   mode, //PAUSE FLAG
    
    input                   ui,
    input   [Y_WIDTH-1:0]   ui_data,

    input   [Y_WIDTH-1:0]   line_buffer_fetch_addr,
    output  [X_SIZE-1:0]    line_buffer_fetch_mem,
    input   [Y_WIDTH-1:0]   parallel_next_state_write_addr,
    input   [X_SIZE-1:0]    parallel_next_state_result,
    input                   parallel_next_state_write_en,
    input   [Y_WIDTH-1:0]   video_out_row_addr,
    output  [X_SIZE-1:0]    video_out_row_data,

    //ram A
    output  [Y_WIDTH-1:0]   BRAM_A_addra,
    output  [X_SIZE-1:0]    BRAM_A_dina,
    input   [X_SIZE-1:0]    BRAM_A_douta,
    output                  BRAM_A_wea,
    output  [Y_WIDTH-1:0]   BRAM_A_addrb,
    // output  [X_SIZE-1:0]    BRAM_A_dinb,
    input   [X_SIZE-1:0]    BRAM_A_doutb,
    // output                  BRAM_A_web,

    //ram B
    output  [Y_WIDTH-1:0]   BRAM_B_addra,
    output  [X_SIZE-1:0]    BRAM_B_dina,
    input   [X_SIZE-1:0]    BRAM_B_douta,
    output                  BRAM_B_wea,
    output  [Y_WIDTH-1:0]   BRAM_B_addrb,
    // output  [X_SIZE-1:0]    BRAM_B_dinb,
    input   [X_SIZE-1:0]    BRAM_B_doutb
    // output                  BRAM_B_web
);

//all READ port 'a' for line buffer
//all READ port 'b' for outstream video


// reg [Y_WIDTH-1:0]   BRAM_A_addra_reg;
// reg [Y_WIDTH-1:0]   BRAM_A_addrb_reg;
// reg [X_SIZE-1:0]    line_buffer_fetch_mem_reg;
// reg [X_SIZE-1:0]    video_out_row_data_reg;

// reg [Y_WIDTH-1:0]   BRAM_B_addra_reg;
// reg [X_SIZE-1:0]    BRAM_B_dina_reg;
// reg                 BRAM_B_wea_reg;

// reg [Y_WIDTH-1:0]   BRAM_B_addrb_reg;
// reg [X_SIZE-1:0]    BRAM_A_dina_reg;
// reg                 BRAM_A_wea_reg;

//mode 0: RAM_A read, RAM_B write

assign  BRAM_A_addra = mode ? line_buffer_fetch_addr : parallel_next_state_write_addr;
assign  BRAM_A_addrb = ui ? ui_data : video_out_row_addr;
assign  BRAM_B_addrb = ui ? ui_data : video_out_row_addr;
assign  line_buffer_fetch_mem = mode ? BRAM_A_douta : BRAM_B_douta;
assign  video_out_row_data = mode ? BRAM_A_doutb : BRAM_B_doutb;
assign  BRAM_B_addra = mode ? parallel_next_state_write_addr : line_buffer_fetch_addr;
assign  BRAM_B_dina = parallel_next_state_result;
assign  BRAM_A_dina = parallel_next_state_result;
assign  BRAM_B_wea = mode ? 1 : 0;   // assign  BRAM_B_wea = mode ? parallel_next_state_write_en : 0;
assign  BRAM_A_wea = mode ? 0 : 1;   // assign  BRAM_A_wea = mode ? 0 : parallel_next_state_write_en;
// assign  BRAM_A_web = 1'b0;
// assign  BRAM_B_web = 1'b0;
// assign BRAM_A_dinb = 1280'b0;
// assign  BRAM_B_dinb  = 1280'b0;





// always @(*) begin //use always comb
//     if(mode) begin
//         BRAM_A_addra = line_buffer_fetch_addr;
//         BRAM_A_addrb = video_out_row_addr;
//         line_buffer_fetch_mem = BRAM_A_douta;
//         video_out_row_data = BRAM_A_doutb;

//         BRAM_B_addra = parallel_next_state_write_addr;
//         BRAM_B_dina = parallel_next_state_result;
//         BRAM_B_wea = parallel_next_state_write_en;
//     end else begin
//         BRAM_B_addra = line_buffer_fetch_addr;
//         BRAM_B_addrb = video_out_row_addr;
//         line_buffer_fetch_mem = BRAM_B_douta;
//         video_out_row_data = BRAM_B_doutb;

//         BRAM_A_addra = parallel_next_state_write_addr;
//         BRAM_A_dina = parallel_next_state_result;
//         BRAM_A_wea = parallel_next_state_write_en;
//     end
//end
endmodule
