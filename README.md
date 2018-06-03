# OM Ansible

Minimalistic, disposable Ops Manager environment with Ansible.

## Table of contents

1. [Installation](#installtion)
1. [Usage with Docker](#docker)
1. [Usage with Vagrant](#vagrant)
1. [Infrastructure](#infrastructure)

## Installation <a name="installation"></a>

1. Create a local directory to use as home for OM Ansible and clone this repository into that directory:
   ```
   mkdir ~/om_ansible
   git clone https://github.com/HenryGP/om_ansible ~/om_ansible
   ```

**To use with Docker**

1. [Install Docker Compose](https://docs.docker.com/compose/install/)
1. **IMPORTANT!** Start the Docker UI and raise the memory limit to at least 4GB. This will avoid any issues with the Ops Manager server particularly.
   - If running on Mac OS refer to the documentation on [getting started with Docker for Mac](https://docs.docker.com/docker-for-mac/)

**To use with Vagrant**
1. [Download and install Virtual Box](https://www.virtualbox.org/wiki/Downloads)
1. [Install Vagrant](https://www.vagrantup.com/docs/installation/)
1. [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## Usage with Docker <a name="docker"></a>
1. Navigate to the directory used for om_ansible, in this case `~/om_ansible`:
   ```
   cd ~/om_ansible
   ```
1. Build the images for creating the infrastructure:
   ```
   docker-compose build
   ```
1. Create the containers:
   ```
   docker-compose up -d
   ```
1. Provision containers by executing general Ansible task:
   ```
   docker exec -it om_ansible_dev_provisioner_1 /opt/ansible-2.3.1.0/bin/ansible-playbook /root/om_ansible.yaml
   ```
   **NOTE** The plans following tasks are expected to fail on containers due to the nature of Docker containers:
   - Copy mongodb repository files (changing /etc/hosts)
   - Set SELinux to permissive
   - Changing SELinux context
   These are the only tasks ignored by Ansible in case of failure, the rest will stop the execution in case of failure.
1. Check the container names by executing `docker ps`
1. ssh into an specific container:
   ```
   docker exec -ti <container_name> /bin/bash
   ```
1. Pause/resume environment:
   ```
   docker-compose pause/unpause
   ```
1. Destroy the containers:
   ``` 
   docker-compose down
   ```

Access the following UIs using the web browser:
- Ops Manager UI: http://localhost:8080
   - User: admin
   - Password: Password1!
- S3 minio UI: http://localhost:9000
   - Credentials will be provided by Ansible when provisioning.

## Usage with Vagrant <a name="vagrant"></a>
1. Navigate to the directory used for om_ansible, in this case `~/om_ansible`:
   ```
   cd ~/om_ansible
   ```
1. Create the Virtual Machines using vagrant:
   ```
   vagrant up
   ```
   - Optionally you can startup individual virtual machines:
     ```
     vagrant up opsmgr
     ```
1. Provision the started Virtual Machine:
   ```
   vagrant provision <vm_name>
   ```
1. ssh into the instance:
   ```
   vagrant ssh <vm_name>
   ```
1. Pause environment:
   ```
   vagrant suspend
   ```
1. Destroy environment:
   ```
   vagrant destroy
   ```

Access the following UIs using the web browser:
- Ops Manager UI: http://192.168.1.100:8080
   - User: admin
   - Password: Password1!
- S3 minio UI: http://192.168.1.103:9000
   - Credentials will be provided by Ansible when provisioning.

## Infrastructure <a name="infrastructure"></a>

The default infrastructure consists of the following:

|Host|IP address|Role|
|-|-|-|
|omserver|192.168.1.100|Ops Manager server + Application DB|
|n\[1-2\]|192.168.1.10\[1-2\]|client with Automation installed|
|bkp|192.168.1.103|S3 storage|  
|provisioner*|192.168.1.99|Ansible provisioner|

\* only if using Docker