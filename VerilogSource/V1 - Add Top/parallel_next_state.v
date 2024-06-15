
parameter row_length=1280

module parallel_next_state(
    input wire [row_length-1:0] top_row,
    input wire [row_length-1:0] middle_row,
    input wire [row_length-1:0] bottom_row,
    input wire clk,
    output wire [row_length-1:0] result 
);

    wire [row_length+1:0] padded_top_row = {1'b0, top_row, 1'b0};
    wire [row_length+1:0] padded_middle_row = {1'b0, middle_row, 1'b0};
    wire [row_length+1:0] padded_bottom_row = {1'b0, bottom_row, 1'b0};
    
    // Generate and wire together 1280 Conway single modules to calculate the next state for all at once
    genvar i;
    generate
        for (i = 1; i < row_length-1; i = i + 1) begin : accelerator
            single_next_state cell (
                .top_row(top_row[i+2:i]),
                .middle_row(middle_row[i+2:i]),
                .bottom_row(bottom_row[i+2:i]),
                .next_state(result[i])
            );
        end
    endgenerate
endmodule