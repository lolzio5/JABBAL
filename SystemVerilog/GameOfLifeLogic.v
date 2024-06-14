module GameOfLifeLogic #(parameter WIDTH = 640, HEIGHT = 480, NUM_THREADS = 4) ( //NUM_THREADS should be set to appropriate value
    input logic clk,
    input logic reset,
    input logic get_next
);
    // Signals for RAM access
    reg ena, enb;
    reg wea, web;
    reg [10:0] addra, addrb;
    reg [15:0] dia, dib;
    wire [15:0] doa, dob;  // Outputs from ram_block

    // Instantiate ram_block module
    ram_block ram_instance (
        .clka(clk),     // Connect clka of ram_block to clk_a in top_module
        .clkb(clk),     // Connect clkb of ram_block to clk_b in top_module
        .ena(ena),        // Connect ena of ram_block to ena in top_module
        .enb(enb),        // Connect enb of ram_block to enb in top_module
        .wea(wea),        // Connect wea of ram_block to wea in top_module
        .web(web),        // Connect web of ram_block to web in top_module
        .addra(addra),    // Connect addra of ram_block to addra in top_module
        .addrb(addrb),    // Connect addrb of ram_block to addrb in top_module
        .dia(dia),        // Connect dia of ram_block to dia in top_module
        .dib(dib),        // Connect dib of ram_block to dib in top_module
        .doa(doa),        // Connect doa of ram_block to doa in top_module
        .dob(dob)         // Connect dob of ram_block to dob in top_module
    );

    // Function to count live neighbors
    function integer count_live_neighbors;
        input reg [2:0][2:0] neighbors;
        integer live_neighbors, dx, dy;
        begin
            live_neighbors = 0;
            for (dx = 0; dx < 3; dx = dx + 1) begin
                for (dy = 0; dy < 3; dy = dy + 1) begin
                    if (!(dx == 1 && dy == 1)) begin
                        live_neighbors = live_neighbors + neighbors[dy][dx];
                    end
                end
            end
            count_live_neighbors = live_neighbors;
        end
    endfunction

    
    genvar i, j;
    localparam ROWS_PER_THREAD = (HEIGHT + NUM_THREADS - 1) / NUM_THREADS;
    localparam COLS_PER_THREAD = (WIDTH + NUM_THREADS - 1) / NUM_THREADS;

    generate
        for (i = 0; i < NUM_SQUARES; i++) begin : row_threads
            for (j = 0; j < NUM_SQUARES; j++) begin : col_threads
                always_ff @(posedge clk or posedge reset) begin
                    if(get_next) begin
                        int x, y;
                        int live_neighbors;
                        for (y = i * ROWS_PER_THREAD; y < (i + 1) * ROWS_PER_THREAD && y < HEIGHT; y++) begin
                            for (x = j * COLS_PER_THREAD; x < (j + 1) * COLS_PER_THREAD && x < WIDTH; x++) begin
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

endmodule