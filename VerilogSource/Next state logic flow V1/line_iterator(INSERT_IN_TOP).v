// TO READ: NOTES
// line_buffer.v and parallel_next_state.v files have been changed - extra inputs/outputs and more logic handling flags 
// This is not an independent module COPY PASTE CODE BELOW INTO TOP LEVEL FILE
// Leave out lines  -  "module line_interator();" and "endmodule" [added for syntax highlighting in stand alone module for debugging]
// Connections to memory have not been made yet

module line_interator(); // DONT COPY

reg calc_flag = 0;      // Calc flag - INITIALISED HERE

wire calc_row_out; // TO line_buffer
reg calc_row_reg;
assign calc_row_out = calc_row_reg;

always @(posedge clk) begin
    if (calc_flg == 1) begin
        if (valid_set) begin
            if (calc_row_reg == 10'd719) begin
                calc_flag <= 0;
                calc_row_reg <= 0;
            end
            else begin
                calc_row_reg <= calc_row_reg + 1;
            end
        end
        else begin
            calc_row_reg <= 0;
        end
    end
end

// Interconnect wires between TOP , parrallel_next_state and line buffer
// _2 is for wires betwenen line buffer and parallel_next_state
wire valid_set;
wire top;
wire middle;
wire bottom;
wire calc_flag_1;
wire calc_flag_2;
wire calc_row_2;


line_buffer buffer(
    .clk(out_stream_aclk),
    .calc_row(calc_row_out), // FROM line iterator 

    // Fetching stuff
    .fetch_addr(), // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  TO read BRAM
    .fetch_mem(),   // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! FROM read BRAM

    // Buffers
    .top(top),    // TO parallel_next_state
    .middle(middle), // TO parallel_next_state
    .bottom(bottom), // TO parallel_next_state
    
    // New
    .calc_flag_in(calc_flag_1),         // FROM line_iterator 
    .valid_set(valid_set),           // TO parallel_next_state AND line_iterator
    .calc_row_out(calc_row_2),  // TO parallel_next_state 
    .calc_flag_out(calc_flag_2)        // TO parallel_next_state
);

parallel_next_state next_state(
    .clk(out_stream_aclk),
    .top_row(top),    // FROM line_buffer
    .middle_row(middle), // FROM line_buffer
    .bottom_row(bottom), // FROM line_buffer
    .result(), // TO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! BRAM write

    // New
    .calc_row_in(calc_row_2),    // FROM line_buffer
    .calc_flg(calc_flag_2),             // FROM line_buffer
    .valid_set(valid_set),            // FROM line_buffer
    .write_addr(),    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TO BRAM write
    .write_en()             // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TO BRAM write
);

endmodule   // DON'T COPY

