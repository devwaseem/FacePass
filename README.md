> :warning: **THIS PROJECT IS NO LONGER MAITAINED**
# Project FacePass

![Alt text](https://pbs.twimg.com/media/DLhGc5wUEAAAXMm.jpg "FacePass")

We developed a Ask.fm / Sarahah clone but with facial recognition capabilities which mean you can simply point your camera at your friends’ face, scan and read/write comments anonymously on their public wall. Of course this will run on any device and not just iPhone X because the recognition is powered by the OpenCV library. For developers we’re open-sourcing the backend and the app itself so you could integrate this with your apps and help us improve our service as well. More info on our website and my Twitter handle 

[click me to see a demo video](https://drive.google.com/open?id=0B1InhyZ75GkVV2hYYkVjYXpIdDQ)

## How the App Looks
![Alt text](https://pbs.twimg.com/media/DQsR_HRW0AA3m2G.jpg)
![Alt text](https://pbs.twimg.com/media/DQsR_HNWkAAzQjU.jpg)



## API Installation: (local machine)

Build and run the project in xcode to test the App.

To test out the Facial recognition API in local machine follow the steps given below:

1.change directory to webservice dir:
`cd FacePass\ Webservice`

2.create a virual environment:
 `virtualenv facepassenv`
 
3.activate virtualenv:
`source facepassenv/bin/activate`

4.install virtualenv:
`pip install virtualenv`

5.install the required dependencies:
`pip install -r requirements.txt`

this will install the required dependencies for the project automatically

6.Now run the flask app using:
`python runApp.py`

Now you will get something like this:
```
* Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
* Restarting with stat
* Debugger is active!
```

Now open any browser you like and type this in url:
`localhost:5000`

you will be welcomed with the project name.

At this stage the project is working fine.
you are ready to test the Facial recognition API

## API Calls

_we recommend you to use Postman App for making API calls_

### obtaining UID
**URL:**`localhost:5000/getUID/`

**METHOD:**`GET`

This API will return unique ID(this will generated based on the models already present), this ID should be included in other API calls too. save this UID somewhere temporary or if you are using some database first save this UID and the user name and data.
it is recommended to use this UID instead of your own generated UID to prevent the overwriting of other users models.

### Storing Face to the Server (in our case in local machine)
**URL:**`localhost:5000/storeFace/img/id/<UID>/`

**METHOD:**`POST`

**PARAMS:** 

```
UID : your UID obtained from getUID API
binary data : image in .jpg format
```

This API will take UID(which we obtained before) parameter and image (.jpg format) through post method. we recommend you to use postman app to easily upload images. This API simply stores your face in the server under the specified UID. The photos are saved in FacePass\ Webservice/model/<UID>


### Detecting Faces from the uploaded photos 

**URL:**`localhost:5000/detectFaces/id/<UID>/`

**METHOD:**`POST`

**PARAMS:** 
```
UID: your UID obtained from getUID API   
binary data : image in .jpg format
```

This API will take UID(which we obtained before) parameter and image (.jpg format) through post method. we recommend you to use postman app to easily upload images. This API detects and extracts your face in the uploaded/saved photos of the specified UID and saves in the dataset folder ==> ( FacePass\ Webservice/dataset/ )


### Training faces

**URL:**`localhost:5000/train/`

**METHOD:**`GET`


This API will train the faces stored in the dataset folder and creates a `.yaml` file that is used to store the data for face recognition.

### Recognizing faces

**URL:**`localhost:5000/recognize/`

**METHOD:**`POST`

**PARAMS:** 
```
binary data : image in .jpg format
```

This API will take image (.jpg format) through post method. we recommend you to use postman app to easily upload images. This API detects and Recognizes the face from the photo given to the API. 
