// NOT A STAND ALONE MODULE COPY PASTE INTO TOP
reg temp_mode = 0;
reg calc_flag = 0;

always @(posedge out_stream_aclk) begin
    if (temp_mode != mode_line) begin
        calc_flag <= 1;
        if (valid_set) begin
            if (calc_row_reg == 10'd719) begin
                temp_mode <= !temp_mode;
                calc_flag <= 0;
                calc_row_reg <= {Y_WIDTH{1'b0}};
            end
            else begin
                calc_row_reg <= calc_row_reg + 1'b1;
            end
        end
        else begin
            calc_row_reg <= {Y_WIDTH{1'b0}};
        end
    end
end



// Interconnect wires between TOP , parrallel_next_state and line buffer
// _2 is for wires betwenen line buffer and parallel_next_state
wire                valid_set;
wire [X_SIZE-1:0]  top;
wire [X_SIZE-1:0]  middle;
wire [X_SIZE-1:0]  bottom;
wire                calc_flag_1;
assign calc_flag_1 = calc_flag;
wire                calc_flag_2;
wire [Y_WIDTH-1:0]  calc_row_2;

//BRAM WIRE
wire [Y_WIDTH-1:0]  fetch_addr_line;
wire [X_SIZE-1:0]  fetch_mem_line;



line_buffer buffer(
    .clk(out_stream_aclk),
    .calc_row(calc_row_out), // FROM line iterator `

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

parallel_next_state next_state(
    .clk(out_stream_aclk),
    .top_row(top),    // FROM line_buffer
    .middle_row(middle), // FROM line_buffer
    .bottom_row(bottom), // FROM line_buffer
    .result(parallel_next_state_result_line), // TO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! BRAM write

    // New
    .calc_row_in(calc_row_2),    // FROM line_buffer
    .calc_flg(calc_flag_2),             // FROM line_buffer
    .valid_set(valid_set),            // FROM line_buffer
    .write_addr(parallel_next_state_write_addr_line),    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TO BRAM write
    .write_en(parallel_next_state_write_en_line));             // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TO BRAM write