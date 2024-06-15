#include <iostream>
#include <vector>
#include <thread>
#include <chrono>


void clearScreen() {
    //system("clear");
    system("cls");

}


void printGrid(const std::vector<std::vector<int> >& grid) {
    for (int i = 0; i < grid.size(); ++i) {
        for (int j = 0; j < grid[0].size(); ++j) {
            if(grid[i][j] == 1){
                std::cout<<"X";
            } else {
                std::cout<<".";
            }
        }
        std::cout << std::endl;
    }
}


int countLiveNeighbors(const std::vector<std::vector<int> >& grid, int x, int y) {
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


void updateGrid(std::vector<std::vector<int> >& grid) {
    std::vector<std::vector<int> > newGrid = grid;
    int rows = grid.size();
    int cols = grid[0].size();

    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            int liveNeighbors = countLiveNeighbors(grid, i, j);

            if (grid[i][j] == 1) {
                // Cell is alive
                if (liveNeighbors < 2 || liveNeighbors > 3) {
                    newGrid[i][j] = 0; // Cell dies
                }
            } else {
                // Cell is dead
                if (liveNeighbors == 3) {
                    newGrid[i][j] = 1; // Cell becomes alive
                }
            }
        }
    }

    grid = newGrid;
}


void initializeGrid(std::vector<std::vector<int> >& grid) {
    
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

bool isGridEmpty(const std::vector<std::vector<int> >& grid) {
    for (const auto& row : grid) {
        for (int cell : row) {
            if (cell == 1) {
                return false;
            }
        }
    }
    return true;
}

int main() {
    const int WIDTH = 190;
    const int HEIGHT = 60;

    std::vector<std::vector<int> > grid(HEIGHT, std::vector<int>(WIDTH, 0));

    
    initializeGrid(grid);

    auto start = std::chrono::high_resolution_clock::now(); 

    while (true) {
        clearScreen();
        printGrid(grid);
        updateGrid(grid);

      if (isGridEmpty(grid)) {
            auto end = std::chrono::high_resolution_clock::now();
            std::chrono::duration<double> elapsed = end - start;
            std::cout << "Grid became empty in " << elapsed.count() << " seconds." << std::endl;
            break;
        }

        //std::this_thread::sleep_for(std::chrono::milliseconds(200));
    }

    return 0;
}