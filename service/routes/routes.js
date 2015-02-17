var express = require('express');
var multer = require('multer');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', { title: 'Express' });
});

var done = false;
router.post('/api/photo', [multer({ dest: './uploads/',
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
}), function(req, res) {
  if (done) {
    console.log(req.files);
    res.end("File uploaded.");
  }
}]);

module.exports = router;