imgen_vdma = overlay.video.axi_vdma_0.readchannel
videoMode = common.VideoMode(640, 480, 24)
imgen_vdma.mode = videoMode
imgen_vdma.start()

hdmi_out = overlay.video.hdmi_out
hdmi_out._vdma = overlay.video.axi_vdma #Use the correct VDMA!
hdmi_out.configure(videoMode)
hdmi_out.start()

pixgen = overlay.pixel_generator_0
binary_sstr = '1111'
int(binary_sstr, 2)
pixgen.register_map.gp0 = 1111
pixgen.register_map.gp42 = 1 #activate read from cover2 ram_B
print(pixgen.register_map.gp0)
print(pixgen.register_map.gp42)




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
        print(message)
        counter = 0
        for item in message:

            #print(counter)
            counterd = 0
            for data in item:

                if data:
                    item[counterd] = 0
                else:
                    item[counterd] = 1
                counterd = counterd + 1
            print(item)
            # Convert list of bits to a string of '0's and '1's
            binary_str = ''.join(map(str, item))

            # Pad the binary string to ensure its length is a multiple of 8
            while len(binary_str) % 8 != 0:
                binary_str = '0' + binary_str

            # Convert binary string to hexadecimal string
            hex_int = hex(int(binary_str, 2))  # Convert to hex and remove '0x' prefix, then pad to 8 characters
            print(hex_str)
            register_name = f"gp{counter}"


            pixgen.register_map[register_name].write(hex_int)
            counter = counter +1



            

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