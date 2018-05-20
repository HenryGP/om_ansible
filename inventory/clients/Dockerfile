FROM centos:centos7

#ENV container=docker

RUN yum swap -y fakesystemd systemd && \
    yum install -y systemd-devel
RUN yum -y update && \
    yum install -y initscripts openssh openssh-server openssh-clients sudo passwd sed screen tmux byobu which vim-enhanced
RUN sshd-keygen
RUN sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config

#RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
#systemd-tmpfiles-setup.service ] || rm -f $i; done); \
#rm -f /lib/systemd/system/multi-user.target.wants/*;\
#rm -f /etc/systemd/system/*.wants/*;\
#rm -f /lib/systemd/system/local-fs.target.wants/*; \
#rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
#rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
#rm -f /lib/systemd/system/basic.target.wants/*;\
#rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN useradd admin -G wheel -s /bin/bash -m && \
    echo "admin:welcome" | chpasswd && \
    echo "admin:x:${uid}:${gid}:Abc,,,:/home/abc:/bin/bash" >> /etc/passwd && \
    echo "admin:x:${uid}:" >> /etc/group && \
    echo "admin ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/admin && \
    chmod 0440 /etc/sudoers.d/admin && \
    chown ${uid}:${gid} -R /home/admin

# setup default user
#RUN useradd admin -G wheel -s /bin/bash -m
#RUN echo "admin:welcome" | chpasswd
#RUN echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# setup ssh
RUN mkdir /home/admin/.ssh
ADD keys/id_rsa.pub /home/admin/.ssh/authorized_keys
RUN chown -R admin:admin /home/admin && chmod 700 /home/admin/.ssh && chmod 640 /home/admin/.ssh/authorized_keys

#VOLUME /sys/fs/cgroup /run /tmp

# expose ports for ssh
EXPOSE 22
CMD /usr/sbin/init