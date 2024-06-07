import os
import time
from concurrent.futures import ThreadPoolExecutor
from itertools import product
import math

WIDTH = 1200
HEIGHT = 1920
NUM_THREADS = os.cpu_count()
#print(NUM_THREADS)
#grid_empty = False

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

def update_grid_part(grid, new_grid, start_row, end_row, start_col, end_col):
    for i, j in product(range(start_row, end_row), range(start_col, end_col)):
        live_neighbors = count_live_neighbors(grid, i, j)
        if grid[i][j] == 1:
            new_grid[i][j] = 1 if 2 <= live_neighbors <= 3 else 0
        else:
            new_grid[i][j] = 1 if live_neighbors == 3 else 0

def update_grid_parallel(grid):
    new_grid = [row[:] for row in grid]
    num_squares = math.ceil(math.isqrt(NUM_THREADS))
    rows_per_square = math.ceil(HEIGHT / num_squares)
    cols_per_square = math.ceil(WIDTH / num_squares)
    with ThreadPoolExecutor(max_workers=NUM_THREADS) as executor:
        futures=[]
        for i in range(num_squares):
            for j in range(num_squares):
                start_row = i * rows_per_square
                end_row = min((i + 1) * rows_per_square, HEIGHT)
                start_col = j * cols_per_square
                end_col = min((j + 1) * cols_per_square, WIDTH)
                futures.append(executor.submit(update_grid_part, grid, new_grid, start_row, end_row, start_col, end_col))
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
    start=time.time()
    grid = [[0] * WIDTH for _ in range(HEIGHT)]
    initialize_grid(grid)
    gen=10
    for i in range(gen):
        #global grid_empty
        #if grid_empty:
            #break
        #clear_screen()
        #print_grid(grid)
        grid = update_grid_parallel(grid)
        #grid_empty = is_grid_empty(grid)
        #time.sleep(0.2)
    end=time.time()
    print(f"Time per iteration: {(end-start)/10}. Time to 1000={(end-start)*100}")

if __name__ == "__main__":
    main()