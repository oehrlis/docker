Oracle Software usually can not be downloaded during build without providing some credentials. If the binaries are downloaded using curl or wget the credentials will remain in the docker image. One solution would be to keep the binaries in the docker build context and use *squash* or multi stage builds. Alternatively it is also possible to use a local web server (docker container) to download the files locally.
  
* Start a simple web server to locally share the software during docker build.

```bash
docker run -dit \
  --hostname orarepo \
  --name orarepo \
  -p 80:80 \
  -v /data/docker/volumes/orarepo:/www \
  busybox httpd -fvvv -h /www
```

* Get the IP of the web server

```bash
orarepo_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' orarepo)
```

* Using the local software repository during *docker build*

```bash
docker build --add-host=orarepo:${orarepo_ip} -t oracle/database:18.4.0.0 .
```