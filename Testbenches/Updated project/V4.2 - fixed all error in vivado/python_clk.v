module python_clk(
    input   clk,
    output  mode,
    input   mode_signal //sensitivity
);
reg     prev_reg = 1'b0;
reg     current_mode = 1'b0;
assign  mode = current_mode;

always@(posedge clk) begin 
    if(prev_reg != mode_signal)begin 
        current_mode <= ~current_mode;
        prev_reg <= mode_signal;
    end
end

endmodule
