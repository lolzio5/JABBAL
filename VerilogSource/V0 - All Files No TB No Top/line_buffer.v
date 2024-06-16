module line_buffer(
    input clk,
    input [9:0] calc_row, // 720 rows - need 10 bits

    // Fetching stuff
    output [9:0] fetch_addr,
    input [1279:0] fetch_mem,

    // Buffers
    output [1279:0] top,
    output [1279:0] middle,
    output [1279:0] bottom,
    output valid
);

reg [1279:0] line_1;
reg [1279:0] line_2;
reg [1279:0] line_3;

assign top = line_1;
assign middle = line_2;
assign bottom = line_3;
assign valid = valid_reg;

reg [1:0] temp_fetch_counter = 2'd0; //INITIALISE as 0 - not sure if this is synthesizable

reg valid_reg;


always (@posedge clk) begin
    // Special case - first line
    if (calc_row == 0) begin
        if (temp_fetch_counter = 2'd0) begin
            line_1 <= 1280'd0;
            fetch_addr <= calc_row;

            valid_reg <= 0;
            temp_fetch_counter <= 2'd1;
        end
        if (temp_fetch_counter <= 2'd1) begin
            line_2 <= fetch_mem;
            fetch_addr <= calc_row + 1;     

            valid_reg <= 0;
            temp_fetch_counter <= 2'd2;
            
        end
        if (temp_fetch_counter <= 2'd2) begin
            line_3 <= fetch_mem;
            fetch_addr <= calc_row + 10'd2;   // This sets up the standard case  
            valid_reg <= 1;
            temp_fetch_counter <= 2'd0; 
        end
    end
    // Special case - last line
    else if (calc_row == 10'd719) begin
        line_1 <= line_2;
        line_2 <= line_3;
        line_3 <= 1280'd0;
        
        // Cleaning up
        valid_reg <= 1; 
        temp_fetch_counter <= 0;
        fetch_addr <= 0;
    end
    
    // Standard case
    else begin
        line_1 <= line_2;
        line_2 <= line_3;
        line_3 <= fetch_mem;
        
        //Set up fetch for next new line
        fetch_addr <= calc_row + 10'd2;
        valid_reg <= 1;
    end
end



endmodule
