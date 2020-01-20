# Common Scripts

Common scripts to build the miscellaneous Docker images.

- [buildAllDB.sh](buildAllDB.sh) Script to build all Oracle database images e.g. Dockerfiles in ./OracleDatabase/1?.?.?.? 
- [buildAllDS.sh](buildAllDS.sh) Script to build all Oracle directory server e.g. Dockerfiles in ./OracleJava, ./OracleODSEE, ./OracleOUD and ./OracleOUDSM folder.
- [buildAllOUD.sh](buildAllOUD.sh) Script to build all Oracle Unified Directory images e.g. Dockerfiles in ./OracleOUD and ./OracleOUDSM folder.
- [buildDB.sh](buildDB.sh) Script to build specific Oracle database images. Release can be specified as parameter. If omitted a list of possible releases will be displayed.
- [pushAllDB.sh](pushAllDB.sh) Script to push all local Oracle database images to the trivadis Docker Hub respository. Other repository can be specified by defining the environment variables `DOCKER_USER` and `DOCKER_REPO`.
- [pushAllDS.sh](pushAllDS.sh) Script to push all Oracle directory server images to the trivadis Docker Hub respository. Other repository can be specified by defining the environment variable `DOCKER_USER`.
- [saveAllDB.sh](saveAllDB.sh) Script to save / export Oracle database images to `${DOCKER_VOLUME_BASE}/../images`.
- [saveAllDS.sh](saveAllDS.sh) Script to save / export Oracle directory server images to `${DOCKER_VOLUME_BASE}/../images`.