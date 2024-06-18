import socket
import pickle

# Initialize TCP client
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect(('127.0.0.1', 9999))
print("Connected to server.")


BRAM_A_WE = 0x0000 # pixgen.register_map.BRAM_A_WE  # WRITE ENABLE FLAG
counter=0
PAUSE = 0x0001 #pixgen.register_map.PAUSE = 0x0001  # PAUSE FLAG
while True:
    if (counter<720):
        serial_row = client_socket.recv(1431)
        row=pickle.loads(serial_row)
        counterd = 0
        for data in row:
            if data:
                row[counterd] = 1
            else:
                row[counterd] = 0
            counterd = counterd + 1
        binary_str = ''.join(map(str, row))
        while len(binary_str) % 8 != 0:
            binary_str = '0' + binary_str
        for i in range(40):
            hex_int = int(binary_str[32*i:((i+1)*32)-1], 2)
            register_name = f"gp{i}"
                #setattr(pixgen.register_map, register_name, hex_int)
            print(f"{register_name} = {hex_int}")
        counter=counter+1
    else:
        serialized_message=client_socket.recv(128)
        if serialized_message:
            message = pickle.loads(serialized_message)
        if message:
            PAUSE = 0x0001#pixgen.register_map.PAUSE 
        else:
            PAUSE = 0x0000 #pixgen.register_map.PAUSE =

    #pixgen.register_map.gp40 = 0x0001 # done writing
     
