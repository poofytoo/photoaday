/*Define dependencies.*/

var express=require("express");
var multer  = require('multer');
var apn = require('apn');
var Firebase = require('firebase');

var app = express();
var done = false;

/*Configure the multer.*/

var options = { 
  gateway:"gateway.sandbox.push.apple.com"
};

var apnConnection = new apn.Connection(options);
var myDevice = new apn.Device("6e990cbedb33b90e228037a93b88449a055f045ffcb9ab4cd4171a89769f6b85");

var fbref = new Firebase("https://rliu42.firebaseio.com/infolounge/notifications");

fbref.on('value', function(snapshot) {
  data = snapshot.val();
  console.log("received new message: ", data.message);
  console.log("full message payload: ", data);
  var note = new apn.Notification();

  note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
  note.badge = 1;
  note.sound = "default";
  note.alert = data.message;
  note.payload = {'messageFrom': 'S3 Alert Server'};

  // apnConnection.pushNotification(note, myDevice);
})

app.use(multer({ dest: './uploads/',
 rename: function (fieldname, filename) {
    return filename+Date.now();
  },
  onFileUploadStart: function (file) {
    console.log(file.originalname + ' is starting ...')
  },
  onFileUploadComplete: function (file) {
    console.log(file.fieldname + ' uploaded to  ' + file.path)
    done = true;
  }
}));

/* Handling routes. */

app.get('/', function(req,res){
  res.sendfile("index.html");
});

app.post('/api/photo', function(req,res){
  if (done == true){
    console.log(req.files);
    res.end("File uploaded.");
  }
});

/*Run the server.*/
app.listen(8000,function(){
    console.log("Working on port 8000");
});