import socket
import pickle

# Initialize TCP client
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect(('127.0.0.1', 9999))
print("Connected to server.")

done = 0
BRAM_A_WE = 0x0000 # pixgen.register_map.BRAM_A_WE  # WRITE ENABLE FLAG

PAUSE = 0x0001 #pixgen.register_map.PAUSE = 0x0001  # PAUSE FLAG
while True:
    if (not done):
        num_chunks = pickle.loads(client_socket.recv(4096))
        data = b""
        for i in range(num_chunks):
            chunk = client_socket.recv(4096)
            data += chunk                
        matrix=pickle.loads(data)
       
        for item in matrix[0:50]:
            counterd = 0
            for data in item:
                if data:
                    item[counterd] = 1
                else:
                    item[counterd] = 0
                counterd = counterd + 1
            binary_str = ''.join(map(str, item))
            while len(binary_str) % 8 != 0:
                binary_str = '0' + binary_str
            for i in range(40):
                hex_int = int(binary_str[32*i:((i+1)*32)-1], 2)
                register_name = f"gp{i}"
                #setattr(pixgen.register_map, register_name, hex_int)
                print(f"{register_name} = {hex_int}")
        done=1
    #pixgen.register_map.gp40 = 0x0001 # done writing
    message = pickle.loads(client_socket.recv(2048))
    if message:
        PAUSE = 0x0001#pixgen.register_map.PAUSE 
    else:
        PAUSE = 0x0000 #pixgen.register_map.PAUSE = 
