#!/bin/bash

BASE_DN="dc={{ realm_name.split('.') | join(',dc=') }}"

function check_replication_status() {
	local server=$1

	echo ""
	echo "CHECKING REPLICATION STATUS at ${server}"
	echo ""  
	echo "Connecting as Directory Manager:"

	ldapsearch -LLL -x -H ldaps://${server} \
		-D "cn=Directory Manager" -W \
		-b "cn=mapping tree,cn=config" \
		objectClass=nsDS5ReplicationAgreement
}

for server in $@; do
	check_replication_status $server
done
