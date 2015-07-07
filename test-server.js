var app, express, mime, fs;
express = require("express");
mime = require("mime");
fs = require("fs");
app = express();
app.set('etag', 'strong');
app.use('/', function(req,res){
  var url = req.originalUrl;
  var fpath = __dirname + "/dest" + url;
  var indexpath = __dirname + "/dest/index.html";
  fs.exists(fpath, function(exists){
    console.log(fpath, exists);
    if(exists){
      fs.lstat(fpath, function(err,stat){
        err && console.log(err);
        if(!stat.isDirectory()){
          var check = /\/pages\/(.*?)\.md/.exec(url) && req.headers["x-requested-with"] === "XMLHttpRequest";
          if(check){
          } else if(/\/static\//.test(url)){
          } else {
            res.sendStatus(403);
            return;
          }
          fs.readFile(fpath, "utf-8", function(err,data){
            err && console.log(err);
            res.setHeader("Content-Type", mime.lookup(fpath));
            res.writeHead(200)
            res.end(data);
          });
        } else {
            fs.readFile(indexpath, "utf-8", function(err,data){
              err && console.log(err);
              res.setHeader("Content-Type", "text/html");
              res.writeHead(200);
              res.end(data);
            });
        }
      });
    } else {
      fs.readFile(indexpath, "utf-8", function(err,data){
        err && console.log(err);
        res.setHeader("Content-Type", "text/html");
        res.writeHead(200);
        res.end(data);
      });
    }
  });
});
app.listen(8080, function() {
  console.log('Running');
});
