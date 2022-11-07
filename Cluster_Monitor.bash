#!/bin/bash 
#######################################################################################
#Script Name    :Cluster_Monitor.bash
#Description    :Send alert mail when cluster resource goes offline for Solaris Cluster
#Author         :Amarnath Laxmanrao Jamale
#Email          :amarnathraje@gmail.com
#License        :Thanos Approved
#######################################################################################

## declare mail variables
##Server Name
servername=$(uname -n)
##email subject 
subject="Cluster Resource went offline on $servername"
## sending mail to
to="mail_id@mail.com"
## send carbon copy to
also_to="cc_mail_id@mail.com"

## get offline resource number 
offrs=$(/usr/cluster/bin/clrs list -s offline | wc -l)

## check if offline resources are less than 1
if [[ 1 -le "$offrs"  ]]; then
        
        echo "Hi Team,\n\t Below Resources have went offline on $servername:\n " >> /tmp/cluster_status && /usr/cluster/bin/clrs list -s offline >> /tmp/cluster_status && echo "\n\nGiven below is thecluster status: " >> /tmp/cluster_status && /usr/cluster/bin/clrs status >> /tmp/cluster_status && cat /tmp/cluster_status | mailx -s "$subject" "$to" "$also_to"

fi
rm -f /tmp/cluster_status
exit 0
