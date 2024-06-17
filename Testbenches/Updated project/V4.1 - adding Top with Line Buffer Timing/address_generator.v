module address_generator (
    input wire clk,
    input wire reset,
    output reg [9:0] row_addr, 

    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            row_addr <= 0;
        end else begin
            if (row_addr < 720) begin
                row_addr <= row_addr + 1;
            end
        end
    end
endmodule
