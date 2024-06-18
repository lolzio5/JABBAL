module python_clk(
    output  mode,
    input   mode_signal //sensitivity
);
reg      mode_reg = 1'b0;
assign mode = mode_reg;
always@(*) begin 
    mode_reg = ~mode_reg;
end

endmodule
