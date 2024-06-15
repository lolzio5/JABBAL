# Open the COE file to write
with open(r"C:\summer_project2024\JABBAL\Testbenches\Updated project\V3.1 - Block Ram Read test\memory_initialization.coe", "w") as f:
    # Write the radix
    f.write("; This is a COE file for initializing a 1920 x 1080 BRAM\n")
    f.write("memory_initialization_radix = 2;\n")
    f.write("memory_initialization_vector =\n")
    
    # Initialize the grid data
    for i in range(720):       
        line = ""
        for j in range(1280):
            # Example pattern: alternating black and white
            if (i + j) % 2 == 0:
                line += "1"  # Black
            else:
                line += "0"  # White

        if i == 2047:
            print(line)
            f.write(line + ";\n")
        else:
            print(line)
            f.write(line + ",\n")

print("COE file generated successfully.")
