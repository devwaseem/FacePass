import numpy as np
import cv2
import os
from PIL import Image,ImageFile
import cv2.face as fc
import time
import zipfile,os
import threading

#--------------------------------------------------------#
#    create dataset from image or batch of images
#--------------------------------------------------------#

def detectFace(uid,path,sn):
    if not os.path.exists('dataset'):
        os.makedirs('dataset')
    if path.endswith('.jpg'):
        sampleNum=getSampleNum(uid)
        faces,gray= getFaces(path)
        if(len(faces)>0):
            for (x,y,w,h) in faces:
                cv2.imwrite("dataset/User."+str(uid)+'.'+str(sampleNum)+".jpg",gray[y:y+h,x:x+w])
            return len(faces)

def dataSetCreator(uid,path,isDir):
        if(isDir):
            face = 0
            imagePaths=[os.path.join(path,f) for f in os.listdir(path)]
            for path in imagePaths:
                a = detectFace(uid,path,face)
                if type(a) is int:
                    face += a
                else:
                    print "something error occured"
                print face
            return face
        else:
           return detectFace(uid,path,0)

def getSampleNum(Id):
    imagePaths = [os.path.join('dataset',f) for f in os.listdir('dataset')]
    print('images {}'.format(imagePaths))
    paths = list(filter( lambda x: x.startswith('dataset/User.'+str(Id)), imagePaths))
    print('filtered {}'.format(paths))
    return len(paths)


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
    if not os.path.exists('dataset'):
        os.makedirs('dataset')
    try:
        zip_ref = zipfile.ZipFile(path, 'r')
        model_path = 'model/%d/'%Id
        zip_ref.extractall(model_path)
        zip_ref.close()
        print "zip created"
        faces = dataSetCreator(Id,model_path,isDir=True)
        print "faces %d"%faces
        if faces > 2 :
            return (faces,"Your face has been has been stored in our database")
        else:
            return (faces,"please capture the photo in good lightning condition!")
    except Exception as ex:
        template = "An exception of type {0} occurred. Arguments:\n{1!r}"
        message = template.format(type(ex).__name__, ex.args)
        print message
        return (0,"Please provide a zip file with your faces")



#--------------------------------------------------------#
#    train the dataset
#--------------------------------------------------------#

def train():
    recognizer = fc.LBPHFaceRecognizer_create()
    detector= cv2.CascadeClassifier("haarcascade_frontalface_default.xml");
    path='dataset'
    def getImageWithID(path):
        imagePaths = []
        for i in [os.path.join(path,f) for f in os.listdir(path)]:
            if i.endswith('.jpg'):
                imagePaths.append(i)

        faceSamples=[]
        Ids=[]
        for imagePath in imagePaths:
            if imagePath == '.DS_Store':  #removing unneccesary files if created from macos
                os.remove('.DS_Store')
                continue
            pilImage=Image.open(imagePath)
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
    faces,gray = getFaces(path)
    
    if len(faces) > 0 :
        for(x,y,w,h) in faces:
            Id, conf = recognizer.predict(gray[y:y+h,x:x+w])
        if(conf<48):
            return (Id,conf,"",True)
        else:
            return (Id,conf,"problem in recognising face please retrain the model",False)
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


def getFaces(path):
    ImageFile.LOAD_TRUNCATED_IMAGES = True
    face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
    req_size = 800,800
    _tempImg = Image.open(path)
    _tempImgSize = _tempImg.size
    x,y = _tempImgSize
    if _tempImgSize > req_size :
        _tempImg.thumbnail(req_size, Image.ANTIALIAS)
        _tempImg.save(path,optimize=True)
        if x > y :
            img = Image.open(path)
            temp = img.rotate(-90,expand = True)
            temp.save(path)
    img = cv2.imread(path)
    minisize = (img.shape[1],img.shape[0])
    miniframe = cv2.resize(img, minisize)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(miniframe,1.3,5)
    return faces,gray
