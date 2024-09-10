import socket
import threading
from transformers import AutoImageProcessor, AutoModelForImageClassification
import torch
from PIL import Image, ImageFile
import io
import base64

ImageFile.LOAD_TRUNCATED_IMAGES = True

image_processor = AutoImageProcessor.from_pretrained('kimitoinf/dedc')
model = AutoModelForImageClassification.from_pretrained('kimitoinf/dedc')

def recvall(sock, n):
    """ Helper function to receive n bytes or return None if EOF is hit """
    data = bytearray()
    try:
        while len(data) < n:
            packet = sock.recv(n - len(data))
            if not packet:
                return None
            data.extend(packet)
    except Exception as e:
        print(f"Error receiving data: {e}")
        return None
    return data

def handler(client):
    try:
        # Receive the length of the image data
        length = int(client.recv(16).decode('utf-8').strip())
        client.send('received'.encode('utf-8'))
        print(f"Expected length: {length}")

        # Receive the actual image data
        image_data = recvall(client, length)
        
        if image_data is None or len(image_data) != length:
            print("Error: Received image data length does not match expected length")
            return

        print(f"Received image data of length: {len(image_data)}")

        image = Image.open(io.BytesIO(base64.b64decode(image_data)))
        input = image_processor(image, return_tensors='pt')

        with torch.no_grad():
            logits = model(**input).logits
            prediction = logits.argmax(-1).item()
            client.send(model.config.id2label[prediction].encode('utf-8'))
            print(f'Prediction sent: {model.config.id2label[prediction]}')

    except Exception as e:
        print("Error:", e)

    finally:
        client.close()

SERVER = 'localhost'
PORT = 5000
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((SERVER, PORT))
server.listen()
print(f'Server is listening on {SERVER}:{PORT}.')

clients = []
try:
    while True:
        connect, address = server.accept()
        clients.append(connect)
        print(f'Client {address} is connected.')
        thread = threading.Thread(target=handler, args=(connect,))
        thread.start()
except KeyboardInterrupt:
    print("Server is shutting down...")
    for client in clients:
        client.close()
    server.close()
