var readline = require('readline');
var Firebase = require('firebase');

var fbref = new Firebase("https://rliu42.firebaseio.com/infolounge/notifications");

var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

var question = function() {
  rl.question("message: ", function(answer) {
    var tmp = new Date();
    if (answer !== 'exit') {
      fbref.set({ message: answer, timestamp: tmp}, function() {
        question();
      });
    } else {
      process.exit(code=0)
    }
  }); 
}

question();