# ----------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: Dockerfile 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.03.19
# Revision...: 1.0
# Purpose....: This Dockerfile is to build Oracle Java 1.8
# Notes......: This Dockerfile is based on Oracle's Dockerfile for 
#              Java 1.8.
#              Build this image : docker build -t oracle/serverjre:8 .
# Reference..: https://github.com/oracle/docker-images/tree/master/OracleJava
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ----------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ----------------------------------------------------------------------

# Pull base image
# ----------------------------------------------------------------------
FROM oraclelinux:7-slim

# Maintainer
# ----------------------------------------------------------------------
LABEL maintainer="stefan.oehrli@trivadis.com"

# Install tar, gzip and libaio for OUD stuff 
# enable cipher legacy 3DES_EDE_CBC for Oracle EUS
# ----------------------------------------------------------------------
RUN echo "%_install_langs  en" >/etc/rpm/macros.lang && \
    yum install -y libaio gzip tar && \
    rm -rf /var/cache/yum

# Environment variables required for this build (do NOT change)
# ----------------------------------------------------------------------
ENV JAVA_PKG=server-jre-7u*-linux-x64.tar.gz \
    JAVA_HOME=/usr/java/default

# Copy Java packages to their default location
# ----------------------------------------------------------------------
ADD $JAVA_PKG /usr/java/

# Install Java respectively update alternatives for Java
# ----------------------------------------------------------------------
RUN export JAVA_DIR=$(ls -1 -d /usr/java/*|tail -1) && \
    ln -s $JAVA_DIR /usr/java/latest && \
    ln -s $JAVA_DIR /usr/java/default && \
    alternatives --install /usr/bin/java java $JAVA_DIR/bin/java 20000 && \
    alternatives --install /usr/bin/javac javac $JAVA_DIR/bin/javac 20000 && \
    alternatives --install /usr/bin/jar jar $JAVA_DIR/bin/jar 20000

COPY java.security /usr/java/latest/jre/lib/security/java.security
# --- EOF --------------------------------------------------------------