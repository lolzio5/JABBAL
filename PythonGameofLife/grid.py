import collections

class LifeGrid:
    def __init__(self, pattern):
        self.pattern = pattern

    def evolve(self):
        # Distance calculation to each neighbor given (0,0)
        neighbors = (
            (-1, -1),  # Above left
            (-1, 0),  # Above
            (-1, 1),  # Above right
            (0, -1),  # Left
            (0, 1),  # Right
            (1, -1),  # Below left
            (1, 0),  # Below
            (1, 1),  # Below right
        )
        # Counts how many of the neighbors are alive
        alive_neighbors = collections.defaultdict(int)
        for row, col in self.pattern.alive_cells:
            for drow, dcol in neighbors:
                alive_neighbors[(row + drow, col + dcol)] += 1
        
        # Checks if there are 2 or 3 alive neighbors for each alive cell
        cells=set()
        for cell, num in alive_neighbors.items():
            if num in {2, 3}:
                cells.add(cell)
        stay_alive = cells & self.pattern.alive_cells

        # Check if a cell should be born
        born_cells=set()
        for cell, num in alive_neighbors.items():
            if num == 3:
                born_cells.add(cell)
        come_alive = born_cells - self.pattern.alive_cells

        self.pattern.alive_cells = stay_alive | come_alive

    def as_string(self, bbox):
        start_col, start_row, end_col, end_row = bbox
        display = []
        # Center the grid display
        display.append(self.pattern.name.center(2 * (end_col - start_col)))
        for row in range(start_row, end_row):
            display_row=[]
            # Iterate over each column index from start_col to end_col - 1
            for col in range(start_col, end_col):
            # Check if the cell at (row, col) is alive
                if (row, col) in self.pattern.alive_cells:
                    # If alive, append Heart to the display_row list
                    display_row.append("♥")
                else:
                    # If not alive, append Dot to the display_row list
                    display_row.append("‧")
            display.append(" ".join(display_row))
        return "\n ".join(display)

    def __str__(self):
        return (
            f"{self.pattern.name}:\n"
            f"Alive cells -> {sorted(self.pattern.alive_cells)}"
        )