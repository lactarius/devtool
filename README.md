# devtool
LEMP with multiversion PHP project manager

* Load devtool helper

```shell
cd devtool
source cli.sh
cd
```
* Prepare environment
```
envi prep [ --force ]
```

* Create site
```
site add website [ --root src/www ] [ --php 7.1 ]
```

* Disable / enable site
```
site dis / ena website
```

* List sites
```
site ls
```

* Remove site
```
site rm website [ --force ]
```

_Not necessary, but you can_:

* Create PHP-FMT pool for site
```
pool add website [ --php 7.1 ]
```

* Add IP host record for site
```
host add website
```

* Remove environment
```
envi tidy
```

_Services_:

```
svc [ command ] [ service(s) ]
```
_Commands_:
* p - stop
* s - start
* r - restart

_Services status_:
```
svc
```
_Restart NGINX server and PHP7.2 FMT services_:
```
svc r ng 2
```


_Variables & Paths_
* All these settings are in the file _var.sh_.
