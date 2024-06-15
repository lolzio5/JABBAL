import PIL.Image
import numpy

# Takes a stream of pixels and chucks it into an array fitting the screen
def genImage(f, img):
  count = 0
  test_count = 0
  rgb_index = 0
  with numpy.nditer(f, flags=['multi_index'], op_flags=['writeonly']) as it:
    for x in it:
        
        # UNderstanding images form arrays
        #0000000000000000000000000
        # (1)red
        # if (test_count%3==0):
        #     x[...] = 255
        # (2)green
        # if ((test_count-1)%3==0):
        #     x[...] = 255
        # (3)blue
        # if ((test_count-2)%3==0):
        #     x[...] = 255

        # (4)half red half green
        # if it.multi_index[0] < 240:
        #     if (test_count%3==0):
        #         x[...] = 255
        # else:
        #     if ((test_count-1)%3==0):
        #         x[...] = 255

        #Chequered
        # if it.multi_index[0]%2==0:
        #     x[...] = 255
        # if it.multi_index[1]%2==0:
        #     x[...] = 255 
        #0000000000000000000000000

        test_count = test_count + 1

        x[...] = img[count][rgb_index]
        rgb_index = rgb_index + 1
        if rgb_index > 2:
            rgb_index = 0
            count = count + 1
    
    # TESTING
    #0000000000000000000000000
    # print(count)
    # print("First entry in img", img[0])
    # print("Last entry im img", img[count-1])
    # print(img[count])
    # print("xxxxxxxx")
    #0000000000000000000000000

# Retrives rgb values of individual pixels from 3 32-bit words
def extractPixel(seq):
    pixels = []
    # for i in range(0, 4):
    #     pixels.append( seq[ ( i * 6 ) : ( ( i + 1 ) * 6 ) ] )
    #     # print("pixel", i, pixels[i]) #TESTING
    # return pixels
    # ^Makes sense BUT NOT CORRECT
    
    # Man what is this???? ->
    pix1 = ( seq[2] + seq[3] ) + ( seq[6] + seq[7] ) + ( seq[4] + seq[5] ) # 1,3,2
    pix2 = ( seq[12] + seq[13] ) + ( seq[0] + seq[1] ) + ( seq[14] + seq[15] ) # 6,0,7
    pix3 = ( seq[22] + seq[23] ) + ( seq[10] + seq[11] ) + ( seq[8] + seq[9] ) # 11,5,4
    pix4 = ( seq[16] + seq[17] ) + ( seq[20] + seq[21] ) + ( seq[18] + seq[19] ) # 8,10,9
    pixels.append(pix1)
    pixels.append(pix2)
    pixels.append(pix3)
    pixels.append(pix4)

    return pixels

# Gets the decimal RGB values of a pixel(og in a 24-bit word as 8 hex numbers)
def findRgb(pixel):
    rgb = []
    for i in range(0, 3):
        hex_val = pixel[ (i * 2) : ( (i + 1) * 2 ) ] 
        val = int(format(int(hex_val, 16), 'd'))   #Converts hex to decimal
        rgb.append(val)

        #0000000000000000000000000
        # print("rgb", i, rgb[i]) #TESTING
        #0000000000000000000000000

    return rgb

# Takes in a file of data, valid and user signals and converts it into rgb values for each pixel
def getPixelStream(file):
    img = []
    seq = ""
    seq_count = 0
    
    for line in file:
        line = line[0:-1]   # Remove \n from each line
        line = line.split(".")
        word_32 = line[0]   # Extract word
        valid_flg = line[1][0]  # Get valid flag
        user_flg = line[1][1]   # Get user flag
        
        #0000000000000000000000000
        # print(word_32+valid_flg+user_flg) #TESTING
        #0000000000000000000000000

        # user and valid
        # if user_flg == "0":
        #     if valid_flg == "1":
        #         seq = seq + word_32
        #         seq_count = seq_count + 1

        # ignore user
        if valid_flg == "1":
                seq = seq + word_32
                seq_count = seq_count + 1
        if user_flg == "1":
            print("userhigh-",word_32)

        if seq_count == 3:
            seq_count = 0
            #0000000000000000000000000
            # print(seq)  # TESTING
            # print(".") # TESTING
            #0000000000000000000000000
            pixels = extractPixel(seq)
            #0000000000000000000000000
            # print(pixels)   #TESTING
            #0000000000000000000000000
            for pixel in pixels:
                img.append(findRgb(pixel))
            #0000000000000000000000000
            #     print(findRgb(pixel))   #TESTING
            # print("------------") # TESTING
            #0000000000000000000000000
            seq = ""
    return img

#+++++++++++++++++++++++++++++++++++++++++++++++++++++ 
# Main
#++++++++++++++++++++++++++++++++++++++++++++++++++++++    

# Reading generated pixel values and adding them to the img array
f = open(r"C:\summer_project2024\JABBAL\Testbenches\Updated project\V3.0 - Block Ram testing\word_stream.txt")
img = getPixelStream(f)
f.close()
# print(img[-1]) # TESTING    

# Displaying a picture with the img array
frame = numpy.zeros((480,640,3), dtype = 'uint8')
# print(numpy.shape(frame)) # Testing
genImage(frame,img)
image = PIL.Image.fromarray(frame)
image.show()



# VERIFYING
#0000000000000000000000000
# print(len(img))
# print(len(frame))
#0000000000000000000000000

# TESTING
# 0000000000000000000000
# z = open("Pixels V3.txt","w" )
# for l in img:
#     for f in l:
#         z.write(str(f))
#         z.write(".")
#     z.write("\n")
# z.close()
#0000000000000000000000000