FROM scratch
LABEL org.opencontainers.image.authors = "binhex"
LABEL org.opencontainers.image.source = "https://github.com/binhex/arch-base"

ARG TARGETARCH

# additional files
##################

# add supervisor conf file
ADD build/${TARGETARCH}/*.conf /etc/supervisor.conf

# add install bash script
ADD build/${TARGETARCH}/root/*.sh /root/

# add statically linked busybox arm64
ADD build/${TARGETARCH}/utils/busybox/busybox /bootstrap/busybox

# add build bootstrap file
ADD build/${TARGETARCH}/build-bootstrap.sh /bootstrap/build-bootstrap.sh


# unpack tarball
################

# symlink busybox utilities to /bootstrap folder
RUN ["/bootstrap/busybox", "--install", "-s", "/bootstrap"]

# run busybox bourne shell and use sub shell to execute busybox utils (wget, rm...)
# to download and extract tarball.
# once the tarball is extracted we then use bash to execute the install script to
# install everything else for the base image.
# note, do not line wrap the below command, as it will fail looking for /bin/sh
RUN ["/bootstrap/sh", "-c", "/bootstrap/build-bootstrap.sh"]

# env
#####

# set environment variables for user nobody
ENV HOME /home/nobody

# set environment variable for terminal
ENV TERM xterm

# set environment variables for language
ENV LANG en_GB.UTF-8

# run
#####

# run dumb-init to manage graceful exit and zombie reaping
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
