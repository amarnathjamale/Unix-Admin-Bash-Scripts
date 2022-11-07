#!/bin/bash 
#######################################################################################
#Script Name    :fetch_access_details.bash
#Description    :Fetch access assigned to the host on RedHat IDM
#Author         :Amarnath Jamale
#Email          :amarnathraje@gmail.no
#License        :Thanos Approved
#######################################################################################

echo "Validating the kerberos credentials..."
KLISTSTATUS=$(klist -s; echo $?)
if [[ $KLISTSTATUS == "0" ]]
then
echo "Authentication Successful"
else
echo "Authentication Failed"
echo "Please authenticate yourself using kinit"
echo "Enter your username configured at IDM"
read USERNAME
/usr/bin/kinit $USERNAME
KLISTSTATUS=$(klist -s; echo $?)
if [[ $KLISTSTATUS == "0" ]]
then
echo "Authentication Successful"
else
echo "Authentication Failed"
echo "Please validate your IDM credentials and check if IPA client is configured correctly."
fi
fi
echo ""

hostnaav=`uname -n`
echo "The IDM access configuration for $hostnaav server:"
echo ""

echo "Host Membership Details"
echo ""

echo "Host is Member of below HBAC Rules:"
ipa host-show $hostnaav | grep HBAC | cut -d : -f2 | sed 's/,/\n/g' | awk '{$1=$1;print}'
echo ""
echo "Host is Member of below Sudo Rules:"
ipa host-show $hostnaav | grep Sudo | cut -d : -f2 | sed 's/,/\n/g' | awk '{$1=$1;print}'
echo ""
echo "Host is Member of below host groups"
ipa host-show $hostnaav | grep host-groups | cut -d : -f2 | sed 's/,/\n/g' | awk '{$1=$1;print}'
echo -e "\n"

echo "HBAC Rule Details"
echo ""
for i in `ipa host-show $hostnaav | grep HBAC | cut -d : -f2 | sed 's/,/\n/g' | awk '{$1=$1;print}'`
do 
echo "The HBAC Rule $i gives access to following user groups:"
for j in `ipa hbacrule-show $i | grep User | cut -d : -f2 | sed 's/,/\n/g' | awk '{$1=$1;print}'`
do 
getent group $j | cut -d : -f1,4 | sed 's/:/ with following users: /g'
done
echo "------------------"
done
echo -e "\n"

echo "Sudo Rule Details"
echo ""
for i in `ipa host-show $hostnaav | grep Sudo | cut -d : -f2 | sed 's/,/\n/g' | awk '{$1=$1;print}'`
do 
echo "The Sudo Rule $i gives access to following user groups:"
for j in `ipa sudorule-show $i | grep User | cut -d : -f2 | sed 's/,/\n/g' | awk '{$1=$1;print}'`
do 
getent group $j | cut -d : -f1,4 | sed 's/:/ with following users: /g'
done
echo "Access granted:"
ipa sudorule-show $i | grep Allow | cut -d : -f2 | sed 's/,/\n/g' | awk '{$1=$1;print}'
echo "------------------"
done

