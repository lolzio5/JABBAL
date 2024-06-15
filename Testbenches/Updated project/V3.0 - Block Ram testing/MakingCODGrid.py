# Open the COE file to write
with open("memory_initialization.coe", "w") as f:
    # Write the radix
    f.write("; This is a COE file for initializing a 2048 x 2048 BRAM\n")
    f.write("memory_initialization_radix = 2;\n")
    f.write("memory_initialization_vector =\n")
    
    # Initialize the grid data
    for i in range(2048):    
        line = ""
        for j in range(2048):
            # Example pattern: alternating black and white
            if (i + j) % 2 == 0:
                line += "1"  # Black
            else:
                line += "0"  # White

        if i == 2047:
            f.write(line + ";\n")
        else:
            f.write(line + ",\n")

print("COE file generated successfully.")
