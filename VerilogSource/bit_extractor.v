module bit_extractor (
    input wire clk,
    input wire reset,
    input wire [1279:0] row_data, // Data input from RAM
    output reg bit_out, // Extracted bit output
    output reg [10:0] bit_index, // Index of the bit in the 1280-bit word
    output reg valid // Valid signal to indicate when a bit is valid
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_index <= 0;
            bit_out <= 0;
            valid <= 0;
        end else begin
            if (bit_index < 1280) begin
                bit_out <= row_data[bit_index];
                bit_index <= bit_index + 1;
                valid <= 1;
            end else begin
                bit_index <= 0;
                valid <= 0;
            end
        end
    end
endmodule