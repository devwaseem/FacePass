from flask import Flask, Response, request
from fc import train, dataSetCreator as ds, detecter as detect, createDatasetFromZip,nukedir,detectFace
from werkzeug.contrib.fixers import ProxyFix
import json
import os
import threading,time
import random,string
from PIL import Image
app  = Flask(__name__)

app.wsgi_app = ProxyFix(app.wsgi_app)

@app.route('/')
def printHello():
    return Response('''
        <h1 align='center'>Welcome to FacePass Project</h1>
        </br>
        ''')

@app.route('/storeFaces/zip/<Id>/',methods = ['POST','GET'])
def trainDS(Id):
    if not os.path.exists('model'):
        os.makedirs('model')
    path = "%s"%Id
    createFile(path,request.data)
    (faces,msg) = createDatasetFromZip(int(Id),path)
    jsonData = {}
    nukedir('model/%s/'%path)
    jsonData['detectedFacesCount'] = faces
    jsonData['message'] = msg
    os.remove(path)
    return Response(json.dumps(jsonData))




@app.route('/recognize/',methods = ['POST'])
def recognise():
    path = ''.join(random.choice(string.ascii_uppercase + string.digits) for i in range(5))
    path="%s.jpg"%path
    createFile(path,request.data)
    (Id,conf,errorMsg,isRecognized) = detect(path)
    os.remove(path)
    jsonData = {}
    jsonData['confidence'] = 100 - conf
    jsonData['ID'] = Id
    jsonData['recognized'] = isRecognized
    jsonData['errorMsg'] = errorMsg

    return Response(json.dumps(jsonData))


@app.route('/train/')
def trainModels():
     if not os.path.exists('train'):
        os.makedirs('train')
     train()
     jsonData = {}
     jsonData['trainingStatus'] = "Training completed"
     jsonData['completed'] = True
     return Response(json.dumps(jsonData))

@app.route('/storeFace/img/id/<Id>/',methods = ['POST','GET'])
def detectImage(Id):
    
    if not os.path.exists('model'):
        os.makedirs('model')
    dir = 'model/%d'%int(Id)
    if not os.path.exists(dir):
        os.makedirs(dir)
    path='{}/{}.jpg'.format(dir,len([os.path.join(dir,f) for f in os.listdir(dir)]))
    createFile(path,request.data)
    return Response("Image created")
#    threading.Timer(10.0,detectFace(Id,path,0)).start
#    detectFace(Id,path,0)
#    os.remove(path)



@app.route('/rotateFace/img/id/<Id>/')
def rotate(Id):
    if not os.path.exists('model'):
        os.makedirs('model')
    dir = 'model/%d'%int(Id)
    if not os.path.exists(dir):
        os.makedirs(dir)
    paths = [os.path.join(dir,f) for f in os.listdir(dir)]
    for path in paths:
        if path == "model/1153/.DS_Store" :
            continue
        temp = Image.open(path)
        temp = temp.rotate(-90,expand=True)
        temp.save(path)
    return Response("Rotated")

@app.route('/detectFaces/id/<Id>/')
def detectFaces(Id):
    imagePaths = [os.path.join('dataset',f) for f in os.listdir('dataset')]
    paths = list(filter( lambda x: x.startswith('dataset/User.'+str(Id)), imagePaths))
    _ = [os.remove(x) for x in paths]

    dir = 'model/%d'%int(Id)
    paths = [os.path.join(dir,f) for f in os.listdir(dir)]
    for path in paths:
        print path
        if path == "model/1153/.DS_Store" :
            continue
        detectFace(Id,path,0)
        os.remove(path) #remove original face
    return Response("faces detected")


@app.route('/getUID/')
def getUID():
    Ids=[0]
    imagePaths=[]
    if not os.path.exists('dataset'):
        os.makedirs('dataset')
    for i in [os.path.join('dataset',f) for f in os.listdir('dataset')]:
        if i.endswith('.jpg'):
            imagePaths.append(i)
    for imagePath in imagePaths:
        if imagePath == '.DS_Store':  #removing unneccesary files if created from macos
            os.remove('.DS_Store')
            continue
        Id = int(os.path.split(imagePath)[-1].split(".")[1])
        if Id not in Ids:
            Ids.append(Id)
    Ids.sort()
    temp = Ids[-1] #last element
    outDict = {}
    outDict['newID'] = temp + 1
    return Response(json.dumps(outDict))



def createFile(path,data):
    f = open(path,"wb")
    f.write(data)
    f.close()



if __name__ == '__main__':
    Port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0',debug=True, port=Port)


