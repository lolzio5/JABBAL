import os
import time
from concurrent.futures import ThreadPoolExecutor
from itertools import product

WIDTH = 1920
HEIGHT = 1200
NUM_THREADS = os.cpu_count()
grid_empty = False

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def print_grid(grid):
    for row in grid:
        print(''.join(" ♥ " if cell else " ‧ " for cell in row))

def count_live_neighbors(grid, x, y):
    neighbors = [(-1, -1), (-1, 0), (-1, 1),
                 (0, -1),          (0, 1),
                 (1, -1), (1, 0), (1, 1)]
    live_neighbors = sum(grid[x + dx][y + dy]
                         for dx, dy in neighbors
                         if 0 <= x + dx < HEIGHT and 0 <= y + dy < WIDTH)
    return live_neighbors

def update_grid_part(grid, new_grid, start_row, end_row):
    for i, j in product(range(start_row, end_row), range(WIDTH)):
        live_neighbors = count_live_neighbors(grid, i, j)
        if grid[i][j] == 1:
            new_grid[i][j] = 1 if 2 <= live_neighbors <= 3 else 0
        else:
            new_grid[i][j] = 1 if live_neighbors == 3 else 0

def update_grid_parallel(grid):
    new_grid = [row[:] for row in grid]
    with ThreadPoolExecutor(max_workers=NUM_THREADS) as executor:
        rows_per_thread = HEIGHT // NUM_THREADS
        futures = [executor.submit(update_grid_part, grid, new_grid,
                                   i * rows_per_thread,
                                   (i + 1) * rows_per_thread if i != NUM_THREADS - 1 else HEIGHT)
                   for i in range(NUM_THREADS)]
        for future in futures:
            future.result()
    return new_grid

def initialize_grid(grid):
    # Bunnies
    alive_cells = [
    [10, 10],
    [10, 16],
    [11, 12],
    [11, 16],
    [12, 12],
    [12, 15],
    [12, 17],
    [13, 11],
    [13, 13]
]
    for x, y in alive_cells:
        grid[x][y] = 1

def is_grid_empty(grid):
    return all(cell == 0 for row in grid for cell in row)

def main():
    grid = [[0] * WIDTH for _ in range(HEIGHT)]
    initialize_grid(grid)
    gen=5
    for i in range(gen):
        global grid_empty
        if grid_empty:
            break
        #clear_screen()
        #print_grid(grid)
        old=time.time()
        grid = update_grid_parallel(grid)
        grid_empty = is_grid_empty(grid)
        #time.sleep(0.2)
        new=time.time()
        print(f"Time per gen is {new-old}")

if __name__ == "__main__":
    main()