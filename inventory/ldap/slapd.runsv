#!/bin/sh
SLAPD_OPTIONS=""

if [ -f "/etc/default/slapd" ]; then
   . /etc/default/slapd
fi

if [ ! -d /var/run/openldap ]; then
    install -d -o $SLAPD_USER -g $SLAPD_GROUP -m 755 /var/run/openldap
fi
if [ -z "$SLAPD_SERVICES" ]; then
    exec /usr/sbin/slapd -d 0 -u $SLAPD_USER -g $SLAPD_GROUP $SLAPD_OPTIONS
else
    exec /usr/sbin/slapd -d 0 -u $SLAPD_USER -g $SLAPD_GROUP -h "$SLAPD_SERVICES" $SLAPD_OPTIONS
fi
