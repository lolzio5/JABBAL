import socket

client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect(('localhost', 9999))

try:
    while True:
        message = client_socket.recv(1024).decode()
        if message:
            print(f"Received: {message}")
except Exception as e:
    print(f"Error: {e}")
finally:
    client_socket.close()