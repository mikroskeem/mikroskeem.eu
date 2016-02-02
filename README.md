# mikroskeem's personal site

So, here it is, my awesome webpage. It was created with idea to render everything in browser, not in server.

This idea gives portability, I can migrate my page to every server, since there is no server-side code requred (but webserver configuring is).

### Building
You need to have gulp and bower in path (`npm install -g gulp bower`) and nginx installed (to run bundled mocha tests)

```
$ git clone --depth=1 git@gitlab.com:mikroskeem/mikroskeem.eu.git
$ cd mikroskeem.eu
$ npm run build
$ npm run test-page
$ npm run test-server
(in another terminal)
$ npm test
```

### Configuring web server
nginx is preferred

Use this config:
```
    server {
        server_name     mikroskeem.eu;
        charset         utf-8;
        listen          80;
        root            /var/www/mikroskeem.eu;
        location / {
            set $req_file $uri;
            if ($uri = "/") {
                set $req_file /index.html;
            }
            try_files $req_file =404;
        }
        location ~ /static/ {
            expires max; 
        }
        location ~ /pages/(.+?)\.(md|html)$ {
            try_files $uri =404;
        }
        location ~ /pages/(.+?) {
            try_files /index.html =404;
        }
    }
```

### Known bugs
- CI tests page building, not page itself.
- Sometimes page gets stuck for 2-3 secs while changing page

### Why HTML Imports?
Honestly Markdown isn't that great. You can't use custom stuff like editors and such.  
So it'd better to support both Markdown and HTML imo (I don't want to rewrite my pages by hand)
