# mikroskeem's peronal site

So, here it is, my awesome webpage. It was created with idea to render everything in browser, not in server.

This idea gives portability, I can migrate my page to every server, since there is no server-side code requred (but webserver configuring is).

### Building
You need to have gulp and bower in path (`npm install -g gulp bower`)

```
$ git clone --depth=1 git@gitlab.com:mikroskeem/mikroskeem.eu.git
$ cd mikroskeem.eu
$ bower install
$ npm install
$ mkdir dest/pages
$ npm run test-page
```

### Configuring web server
nginx is preferred

Use this config:
```
server {
	server_name	mikroskeem.eu;
	listen		50001;

	root	/var/www/mikroskeem.eu;
	location / {
		try_files $uri /index.html;
	}
	location ~ \.(md)$ {
		if ($http_x_requested_with != XMLHttpRequest) {
			return 403;
		}
		try_files $uri =404;
	}
}
```

### Known bugs
If you have **_JAVA_OPTIONS** in environment, remove it before building (Look at this [issue](https://github.com/steida/gulp-closure-compiler/issues/33))
