import socket
import pickle
import numpy as np

# Initialize TCP client
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect(('localhost', 9999))
print("Connected to server.")

done = 0
pause = 0

try:
    while True:
        # Receive data from server
        data = b""
        packet = client_socket.recv(99999999)

        # Deserialize received data
        message = pickle.loads(packet)
        if isinstance(message, np.array):
            print("received matrix")
        elif isinstance(message, str):
            # Assuming the received object is a string
            print("Received a string:", message)

except Exception as e:
    print(f"Error: {e}")

finally:
    client_socket.close()
    print("Connection closed.")