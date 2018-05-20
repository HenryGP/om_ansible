FROM centos:7

RUN yum -y update && yum install -y initscripts openssh openssh-server openssh-clients sudo passwd sed screen tmux byobu which vim-enhanced
RUN sshd-keygen
RUN sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config

# setup default user
RUN useradd admin -G wheel -s /bin/bash -m
RUN echo "admin:welcome" | chpasswd
RUN echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# setup ssh
RUN mkdir /home/admin/.ssh
ADD keys/id_rsa.pub /home/admin/.ssh/authorized_keys
RUN chown -R admin:admin /home/admin && chmod 700 /home/admin/.ssh && chmod 640 /home/admin/.ssh/authorized_keys

# expose ports for ssh
EXPOSE 22
#CMD ["/usr/sbin/sshd", "-D"]