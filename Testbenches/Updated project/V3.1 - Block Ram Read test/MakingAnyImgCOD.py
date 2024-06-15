from PIL import Image

# Load the image
image_path = r'C:\summer_project2024\JABBAL\Testbenches\Updated project\V3.1 - Block Ram Read test\cover.png'
img = Image.open(image_path)

# Convert to grayscale
gray_img = img.convert('L')

# Convert to binary (black and white)
bw_img = gray_img.point(lambda x: 0 if x < 128 else 1, '1')

# Resize to 1280x720
bw_img = bw_img.resize((1280, 720), Image.LANCZOS)

# Get pixel data
pixels = list(bw_img.getdata())
width, height = bw_img.size

# Open the COE file to write
with open(r"C:\summer_project2024\JABBAL\Testbenches\Updated project\V3.1 - Block Ram Read test\cover.coe", "w") as f:
    # Write the radix
    f.write("; This is a COE file for initializing a 1920 x 1080 BRAM\n")
    f.write("memory_initialization_radix = 2;\n")
    f.write("memory_initialization_vector =\n")


    for y in range(height):
        line = ""
        for x in range(width):
            pixel = pixels[y * width + x]
            line += '1' if pixel == 0 else '0'
        if x == 1280:
            print(line)
            f.write(line + ";\n")
        else:
            print(line)
            f.write(line + ",\n")

print("COE file generated successfully.")

