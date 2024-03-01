"""
The following curses application in python attempts to read user input from stdin, displays it in an input window, then flushes and outputs to a main window when user hits return. Unfortunately, at the current time, upon first provision of data, the screen no longer shows input in the input window and begins to blit uncontrollably.

I believe this behavior to be due to a lack of concurrency in the implementation of curses. What's more, a threaded solution could lead to inconsistent state due to sharing of window resources.

I believe a potential solution to this bug would be via the utilization of a mutex to lock a thread when a function is attempting to update a window. Is my intuition here correct? And if so, could you provide an implementation?
"""

import curses

def is_printable(c):
    return 32 <= c <= 126

def get_user_input(stdscr):
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
            stdscr.addstr(0, 0, user_input)
            stdscr.refresh()
            user_input = ""

        # Add the character to the input string if it's a printable ASCII character
        if is_printable(c):
            user_input += chr(c)

        # Return the input to be processed by the main function
        yield user_input

def update_input_window(input_win, user_input):
    # Clear the window
    input_win.clear()

    # Add the user's input to the window
    input_win.addstr(0, 0, user_input)

    # Refresh the window
    input_win.refresh()

def main(stdscr):
    # Clear the screen
    stdscr.clear()

    # Create a new window at the bottom of the screen
    input_win = curses.newwin(1, curses.COLS, curses.LINES - 1, 0)

    # Wait for a character
    for user_input in get_user_input(stdscr):
        update_input_window(input_win, user_input)

if __name__ == "__main__":
    curses.wrapper(main)
