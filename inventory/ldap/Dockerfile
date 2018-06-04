FROM ubuntu:16.04

# Install and configure OpenLDAP binaries
ENV DEBIAN_FRONTEND=noninteractive
ADD conf/slapd-deb.conf /tmp
RUN apt-get update && \
    cat /tmp/slapd-deb.conf | debconf-set-selections && \
    apt-get install ldap-utils slapd -y 

# Copy ldif files and configure memberOf, users and groups
ADD ldif/*.ldif /tmp/
RUN service slapd start \
    && ldapsearch -x -w Password1! -D cn=admin,dc=tsdocker,dc=com -b dc=tsdocker,dc=com \
    && ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/memberof.ldif \ 
    && ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/refint.ldif \
    && ldapadd -x -D cn=admin,dc=tsdocker,dc=com -w Password1! -f /tmp/users.ldif \
    && ldapadd -x -D cn=admin,dc=tsdocker,dc=com -w Password1! -f /tmp/groups.ldif \
    && rm -rf /tmp/slapd-deb.conf /tmp/*.ldif \
    && ldapsearch -x -w Password1! -D cn=admin,dc=tsdocker,dc=com -b dc=tsdocker,dc=com

EXPOSE 389

CMD /usr/sbin/slapd -d 1 -h 'ldap:/// ldapi:///' -g openldap -u openldap -F /etc/ldap/slapd.d