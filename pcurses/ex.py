import curses
import sys

def event(output_win, input_win, input_str):
    output_win.refresh()
    input_win.refresh()

    # Get user input
    char = input_win.getch()
    if char == 27:  # Escape key
        sys.exit(0)
    elif char == 10:  # Enter key
        # Calculate the correct position for the new line
        y, x = output_win.getyx()
        output_win.addstr(y + 1 if y == 0 else y, 1, input_str + "\n")
        input_str = ""  # Clear input buffer
        input_win.clear()
        input_win.box()
        input_win.addstr(1, 1, "")  # reset cursor
    elif char == curses.KEY_BACKSPACE or char == 127:
        input_str = input_str[:-1]
        input_win.clear()
        input_win.box()
        input_win.addstr(1, 1, input_str)
    else:
        # Append character to input_str and display
        input_str += chr(char)
        input_win.addstr(1, 1, input_str)

    event(output_win, input_win, input_str) # recursive call


def main(stdscr):
    # Initialize curses
    curses.curs_set(1)  # Make cursor visible
    stdscr.nodelay(0)  # Make getch() wait for user input
    stdscr.clear()  # Clear the screen

    # Calculate window sizes
    max_y, max_x = stdscr.getmaxyx()
    input_height = 3
    output_height = max_y - input_height

    # Create windows
    output_win = curses.newwin(output_height, max_x, 0, 0)
    input_win = curses.newwin(input_height, max_x, output_height, 0)
    input_win.box()
    input_win.addstr(1, 1, "")  # Initialize cursor position

    # Configure scrolling
    output_win.scrollok(True)
    output_win.idlok(1)
    output_win.box()

    # Initialize input buffer
    input_str = ""

    event(output_win, input_win, input_str)

if __name__ == "__main__":
  curses.wrapper(main)
