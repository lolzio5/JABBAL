#include <iostream>
#include <vector>
#include <thread>
#include <chrono>


void clearScreen() {
    system("clear");

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


}

int main() {
    const int WIDTH = 80;
    const int HEIGHT = 40;

    std::vector<std::vector<int> > grid(HEIGHT, std::vector<int>(WIDTH, 0));

    
    initializeGrid(grid);

    while (true) {
        clearScreen();
        printGrid(grid);
        updateGrid(grid);
        //std::this_thread::sleep_for(std::chrono::milliseconds(200));
    }

    return 0;
}