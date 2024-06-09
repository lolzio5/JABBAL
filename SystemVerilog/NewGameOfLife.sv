module GameOfLife #(parameter WIDTH = 1200, HEIGHT = 1920, NUM_THREADS = 4) ( //NUM_THREADS should be set to appropriate value
    input logic clk,
    input logic reset,
    output logic [HEIGHT-1:0][WIDTH-1:0] grid
);

    // Internal grid storage
    logic [HEIGHT-1:0][WIDTH-1:0] current_grid, next_grid;
    logic [HEIGHT-1:0][WIDTH-1:0] init_grid;

 
    initial begin
        int x, y;
        for (y = 0; y < HEIGHT; y++) begin
            for (x = 0; x < WIDTH; x++) begin
                current_grid[y][x] = 1'b0;
            end
        end
  
        init_grid[10][10] = 1'b1;
        init_grid[10][16] = 1'b1;
        init_grid[11][12] = 1'b1;
        init_grid[11][16] = 1'b1;
        init_grid[12][12] = 1'b1;
        init_grid[12][15] = 1'b1;
        init_grid[12][17] = 1'b1;
        init_grid[13][11] = 1'b1;
        init_grid[13][13] = 1'b1;
    end

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
    localparam int NUM_SQUARES = NUM_THREADS;
    localparam int ROWS_PER_SQUARE = (HEIGHT + NUM_SQUARES - 1) / NUM_SQUARES; 
    localparam int COLS_PER_SQUARE = (WIDTH + NUM_SQUARES - 1) / NUM_SQUARES; 

    generate
        for (i = 0; i < NUM_SQUARES; i++) begin : row_threads
            for (j = 0; j < NUM_SQUARES; j++) begin : col_threads
                always_ff @(posedge clk or posedge reset) begin
                    if (reset) begin
                        int x, y;
                        for (y = 0; y < HEIGHT; y++) begin
                            for (x = 0; x < WIDTH; x++) begin
                                current_grid[y][x] <= init_grid[y][x];
                            end
                        end
                    end else begin
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
        end
    endgenerate

    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            integer x, y;
            for (y = 0; y < HEIGHT; y++) begin
                for (x = 0; x < WIDTH; x++) begin
                    current_grid[y][x] <= init_grid[y][x];
                end
            end
        end else begin
            integer x, y;
            for (y = 0; y < HEIGHT; y++) begin
                for (x = 0; x < WIDTH; x++) begin
                    current_grid[y][x] <= next_grid[y][x];
                end
            end
        end
    end

    // Output the current grid
    assign grid = current_grid;

endmodule
