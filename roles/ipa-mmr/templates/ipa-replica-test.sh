#!/bin/bash

BASE_DN="dc={{ realm_name.split('.') | join(',dc=') }}"
ADMIN_USER_DN="uid=admin,cn=users,cn=accounts,${BASE_DN}"
IFS=' ' read -r -a servers <<< "$@"

function cross_check() {
	local host1=$1
	local host2=$2
	local cookie=$3

	ldapmodify -Y GSSAPI -H ldaps://$host1 <<EOF
dn: ${ADMIN_USER_DN}
changetype: modify
replace: gecos
gecos: Administrator ${cookie}
EOF

	ldapsearch -LLL -Y GSSAPI -H ldaps://$host2 \
		-b "${ADMIN_USER_DN}" \
		'(objectclass=*)' gecos | grep ^gecos:
}

if [ ${{ '{#' }}servers[@]} -eq 2 ]; then
	cookie=`date +"%Y-%m-%d %H:%M:%S"`
	cross_check ${servers[0]} ${servers[1]} "${cookie},server1,server2"
	cross_check ${servers[1]} ${servers[0]} "${cookie},server2,server1"
fi
