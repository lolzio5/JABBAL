module GameOfLife #(parameter WIDTH = 640, HEIGHT = 480, NUM_THREADS = 4) ( //NUM_THREADS should be set to appropriate value
    input logic clk,
    input logic reset,
    input logic get_next
);
    function generate_next_state()

    // Function to count live neighbors
    function int count_live_neighbors(input logic [HEIGHT-1:0][WIDTH-1:0] grid, input int x, y);
        int live_neighbors;
        int dx, dy;
        live_neighbors = 0;
        for (dx = -1; dx <= 1; dx++) begin
            for (dy = -1; dy <= 1; dy++) begin
                if ((dx != 0 || dy != 0) && (x + dx >= 0) && (x + dx < WIDTH) && (y + dy >= 0) && (y + dy < HEIGHT)) begin
                    live_neighbors += grid[y + dy][x + dx];
                end
            end
        end
        return live_neighbors;
    endfunction

    
    genvar i, j;
    localparam int ROWS_PER_SQUARE = (HEIGHT + NUM_SQUARES - 1) / NUM_THREADS; 
    localparam int COLS_PER_SQUARE = (WIDTH + NUM_SQUARES - 1) / NUM_THREADS; 

    generate
        for (i = 0; i < NUM_SQUARES; i++) begin : row_threads
            for (j = 0; j < NUM_SQUARES; j++) begin : col_threads
                always_ff @(posedge clk or posedge reset) begin
                    int x, y;
                    int live_neighbors;
                    for (y = i * ROWS_PER_SQUARE; y < (i + 1) * ROWS_PER_SQUARE && y < HEIGHT; y++) begin
                        for (x = j * COLS_PER_SQUARE; x < (j + 1) * COLS_PER_SQUARE && x < WIDTH; x++) begin
                            live_neighbors = count_live_neighbors(current_grid, x, y);
                            if (current_grid[y][x] == 1'b1) begin
                                next_grid[y][x] <= (live_neighbors == 2 || live_neighbors == 3) ? 1'b1 : 1'b0;
                            end else begin
                                next_grid[y][x] <= (live_neighbors == 3) ? 1'b1 : 1'b0;
                            end
                        end
                    end
                end
            end
        end
    endgenerate

endmodule