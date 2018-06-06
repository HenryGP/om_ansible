## Information

This image uses OpenLDAP and a predefined set of users and groups for quickly testing LDAP integration with MongoDB Enterprise and MongoDB Ops Manager. These can be found in `ldif/users.ldif` and `ldif/groups.ldif` respectively.

## User and groups structure

All users have the same password, `Password1!`. The following users have been predefined:

### MongoDB database users
|User|MemberOf|
|-|-|
|uid=dba,ou=dbUsers,dc=tsdocker,dc=com|cn=dbAdmin,ou=dbRoles,dc=tsdocker,dc=com|
|uid=writer,ou=dbUsers,dc=tsdocker,dc=com|cn=readWriteAnyDatabase,ou=dbRoles,dc=tsdocker,dc=com|
|uid=reader,ou=DbUsers,dc=tsdocker,dc=com|cn=read,ou=dbRoles,dc=tsdocker,dc=com|

### Ops Manager Agents
|User|MemberOf|
|-|-|
|uid=mms-automation,ou=dbUsers,dc=tsdocker,dc=com|cn=automation,ou=dbRoles,dc=tsdocker,dc=com|
|uid=mms-monitoring,ou=dbUsers,dc=tsdocker,dc=com|cn=monitoring,ou=dbRoles,dc=tsdocker,dc=com|
|uid=mms-backup,ou=dbUsers,dc=tsdocker,dc=com|cn=backup,ou=dbRoles,dc=tsdocker,dc=com|

### Ops Manager users
|User|MemberOf|
|-|-|
|uid=owner,ou=omusers,dc=tsdocker,dc=com|cn=owners,ou=omgroups,dc=tsdocker,dc=com|
|uid=reader,ou=omusers,dc=tsdocker,dc=com|cn=readers,ou=omgroups,dc=tsdocker,dc=com|
|uid=admin,ou=omusers,dc=tsdocker,dc=com|cn=owners,ou=omgroups,dc=tsdocker,dc=com|

## Build steps

1. Build the Docker image with a tag. Execute the following command while in the current directory:
   ```
   docker build -t ts-ldap .
   ```
   This will create an image with tag name `ts-ldap`.
1. Run the container image by executing:
   ```
   docker run -p 389:389 -tih ldapserver ts-ldap bash
   ```
1. Start the `slapd` service once inside the container:
   ```
   service slapd start
   ```
   The LDAP server listens to 389 in localhost (inside the container) but is also mapped to the host server where it is running. For contacting the LDAP server from outside the container you can use the host IP address. Use `ifconfig` to determine your host's IP address. For example:
   ```
   $ ifconfig
    ...
    en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
        ether 4c:32:75:91:b0:81
        inet6 fe80::14fc:96b9:fc8c:2936%en0 prefixlen 64 secured scopeid 0x5
        inet 192.168.0.59 netmask 0xffffff00 broadcast 192.168.0.255
        inet6 2a02:8084:23:6380:1404:a47:2e03:e8c5 prefixlen 64 autoconf secured
        inet6 2a02:8084:23:6380:45c4:f582:722d:91b1 prefixlen 64 autoconf temporary
        nd6 options=201<PERFORMNUD,DAD>
        media: autoselect
        status: active
    ...
   ```
1. Verify the LDAP server can be reached by binding to the 'admin' user. Note that the following example uses the IP address from the host shared as an example in item 3:
   ```
   ldapsearch -x -w Password1! -D cn=admin,dc=tsdocker,dc=com -b dc=tsdocker,dc=com -h 192.168.0.59
   ```

## LDAP integrations
### LDAP + SASL authentication for MongoDB

