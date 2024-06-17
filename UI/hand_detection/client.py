import socket
import pickle
from objsize import get_deep_size

# Initialize TCP client
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect(('localhost', 9999))
print("Connected to server.")

done = 0
pause = 0

try:
    while True:
        if (not done):
            num_chunks = pickle.loads(client_socket.recv(4096))
            data = b""
            for i in range(num_chunks):
                chunk = client_socket.recv(4096)
                data += chunk                
            matrix=pickle.loads(data)
            
            done=1
        message = pickle.loads(client_socket.recv(2048))
        #print("Received a string:", message)

except Exception as e:
    print(f"Error: {e}")

finally:
    client_socket.close()
    print("Connection closed.")