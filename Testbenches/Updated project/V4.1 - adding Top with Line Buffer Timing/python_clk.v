module python_clk(
    output  mode,
    input   mode_signal, //sensitivity
);
reg      mode = 1'b0;
always@(*) begin 
    mode = ~mode;
end

endmodule
