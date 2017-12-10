import numpy as np
import cv2
import os
from PIL import Image
import cv2.face as fc
import time
import zipfile,os


#--------------------------------------------------------#
#    create dataset from image or batch of images
#--------------------------------------------------------#

def detectFace(uid,path):
    if path.endswith('.jpg'):
        req_size = 400,400
        _tempImg = Image.open(path)
        _tempImgSize = _tempImg.size
        if _tempImgSize == req_size :
            _tempImg.thumbnail(req_size, Image.ANTIALIAS)
            _tempImg.save(path,optimize=True)
        face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
        sampleNum=0
        color = Image.open(path)
        color = np.array(color)
        img = Image.open(path).convert('L')
        gray = np.array(img,'uint8')
        faces = face_cascade.detectMultiScale(gray)
        if(len(faces)>0):
            for (x,y,w,h) in faces:
                sampleNum=sampleNum+1
                cv2.imwrite("dataset/User."+str(uid)+'.'+str(sampleNum)+".jpg",gray[y:y+h,x:x+w])
#                cv2.rectangle(color,(x,y),(x+w,y+h),(255,0,0),2)
        return len(faces)

def dataSetCreator(uid,path,isDir):

        if(isDir):
            imagePaths=[os.path.join(path,f) for f in os.listdir(path)]
            for path in imagePaths:
                return detectFace(uid,path)
        else:
           return detectFace(uid,path)

#--------------------------------------------------------#
#    create dataset with webcam
#--------------------------------------------------------#

def dataSetCreatorWithCamera(val):
    face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
    cap = cv2.VideoCapture(0)
    id = val
    sampleNum=0
    while True:
        ret,img=cap.read()
        gray=cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray,1.3,5)
        for (x,y,w,h) in faces:
            sampleNum=sampleNum+1
            cv2.imwrite("dataset/User."+str(id)+'.'+str(sampleNum)+".jpg",gray[y:y+h,x:x+w])
            cv2.rectangle(img,(x,y),(x+w,y+h),(255,0,0),2)
            cv2.waitKey(100);
        cv2.imshow('img',img)
        cv2.waitKey(1);
        if(sampleNum>20):
            break
    cap.release();
    cv2.destroyAllWindows()




def createDatasetFromZip(Id,path):
    try:
        zip_ref = zipfile.ZipFile(path, 'r')
        model_path = 'model/%d/'%Id
        zip_ref.extractall(model_path)
        zip_ref.close()
        faces = dataSetCreator(Id,model_path,isDir=True)
        if faces > 5 :
            return (faces,"Your face has been has been stored in our database")
        else:
            return (faces,"please capture the photo in good lightning condition!")
    except :
        return (0,"Please provide a zip file with your faces")



#--------------------------------------------------------#
#    train the dataset
#--------------------------------------------------------#

def train():
    recognizer = fc.LBPHFaceRecognizer_create()
    detector= cv2.CascadeClassifier("haarcascade_frontalface_default.xml");
    path='datasets'

    def getImageWithID(path):
#        imagePaths=[os.path.join(path,f) for f in os.listdir(path)]
#        imagePaths = [if f.endswith('.jpg'): f for f in imagePaths]
        imagePaths = []
        for i in [os.path.join(path,f) for f in os.listdir(path)]:
            if i.endswith('.jpg'):
                imagePaths.append(i)

        faceSamples=[]
        Ids=[]
        for imagePath in imagePaths:
            if path == '.DS_Store':
                os.remove(path)
                continue
            pilImage=Image.open(imagePath).convert('L')
            imageNp=np.array(pilImage,'uint8')
            Id=int(os.path.split(imagePath)[-1].split(".")[1])
            faces=detector.detectMultiScale(imageNp)
            for (x,y,w,h) in faces:
                faceSamples.append(imageNp[y:y+h,x:x+w])
                Ids.append(Id)
        return faceSamples,Ids

    faces,Ids = getImageWithID('dataset')
    recognizer.train(faces, np.array(Ids))
    recognizer.write('train/trainner.yml')



#--------------------------------------------------------#
#    recognize the face
#--------------------------------------------------------#



def detecter(path):
    recognizer = fc.LBPHFaceRecognizer_create()
    recognizer.read('train/trainner.yml')
    cascadePath = "haarcascade_frontalface_default.xml"
    faceCascade = cv2.CascadeClassifier(cascadePath);
    color = Image.open(path)
    color = np.array(color)
    img = Image.open(path).convert('L')
    gray = np.array(img,'uint8')
    faces=faceCascade.detectMultiScale(gray,1.2,5)
    if len(faces) > 0 :
        for(x,y,w,h) in faces:
            cv2.rectangle(color,(x-50,y-50),(x+w+50,y+h+50),(225,0,0),2)
            Id, conf = recognizer.predict(gray[y:y+h,x:x+w])

        if(conf<50):

            return (Id,conf,"",True)
        else:

            return (0,0,"problem in recognising face please retrain the model",False)
    else:

        return(0,0,"No face Found",False)


def nukedir(dir):
    if dir[-1] == os.sep: dir = dir[:-1]
    files = os.listdir(dir)
    for file in files:
        if file == '.' or file == '..': continue
        path = dir + os.sep + file
        if os.path.isdir(path):
            nukedir(path)
        else:
            os.unlink(path)
    os.rmdir(dir)

