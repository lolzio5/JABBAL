module GameOfLifeLogic #(parameter WIDTH = 640, HEIGHT = 480, NUM_THREADS = 4) (
    input logic clk,          // Clock signal
    input logic reset,        // Reset signal
    input logic get_next      // Signal to get the next state
);
    // Signals for RAM access
    reg ena, enb;             // Enable signals for the RAM
    reg wea, web;             // Write enable signals for the RAM
    reg [10:0] addra, addrb;  // Address lines for the RAM
    reg [15:0] dia, dib;      // Data input lines for the RAM
    wire [15:0] doa, dob;     // Data output lines from the RAM

    // Instantiate the RAM block module
    ram_block ram_instance (
        .clka(clk),     // Connect clock A to the top module clock
        .clkb(clk),     // Connect clock B to the top module clock
        .ena(ena),      // Connect enable A to the top module enable A
        .enb(enb),      // Connect enable B to the top module enable B
        .wea(wea),      // Connect write enable A to the top module write enable A
        .web(web),      // Connect write enable B to the top module write enable B
        .addra(addra),  // Connect address A to the top module address A
        .addrb(addrb),  // Connect address B to the top module address B
        .dia(dia),      // Connect data input A to the top module data input A
        .dib(dib),      // Connect data input B to the top module data input B
        .doa(doa),      // Connect data output A to the top module data output A
        .dob(dob)       // Connect data output B to the top module data output B
    );

    // Function to count live neighbors
    function integer count_live_neighbors;
        input reg [2:0][2:0] neighbors;  // 3x3 grid of neighboring cells
        integer live_neighbors, dx, dy;  // Counters and indices
        begin
            live_neighbors = 0;
            // Loop through the 3x3 grid
            for (dx = 0; dx < 3; dx = dx + 1) begin
                for (dy = 0; dy < 3; dy = dy + 1) begin
                    // Skip the center cell
                    if (!(dx == 1 && dy == 1)) begin
                        live_neighbors = live_neighbors + neighbors[dy][dx];
                    end
                end
            end
            count_live_neighbors = live_neighbors;  // Return the count of live neighbors
        end
    endfunction

    genvar i, j;
    // Calculate the number of rows and columns each thread will process
    localparam ROWS_PER_THREAD = (HEIGHT + NUM_THREADS - 1) / NUM_THREADS;
    localparam COLS_PER_THREAD = (WIDTH + NUM_THREADS - 1) / NUM_THREADS;

    generate
        // Create a grid of threads to process the grid in parallel
        for (i = 0; i < NUM_SQUARES; i++) begin : row_threads
            for (j = 0; j < NUM_SQUARES; j++) begin : col_threads
                always_ff @(posedge clk or posedge reset) begin
                    if(get_next) begin
                        int x, y;             // Indices for grid traversal
                        int live_neighbors;   // Variable to hold the count of live neighbors
                        // Loop through the grid section assigned to this thread
                        for (y = i * ROWS_PER_THREAD; y < (i + 1) * ROWS_PER_THREAD && y < HEIGHT; y++) begin
                            for (x = j * COLS_PER_THREAD; x < (j + 1) * COLS_PER_THREAD && x < WIDTH; x++) begin
                                live_neighbors = count_live_neighbors(current_grid, x, y); // Count live neighbors
                                if (current_grid[y][x] == 1'b1) begin
                                    // Apply Game of Life rules for live cells
                                    next_grid[y][x] <= (live_neighbors == 2 || live_neighbors == 3) ? 1'b1 : 1'b0;
                                end else begin
                                    // Apply Game of Life rules for dead cells
                                    next_grid[y][x] <= (live_neighbors == 3) ? 1'b1 : 1'b0;
                                end
                            end
                        end
                    end
                end
            end
        end
    endgenerate

endmodule
