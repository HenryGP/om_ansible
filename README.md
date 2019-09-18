# OM Ansible

Minimalistic, disposable Ops Manager environment with Ansible.

## Quickstart
1. Create a local directory to use as home for OM Ansible and clone this repository into that directory:
   ```
   mkdir ~/om_ansible
   git clone https://github.com/HenryGP/om_ansible ~/om_ansible
   ```
1. Start using om_ansible:
   1. [Usage with Docker](https://github.com/HenryGP/om_ansible/wiki/Usage-with-Docker)
   1. [Usage with Vagrant](https://github.com/HenryGP/om_ansible/wiki/Usage-with-Vagrant)

## Infrastructure
The default infrastructure consists of the following components:

|Host|IP address|Role|
|-|-|-|
|omserver|192.168.1.100|Ops Manager server + Application DB|
|n\[1-2\]|192.168.1.10\[1-2\]|client with Automation installed|
|bkp|192.168.1.103|S3 storage|  
|provisioner*|192.168.1.99|Ansible provisioner|
|ldapserver*|192.168.1.104|OpenLDAP server|
|kmip*|192.168.1.105|KMIP server|

\* only available if using Docker

## Access to UIs
Once the infrastructure has been provisioned, the following UIs can be accessed:
- Ops Manager UI: 
   - URL: http://localhost:8080 or https://localhost:8443 if [https for Ops Manager](https://github.com/HenryGP/om_ansible/wiki/Security#https-for-ops-manager-server-) was enabled. 
   - User: admin
   - Password: Password1!
- S3 minio UI: http://localhost:9000
   - Access key: minio
   - Secret key: miniostorage

## Further information and resources
Please refer to this repository's [wiki page](https://github.com/HenryGP/om_ansible/wiki) for more details. 
