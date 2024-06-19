module line_buffer #(
    parameter X_SIZE = 1280,
    parameter Y_SIZE = 720,
    parameter X_WIDTH = 11,
    parameter Y_WIDTH = 10
) (
    input clk,
    input [Y_WIDTH-1:0] calc_row, // FROM line iterator 720 rows - need 10 bits

    // Fetching stuff
    output [9:0] fetch_addr, // TO read BRAM
    input [1279:0] fetch_mem,   // FROM read BRAM

    // Buffers
    output [1279:0] top,    // TO parallel_next_state
    output [1279:0] middle, // TO parallel_next_state
    output [1279:0] bottom, // TO parallel_next_state
    
    // New
    input calc_flag_in,         // FROM line_iterator 
    output valid_set,           // TO parallel_next_state AND line_iterator
    output [9:0] calc_row_out,  // TO parallel_next_state 
    output calc_flag_out        // TO parallel_next_state
);


//top
//bottom
//middle

reg     [X_SIZE-1:0]    top;
reg     [X_SIZE-1:0]    middle;
reg     [X_SIZE-1:0]    bottom;
reg     [Y_WIDTH-1:0]   current_row;


always @(posedge clk) begin 
    if(current_row == {Y_WIDTH{1'b0}}) begin 
        top <= {X_WIDTH{1'b0}};
        middle <= fetch_mem
    end else if (current_row == 10'd719) begin 
        
    end else begin 

    end

end




endmodule
