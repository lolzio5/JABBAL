module state_mem(
    input aclk,
    input [9:0] x,
    input [8:0] y,
    output state
);

reg rom_array [11:0]; 
reg state_reg;

wire [3:0] index;

reg [2:0] x_index;
reg [1:0] y_index;

localparam cell_1 = 120;
localparam cell_2 = 320;
localparam cell_3 = 480;

// assign x_index = 'd3;
// assign y_index = 'd2;

// assign index = 'd5;
assign index = x_index + y_index * 4;
assign state = state_reg;

initial begin
    $readmemh ("state_rom.mem", rom_array, 0);
end

always @(posedge aclk) begin
    state_reg <= rom_array [index];
    // index <= index + 1;
    // if (index == 4'd11) begin
    //     index <= 4'd0;
    //end
end

always @* begin
    if (x < cell_1) begin
        x_index = 3'h0;
    end
    if ( (x >= cell_1) && (x < cell_2) ) begin
        x_index = 3'h1;
    end
    if ( (x >= cell_2) && (x < cell_3) ) begin
        x_index = 3'h2;
    end
    if (x >= cell_3) begin
        x_index = 3'h3;
    end

    if (y < cell_1) begin
        y_index = 2'h0;
    end
    if ( (y >= cell_1) && (y < cell_2) ) begin
        y_index = 2'h1;
    end
    if (y >= cell_2) begin
        y_index = 2'h2;
    end
end

endmodule