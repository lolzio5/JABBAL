import cv2
import numpy as np
import math
from cvzone.HandTrackingModule import HandDetector
from cvzone.ClassificationModule import Classifier
import socket
import time
import pickle

offset = 20
imageHeight = 480
counter = 0
drawing = True
start=time.time()
done_sending=0

# Initialize TCP server
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(('127.0.0.1', 9999))
server_socket.listen(1)
print("Waiting for a connection...")
client_socket, client_address = server_socket.accept()
print(f"Connected to {client_address}")

cap = cv2.VideoCapture(0)
detector = HandDetector(maxHands=1)
label = ["draw","fast","ok","reset","select","start","stop"]
coordinates=set()
matrix=np.zeros((720,1280), dtype=np.int8)

def is_thumbs_up(hand):
    thumb_tip = hand[4][1]  # y-coordinate of thumb tip
    thumb_ip = hand[3][1]   # y-coordinate of thumb IP joint
    index_tip = hand[8][1]  # y-coordinate of index finger tip
    middle_tip = hand[12][1]  # y-coordinate of middle finger tip
    ring_tip = hand[16][1]  # y-coordinate of ring finger tip
    pinky_tip = hand[20][1]  # y-coordinate of pinky finger tip

    # Check if thumb is above other fingers and is extended
    if (thumb_tip < index_tip and thumb_tip < middle_tip and thumb_tip < ring_tip and thumb_tip < pinky_tip
            and thumb_ip < index_tip and thumb_ip < middle_tip and thumb_ip < ring_tip and thumb_ip < pinky_tip):
        return True
    return False

def is_hand_open(hand):
    # Define the landmark pairs for the fingers
    fingers = [
        (4, 2),  # Thumb: tip to MCP joint
        (8, 5),  # Index finger: tip to MCP joint
        (12, 9), # Middle finger: tip to MCP joint
        (16, 13),# Ring finger: tip to MCP joint
        (20, 17) # Pinky: tip to MCP joint
    ]
    
    threshold = 50  # Threshold distance in pixels; adjust based on your setup

    for tip, base in fingers:
        distance = math.hypot(hand[tip][0] - hand[base][0], hand[tip][1] - hand[base][1])
        if distance < threshold:
            return False
    return True

while True:
    success, img = cap.read()
    if success:
        hands, img = detector.findHands(img, draw=True, flipType=True)
        whiteImage = np.ones((imageHeight, imageHeight, 3), np.uint8)*255

        if hands:
                hand = hands[0]
                lmHand = hand["lmList"]
                x, y, w, h = hand['bbox']
                imgCrop = img[y-offset:y+h+offset,x-offset:x+w+offset] #no boundary protection

                if w > h:
                    ratio = imageHeight/w
                else:
                    ratio = imageHeight/h

                if ratio:
                    newWidth = math.ceil(w*ratio)
                    newHeight = math.ceil(h*ratio)
                    if newHeight> imageHeight:
                        newHeight = imageHeight
                    if newWidth> imageHeight:
                        newWidth = imageHeight
                    if imgCrop.any():
                        imgResize = cv2.resize(imgCrop, (newWidth, newHeight))
                    else:
                        imgResize = imgCrop

                    wCenterGap = math.floor((imageHeight - newWidth)/2)
                    hCenterGap = math.floor((imageHeight - newHeight)/2)

                    if wCenterGap > 0:
                        h_end = min(imgResize.shape[0], whiteImage.shape[0])
                        w_end = min(imgResize.shape[1] + wCenterGap, whiteImage.shape[1])
                        whiteImage[0:h_end, wCenterGap:w_end] = imgResize[0:h_end, 0:(w_end - wCenterGap)]

                    if hCenterGap > 0:
                        h_end = min(imgResize.shape[0] + hCenterGap, whiteImage.shape[0])
                        w_end = min(imgResize.shape[1], whiteImage.shape[1])
                        whiteImage[hCenterGap:h_end, 0:w_end] = imgResize[0:(h_end - hCenterGap), 0:w_end]

                cv2.imshow(("Zoomed Image"), whiteImage)
                exec_time=time.time()-start
                if is_thumbs_up(lmHand) and exec_time>10:
                    drawing = False
                    if not done_sending:
                        for alive in coordinates:
                            matrix[min(int(alive[1]*1.5),719)][min(int(alive[0]*2),1279)]=1
                            if (alive[1]+1<720):
                                matrix[min(int((alive[1]+1)*1.5),719)][min(int(alive[0]*2), 1279)]=1
                            if (alive[1]+1<720) and (alive[0]+1<1280):
                                matrix[min(int((alive[1]+1)*1.5),719)][min(int((alive[0]+1)*2),1279)]=1
                            if (alive[1]+1<720) and (alive[0]-1>-1):
                                matrix[min(int((alive[1]+1)*1.5),719)][min(int((alive[0]-1)*2), 1279)]=1
                            if (alive[1]-1>-1):
                                matrix[min(int((alive[1]-1)*1.5),719)][min(int(alive[0]*2),1279)]=1
                            if (alive[1]-1>-1) and (alive[0]-1>-1):
                                matrix[min(int((alive[1]-1)*1.5),719)][min(int((alive[0]-1)*2),1279)]=1
                            if (alive[1]-1>-1) and (alive[0]+1<1280):
                                matrix[min(int((alive[1]-1)*1.5),719)][min(int((alive[0]+1)*2), 1279)]=1
                        try:
                            for row in matrix:
                                serialized_row = pickle.dumps(row)
                                client_socket.send(serialized_row)
                            print("Starting grid sent!")
                            done_sending=1
                        except Exception as e:
                            print(f"Error sending matrix: {e}")
                if drawing:
                    length, info, img = detector.findDistance(lmHand[4][0:2], lmHand[8][0:2], img, color=(255, 0, 255), scale=10)
                    if length != 0:
                        if w // length > 6:
                            coordinates.add((lmHand[4][0:2][0], lmHand[4][0:2][1]))
                else:
                    if (is_hand_open(lmHand) and done_sending):
                        message="P" # Pause
                        print(message)
                        pickled_message=pickle.dumps(message)
                        client_socket.send(pickled_message)

        cv2.imshow(("Image"), img)
    else:
        print("fail to get frame")
    key = cv2.waitKey(2)