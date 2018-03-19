Oracle Java on Docker
=====
Build a Docker image containing Oracle Java (Server JRE specifically).

The Oracle Java Server JRE provides the same features as Oracle Java JDK commonly required for Server-side Applications (i.e. Java EE application servers). For more information about Server JRE, visit the [Understanding the Server JRE](https://blogs.oracle.com/java-platform-group/understanding-the-server-jre) blog entry from the Java Product Management team.

## Java 8
[Download Server JRE 8](http://www.oracle.com/technetwork/java/javase/downloads/server-jre8-downloads-2133154.html) `.tar.gz` file and drop it inside folder `java-8`. If you download Java 1.8 with the latest update from MOS (see Doc ID [1439822.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=1439822.1)), make sure to first unzip the `p<PATCHID>_180<UPDATE>_Linux-x86-64.zip` file. This Dockerfile expects the Java package in the form `server-jre-8u<UPDATE>-linux-x64.tar.gz`.

Build it:

```
$ cd java-8
$ docker build -t oracle/serverjre:8 .
```

Alternatively you may use the shell script `build.sh` to build the docker images. The script does check if a server JRE package (`server-jre-8u<UPDATE>-linux-x64.tar.gz`) is available. Otherwise it either tries to fallback to a local Java patch package (eg. `p<PATCHID>_180<UPDATE>_Linux-x86-64.zip`) or download the Java patch package from MOS using [curl](https://linux.die.net/man/1/curl). Since you have to be logged in to MOS, curl needs a `.netrc` file with the MOS credentials.

Build with a local `server-jre-8u<UPDATE>-linux-x64.tar.gz` or `p<PATCHID>_180<UPDATE>_Linux-x86-64.zip` file:

```
$ cd java-8
$ ./build.sh
```

Create a `.netrc` file containing the credentials for *login.oracle.com* to automatically download the Java patch package before building the docker image:

```
    $ cd java-8
    $ echo "machine login.oracle.com login <MOS_USER> password <MOS_PASSWORD>" >.netrc
    $ ./build.sh
```

## License

To download and run Oracle Java, regardless whether inside or outside a Docker container, you must download the binaries from the Oracle website and accept the license indicated at that page.
