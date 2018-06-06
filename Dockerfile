FROM python:2.7
 
# Install Ansible from source (master)
RUN apt-get -y update && apt-get install -y wget && \
    apt-get install -y python-httplib2 python-keyczar python-setuptools python-pkg-resources git python-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN pip install paramiko jinja2 PyYAML setuptools pycrypto>=2.6 six \
    requests docker-py  # docker inventory plugin
RUN wget http://releases.ansible.com/ansible/ansible-2.3.1.0.tar.gz && \
    tar xvf ansible-2.3.1.0.tar.gz -C /opt && \
    pip install -r /opt/ansible-2.3.1.0/requirements.txt

#git clone http://github.com/ansible/ansible.git /opt/ansible && \
#    cd /opt/ansible && \
#    git reset --hard fbec8bfb90df1d2e8a0a4df7ac1d9879ca8f4dde && \
#    git submodule update --init
 
#ENV PATH /opt/ansible/bin:$PATH
#ENV PYTHONPATH $PYTHONPATH:/opt/ansible/lib
#ENV ANSIBLE_LIBRARY /opt/ansible/library

ENV PATH /opt/ansible-2.3.1.0/bin:$PATH
ENV PYTHONPATH $PYTHONPATH:/opt/ansible-2.3.1.0/lib
ENV ANSIBLE_LIBRARY /opt/ansible-2.3.1.0/library

# setup ssh
RUN mkdir /root/.ssh
ADD /inventory/clients/keys/id_rsa /root/.ssh/id_rsa
ADD /inventory/clients/keys/id_rsa.pub /root/.ssh/id_rsa.pub
RUN chmod 700 /root/.ssh/id_rsa
 
# extend Ansible
# use an inventory directory for multiple inventories support
ADD inventory/provisioner/ansible.cfg  /etc/ansible/ansible.cfg
ADD inventory/provisioner/hosts  /etc/ansible/inventory/hosts

ADD tasks /root/tasks
ADD files /root/files
ADD vars /root/vars
ADD tests /root/tests
ADD om_ansible.yaml /root/om_ansible.yaml