module state_mem(
    input aclk,
    input [9:0] x,
    input [8:0] y,
    output state
);

reg rom_array [4799:0]; //4000pixels
reg state_reg;

wire [12:0] index; 

wire [6:0] x_index;  // 0-79
wire [5:0] y_index;  // 0-59

integer k;
reg init;

assign x_index = x >> 3; 
assign y_index = y >> 3;


assign index = x_index + y_index * 80;
assign state = state_reg;

initial begin
    // $readmemh ("state_rom.mem", rom_array, 0);
    for (k = 0; k < 4799; k = k + 1)
    begin
        // if (k%2) begin
        // if (k%2) init
        // rom_array[k] = init;
        // end
        rom_array[k] = k%2;
    end
end

always @(posedge aclk) begin
    state_reg <= rom_array [index];
    // index <= index + 1;
    // if (index == 4'd11) begin
    //     index <= 4'd0;
    //end
end

endmodule