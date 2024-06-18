#include <iostream>
#include <vector>
#include <thread>
#include <chrono>

// Function to clear the console screen
void clearScreen() {
    // system("clear"); // Uncomment this line if you're on a Unix-based system
    system("cls"); // Use this line if you're on a Windows system
}

// Function to print the grid to the console
void printGrid(const std::vector<std::vector<int> >& grid) {
    for (int i = 0; i < grid.size(); ++i) {
        for (int j = 0; j < grid[0].size(); ++j) {
            if (grid[i][j] == 1) {
                std::cout << "X"; // Print 'X' for alive cells
            } else {
                std::cout << "."; // Print '.' for dead cells
            }
        }
        std::cout << std::endl; // Newline at the end of each row
    }
}

// Function to count live neighbors around a specific cell (x, y)
int countLiveNeighbors(const std::vector<std::vector<int> >& grid, int x, int y) {
    int liveNeighbors = 0;
    int rows = grid.size();
    int cols = grid[0].size();

    // Loop through the 3x3 grid surrounding (x, y)
    for (int i = -1; i <= 1; ++i) {
        for (int j = -1; j <= 1; ++j) {
            if (i == 0 && j == 0) continue; // Skip the cell itself
            int nx = x + i, ny = y + j;
            // Check if neighbor is within bounds and count if alive
            if (nx >= 0 && nx < rows && ny >= 0 && ny < cols) {
                liveNeighbors += grid[nx][ny];
            }
        }
    }
    return liveNeighbors;
}

// Function to update the grid based on the Game of Life rules
void updateGrid(std::vector<std::vector<int> >& grid) {
    std::vector<std::vector<int> > newGrid = grid; // Create a copy of the grid
    int rows = grid.size();
    int cols = grid[0].size();

    // Loop through each cell in the grid
    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            int liveNeighbors = countLiveNeighbors(grid, i, j);

            if (grid[i][j] == 1) {
                // Cell is alive
                if (liveNeighbors < 2 || liveNeighbors > 3) {
                    newGrid[i][j] = 0; // Cell dies due to underpopulation or overpopulation
                }
            } else {
                // Cell is dead
                if (liveNeighbors == 3) {
                    newGrid[i][j] = 1; // Cell becomes alive due to reproduction
                }
            }
        }
    }

    grid = newGrid; // Update the grid with the new state
}

// Function to initialize the grid with some predefined patterns
void initializeGrid(std::vector<std::vector<int> >& grid) {
    // Initialize some cells to be alive
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

    grid[20][21] = 1;
    grid[21][22] = 1;
    grid[22][20] = 1;
    grid[22][21] = 1;
    grid[22][22] = 1;

    grid[30][31] = 1;
    grid[31][32] = 1;
    grid[32][30] = 1;
    grid[32][31] = 1;
    grid[32][32] = 1;
}

// Function to check if the grid is completely empty (no live cells)
bool isGridEmpty(const std::vector<std::vector<int> >& grid) {
    for (const auto& row : grid) {
        for (int cell : row) {
            if (cell == 1) {
                return false; // Found a live cell
            }
        }
    }
    return true; // No live cells found
}

int main() {
    const int WIDTH = 190; // Width of the grid
    const int HEIGHT = 60; // Height of the grid

    std::vector<std::vector<int> > grid(HEIGHT, std::vector<int>(WIDTH, 0)); // Initialize grid with all dead cells

    initializeGrid(grid); // Initialize the grid with predefined patterns

    auto start = std::chrono::high_resolution_clock::now(); // Start the timer

    while (true) {
        clearScreen(); // Clear the console screen
        printGrid(grid); // Print the current state of the grid
        updateGrid(grid); // Update the grid to the next state

        if (isGridEmpty(grid)) {
            auto end = std::chrono::high_resolution_clock::now(); // End the timer
            std::chrono::duration<double> elapsed = end - start; // Calculate elapsed time
            std::cout << "Grid became empty in " << elapsed.count() << " seconds." << std::endl;
            break; // Exit the loop if the grid is empty
        }

        // std::this_thread::sleep_for(std::chrono::milliseconds(200)); // Optional: slow down the loop for better visibility
    }

    return 0; // End of the program
}
