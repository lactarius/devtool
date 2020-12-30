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
site add website [ --root | -r PATH ] [ --php | -p X.Y ] [ --force | -f ] [ --simple | -s ]
```
* --root - project root path (index.php)
* --php	- PHP version
* --force - force defined document root
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

#### Services
```
svc [ p | r | s ] [ service(s) ]
```
* p - stop
* r - restart
* s - start

#### Services status
```
svc
```

#### Switch PHP current version
```
phpsw X.Y
```
#### Examples

_Create empty site **webarchive**_
```
site add webarchive
```
* docroot **www**
* PHP **current** version

_Create site **stack** from existing project choosing older PHP version_
```
site add stack -p 7.1
```
* docroot **original** (obtained)
* PHP **7.1**

_Remove site **stack** with all PHP versions pools_
```
site rm stack -f
```
_Removed_:
* PHP **7.1** pool definition
* **NginX** definition
* hosts record
* Project source directory

_Restart **NginX** server and **PHP7.1 FPM** service_:
```
svc r ng 2
```

#### Variables & Paths
* All these settings are in the file _var.sh_.
