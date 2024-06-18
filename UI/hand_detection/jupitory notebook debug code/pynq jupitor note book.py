import socket
import pickle
import numpy as np

# Initialize TCP client
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect(('192.168.2.1', 9999))
print("Connected to server.")

done = False
pixgen.register_map.gp40 = 0x0000 # WRITE ENABLE FLAG
print(pixgen.register_map.gp0)
pixgen.register_map.gp41 = 0x0001  # 

#try:
while True:
        # Receive data from server
        packet = client_socket.recv(4096)
        # Deserialize received data
        message = pickle.loads(packet)
        message=message.tolist()
        #if not done and isinstance(message, np.array()):
        for j, l in enumerate(message):
            for k, val in enumerate(l):
                if(val):
                    message[j][k]=1
                else:
                    message[j][k]=0

        for i in range(20):
                pixgen.register_map.gp40 = 0x0001 # flag to indicate data is being written
                zero_one = map(int, message[i][0:14])  # convert True to 1, False to 0  using `int`
                n = int(''.join(map(str, zero_one)), 2)  # numbers to strings, join them
                                     # convert to number (base 2)
                print('{:02x}'.format(n))
                an_integer = int('{:02x}'.format(n), 16)

                hex_value = hex(an_integer)
                print(hex_value)
                pixgen.register_map.gp0 = hex_value
                zero_one = map(int, message[i][15:29])  # convert True to 1, False to 0  using `int`
                n = int(''.join(map(str, zero_one)), 2)  # numbers to strings, join them
                                     # convert to number (base 2)
                an_integer = int('{:02x}'.format(n), 16)

                hex_value = hex(an_integer)
                pixgen.register_map.gp1 = hex_value

                '''
                pixgen.register_map.gp2 = message[i][64:95]
                pixgen.register_map.gp3 = message[i][96:127]
                pixgen.register_map.gp4 = message[i][128:159]
                pixgen.register_map.gp5 = message[i][160:191]
                pixgen.register_map.gp6 = message[i][192:223]
                pixgen.register_map.gp7 = message[i][224:255]
                pixgen.register_map.gp8 = message[i][256:287]
                pixgen.register_map.gp9 = message[i][288:319]
                pixgen.register_map.gp10 = message[i][320:351]
                pixgen.register_map.gp11 = message[i][352:383]
                pixgen.register_map.gp12 = message[i][384:415]
                pixgen.register_map.gp13 = message[i][416:447]
                pixgen.register_map.gp14 = message[i][448:479]
                pixgen.register_map.gp15 = message[i][480:511]
                pixgen.register_map.gp16 = message[i][512:543]
                pixgen.register_map.gp17 = message[i][544:575]
                pixgen.register_map.gp18 = message[i][576:607]
                pixgen.register_map.gp19 = message[i][608:639]
                pixgen.register_map.gp20 = message[i][640:671]
                pixgen.register_map.gp21 = message[i][672:703]
                pixgen.register_map.gp22 = message[i][704:735]
                pixgen.register_map.gp23 = message[i][736:767]
                pixgen.register_map.gp24 = message[i][768:799]
                pixgen.register_map.gp25 = message[i][800:831]
                pixgen.register_map.gp26 = message[i][832:863]
                pixgen.register_map.gp27 = message[i][864:895]
                pixgen.register_map.gp28 = message[i][896:927]
                pixgen.register_map.gp29 = message[i][928:959]
                pixgen.register_map.gp30 = message[i][960:991]
                pixgen.register_map.gp31 = message[i][992:1023]
                pixgen.register_map.gp32 = message[i][1024:1055]
                pixgen.register_map.gp33 = message[i][1056:1087]
                pixgen.register_map.gp34 = message[i][1088:1119]
                pixgen.register_map.gp35 = message[i][1120:1151]
                pixgen.register_map.gp36 = message[i][1152:1183]
                pixgen.register_map.gp37 = message[i][1184:1215]
                pixgen.register_map.gp38 = message[i][1216:1247]
                pixgen.register_map.gp39 = message[i][1248:1279]
                '''
        pixgen.register_map.gp40 = 0x0000 # done writing
        done=1

        # elif isinstance(message, str):
            # pixgen.register_map.gp41 = pixgen.register_map.gp41 # Pause flag must be high
        # else:
            # pixgen.register_map.gp41 = not pixgen.register_map.gp41 # Unpause
        
        frame = imgen_vdma.readframe() # Output next frame
        hdmi_out.writeframe(frame)
      
# except Exception as e:
   # print(f"Error: {e}")
  #  frame = imgen_vdma.readframe() # Output next frame
   # hdmi_out.writeframe(frame)

#finally:
 #   client_socket.close()
  #  print("Connection closed.")