1. Follow the documentation on [Authenticate Using SASL and LDAP with OpenLDAP](https://docs.mongodb.com/manual/tutorial/configure-ldap-sasl-openldap/index.html). As per the documentation, the `mongod` configuration file should have at least the following entries:
   ```
   security:
      authorization: enabled

   setParameter:
      saslauthdPath: /var/run/saslauthd/mux
      authenticationMechanisms: PLAIN
   ```
1. Define the pre-defined LDAP users from this image in `$external`:
   ```
   db.getSiblingDB("$external").createUser({
       user: "dba",
       roles: [ {role: "dbAdmin", db: "admin"} ]
   })

   db.getSiblingDB("$external").createUser({
       user: "writer",
       roles: [ {role: "readWriteAnyDatabase", db: "admin"} ]
   })

   db.getSiblingDB("$external").createUser({
       user: "reader",
       roles: [ {role: "readAnyDatabase", db: "admin"} ]
   })
   ```

### LDAP authorization with MongoDB
1. Check the membership of pre-defined users in LDAP:
   ```
   ldapsearch -x -LLL -D 'cn=admin,dc=tsdocker,dc=com' -w Password1! -b 'ou=dbUsers,dc=tsdocker,dc=com' memberOf -h <ip_host_machine>
   ```
1. On the MongoDB instance, set the following parameters for the `mongod` configuration file:
   ```
   security:
     authorization: enabled
     ldap:
       servers: <ip_host_machine>
       bind:
         method: "simple"
         queryUser: "cn=admin,dc=tsdocker,dc=com"
         queryPassword: "Password1!"
       transportSecurity: "none"
       userToDNMapping:
         '[
           {
             match: "(.+)",
             substitution: "uid={0},ou=dbUsers,dc=tsdocker,dc=com"
           }
         ]'
       authz:
          queryTemplate: "{USER}?memberOf?base"
   setParameter:
     authenticationMechanisms: PLAIN
   ```
1. Verify the configuration by runnig `mongoldap`:
   ```
   mongoldap --config <mongod_config_file> --user <username> --password Password1! --ldapServers <ip_host_machine> --ldapTransportSecurity none
   ```
1. Define roles for pre-defined LDAP users in `admin`:
   ```
   db.getSiblingDB("admin").createRole({
       role: "cn=dbAdmin,ou=dbRoles,dc=tsdocker,dc=com",
       privileges: [],
       roles: [ "dbAdmin" ]
   })

   db.getSiblingDB("admin").createRole({
       role: "cn=readWriteAnyDatabase,ou=dbRoles,dc=tsdocker,dc=com",
       privileges: [],
       roles: [ "readWriteAnyDatabase" ]
   })

   db.getSiblingDB("admin").createRole({
       role: "cn=read,ou=dbRoles,dc=tsdocker,dc=com",
       privileges: [],
       roles: [ "readAnyDatabase" ]
   })
   ```
1. Authenticate with an LDAP user:
   * When connecting with the mongo shell:
      ```
      mongo --username <username> --password Password1! --authenticationDatabase '$external' --authenticationMechanism PLAIN
      ```
   * Once connected with the mongo shell:
      ```
      db.getSiblingDB("$external").auth({mechanism: "PLAIN", user: <username>, pwd: <password>})
      ``` 
Refer to the MongoDB documentation on [LDAP authorisation](https://docs.mongodb.com/manual/core/security-ldap-external/) for further details.

### Ops Manager users authentication and authorisation
1. Create a user in the Application Database. The name for this user should be either `owner` or `admin` to match the already existant user in LDAP.
1. Follow the procedure described in the documentation on [Configure Ops Manager Users for LDAP Authentication and Authorization](https://docs.opsmanager.mongodb.com/current/tutorial/configure-for-ldap-authentication/). Providing the following values:
   - LDAP URI: ldap://<ip_host_machine>
   - LDAP Bind Dn: cn=admin,dc=tsdocker,dc=com
   - LDAP Bind Password: Password1!
   - LDAP User Base Dn: dc=tsdocker,dc=com
   - LDAP User Search Attribute: uid
   - LDAP Group Member Attribute (only 3.6): member
   - LDAP Global Role Owner: cn=owners,ou=omgroups,dc=tsdocker,dc=com
   - LDAP Global Role Read Only: cn=readers,ou=omgroups,dc=tsdocker,dc=com