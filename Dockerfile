FROM python:3.7

# Update
RUN apt-get -y update

# Upgrade included pip
RUN pip install --upgrade pip

# Install latest (stable) Ansible version
RUN pip install ansible

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