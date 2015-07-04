var app, express;
express = require("express");
app = express();
app.set('etag', 'strong');
app.use('/', express["static"]('./dest'));
app.listen(8080, function() {
  console.log('Running');
});
