import cv2
import numpy as np
import math
import time
from cvzone.HandTrackingModule import HandDetector

offset = 20
imageHeight = 480
folder_path = r"JABBAL\UI\hand_detection\model_img\ok"
counter = 0

cap = cv2.VideoCapture(1)
detector = HandDetector(maxHands=1)
while True:
    success, img = cap.read()
    if success:
        #img = cv2.flip(img, 1)
        hands, img = detector.findHands(img)
        whiteImage = np.ones((imageHeight, imageHeight, 3), np.uint8)*255




        if hands:
                hand = hands[0]
                x, y, w, h = hand['bbox']
                imgCrop = img[y-offset:y+h+offset,x-offset:x+w+offset] #no boundary protection
                # cv2.imshow("ImageCropped", imgCrop)

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

                    wCenterGap = math.floor((imageHeight - newWidth)/2)
                    hCenterGap = math.floor((imageHeight - newHeight)/2)
                    print("W: ",newWidth," H: ", newHeight, " imageHeight: ",imageHeight, " hCenterGap: ", hCenterGap, " wCenterGap: ", wCenterGap)



                    if(wCenterGap > 0): 
                        whiteImage[0:imgResize.shape[0], wCenterGap:imgResize.shape[1]+wCenterGap] = imgResize
                    if(hCenterGap > 0 ): 
                        whiteImage[hCenterGap:imgResize.shape[0]+hCenterGap, 0:imgResize.shape[1]] = imgResize

                cv2.imshow(("White Image"), whiteImage)
        cv2.imshow(("Image"), img)
    else:
        print("fail to get frame")
    key = cv2.waitKey(2)

    if key == ord("s"):
        print(cv2.imwrite(f'{folder_path}/Image_{time.time()}.jpg', whiteImage))
        #print(cv2.imwrite('Image_{time.time()}.jpg', img))

        counter += 1
        print(counter)
