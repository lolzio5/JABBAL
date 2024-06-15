import random

for x in range (24):
    word_32 = ""
    for i in range(32):
        bit = str(random.randint(0,1))
        word_32 += bit
    print("regfile["+str(x)+"] = 32'b"+word_32+";")
