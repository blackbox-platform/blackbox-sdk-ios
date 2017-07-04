var express = require('express');
var app = express();
 
app
  .use(require('log-request'))
  .listen(3000);

