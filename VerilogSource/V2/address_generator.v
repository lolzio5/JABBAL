module address_generator (
    input wire clk,          // Clock input
    input wire reset,        // Reset input
    output reg [9:0] row_addr // 10-bit row address output
);

    // Always block triggered on the rising edge of clk or reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            row_addr <= 0; // If reset is active, set row_addr to 0
        end else begin
            if (row_addr < 720) begin
                row_addr <= row_addr + 1; // Increment row_addr if it's less than 720
            end
        end
    end

endmodule
