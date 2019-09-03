# OM Ansible

Minimalistic, disposable Ops Manager environment with Ansible.

## Table of contents

1. [Installation](#installtion)
1. [Usage with Docker](#docker)
1. [Usage with Vagrant](#vagrant)
1. [Local and internet mode](#provisioningmodes)
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
   - Click on the Docker icon at the topbar and select `Preferences`:
      
      ![](files/docker_menu.png)
   - Select 'Advanced' and increase the memory limit to *at least* 4GB.
      
      ![](files/docker_memory.png)
  - Click on 'Apply and restart'


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
   docker-compose exec provisioner ansible-playbook /root/om_ansible.yaml
   ```
1. Check the container names by executing `docker ps`
1. ssh into an specific container:
   ```
   docker-compose exec <container_name> bash
   ```
1. Pause/resume environment:
   ```
   docker-compose [pause|unpause]
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
1. Set the variable `vms` in _vars/om-install-vars.yaml_ to `true`.
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
   - Access key: minio
   - Secret key: miniostorage

## Local and internet mode <a name="provisioningmodes"></a>

When provisioning the Ops Manager server, Ansible by default will proceed to download the required _rpm_ package from the URL specified in the `om_download_url` parameter under the _vars_ directory.
If you have already downloaded a package, you can modify the _vars/om-install-vars.yaml_ and set the `local_mode` variable to `true`. Additionally, rename the downloaded package to _mongodb-mms.rpm_ and place it in the _files_ directory.

## Infrastructure <a name="infrastructure"></a>

The default infrastructure consists of the following:

|Host|IP address|Role|
|-|-|-|
|omserver|192.168.1.100|Ops Manager server + Application DB|
|n\[1-2\]|192.168.1.10\[1-2\]|client with Automation installed|
|bkp|192.168.1.103|S3 storage|  
|provisioner*|192.168.1.99|Ansible provisioner|
|ldapserver*|192.168.1.104|OpenLDAP server|

\* only available if using Docker
