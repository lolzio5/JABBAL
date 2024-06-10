import random

no_of_pixels = 4800
no_of_x_cells = 80

f = open("state_rom.mem","w")
for i in range(no_of_pixels):
    state =  str(random.randint(0,1))
    if (i+1)%no_of_x_cells == 0:
        s = state + "\n"
    else:
        s = state + " "
    f.write(s)

f.close()