module python_clk(
    output  mode,
    input   mode_signal, //sensitivity
);
reg      mode = 1'b0;

always@(posedge mode_signal or negedge mode_signal) begin 
    mode <= ~mode;
end

endmodule
