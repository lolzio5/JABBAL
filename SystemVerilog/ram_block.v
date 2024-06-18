module ram_block (
    input clka,            // Clock input for port A
    input clkb,            // Clock input for port B
    input ena,             // Enable signal for port A
    input enb,             // Enable signal for port B
    input wea,             // Write enable signal for port A
    input web,             // Write enable signal for port B
    input [10:0] addra,    // Address input for port A (11 bits to address 2048 locations)
    input [10:0] addrb,    // Address input for port B (11 bits to address 2048 locations)
    input [15:0] dia,      // Data input for port A (16 bits wide)
    input [15:0] dib,      // Data input for port B (16 bits wide)
    output reg [15:0] doa, // Data output for port A (16 bits wide)
    output reg [15:0] dob  // Data output for port B (16 bits wide)
);

(* ram_style = "block" *) reg [15:0] ram [0:2047];  // Declare the RAM variable with 2048 entries, each 16 bits wide

// Port A: Handle read and write operations
always @(posedge clka) begin
    if (ena) begin         // If enable signal for port A is active
        if (wea)           // If write enable signal for port A is active
            ram[addra] <= dia; // Write data to the addressed location
        doa <= ram[addra]; // Read data from the addressed location
    end
end

// Port B: Handle read and write operations
always @(posedge clkb) begin
    if (enb) begin         // If enable signal for port B is active
        if (web)           // If write enable signal for port B is active
            ram[addrb] <= dib; // Write data to the addressed location
        dob <= ram[addrb]; // Read data from the addressed location
    end
end

endmodule
