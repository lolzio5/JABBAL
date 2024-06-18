import cv2
import numpy as np
import math
import time
from cvzone.HandTrackingModule import HandDetector

# Constants for image processing
offset = 20
imageHeight = 480
counter = 0

# Folder path to save images
# folder_path = r"JABBAL\UI\hand_detection\model_img\draw"
# folder_path = r"JABBAL\UI\hand_detection\model_img\fast"
# folder_path = r"JABBAL\UI\hand_detection\model_img\ok"
folder_path = r"JABBAL\UI\hand_detection\model_img\reset"
# folder_path = r"JABBAL\UI\hand_detection\model_img\select"
# folder_path = r"JABBAL\UI\hand_detection\model_img\start"
# folder_path = r"JABBAL\UI\hand_detection\model_img\stop"

# Capture video from the default camera (usually the first one)
cap = cv2.VideoCapture(1)

# Initialize hand detector with a maximum of one hand to detect
detector = HandDetector(maxHands=1)

while True:
    # Read a frame from the video capture
    success, img = cap.read()
    if success:
        # Detect hands in the image
        hands, img = detector.findHands(img)
        
        # Create a white image of specified height
        whiteImage = np.ones((imageHeight, imageHeight, 3), np.uint8) * 255

        if hands:
            # Get bounding box of the detected hand
            hand = hands[0]
            x, y, w, h = hand['bbox']
            
            # Crop the hand image with some offset
            imgCrop = img[y-offset:y+h+offset, x-offset:x+w+offset]
            
            # Determine the scaling ratio to resize the cropped image
            if w > h:
                ratio = imageHeight / w
            else:
                ratio = imageHeight / h

            if ratio:
                newWidth = math.ceil(w * ratio)
                newHeight = math.ceil(h * ratio)

                # Ensure the new dimensions do not exceed the image height
                if newHeight > imageHeight:
                    newHeight = imageHeight
                if newWidth > imageHeight:
                    newWidth = imageHeight

                # Resize the cropped image if it exists
                if imgCrop.any():
                    imgResize = cv2.resize(imgCrop, (newWidth, newHeight))

                # Calculate the gaps to center the resized image on the white background
                wCenterGap = math.floor((imageHeight - newWidth) / 2)
                hCenterGap = math.floor((imageHeight - newHeight) / 2)

                # Place the resized image on the white background, centered
                if wCenterGap > 0: 
                    whiteImage[0:imgResize.shape[0], wCenterGap:imgResize.shape[1]+wCenterGap] = imgResize
                if hCenterGap > 0: 
                    whiteImage[hCenterGap:imgResize.shape[0]+hCenterGap, 0:imgResize.shape[1]] = imgResize

            # Display the white image with the hand
            cv2.imshow("White Image", whiteImage)

        # Display the original image with hand detection
        cv2.imshow("Image", img)
    else:
        print("Failed to get frame")

    # Wait for a key press and check if it is 's'
    key = cv2.waitKey(2)
    if key == ord("s"):
        # Save the white image to the specified folder with a timestamp
        print(cv2.imwrite(f'{folder_path}/Image_{time.time()}.jpg', whiteImage))
        counter += 1
        print(counter)
