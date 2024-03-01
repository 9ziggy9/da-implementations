import sys
import os

def assert_file_requirements(filename):
    if not os.path.isfile(filename):
        print(f'Error: The file {filename} does not exist.')
        sys.exit(1)
    if not os.access(filename, os.R_OK):
        print(f'Error: You do not have read access to the file {filename}.')
        sys.exit(1)
    if not os.access(filename, os.W_OK):
        print(f'Error: You do not have write access to the file {filename}.')
        sys.exit(1)

def seek_and_overwrite(file, content):
    file.seek(0)  # Move the file pointer to the beginning of the file
    file.truncate()  # Remove all the content in the file
    file.write(content)  # Write the new content

def main():
    assert_file_requirements('data.txt')

    with open('data.txt', 'r+') as file:
        # Use a list comprehension to read lines and strip any leading/trailing whitespace
        lines = [line.strip() for line in file.readlines()]

        # Print the lines
        for line in lines:
            print(line)

        # Ask for user input
        user_input = input("Please enter the content you want to write to the file: ")

        # Truncate the file and overwrite with user input
        seek_and_overwrite(file, user_input)

if __name__ == '__main__':
    main()
