module mode_selector #(
    parameter X_SIZE = 1280,
    parameter Y_SIZE =720,
    parameter X_WIDTH = 11,
    parameter Y_WIDTH = 10
) (
    input                   clk,
    input                   mode, //PAUSE FLAG
    
    input   [Y_WIDTH-1:0]   line_buffer_fetch_addr,
    output  [X_SIZE-1:0]    line_buffer_fetch_mem,
    input   [X_SIZE-1:0]    parallel_next_state_result,
    input   [Y_SIZE-1:0]    parallel_next_state_write_addr,
    input                   parallel_next_state_write_en,
    input                   y,
    output  [X_SIZE-1:0]    topline_out,

    //ram A
    output  [Y_WIDTH-1:0]   BRAM_A_addra,
    output  [X_WIDTH-1:0]   BRAM_A_dina,
    input   [X_SIZE-1:0]    BRAM_A_douta,
    output                  BRAM_A_wea,
    output  [Y_WIDTH-1:0]   BRAM_A_addrb,
    output  [X_SIZE-1:0]    BRAM_A_dinb,
    input   [X_SIZE-1:0]    BRAM_A_doutb,
    output                  BRAM_A_web,

    //ram B
    output  [Y_WIDTH-1:0]   BRAM_B_addra,
    output  [X_WIDTH-1:0]   BRAM_B_dina,
    input   [X_SIZE-1:0]    BRAM_B_douta,
    output                  BRAM_B_wea,
    output  [Y_WIDTH-1:0]   BRAM_B_addrb,
    output  [X_SIZE-1:0]    BRAM_B_dinb,
    input   [X_SIZE-1:0]    BRAM_B_doutb,
    output                  BRAM_B_web
);

//all READ port 'a' for line buffer
//all READ port 'b' for outstream video

//mode 0: RAM_A read, RAM_B write

always @(posedge) //use always comb
    if(mode) begin
        BRAM_A_addra <= line_buffer_fetch_addr;
        BRAM_A_addrb <= y;
        line_buffer_fetch_mem <= BRAM_A_douta;
        topline_out <= BRAM_A_doutb;

        BRAM_B_addra <= parallel_next_state_write_addr;
        BRAM_B_dina <= parallel_next_state_result;
        BRAM_B_wea <= parallel_next_state_write_en;
    end else begin
        BRAM_B_addra <= line_buffer_fetch_addr;
        BRAM_B_addrb <= y;
        line_buffer_fetch_mem <= BRAM_B_douta;
        topline_out <= BRAM_B_doutb;

        BRAM_A_addra <= parallel_next_state_write_addr;
        BRAM_A_dina <= parallel_next_state_result;
        BRAM_A_wea <= parallel_next_state_write_en;
    end



end


endmodule