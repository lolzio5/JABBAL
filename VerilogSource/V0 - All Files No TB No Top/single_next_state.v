module single_next_state (
    input wire [2:0] top_row,
    input wire [2:0] middle_row,
    input wire [2:0] bottom_row,
    output reg next_state
);
    wire [1:0] sum_top, sum_middle, sum_bottom;
    wire [3:0] total_sum;

    assign sum_top = top_row[2] + top_row[1] + top_row[0];
    assign sum_middle = middle_row[2] + middle_row[0];
    assign sum_bottom = bottom_row[2] + bottom_row[1] + bottom_row[0];
    assign total_sum = sum_top + sum_middle + sum_bottom;

    // Determine if a cell is dead(0) or alive(1)
    // based on how many 1s are around it and its own state.
    always @(*) begin
        if (middle_row[1] == 1) begin
            if (total_sum == 4'd2 || total_sum == 4'd3) 
                next_state = 1;
            else 
                next_state = 0;
        end else begin
            if (total_sum == 4'd3) 
                next_state = 1;
            else 
                next_state = 0;
        end
    end
endmodule
