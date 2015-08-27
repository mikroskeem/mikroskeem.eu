# mikroskeem's personal site

So, here it is, my awesome webpage. It was created with idea to render everything in browser, not in server.

This idea gives portability, I can migrate my page to every server, since there is no server-side code requred (but webserver configuring is).

### Building
You need to have gulp and bower in path (`npm install -g gulp bower`)

```
$ git clone --depth=1 git@gitlab.com:mikroskeem/mikroskeem.eu.git
$ cd mikroskeem.eu
$ npm run build
$ npm run test-page
```

### Configuring web server
nginx is preferred

Use this config:
```
	server {
		server_name	mikroskeem.eu;
		charset		utf-8;
		listen		80;
		root		/var/www/mikroskeem.eu;
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
		location ~ /pages/(.+?)\.(md)$ {
			if ($http_x_requested_with != "XMLHttpRequest") {
				return 403;
			}
			try_files $uri =404;
		}
	    location ~ /pages/(.+?) {
            try_files /index.html =404;
        }
    }
```

### Known bugs
None!

### Why did I started using jQuery, even if I promised not to?

Honestly, it is pain to write XMLHttpRequest functions by hand. It makes code worse and makes readability bad.
