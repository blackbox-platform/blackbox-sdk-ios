var express = require('express');
var app = express();

app
  .use(require('log-request'), require('body-parser').json(), (req, res) => {
    if (req.body) {
      console.log(JSON.stringify(req.body, undefined, 4))
    }

    res.end();
  })
  .listen(3000);

