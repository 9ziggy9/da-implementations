import curses
import threading

def is_printable(c):
    return 32 <= c <= 126

def get_user_input(stdscr, input_win, output_win, mutex):
    # Disable echoing of input
    curses.noecho()

    # Don't wait for a character
    stdscr.nodelay(True)

    user_input = ""
    while True:
        c = stdscr.getch()

        # If the user pressed the escape key, exit the program
        if c == 27:
            break

        # If the user pressed return, add the input to the screen
        if c == 10:
            mutex.acquire()
            output_win.addstr(0, 0, user_input + "\n")
            output_win.refresh()
            mutex.release()
            user_input = ""

        # Add the character to the input string if it's a printable ASCII character
        if is_printable(c):
            user_input += chr(c)

        # Return the input to be processed by the main function
        yield user_input

def update_input_window(input_win, user_input, mutex):
    mutex.acquire()
    input_win.clear()
    input_win.addstr(0, 0, user_input)
    input_win.refresh()
    mutex.release()

def main(stdscr):
    # Clear the screen
    stdscr.clear()

    # Create a new window at the bottom of the screen for input
    input_win = curses.newwin(1, curses.COLS, curses.LINES - 1, 0)

    # Create a new window at the top of the screen for output
    output_win = curses.newwin(curses.LINES - 2, curses.COLS, 0, 0)

    # Create a mutex to lock the screen updates
    mutex = threading.Lock()

    # Wait for a character
    for user_input in get_user_input(stdscr, input_win, output_win, mutex):
        update_input_window(input_win, user_input, mutex)

if __name__ == "__main__":
    curses.wrapper(main)
