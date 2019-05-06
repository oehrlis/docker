# Common Scripts

Common scripts to build the miscellaneous Docker images.

| Script                           | Description                                                                    |
|----------------------------------|--------------------------------------------------------------------------------|
| [buildAllDB.sh](buildAllDB.sh)   | Script to build all Oracle database images e.g. Dockerfiles in ./OracleDatabase/1?.?.?.? folder.                          |
| [buildAllDS.sh](buildAllDS.sh)   | Script to build all Oracle directory server e.g. Dockerfiles in ./OracleJava, ./OracleODSEE, ./OracleOUD and ./OracleOUDSM folder. |
| [buildAllOUD.sh](buildAllOUD.sh) | Script to build all Oracle Unified Directory images e.g. Dockerfiles in ./OracleOUD and ./OracleOUDSM folder. |
| [pushAllDB.sh](pushAllDB.sh)     | Script to push all Oracle database images e.g. to the trivadis Docker Hub respository   |
| [pushAllDS.sh](pushAllDS.sh)     | Script to push all Oracle directory server images e.g. to the trivadis Docker Hub respository   |
| [saveAllDB.sh](saveAllDB.sh)     | Script to save / export Oracle database images to `${DOCKER_VOLUME_BASE}/../images`.                                           |
| [saveAllDS.sh](saveAllDS.sh)     | Script to save / export Oracle directory server images to `${DOCKER_VOLUME_BASE}/../images`.                                           |Script to install Oracle server jre.                                           |
