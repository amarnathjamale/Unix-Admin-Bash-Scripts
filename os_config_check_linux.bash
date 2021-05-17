#!/bin/bash
####################################################################################### 
#Script Name    :os_config_check_linux.sh 
#Description    :Pre and Post OS Configurations Backup for Linux Server 
#Author         :Amarnath Laxmanrao Jamale 
#Email          :amarnathraje@gmail.com
#License        :Thanos Approved 
####################################################################################### 

#Option UI and Variable Declarations
echo
echo "1. Pre-checks"
echo "2. Post-checks"
echo "3. Quit"
echo "Please select the option:"
read OPT
SERVERNAAV=$(uname -n)
DIWAS=$(date +%d%b%Y)
PREVISHAY="Pre-Checks from $SERVERNAAV on $DIWAS"
POSTVISHAY="Post-Check differences from $SERVERNAAV on $DIWAS"
KUNALA="mail_id@mail.com"
ROOT_DIR=/root/OS_Configs_on_$DIWAS
PRE_DIR=$ROOT_DIR/Pre-checks/
POST_DIR=$ROOT_DIR/Post-checks/
BOND_FILE=/proc/net/bonding/bond0
VCS_PRESENT=$(rpm -qa | grep -i VRTS | wc -l)
PCS_PRESENT=$(rpm -qa | grep -i pcs | wc -l)

