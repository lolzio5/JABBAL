import PIL.Image
import numpy

# Retrives rgb values of individual pixels from 3 32-bit words
def extract_pixel(seq):
    pixels = []
    for i in range(0, 4):
        pixels.append( seq[ ( i * 6 ) : ( ( i + 1 ) * 6 ) ] )
        # print("pixel", i, pixels[i]) #TESTING
    return pixels

# Gets the decimal RGB values of a pixel(og in a 24-bit word as 8 hex numbers)
def find_rgb(pixel):
    rgb = []
    for i in range(0, 3):
        hex_val = pixel[ (i * 2) : ( (i + 1) * 2 ) ] 
        val = int(format(int(hex_val, 16), 'd'))   # Converts hex to decimal
        rgb.append(val)
        # print("RGB", i, rgb[i]) #TESTING
    return rgb

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Reading generated pixel values and adding them to the img array
f = open("hex_values.txt")
valid_check = 1
img = []
seq = ""
count = 3

for word in f:
    
    if ("x" not in word) and (valid_check%4 != 0):
        # print( word[0:-1] ) #TESTING
        seq = seq + word[0:-1]
        valid_check = valid_check + 1
    
    elif valid_check % 4 == 0:
        valid_check = 1
        # print(seq) #TESTING
        # extract_pixel(seq) #TESTING
        pixels = extract_pixel(seq)
        for pixel in pixels: 
            # print(pixel) #TESTING
            # find_rgb(pixel) #TESTING
            img.append(find_rgb(pixel))
        seq = ""
        # print("------------------------") #TESTING
f.close()
# for y in img: #TESTING
#     print(y)  #TESTING
# print("check pixels") #TESTING




#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Displaying a picture with rgb array

def genImage(f, img):
  count = 0
  rgb_index = 0
  with numpy.nditer(f, flags=['multi_index'], op_flags=['writeonly']) as it:
    for x in it:
        #x[...] = int(str(img[count][0]) + str(img[count][1]) + str(img[count][2]) )
        x[...] = img[count][rgb_index]
        rgb_index = rgb_index + 1
        
        if rgb_index == 3:
            rgb_index = 0
            if count < len(img)-1:
                count = count + 1
    #print(count) 

frame = numpy.zeros((480,640,3), dtype = 'uint8')
genImage(frame,img)
image = PIL.Image.fromarray(frame)
image.show()