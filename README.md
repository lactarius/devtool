# devtool
LEMP with multiversion PHP project manager

#### Load devtool helper

```shell
cd devtool
source cli.sh
cd
```
#### Prepare environment
```
envi prep [ --force | -f ]
```
* --force - remove first

#### Remove environment
```
envi tidy
```

#### Create site
```
site add website [ --root | -r PATH ] [ --php | -p X.Y ] [ --quiet | -q ] [ --simple | -s ]
```
* --root - project root path (index.php)
* --php	- PHP version
* --quiet - register only existing project directory
* --simple - don't touch the hosts order

#### Disable / enable site
```
site dis / ena website
```

#### Remove site
```
site rm website [ --force | -f ]
```
* --force - remove rests and all PHP versions pools

#### List sites
```
site ls
```

_Individually_:

#### Create PHP-FPM pool for site
```
pool add website [ --php | -p X.Y ]
```
* --php	- PHP version

#### Add IP host record for site
```
host add website [ --simple ]
```
* --simple - don't touch the hosts order

_Services_:

```
svc [ p | r | s ] [ service(s) ]
```
* p - stop
* r - restart
* s - start

_Services status_:
```
svc
```


_Example - restart NginX server and PHP7.2 FPM services_:
```
svc r ng 2
```


_Variables & Paths_
* All these settings are in the file _var.sh_.
