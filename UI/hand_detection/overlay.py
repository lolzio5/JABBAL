# Define ANSI color codes
colors = {
    5: '\033[93m',  # Red
    6: '\033[93m',  # Green
    7: '\033[93m',  # Yellow
    8: '\033[93m',  # Blue
    9: '\033[93m'   # Magenta
}

colors2 = {
    5: '\033[92m',  # Red
    6: '\033[92m',  # Green
    7: '\033[92m',  # Yellow
    8: '\033[92m',  # Blue
    9: '\033[92m'   # Magenta
}

# Reset color
reset = '\033[0m'

# Print statements with colors
for i in range(10, 25):
    print(f"number of cycles: {colors[5]}{i}{reset}", f"number of threads using: {colors2[5]}{10}{reset}")