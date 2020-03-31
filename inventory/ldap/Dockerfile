# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.11

# Install and configure OpenLDAP binaries
ENV DEBIAN_FRONTEND=noninteractive
ADD conf/slapd-deb.conf /tmp
RUN apt-get update && \
    apt-get install openssh-client openssh-server sudo -y && \
    cat /tmp/slapd-deb.conf | debconf-set-selections && \
    apt-get install ldap-utils slapd -y 
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -f /etc/service/sshd/down

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# setup user for ansible
RUN useradd admin -s /bin/bash -m && \
    echo "admin:welcome" | chpasswd && \
    echo "admin:x:${uid}:${gid}:Abc,,,:/home/admin:/bin/bash" >> /etc/passwd && \
    echo "admin:x:${uid}:" >> /etc/group && \
    echo "admin ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/admin && \
    chmod 0440 /etc/sudoers.d/admin && \
    chown ${uid}:${gid} -R /home/admin

# setup ssh
RUN mkdir /home/admin/.ssh
ADD keys/id_rsa.pub /home/admin/.ssh/authorized_keys
RUN chown -R admin:admin /home/admin && chmod 700 /home/admin/.ssh && chmod 640 /home/admin/.ssh/authorized_keys

# Copy ldif files and configure memberOf, users and groups
ADD ldif/*.ldif /tmp/

# prepare slapd service
RUN mkdir -p /etc/service/slapd
#RUN echo -e '#!/bin/sh\nSLAPD_OPTIONS=""\n\nif [ -f "/etc/default/slapd" ]; then\n   . /etc/default/slapd\nfi\n\nif [ ! -d /var/run/openldap ]; then\n    install -d -o $SLAPD_USER -g $SLAPD_GROUP -m 755 /var/run/openldap\nfi\nif [ -z "$SLAPD_SERVICES" ]; then\n    exec /usr/sbin/slapd -d 0 -u $SLAPD_USER -g $SLAPD_GROUP $SLAPD_OPTIONS\nelse\n    exec /usr/sbin/slapd -d 0 -u $SLAPD_USER -g $SLAPD_GROUP -h "$SLAPD_SERVICES" $SLAPD_OPTIONS\nfi' > /etc/service/slapd/run
COPY slapd.runsv /etc/service/slapd/run
RUN chmod 755 /etc/service/slapd/run

EXPOSE 389

EXPOSE 636

EXPOSE 22

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