#Prechecks Functions Declearations
prechecks()
{
  if [ -d "$ROOT_DIR" ]; then
   echo "$PRE_DIR already exists!!, Please rename it before executing the script"
   exit
  fi
  mkdir $ROOT_DIR
  mkdir $PRE_DIR

#Files to be backed up
  cp -p /etc/redhat-release $PRE_DIR
  cp -p /etc/fstab $PRE_DIR
  cp -p /etc/grub*.cfg  $PRE_DIR
  cp -p /etc/postfix/* $PRE_DIR
  cp -p /etc/sysconfig/network-scripts/ifcfg* $PRE_DIR 
  cp -p /etc/sysconfig/network-scripts/route* $PRE_DIR
  cp -p /etc/resolv.conf $PRE_DIR
  if [ -f "$BOND_FILE" ]; then
  cp -p /proc/net/bonding/bond0 $PRE_DIR/bond0.txt
  fi

  #Outputs of Important commands
  for i in `ifconfig -a |grep HWaddr |cut -d" " -f1`;
  do
   ethtool $i > $PRE_DIR/ethtool_$i.txt;
  done
  
  uname -a > $PRE_DIR/uname.txt
  ifconfig -a > $PRE_DIR/ifconfig_all.txt
  route -n > $PRE_DIR/routing_table.txt
  mount | column -t > $PRE_DIR/mount.txt
  df -h > $PRE_DIR/df.txt
  sysctl -a > $PRE_DIR/sysctl.txt
  pvdisplay > $PRE_DIR/physical-volume-config.txt 
  vgdisplay > $PRE_DIR/volume-group-config.txt 
  lvdisplay > $PRE_DIR/logical-volume-group-config.txt 
  cat /proc/mounts | egrep  'nfs|cifs' > $PRE_DIR/nfs.txt
  ip a > $PRE_DIR/interface-config.txt 
  ip route > $PRE_DIR/route-config.txt 
  netstat -nr | awk '{​print $1 "\t" $2 "\t" $3 }​' > $PRE_DIR/netstat-nr.txt
  rpm -qa --last > $PRE_DIR/rpm-installed.txt 
  chkconfig --list > $PRE_DIR/chkconfig-info.txt 
  systemctl list-unit-files --type service > $PRE_DIR/services-unit-info.txt 
  multipath -ll > $PRE_DIR/multipath.txt
  subscription-manager identity > $PRE_DIR/subscription-manager-identity.txt
  crontab -l > $PRE_DIR/crontab-info.txt 
  lsblk --fs > $PRE_DIR/lsblk-config.txt 
  pvs > $PRE_DIR/pvs.txt
  vgs > $PRE_DIR/vgs.txt
  lvs > $PRE_DIR/lvs.txt
  netstat -nuatp | grep LIST | awk -F "/" '{ print $2 }' > $PRE_DIR/services.txt
  nmcli connection show > $PRE_DIR/nmcli_con.txt
  nmcli device status > $PRE_DIR/nmcli_dev.txt
  firewall-cmd --list-all-zones > $PRE_DIR/firewall-all-zone.txt
  chronyc sources -v > $PRE_DIR/chronyc.txt
  ntpq -p > $PRE_DIR/ntpq-p.txt
    
  #Pacemaker Cluster Configurations 
  if [ $PCS_PRESENT -gt 0 ]
  then
  pcs resource show --full >> $PRE_DIR/pcs-resource-full.txt 
  pcs resource show >> $PRE_DIR/pcs-resource.txt
  pcs status >> $PRE_DIR/pcs-status.txt 
  cp -p /var/lib/pacemaker/cib/cib.xml $PRE_DIR/cib.xml 
  cp -p /etc/corosync/corosync.conf $PRE_DIR/corosync.conf 
  fi

  #Veritas Cluster Configurations
  if [ $VCS_PRESENT -gt 0 ]
  then
  /opt/VRTSvcs/bin/hastatus -summ >> $PRE_DIR/hastatus.txt 
  /opt/VRTSvcs/bin/hagrp -state >> $PRE_DIR/hagrp-state.txt 
  /opt/VRTSvcs/bin/hares -state >> $PRE_DIR/hares-state.txt
  /opt/VRTSvcs/bin/hagrp -display >> $PRE_DIR/hagrp-display.txt 
  vxdg list >> $PRE_DIR/vxdg_list.txt 
  vxprint -hvt >> $PRE_DIR/vxprint.txt 
  vxdisk list >> $PRE_DIR/vxdisk.txt  
  cp -p /etc/VRTSvcs/conf/config/main.cf $PRE_DIR/vcs_main.cf 
  fi

  echo "Required files and command outputs copied to $PRE_DIR"
 while true; do
    read -p "Do you wish to send the mail to Unix DL with Prechecks?" yn
    case $yn in
        [Yy]* ) echo -e "Hi Team,\n\t Below are the OS Configurations of $SERVERNAAV on $DIWAS before activity: \n\n" >> $PRE_DIR/Pre-Checks.txt && for i in `ls -lR $PRE_DIR | grep ^- | awk '{print $9}'`;do echo  >> $PRE_DIR/Pre-Checks.txt; echo  "File Name: $i" >> $PRE_DIR/Pre-Checks.txt; echo "===============================" >> $PRE_DIR/Pre-Checks.txt;cat $PRE_DIR/$i >> $PRE_DIR/Pre-Checks.txt; echo  >> $PRE_DIR/Pre-Checks.txt; echo  >> $PRE_DIR/Pre-Checks.txt; done && mailx -s "$PREVISHAY" $KUNALA < $PRE_DIR/Pre-Checks.txt; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
 done
}   
postchecks()
{
 if [ -d "$POST_DIR" ]; then
   echo "$POST_DIR already exists!!, Please rename it before executing the script"
   exit
  fi
  if [ ! -d "$PRE_DIR" ]; then
   echo "Precheck Directory $PRE_DIR does not exist, please perform Prechecks first"
   exit
  fi
  mkdir $POST_DIR

  #Files to be backed up
  cp -p /etc/redhat-release $POST_DIR
  cp -p /etc/fstab $POST_DIR
  cp -p /etc/grub*.cfg  $POST_DIR
  cp -p /etc/postfix/* $POST_DIR
  cp -p /etc/sysconfig/network-scripts/* $POST_DIR 
  cp -p /etc/resolv.conf $POST_DIR
  if [ -f "$BOND_FILE" ]; then
  cp -p /proc/net/bonding/bond0 $POST_DIR/bond0.txt
  fi

  #Outputs of Important commands
  for i in `ifconfig -a |grep HWaddr |cut -d" " -f1`;
  do
   ethtool $i > $POST_DIR/ethtool_$i.txt;
  done
  
  uname -a > $POST_DIR/uname.txt
  ifconfig -a > $POST_DIR/ifconfig_all.txt
  route -n > $POST_DIR/routing_table.txt
  mount | column -t > $POST_DIR/mount.txt
  df -h > $POST_DIR/df.txt
  sysctl -a > $POST_DIR/sysctl.txt
  pvdisplay > $POST_DIR/physical-volume-config.txt 
  vgdisplay > $POST_DIR/volume-group-config.txt 
  lvdisplay > $POST_DIR/logical-volume-group-config.txt 
  cat /proc/mounts | egrep  'nfs|cifs' > $POST_DIR/nfs.txt
  ip a > $POST_DIR/interface-config.txt 
  ip route > $POST_DIR/route-config.txt 
  netstat -nr | awk '{​print $1 "\t" $2 "\t" $3 }​' > $POST_DIR/netstat-nr.txt
  rpm -qa --last > $POST_DIR/rpm-installed.txt 
  chkconfig --list > $POST_DIR/chkconfig-info.txt 
  systemctl list-unit-files --type service > $POST_DIR/services-unit-info.txt 
  multipath -ll > $POST_DIR/multipath.txt
  subscription-manager identity > $POST_DIR/subscription-manager-identity.txt
  crontab -l > $POST_DIR/crontab-info.txt 
  lsblk --fs > $POST_DIR/lsblk-config.txt 
  pvs > $POST_DIR/pvs.txt
  vgs > $POST_DIR/vgs.txt
  lvs > $POST_DIR/lvs.txt
  netstat -nuatp | grep LIST | awk -F "/" '{ print $2 }' > $POST_DIR/services.txt
    
  #Pacemaker Cluster Configurations 
  if [ $PCS_PRESENT -gt 0 ]
  then
  pcs resource show --full >> $POST_DIR/pcs-resource-full.txt 
  pcs resource show >> $POST_DIR/pcs-resource.txt
  pcs status >> $POST_DIR/pcs-status.txt 
  cp -p /var/lib/pacemaker/cib/cib.xml $POST_DIR/cib.xml 
  cp -p /etc/corosync/corosync.conf $POST_DIR/corosync.conf 
  fi

  #Veritas Cluster Configurations
  if [ $VCS_PRESENT -gt 0 ]
  then
  /opt/VRTSvcs/bin/hastatus -summ >> $POST_DIR/hastatus.txt 
  /opt/VRTSvcs/bin/hagrp -state >> $POST_DIR/hagrp-state.txt 
  /opt/VRTSvcs/bin/hares -state >> $POST_DIR/hares-state.txt
  /opt/VRTSvcs/bin/hagrp -display >> $POST_DIR/hagrp-display.txt 
  vxdg list >> $POST_DIR/vxdg_list.txt 
  vxprint -hvt >> $POST_DIR/vxprint.txt 
  vxdisk list >> $POST_DIR/vxdisk.txt  
  cp -p /etc/VRTSvcs/conf/config/main.cf $POST_DIR/vcs_main.cf 
  fi

 #Finding the differences between Pre-checks and Post-checks
 for i in `ls -lR $POST_DIR | grep ^- | awk '{print $9}'`
  do
    echo  >> $POST_DIR/DIFFERENCES.TXT
    echo  "File Name: $i" >> $POST_DIR/DIFFERENCES.TXT
    echo "--------" >> $POST_DIR/DIFFERENCES.TXT
    diff -y --suppress-common-lines $PRE_DIR/$i $POST_DIR/$i >> $POST_DIR/DIFFERENCES.TXT
    echo  >> $POST_DIR/DIFFERENCES.TXT
    echo  >> $POST_DIR/DIFFERENCES.TXT
  done
 echo
 echo "Post activity checks done, please check $POST_DIR/DIFFERENCES.TXT for all important differences"

 while true; do
    read -p "Do you wish to send the mail to Unix DL with differences?" yn
    case $yn in
        [Yy]* ) echo -e "Hi Team,\n\t Below are the OS Configurations differences of $SERVERNAAV on $DIWAS post activity: \n\n" >> /tmp/postchecks && cat $POST_DIR/DIFFERENCES.TXT >> /tmp/postchecks && cat /tmp/postchecks | mailx -s "$POSTVISHAY" $KUNALA; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
 done
 rm -f /tmp/postchecks
}

case $OPT in
"1")  prechecks
      ;;
"2")  postchecks
      ;;
"3")  exit
      ;;
*)  echo "What are you doing buddy? $OPT is an invalid option. Try again."
      ;;
esac
############### THANOS RESTS NOW #######################
