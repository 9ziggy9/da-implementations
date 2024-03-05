import curses
import sys

# Stores application state.
class Session:
    def __init__(self):
        self.MODE_INPUT  = 0 # No enums, so doing this
        self.MODE_OUTPUT = 1
        self.mode        = self.MODE_INPUT
        self.entries     = []
        self.line        = 0
        self.input       = ""

    def __del__(self):
        print("Destructor called.")
        print("TODO: Backup/save mechanism.")


def render_output_highlights(session, output_win):
    output_win.clear()
    output_win.box()
    for y, entry in enumerate(session.entries):
        attr = curses.A_REVERSE if y == session.line else curses.A_NORMAL
        output_win.addstr(y + 1, 1, entry, attr)

def handle_input_mode(char, session, input_win, output_win):
    if char == 27:  # Escape key
        sys.exit(0)
    elif char == curses.KEY_UP:
        session.mode = session.MODE_OUTPUT
        render_output_highlights(session, output_win)
    elif char == 10:  # Enter key
        # Calculate the correct position for the new line
        y, x = output_win.getyx()
        session.entries.append(session.input)
        output_win.addstr(y + 1 if y == 0 else y, 1, session.input + "\n")
        session.input = ""  # Clear input buffer
        input_win.clear()
        input_win.box()
        input_win.addstr(1, 1, "")  # reset cursor
    elif char == curses.KEY_BACKSPACE or char == 127:
        session.input = session.input[:-1]
        input_win.clear()
        input_win.box()
        input_win.addstr(1, 1, session.input)
    else:
        session.input += chr(char)
        input_win.addstr(1, 1, session.input)

def handle_output_mode(char, session, output_win):
    if char == 9: # Tab
        session.mode = session.MODE_INPUT
    elif char == curses.KEY_UP and session.line > 0:
        session.line -= 1
    elif char == curses.KEY_DOWN:
        session.line += 1
    render_output_highlights(session, output_win)

def event(output_win, input_win, session):
    output_win.refresh()
    input_win.refresh()

    # Get user input
    char = input_win.getch()

    if session.mode == session.MODE_INPUT:
        handle_input_mode(char, session, input_win, output_win)
    elif session.mode == session.MODE_OUTPUT:
        handle_output_mode(char, session, output_win)

    event(output_win, input_win, session) # recursive call


def main(stdscr):
    session = Session()
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
    input_win.keypad(1)

    # Configure scrolling
    output_win.scrollok(True)
    output_win.idlok(1)
    output_win.box()
    output_win.keypad(1)

    event(output_win, input_win, session)

if __name__ == "__main__":
  curses.wrapper(main)
