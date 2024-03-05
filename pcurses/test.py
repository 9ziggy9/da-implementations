import curses
import sys

# Stores application state.
class Session:
    def __init__(self):
        self.MODE_INPUT  = 0 # No enums, so doing this
        self.MODE_OUTPUT = 1
        self.mode    = self.MODE_INPUT
        self.entries = []
        self.line    = None

    def __del__(self):
        print("Destructor called.")
        print("TODO: Backup/save mechanism.")

def event(output_win, input_win, input_str, session):  # Add session to parameters
    while True:  # Use a loop instead of recursion
      output_win.refresh()
      input_win.refresh()

      char = input_win.getch()

      if session.mode == session.MODE_INPUT:
          if char == 27:  # Escape key
              sys.exit(0)
          elif char == 10:  # Enter key
              # Calculate the correct position for the new line
              y, x = output_win.getyx()
              output_win.addstr(y + 1 if y == 0 else y, 1, input_str + "\n")
              session.entries.append(input_str)
              input_str = ""  # Clear input buffer
              input_win.clear()
              input_win.box()
              input_win.addstr(1, 1, "")  # reset cursor
          elif char == curses.KEY_BACKSPACE or char == 127:
              input_str = input_str[:-1]
              input_win.clear()
              input_win.box()
              input_win.addstr(1, 1, input_str)
          elif char == 9:
              session.mode = session.MODE_OUTPUT
              session.line = 0
          else:
              # Append character to input_str and display
              input_str += chr(char)
              input_win.addstr(1, 1, input_str)

      elif session.mode == session.MODE_OUTPUT:
          if char == curses.KEY_UP:
              if session.line > 0:  # Ensure we don't go below 0
                  session.line -= 1
          elif char == curses.KEY_DOWN:
              max_y, _ = output_win.getmaxyx()
              if session.line < max_y - 2:  # Adjust for the box and 0-index
                  session.line += 1
          elif char == 9:  # Tab
              session.mode = session.MODE_INPUT
              session.line = None  # Clear line selection

          # Rendering the selection
          output_win.erase()  # Clear the previous content
          output_win.box()   

          y = 0
          for entry in session.entries:
              attr = curses.A_REVERSE if y == session.line else curses.A_NORMAL
              output_win.addstr(y, 1, entry, attr)
              y += 1


def main(stdscr):
    s = Session()
    # ... (Your existing code for initializing curses, windows, etc)

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

    event(output_win, input_win, input_str, s)    # Pass session here

if __name__ == "__main__":
  curses.wrapper(main)
