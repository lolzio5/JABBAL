module line_buffer(
    input clk,
    input [9:0] calc_row, // FROM line iterator 720 rows - need 10 bits

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

reg [9:0] calc_row_out_reg;
assign calc_row_out = calc_row_out_reg;

reg calc_flag_out_reg;
assign calc_flag_out = calc_flag_out_reg;

// Control signal logic
always @(posedge clk) begin
    calc_row_out_reg <= calc_row;
    calc_flag_out_reg <= calc_flag_in;
end

reg valid_reg;
assign valid_set = valid_reg;

reg [1279:0] line_1;
reg [1279:0] line_2;
reg [1279:0] line_3;

assign top = line_1;
assign middle = line_2;
assign bottom = line_3;


reg [1:0] temp_fetch_counter = 2'd0; //INITIALISE as 0 - not sure if this is synthesizable {Pretty sure it is}

reg [9:0] fetch_addr_reg;
assign fetch_addr = fetch_addr_reg;
// Line buffer logic
always @(posedge clk) begin
    // Special case - first line
    if (calc_row == 0) begin
        if (temp_fetch_counter == 2'd0) begin
            line_1 <= 1280'd0;
            fetch_addr_reg <= calc_row;

            valid_reg <= 0;
            temp_fetch_counter <= 2'd1;
        end
        else if (temp_fetch_counter == 2'd1) begin
            line_2 <= fetch_mem;
            fetch_addr_reg <= calc_row + 1;     

            valid_reg <= 0;
            temp_fetch_counter <= 2'd2;
            
        end
        else if (temp_fetch_counter == 2'd2) begin
            line_3 <= fetch_mem;
            fetch_addr_reg <= calc_row + 10'd2;   // This sets up the standard case  
            valid_reg <= 1;
            temp_fetch_counter <= 2'd0; 
        end
    end
    // Special case - one before last line 
    else if (calc_row == 10'd718) begin
        line_1 <= line_2;
        line_2 <= line_3;
        line_3 <= fetch_mem;
        
        valid_reg <= 1;
        //Can't fetch memory for next line so no diff fetch adrr loaded here 
    end
    // Special case - last line
    else if (calc_row == 10'd719) begin
        line_1 <= line_2;
        line_2 <= line_3;
        line_3 <= 1280'd0;
        
        // Cleaning up
        valid_reg <= 1; 
        temp_fetch_counter <= 0;
        fetch_addr_reg <= 0;    
    end
    
    // Standard case
    else begin
        line_1 <= line_2;
        line_2 <= line_3;
        line_3 <= fetch_mem;
        
        //Set up fetch for next new line
        fetch_addr_reg <= calc_row + 10'd2;
        valid_reg <= 1;
    end
end



endmodule
 