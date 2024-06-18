import asyncio

class LifeGrid:
    def __init__(self, pattern):
        """
        Initialize the LifeGrid with a given pattern.
        """
        self.pattern = pattern

    async def thread(self, row, col):
        """
        Determine the next state of a cell at (row, col) based on its neighbors.
        """
        neighbors = (
            (-1, -1),  # Above left
            (-1, 0),   # Above
            (-1, 1),   # Above right
            (0, -1),   # Left
            (0, 1),    # Right
            (1, -1),   # Below left
            (1, 0),    # Below
            (1, 1),    # Below right
        )
        alive_count = 0
        for drow, dcol in neighbors:
            if (row + drow, col + dcol) in self.pattern.alive_cells:
                alive_count += 1
        if ((alive_count == 2) and ((row, col) in self.pattern.alive_cells)):
            return 1
        elif alive_count == 3:
            return 1
        else:
            return 0

    async def evolve(self, bbox):
        """
        Evolve the grid within the bounding box (bbox) to the next generation.
        """
        start_col, start_row, end_col, end_row = bbox
        tasks = []
        for row in range(start_row, end_row):
            for col in range(start_col, end_col):
                tasks.append(self.thread(row, col))
        results = await asyncio.gather(*tasks)
        new_alive_cells = set()
        index = 0
        for row in range(start_row, end_row):
            for col in range(start_col, end_col):
                if results[index]:
                    new_alive_cells.add((row, col))
                index += 1
        self.pattern.alive_cells = new_alive_cells

    def as_string(self, bbox):
        """
        Return a string representation of the grid within the bounding box (bbox).
        """
        start_col, start_row, end_col, end_row = bbox
        display = []
        # Center the grid display
        display.append(self.pattern.name.center(2 * (end_col - start_col)))
        for row in range(start_row, end_row):
            display_row = []
            for col in range(start_col, end_col):
                if (row, col) in self.pattern.alive_cells:
                    display_row.append("♥")  # Alive cell
                else:
                    display_row.append("‧")  # Dead cell
            display.append(" ".join(display_row))
        return "\n ".join(display)

    def __str__(self):
        """
        Return a string representation of the pattern and its alive cells.
        """
        return (
            f"{self.pattern.name}:\n"
            f"Alive cells -> {sorted(self.pattern.alive_cells)}"
        )
