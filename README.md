# Project FacePass

### Designed by [Haze Corp](Hazecorp.co)

![Alt text](https://pbs.twimg.com/media/DLhGc5wUEAAAXMm.jpg "FacePass")

The Facial recognition system made with OpenCV python library 

## Installation:

Build and run the project in xcode to test the facial recognition feature.

To test out the _Webservice_ or code behind the facial recognition follow the steps given below:

1.install virtualenv:
`pip install virtualenv`

2.create a virual environment:
 `virtualenv facepassenv`
 
3.activate virtualenv:
`source facepassenv/bin/activate`

4.change directory to webservice dir:
`cd FacePass\ Webservice`

5.install the required dependencies:
`pip install -r requirements.txt`

this will install the required dependencies for the project automatically

6.Now the flask app using:
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


