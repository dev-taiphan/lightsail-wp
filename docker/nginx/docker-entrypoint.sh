#!/bin/sh

export PATH=/usr/local/bin:/bin:/usr/bin:/usr/sbin

function env2cert {
    file=$1
    var="$2"
    (echo "$var" | sed 's/"//g' | grep '^-----' > /dev/null) && 
    (echo "$var" | sed -e 's/"//g' -e 's/\r//g' | sed -e 's/- /-\n/g' -e 's/ -/\n-/g' | sed -e '2s/ /\n/g' > $file) && 
    echo -n $file || echo -n
}

[ "x$SSL_CERT" != "x" -a ! -f "$SSL_CERT" ] && SSL_CERT=$(env2cert /etc/nginx/default.pem "$SSL_CERT")
[ "x$SSL_KEY" != "x" -a ! -f "$SSL_KEY" ] && SSL_KEY=$(env2cert /etc/nginx/default.key "$SSL_KEY")

#//---------------------------------------------------------------------------
#// Improv security
#//---------------------------------------------------------------------------
# Improv Sec
export SSL_DHPARAM="-----BEGIN DH PARAMETERS----- MIIBDAKCAQEA6hdpbI02GB+vYMROcw2BBtoVF/irYjiiHPHxJXiBGm8z4ryJk8ht tPgHNa/dIUCl8Pg46YWVkMXAIahVSQrqPMZnKYy3e/zDGulbZwfyU4M/PFw8t/U5 jmq+EJShQO6j9ozVJyU/JXPHjpgQqNbiKjJoQPwKkjazjzQp02lZGmKL0+87HfLv FRh/L2iwK092P536Couxhg5UrHJfDkPwsNQ6102HyaZ/4REyvbcwknivYQfGwZgZ fTN0lK/4RPMasEeJozFYZ0EcG/G7sqfDFr3Zc+zSlw8gXfosJpukeSfdT8545yFY cW7HFBV1Rl43CegBTlUkXqWdr/E11gy3twIBAgICAOE= -----END DH PARAMETERS----- "
if [ ! -e /etc/nginx/ssl_sess_ticket.key ] ; then
    openssl rand 48 > /etc/nginx/ssl_sess_ticket.key
fi
if [ ! -e /etc/nginx/dhparam.key ] ; then
    env2cert /etc/nginx/dhparam.key "$SSL_DHPARAM" > /dev/null
    test -f /etc/nginx/dhparam.key || openssl dhparam 2048 > /etc/nginx/dhparam.key 2> /dev/null
fi

cd /etc/nginx/conf.d \
&& env PHPHOST=${PHPHOST:-php} envsubst '$$PHPHOST' \
    < fastcgi.inc.template > fastcgi.inc || exit 1

#//---------------------------------------------------------------------------
#// create self-signed cert
#//---------------------------------------------------------------------------
if [ -f /etc/nginx/default.key -o -f /etc/nginx/default.crt ]; then
    /bin/true
else
    keyfile=$(mktemp /tmp/k_ssl_key.XXXXXX)
    certfile=$(mktemp /tmp/k_ssl_cert.XXXXXX)
    trap "rm -f ${keyfile} ${certfile}" SIGINT
    (echo --; echo SomeState; echo SomeCity; echo SomeOrganization; \
     echo SomeOrganizationalUnit; echo localhost.localdomain; \
     echo root@localhost.localdomain) | \
    openssl req -newkey rsa:2048 -keyout "${keyfile}" -nodes -x509 \
                -days 365 -out "${certfile}" 2> /dev/null
    mv "${keyfile}" /etc/nginx/default.key
    chmod 0600 /etc/nginx/default.key
    mv "${certfile}" /etc/nginx/default.crt
    chmod 0644 /etc/nginx/default.crt
fi

export SSL_CERT=${SSL_CERT:-/etc/nginx/default.crt}
export SSL_KEY=${SSL_KEY:-/etc/nginx/default.key}

# generate nginx configuration file
if [ -f /etc/nginx/conf.d/default.conf.template ]; then
    envsubst '$$FQDN $$DOCUMENTROOT $$SSL_CERT $$SSL_KEY' \
        < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
fi

#//---------------------------------------------------------------------------
#// execute nginx
#//---------------------------------------------------------------------------
exec "$@"
