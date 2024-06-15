module address_generator (
    input wire clk,
    input wire reset,
    output reg [9:0] row_addr, 
    output reg valid 
    );
    reg [9:0] addr_counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            addr_counter <= 0;
            row_addr <= 0;
            valid <= 0;
        end else begin
            if (addr_counter < 720) begin
                row_addr <= addr_counter;
                addr_counter <= addr_counter + 1;
                valid <= 1;
            end else begin
                valid <= 0;
            end
        end
    end
endmodule