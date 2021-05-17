#!/bin/bash
####################################################################################### 
#Script Name    :os_config_check_solaris.sh 
#Description    :Pre and Post OS Configurations Backup for Solaris Server 
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
SunOS_DIR=/usr/cluster/bin/

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
 
  cp -p /etc/system $PRE_DIR
  cp -p /etc/vfstab $PRE_DIR
  cp -p /etc/resolv.conf $PRE_DIR
  cp -p /etc/hosts $PRE_DIR
  cp -p /etc/passwd $PRE_DIR
  cp -p /etc/shadow $PRE_DIR
  cp -p /rpool/boot/grub/menu.lst $PRE_DIR
  cp -p /etc/group $PRE_DIR
  cp -p /etc/zones/index $PRE_DIR
  cp -p /etc/zones/*xml $PRE_DIR
  
  #Outputs of Important commands
  
  for i in `zoneadm list`;
  do
   zonecfg -z $i info > $PRE_DIR/zonecfg_info_$i.txt
   zonecfg -z $i export > $PRE_DIR/zonecfg_export_$i.txt;
  done
  
  uname -a > $PRE_DIR/uname.txt
  virtinfo > $PRE_DIR/virtinfo.txt
  sneep > $PRE_DIR/sneep.txt
  env > $PRE_DIR/env.txt
  df -h > $PRE_DIR/df.txt
  swap -l > $PRE_DIR/swap.txt
  ifconfig -a > $PRE_DIR/ifconfig_all.txt
  netstat -nr | awk '{​print $1 "\t" $2 "\t" $3 }​' > $PRE_DIR/netstat_nr.txt
  netstat -nrv| awk '{​print $1 "\t" $2 "\t" $3 }​' > $PRE_DIR/netstat_nrv.txt
  dladm show-phys > $PRE_DIR/dladm_show-phys.txt
  impstat -g > $PRE_DIR/impstat-g.txt
  zfs list  > $PRE_DIR/zfs_list.txt
  zpool list > $PRE_DIR/zpool_list.txt
  zpool status -x > $PRE_DIR/zpool_status.txt
  prtconf -vp > $PRE_DIR/prtconf_vp.txt
  eeprom > $PRE_DIR/eeprom.txt
  prtconf > $PRE_DIR/prtconf.txt
  svcs -xv > $PRE_DIR/svcs_xv.txt
  iostat -entire > $PRE_DIR/iostat-entire.txt
  fmadm faulty > $PRE_DIR/fmadm-faulty.txt
  prtdiag -v > $PRE_DIR/prtdiag-v.txt
  echo | format > $PRE_DIR/echo-format.txt
  fcinfo hba-port > $PRE_DIR/fcinfo_hba-port.txt
  pkg publisher > $PRE_DIR/pkg-publisher.txt
  pkg list > $PRE_DIR/pkg-list.txt
  pkg list entire > $PRE_DIR/pkg-list-entire.txt
  ldm list > $PRE_DIR/ldm-list.txt
  lustatus > $PRE_DIR/lustatus.txt
  zoneadm list -cv > $PRE_DIR/zoneadm_list-cv.txt
  
  #SunOS Cluster Configurations 
  if [ -d "$SunOS_DIR" ]
  then
  /usr/cluster/bin/cluster list -v > $PRE_DIR/cluster-list.txt
  /usr/cluster/bin/cluster show > $PRE_DIR/cluster-show.txt
  /usr/cluster/bin/cluster status > $PRE_DIR/cluster-status.txt
  /usr/cluster/bin/clnode list -v > $PRE_DIR/clnode-list.txt
  /usr/cluster/bin/clnode show > $PRE_DIR/clnode-show.txt
  /usr/cluster/bin/clnode status > $PRE_DIR/clnode-status.txt
  /usr/cluster/bin/cldevice list > $PRE_DIR/cldevice-list.txt
  /usr/cluster/bin/cldevice show > $PRE_DIR/cldevice-show.txt
  /usr/cluster/bin/cldevice status > $PRE_DIR/cldevice-status.txt
  /usr/cluster/bin/clquorum list -v > $PRE_DIR/clquorum-list.txt
  /usr/cluster/bin/clquorum show > $PRE_DIR/clquorum-show.txt
  /usr/cluster/bin/clquorum status > $PRE_DIR/clquorum-status.txt
  /usr/cluster/bin/clinterconnect show > $PRE_DIR/clinterconnect-show.txt
  /usr/cluster/bin/clinterconnect status > $PRE_DIR/clinterconnect-status.txt
  /usr/cluster/bin/clresource list -v > $PRE_DIR/clresource-list.txt
  /usr/cluster/bin/clresource show > $PRE_DIR/clresource-show.txt
  /usr/cluster/bin/clresource status > $PRE_DIR/clresource-status.txt
  /usr/cluster/bin/clresourcegroup list -v > $PRE_DIR/clresourcegroup-list.txt
  /usr/cluster/bin/clresourcegroup show > $PRE_DIR/clresourcegroup-show.txt
  /usr/cluster/bin/clresourcegroup status > $PRE_DIR/clresourcegroup-status.txt
  /usr/cluster/bin/clresourcetype list -v > $PRE_DIR/clresourcetype-list.txt
  /usr/cluster/bin/clresourcetype list-props -v > $PRE_DIR/clresourcetype-list-props.txt
  /usr/cluster/bin/clresourcetype show > $PRE_DIR/clresourcetype-show.txt
  /usr/cluster/bin/clnode status -m > $PRE_DIR/clnode-status.txt
  /usr/cluster/bin/clnode show-rev -v > $PRE_DIR/clnode-show-rev.txt
  fi

  echo "Required files and command outputs copied to $PRE_DIR ."
 while true; do
    read -p "Do you wish to send the mail to Unix DL with Prechecks?" yn
    case $yn in
        [Yy]* ) echo -e "Hi Team,\n\t Below are the OS Configurations of $SERVERNAAV on $DIWAS before activity: \n\n" >> $PRE_DIR/Pre-Checks.txt && for i in `ls -lR $PRE_DIR | grep ^- | awk '{print $9}'`;do echo  >> $PRE_DIR/Pre-Checks.txt; echo  "File Name: $i" >> $PRE_DIR/Pre-Checks.txt; echo "===============================" >> $PRE_DIR/Pre-Checks.txt;cat $PRE_DIR/$i >> $PRE_DIR/Pre-Checks.txt; echo  >> $PRE_DIR/Pre-Checks.txt; echo  >> $PRE_DIR/Pre-Checks.txt; done && cat $PRE_DIR/Pre-Checks.txt | mailx -s "$PREVISHAY" "$KUNALA" ; break;;
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
 
  cp -p /etc/system $POST_DIR
  cp -p /etc/vfstab $POST_DIR
  cp -p /etc/resolv.conf $POST_DIR
  cp -p /etc/hosts $POST_DIR
  cp -p /etc/passwd $POST_DIR
  cp -p /etc/shadow $POST_DIR
  cp -p /rpool/boot/grub/menu.lst $POST_DIR
  cp -p /etc/group $POST_DIR
  cp -p /etc/zones/index $POST_DIR
  cp -p /etc/zones/*xml $POST_DIR
  
  #Outputs of Important commands
  
  for i in `zoneadm list`;
  do
   zonecfg -z $i info > $POST_DIR/zonecfg_info_$i.txt
   zonecfg -z $i export > $POST_DIR/zonecfg_export_$i.txt
  done
  
  uname -a > $POST_DIR/uname.txt
  virtinfo > $POST_DIR/virtinfo.txt
  sneep > $POST_DIR/sneep.txt
  env > $POST_DIR/env.txt
  df -h > $POST_DIR/df.txt
  swap -l > $POST_DIR/swap.txt
  ifconfig -a > $POST_DIR/ifconfig_all.txt
  netstat -nr | awk '{​print $1 "\t" $2 "\t" $3 }​' > $POST_DIR/netstat_nr.txt
  netstat -nrv | awk '{​print $1 "\t" $2 "\t" $3 }​' > $POST_DIR/netstat_nrv.txt
  dladm show-phys > $POST_DIR/dladm_show-phys.txt
  impstat -g > $POST_DIR/impstat-g.txt
  zfs list  > $POST_DIR/zfs_list.txt
  zpool list > $POST_DIR/zpool_list.txt
  zpool status -x > $POST_DIR/zpool_status.txt
  prtconf -vp > $POST_DIR/prtconf_vp.txt
  eeprom > $POST_DIR/eeprom.txt
  prtconf > $POST_DIR/prtconf.txt
  svcs -xv > $POST_DIR/svcs_xv.txt
  iostat -entire > $POST_DIR/iostat-entire.txt
  fmadm faulty > $POST_DIR/fmadm-faulty.txt
  prtdiag -v > $POST_DIR/prtdiag-v.txt
  echo | format > $POST_DIR/echo-format.txt
  fcinfo hba-port > $POST_DIR/fcinfo_hba-port.txt
  pkg publisher > $POST_DIR/pkg-publisher.txt
  pkg list > $POST_DIR/pkg-list.txt
  pkg list entire > $POST_DIR/pkg-list-entire.txt
  ldm list > $POST_DIR/ldm-list.txt
  lustatus > $POST_DIR/lustatus.txt
  zoneadm list -cv > $POST_DIR/zoneadm_list-cv.txt
  
  #SunOS Cluster Configurations 
  if [ -d "$SunOS_DIR" ]
  then
  /usr/cluster/bin/cluster list -v > $POST_DIR/cluster-list.txt
  /usr/cluster/bin/cluster show > $POST_DIR/cluster-show.txt
  /usr/cluster/bin/cluster status > $POST_DIR/cluster-status.txt
  /usr/cluster/bin/clnode list -v > $POST_DIR/clnode-list.txt
  /usr/cluster/bin/clnode show > $POST_DIR/clnode-show.txt
  /usr/cluster/bin/clnode status > $POST_DIR/clnode-status.txt
  /usr/cluster/bin/cldevice list > $POST_DIR/cldevice-list.txt
  /usr/cluster/bin/cldevice show > $POST_DIR/cldevice-show.txt
  /usr/cluster/bin/cldevice status > $POST_DIR/cldevice-status.txt
  /usr/cluster/bin/clquorum list -v > $POST_DIR/clquorum-list.txt
  /usr/cluster/bin/clquorum show > $POST_DIR/clquorum-show.txt
  /usr/cluster/bin/clquorum status > $POST_DIR/clquorum-status.txt
  /usr/cluster/bin/clinterconnect show > $POST_DIR/clinterconnect-show.txt
  /usr/cluster/bin/clinterconnect status > $POST_DIR/clinterconnect-status.txt
  /usr/cluster/bin/clresource list -v > $POST_DIR/clresource-list.txt
  /usr/cluster/bin/clresource show > $POST_DIR/clresource-show.txt
  /usr/cluster/bin/clresource status > $POST_DIR/clresource-status.txt
  /usr/cluster/bin/clresourcegroup list -v > $POST_DIR/clresourcegroup-list.txt
  /usr/cluster/bin/clresourcegroup show > $POST_DIR/clresourcegroup-show.txt
  /usr/cluster/bin/clresourcegroup status > $POST_DIR/clresourcegroup-status.txt
  /usr/cluster/bin/clresourcetype list -v > $POST_DIR/clresourcetype-list.txt
  /usr/cluster/bin/clresourcetype list-props -v > $POST_DIR/clresourcetype-list-props.txt
  /usr/cluster/bin/clresourcetype show > $POST_DIR/clresourcetype-show.txt
  /usr/cluster/bin/clnode status -m > $POST_DIR/clnode-status.txt
  /usr/cluster/bin/clnode show-rev -v > $POST_DIR/clnode-show-rev.txt
  fi


 #Finding the differences between Pre-checks and Post-checks
 for i in `ls -lR $POST_DIR | grep ^- | awk '{print $9}'`
  do
    echo  >> $POST_DIR/DIFFERENCES.TXT
    echo  "File Name: $i" >> $POST_DIR/DIFFERENCES.TXT
    echo "--------" >> $POST_DIR/DIFFERENCES.TXT
    sdiff -s $PRE_DIR/$i $POST_DIR/$i >> $POST_DIR/DIFFERENCES.TXT
    echo  >> $POST_DIR/DIFFERENCES.TXT
    echo  >> $POST_DIR/DIFFERENCES.TXT
  done
 echo
 echo "Post activity checks done, please check $POST_DIR/DIFFERENCES.TXT for all important differences"
 while true; do
    read -p "Do you wish to send the mail to Unix DL with differences?" yn
    case $yn in
        [Yy]* ) echo -e "Hi Team,\n\t Below are the OS Configurations differences of $SERVERNAAV on $DIWAS post activity: \n\n" >> /tmp/postchecks && cat $POST_DIR/DIFFERENCES.TXT >> /tmp/postchecks && cat /tmp/postchecks | mailx -s "$POSTVISHAY" "$KUNALA"; break;;
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
