import curses
import threading
import queue
import time

def is_printable(c):
    return 32 <= c <= 126

def get_user_input(stdscr, input_queue, stop_event):
    curses.noecho()
    stdscr.nodelay(False)

    while not stop_event.is_set():
        c = stdscr.getch()

        if c == 27:  # Escape key
            stop_event.set()
            break

        elif c == 10:  # Enter key
            input_queue.put(None)  # Signal to process input

        elif is_printable(c):
            input_queue.put(chr(c))

def update_input_window(input_win, output_win, lock, input_queue, stop_event):
    user_input = ""
    lines = []

    while not stop_event.is_set():
        try:
            char = input_queue.get(timeout=0.1)  # Use a timeout to periodically check the stop_event
        except queue.Empty:
            continue  # No input, loop back and check stop_event again

        if char is None:  # Enter key was pressed, process the input
            with lock:
                lines.append(user_input)
                output_win.clear()
                for i, line in enumerate(lines[-output_win.getmaxyx()[0]:]):  # Show only as many lines as will fit
                    output_win.addstr(i, 0, line)
                output_win.refresh()
            user_input = ""
        else:
            user_input += char

        with lock:
            input_win.clear()
            input_win.addstr(0, 0, user_input)
            input_win.refresh()

def main(stdscr):
    stdscr.clear()

    output_win_height = curses.LINES - 2
    input_win = curses.newwin(1, curses.COLS, curses.LINES - 1, 0)
    output_win = curses.newwin(output_win_height, curses.COLS, 0, 0)

    lock = threading.Lock()
    input_queue = queue.Queue()
    stop_event = threading.Event()

    input_thread = threading.Thread(target=get_user_input, args=(stdscr, input_queue, stop_event), daemon=True)
    ui_thread = threading.Thread(target=update_input_window, args=(input_win, output_win, lock, input_queue, stop_event), daemon=True)

    input_thread.start()
    ui_thread.start()

    while not stop_event.is_set():  # Keep the main thread alive until the stop_event is set
        pass

    # Threads are daemons, so they will exit when the main thread exits

if __name__ == "__main__":
    try:
        curses.wrapper(main)
    except KeyboardInterrupt:
        print("Program exited by user.")
