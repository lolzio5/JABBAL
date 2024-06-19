module parallel_next_state #(
    parameter row_length = 1280;
) (
    input wire clk,
    input wire [row_length-1:0] top_row,    // FROM line_buffer
    input wire [row_length-1:0] middle_row, // FROM line_buffer
    input wire [row_length-1:0] bottom_row, // FROM line_buffer
    output wire [row_length-1:0] result, // TO BRAM write

    // New
    input [9:0] calc_row_in,    // FROM line_buffer
    input calc_flg,             // FROM line_buffer
    input valid_set,            // FROM line_buffer
    output [9:0] write_addr,    // To BRAM write
    output write_en             // TO BRAM write
);

    wire [row_length+1:0] padded_top_row = {1'b0, top_row, 1'b0};
    wire [row_length+1:0] padded_middle_row = {1'b0, middle_row, 1'b0};
    wire [row_length+1:0] padded_bottom_row = {1'b0, bottom_row, 1'b0};
    
    // Generate and wire together 1280 Conway single modules to calculate the next state for all at once
    genvar i;
    generate
        for (i = 0; i < row_length ; i = i + 1) begin : accelerator
            single_next_state single_next_state(
                .top_row(padded_top_row[i+2:i]),
                .middle_row(padded_middle_row[i+2:i]),
                .bottom_row(padded_bottom_row[i+2:i]),
                .next_state(result[i])
            );
        end
    endgenerate

    // NEW STUFF

    reg [9:0] write_addr_reg;
    assign write_addr = write_addr_reg;

    reg write_en_reg;
    assign write_en = write_en_reg;

    always @(posedge clk) begin
        write_addr_reg <= calc_row_in;   // Sends address to write to
        
        // SET WRITE ENABLE LOW IF NOT VALID OR IF FINISHED WIRTING - prevents unwanted/corrupt writing 
        if (valid_set && calc_flg) begin // Only writes if valid and we set calc_flg high
            write_en_reg <= 1;
        end
        else begin
            write_en_reg <= 0;
        end
    end
    
endmodule
