// Initial implementation with no parallelisation

module game_of_life #(parameter WIDTH = 80, HEIGHT = 40) ( //Width and Height of grid set to what is desired
    input logic clk,
    input logic reset
);
    // Define the grid
    logic [0:HEIGHT-1][0:WIDTH-1] grid;
    logic [0:HEIGHT-1][0:WIDTH-1] new_grid;

    // Initialize the grid
    initial begin
        integer i, j;
        for (i = 0; i < HEIGHT; i++) begin
            for (j = 0; j < WIDTH; j++) begin
                grid[i][j] = 0;
            end
        end
        // Initial grid pattern
        grid[1][2] = 1;
        grid[2][3] = 1;
        grid[3][1] = 1;
        grid[3][2] = 1;
        grid[3][3] = 1;

        grid[10][11] = 1;
        grid[11][12] = 1;
        grid[12][10] = 1;
        grid[12][11] = 1;
        grid[12][12] = 1;
    end

    // Count live neighbors task
    function int count_live_neighbors(int x, int y);
        int live_neighbors = 0;
        int i, j;
        for (i = -1; i <= 1; i++) begin
            for (j = -1; j <= 1; j++) begin
                if (i != 0 || j != 0) begin
                    int nx = x + i;
                    int ny = y + j;
                    if (nx >= 0 && nx < HEIGHT && ny >= 0 && ny < WIDTH) begin
                        live_neighbors += grid[nx][ny];
                    end
                end
            end
        end
        return live_neighbors;
    endfunction

    // Update the grid on each clock cycle
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            integer i, j;
            for (i = 0; i < HEIGHT; i++) begin
                for (j = 0; j < WIDTH; j++) begin
                    grid[i][j] <= 0;
                end
            end
        end else begin
            integer i, j;
            for (i = 0; i < HEIGHT; i++) begin
                for (j = 0; j < WIDTH; j++) begin
                    int live_neighbors = count_live_neighbors(i, j);
                    if (grid[i][j] == 1) begin
                        if (live_neighbors < 2 || live_neighbors > 3) begin
                            new_grid[i][j] = 0; // Cell dies
                        end else begin
                            new_grid[i][j] = 1; // Cell lives
                        end
                    end else begin
                        if (live_neighbors == 3) begin
                            new_grid[i][j] = 1; // Cell becomes alive
                        end else begin
                            new_grid[i][j] = 0; // Cell stays dead
                        end
                    end
                end
            end
            grid <= new_grid; // Update the grid
        end
    end

    // Display the grid (for simulation purposes)
    always_ff @(posedge clk) begin
        integer i, j;
        for (i = 0; i < HEIGHT; i++) begin
            for (j = 0; j < WIDTH; j++) begin
                if (grid[i][j] == 1) begin
                    $write("X");
                end else begin
                    $write(".");
                end
            end
            $write("\n");
        end
        $write("\n");
    end

endmodule
