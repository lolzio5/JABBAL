#include <iostream>
#include <vector>
#include <thread>
#include <chrono>
#include <mutex>
#include <condition_variable>

const int WIDTH = 190;
const int HEIGHT = 60;
unsigned int NUM_THREADS = std::thread::hardware_concurrency();
bool gridEmpty = false;

std::mutex mtx;
std::condition_variable cv;

void clearScreen() {
    system("clear");
}

void printGrid(const std::vector<std::vector<int>>& grid) {
    for (const auto& row : grid) {
        for (const auto& cell : row) {
            std::cout << (cell ? "X" : ".");
        }
        std::cout << std::endl;
    }
}

int countLiveNeighbors(const std::vector<std::vector<int>>& grid, int x, int y) {
    int liveNeighbors = 0;
    int rows = grid.size();
    int cols = grid[0].size();
    for (int i = -1; i <= 1; ++i) {
        for (int j = -1; j <= 1; ++j) {
            if (i == 0 && j == 0) continue;
            int nx = x + i, ny = y + j;
            if (nx >= 0 && nx < rows && ny >= 0 && ny < cols) {
                liveNeighbors += grid[nx][ny];
            }
        }
    }
    return liveNeighbors;
}

void updateGridPart(const std::vector<std::vector<int>>& grid, std::vector<std::vector<int>>& newGrid, int startRow, int endRow) {
    int rows = grid.size();
    int cols = grid[0].size();
    for (int i = startRow; i < endRow; ++i) {
        for (int j = 0; j < cols; ++j) {
            int liveNeighbors = countLiveNeighbors(grid, i, j);
            if (grid[i][j] == 1) {
                if (liveNeighbors < 2 || liveNeighbors > 3) {
                    newGrid[i][j] = 0;
                }
            } else {
                if (liveNeighbors == 3) {
                    newGrid[i][j] = 1;
                }
            }
        }
    }
}

void updateGridParallel(std::vector<std::vector<int>>& grid) {
    std::vector<std::vector<int>> newGrid = grid;
    std::vector<std::thread> threads;
    int rowsPerThread = HEIGHT / NUM_THREADS;
    for (int i = 0; i < NUM_THREADS; ++i) {
        int startRow = i * rowsPerThread;
        int endRow = (i == NUM_THREADS - 1) ? HEIGHT : (i + 1) * rowsPerThread;
        threads.emplace_back(updateGridPart, std::cref(grid), std::ref(newGrid), startRow, endRow);
    }
    for (auto& thread : threads) {
        thread.join();
    }
    grid = newGrid;
}

void initializeGrid(std::vector<std::vector<int>>& grid) {
    // Multiple gliders across the grid
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

bool isGridEmpty(const std::vector<std::vector<int>>& grid) {
    for (const auto& row : grid) {
        for (const auto& cell : row) {
            if (cell == 1) return false;
        }
    }
    return true;
}

int main() {
    std::vector<std::vector<int>> grid(HEIGHT, std::vector<int>(WIDTH, 0));
    initializeGrid(grid);

    auto start = std::chrono::high_resolution_clock::now();

    while (true) {
        {
            std::lock_guard<std::mutex> lock(mtx);
            if (gridEmpty) break;
            clearScreen();
            printGrid(grid);
            updateGridParallel(grid);
            gridEmpty = isGridEmpty(grid);
        }
        cv.notify_all();
        //std::this_thread::sleep_for(std::chrono::milliseconds(200));
    }

    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> duration = end - start;
    std::cout << "Time taken: " << duration.count() << " seconds" << std::endl;

    return 0;
}
