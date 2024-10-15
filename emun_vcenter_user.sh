target=172.28.48.27
for username in $(cat user.txt); do echo -e "\n$username"; ldapsearch -x -H ldap://$target -D "CN=$username,CN=Users,DC=vsphere,DC=local" -w $username -b "DC=vsphere,DC=local" | grep "# numEntries"; done
unset target