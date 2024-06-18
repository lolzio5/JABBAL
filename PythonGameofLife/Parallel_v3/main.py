import os
import time
from concurrent.futures import ThreadPoolExecutor
from itertools import product
import math

# Constants for the grid dimensions and number of threads
WIDTH = 20
HEIGHT = 20
NUM_THREADS = os.cpu_count()  # Use the number of available CPU cores
print(NUM_THREADS)
grid_empty = False

# Function to clear the console screen
def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

# Function to print the grid to the console
def print_grid(grid):
    for row in grid:
        print(''.join(" ♥ " if cell else " ‧ " for cell in row))

# Function to count the number of live neighbors around a specific cell (x, y)
def count_live_neighbors(grid, x, y):
    neighbors = [(-1, -1), (-1, 0), (-1, 1),
                 (0, -1),          (0, 1),
                 (1, -1), (1, 0), (1, 1)]
    live_neighbors = sum(grid[x + dx][y + dy]
                         for dx, dy in neighbors
                         if 0 <= x + dx < HEIGHT and 0 <= y + dy < WIDTH)
    return live_neighbors

# Function to update a portion of the grid
def update_grid_part(grid, new_grid, start_row, end_row, start_col, end_col):
    for i, j in product(range(start_row, end_row), range(start_col, end_col)):
        live_neighbors = count_live_neighbors(grid, i, j)
        if grid[i][j] == 1:
            new_grid[i][j] = 1 if 2 <= live_neighbors <= 3 else 0
        else:
            new_grid[i][j] = 1 if live_neighbors == 3 else 0

# Function to update the entire grid in parallel
def update_grid_parallel(grid):
    new_grid = [row[:] for row in grid]  # Create a copy of the grid
    num_squares = math.ceil(math.isqrt(NUM_THREADS))  # Calculate the number of squares
    rows_per_square = math.ceil(HEIGHT / num_squares)  # Rows per square
    cols_per_square = math.ceil(WIDTH / num_squares)   # Columns per square
    with ThreadPoolExecutor(max_workers=NUM_THREADS) as executor:
        futures = []
        for i in range(num_squares):
            for j in range(num_squares):
                start_row = i * rows_per_square
                end_row = min((i + 1) * rows_per_square, HEIGHT)
                start_col = j * cols_per_square
                end_col = min((j + 1) * cols_per_square, WIDTH)
                futures.append(executor.submit(update_grid_part, grid, new_grid, start_row, end_row, start_col, end_col))
        for future in futures:
            future.result()  # Wait for all threads to complete
    return new_grid

# Function to initialize the grid with some live cells
def initialize_grid(grid):
    alive_cells = [
        [10, 10], [10, 16], [11, 12], [11, 16],
        [12, 12], [12, 15], [12, 17], [13, 11], [13, 13]
    ]
    for x, y in alive_cells:
        grid[x][y] = 1

# Function to check if the grid is completely empty
def is_grid_empty(grid):
    return all(cell == 0 for row in grid for cell in row)

# Main function to run the simulation
def main():
    grid = [[0] * WIDTH for _ in range(HEIGHT)]  # Initialize the grid with all dead cells
    initialize_grid(grid)  # Set some cells to be alive
    gen = 100  # Number of generations to simulate
    for i in range(gen):
        global grid_empty
        if grid_empty:
            break
        clear_screen()  # Clear the console screen
        print_grid(grid)  # Print the current state of the grid
        grid = update_grid_parallel(grid)  # Update the grid to the next state
        grid_empty = is_grid_empty(grid)  # Check if the grid is empty
        time.sleep(0.2)  # Pause for a short time

# Run the main function if the script is executed
if __name__ == "__main__":
    main()
