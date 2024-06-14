module ram_block (
    input clka,
    input clkb,
    input ena,
    input enb,
    input wea,
    input web,
    input [10:0] addra,
    input [10:0] addrb,
    input [15:0] dia,
    input [15:0] dib,
    output reg [15:0] doa,
    output reg [15:0] dob
);

// Declare the RAM variable
(* ram_style = "block" *) reg [15:0] ram [0:2047];  // Updated to 2048 entries, each 32 bits wide

// Port A
always @(posedge clka) begin
    if (ena) begin
        if (wea)
            ram[addra] <= dia;
        doa <= ram[addra];
    end
end

// Port B
always @(posedge clkb) begin
    if (enb) begin
        if (web)
            ram[addrb] <= dib;
        dob <= ram[addrb];
    end
end

endmodule