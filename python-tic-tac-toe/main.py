import curses

def create_grid(stdscr):
    """Creates a 3x3 grid of selectable cells on the console.

    Args:
        stdscr: The curses window object.
    """
    height, width = stdscr.getmaxyx()

    cell_height = min(10, (height - 5) // 3)  
    cell_width = min(10, (width - 5) // 3)  

    grid_y = (height - cell_height * 3) // 2
    grid_x = (width - cell_width * 3) // 2
    selected_y, selected_x = 0, 0

    while True:
        # Draw borders
        for y in range(4):
            stdscr.hline(grid_y + y * cell_height, grid_x, curses.ACS_HLINE, cell_width * 3)
        for x in range(4):
            stdscr.vline(grid_y, grid_x + x * cell_width, curses.ACS_VLINE, cell_height * 3)

        # Clear previous cell content (leave borders)
        for y in range(3):
            for x in range(3):
                stdscr.addstr(grid_y + y * cell_height + 1, grid_x + x * cell_width + 1, " " * (cell_width - 2))

        # Highlight the selected cell
        stdscr.chgat(grid_y + selected_y * cell_height + 1, grid_x + selected_x * cell_width + 1, 
                     cell_width - 2, curses.color_pair(1))

        stdscr.refresh()

        # Handle key presses (same as before)
        key = stdscr.getch()
        if key == curses.KEY_UP and selected_y > 0:
            selected_y -= 1
        elif key == curses.KEY_DOWN and selected_y < 2:
            selected_y += 1
        elif key == curses.KEY_LEFT and selected_x > 0:
            selected_x -= 1
        elif key == curses.KEY_RIGHT and selected_x < 2:
            selected_x += 1
        elif key == ord(' '):  # Spacebar
            stdscr.addstr(grid_y + selected_y, grid_x + selected_x, "X", curses.color_pair(2))
            stdscr.refresh() 
            curses.napms(200)  

if __name__ == "__main__":
    curses.wrapper(create_grid)
