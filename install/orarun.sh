#!/bin/sh
#
# $Header: oui/prov/fixup/aix/orarun.sh /main/5 2010/10/04 02:19:20 sandgoya Exp $
#
# orarun.sh
#
# Copyright (c) 2005, 2010, Oracle and/or its affiliates. All rights reserved. 
#
#    NAME
#      orarun.sh - <one-line expansion of the name>
#
#    DESCRIPTION
#      <short description of component this file declares/defines>
#
#    NOTES
#      <other useful comments, qualifications, etc.>
#
#    MODIFIED   (MM/DD/YY)
#     sandgoya 10/01/10 - bugfix 9697001
#     sandgoya 09/30/09 - bugfix 8892764
#     sandgoya 09/01/09 - bug 8844313
#     sandgoya 05/31/09 - Bug Fix 8505997,adding port specific orarun.sh files
#     vkamthan 05/12/09 - Bug Fix 8445702
#     vkamthan 04/13/09 - Bug Fix 8304796
#     vkamthan 12/15/08 - Bug Fix 7378320
#     skhekale 07/22/08 - Added shell limit fixup 
#     kkhanuja 07/06/06 - Added fixup to start nscd 
#     vsubrahm 03/28/06 - XbranchMerge vsubrahm_orarun_rpm_changes from 
#                         st_empp_10.2.0.1.0 
#     vsubrahm 02/23/06 - Adding checks before changing values 
#     njerath  02/06/06 - XbranchMerge njerath_misc_prereq_fixup_2 from main 
#     vsubrahm 02/02/06 - XbranchMerge vsubrahm_orarun_target from main 
#     vsubrahm 01/27/06 -  Fix the variable name for shell limits
#     njerath  12/04/05 - Changed constant names for base urls
#     njerath  11/27/05 - Added more fixups
#       vsubrahm 10/22/05 - 
#   
#    vsubrahm    10/22/05  - changing add user to group to includ groups user belongs to
#    vsubrahm    10/18/05  -  Adding fixup for mount parameters
#    vsagar      10/26/05  - 
#    vsubrahm    10/22/05 -    
#    vsubrahm    10/22/05  - changing add user to group to includ groups user belongs to
#    vsubrahm    10/18/05  -  Adding fixup for mount parameters
#    gmanglik    09/02/05  - add fix up for central inventory permissions 
#    vsburahm    08/26/05 -  Added fixup for adding user to groups
#    bpaliwal    08/25/05 -  use tee to output the progress / errors an log
#    vsubrahm    07/26/05 - Changes for Shell limits 
#    suravind    07/15/05 - suravind_updation_prereq_xml
#    vsubrahm    07/06/05 - Creation
#
#set -x
#Assign command line params 1 and 2 to response file and enable file

# Helper function to verify an address is associated with an interface
resp_file=$1
enable_file=$2
log_file=$3
#If both files are not specified look for the files in the current directory
if [ $# -eq 0 ]
then
  resp_file=`pwd`/orarun.response
  enable_file=`pwd`/orarun.enable
  log_file=`pwd`
elif [ $# -eq 1 ]
then
 enable_file=`pwd`/orarun.enable
 log_file=`pwd`
elif [ $# -eq 2 ]
then
 log_file="`pwd`"
fi

EXIT_CODE=0

#if the user does not have write permission on given directory, then create logs in /tmp directory
#if ! echo "This is the log file for orarun script" >> $log_file/orarun.log
echo "This is the log file for orarun script" >> $log_file/orarun.log
flag=$?

if [ $flag != "0" ]
then
   log_file="/tmp"
  echo "This is the log file for orarun script" >> $log_file/orarun.log
fi
echo "Timestamp: `date +%m%d%y%H%M%S`" >> $log_file/orarun.log

echo "Response file being used is :$resp_file" |tee -a $log_file/orarun.log

echo "Enable file being used is :$enable_file" | tee -a $log_file/orarun.log

echo "Log file location: $log_file/orarun.log"

 if [ ! -f $resp_file -o ! -f $enable_file ]
 then
         echo "Nothing to fix!!" | tee -a $log_file/orarun.log
         exit 0
 fi
 if [ ! -r $resp_file -o ! -r $enable_file ]
 then
         echo "One or both of the input files are not readable" |tee -a $log_file/orarun.log
         exit 1
 fi

#check if user has given absolute/relative path or just filename
first_char=`expr "$resp_file" : '\(.\)'`
if [ "$first_char" != "/" -a "$first_char" != "." ]
then
 . ./$resp_file
else
. $resp_file
fi

first_char=`expr "$enable_file" : '\(.\)'`
if [ "$first_char" != "/" -a "$first_char" != "." ]
then
 . ./$enable_file
else
. $enable_file
fi

check_ifconfig()
{
    ADDR="$1"
    IFCONFIG="`/sbin/ifconfig 2>/dev/null`"
    if [ "$?" != 0 ]
    then
        echo "Unable to run ifconfig"
        return 1
    fi

    case "$IFCONFIG" in
    *addr:"$ADDR"*)
        return 0
        ;;
    *)
        ;;
    esac

    echo "IP address \"$ADDR\" is not associated with an interface"
    return 1
}

if [ "`echo $SET_KERNEL_PARAMETERS | tr A-Z a-z`" = "true" ]
then
    echo "Setting Kernel Parameters..." | tee -a $log_file/orarun.log

   if [ -n "$TCP_EPHEMERAL_LOW" ]
        then
   	/usr/sbin/no -o tcp_ephemeral_low=$TCP_EPHEMERAL_LOW 
   fi

   if [ -n "$TCP_EPHEMERAL_HIGH" ]
        then
        /usr/sbin/no -o tcp_ephemeral_high=$TCP_EPHEMERAL_HIGH
   fi

   if [ -n "$UDP_EPHEMERAL_LOW" ]
        then
        /usr/sbin/no -o udp_ephemeral_low=$UDP_EPHEMERAL_LOW
   fi

   if [ -n "$UDP_EPHEMERAL_HIGH" ]
        then
        /usr/sbin/no -o udp_ephemeral_high=$UDP_EPHEMERAL_HIGH
   fi
 
 if [ -n "$NCARGS" ]
      then
	#set the value of expected ncargs
        chdev -l sys0 -a ncargs=$NCARGS
        if [ $? -ne 0 ]
        then
          echo "Errors occured during setting kernel parameter ncargs." | tee -a $log_file/orarun.log
        fi
         else
            if [ -n "$SEM_NSEMS_MAX" ]
            then
              #set the value of expected sem_nsems_max
              #comamnd
              if [ $? -ne 0 ]
                then
                  echo "Errors occured during setting kernel parameter SEM_NSEMS_MAX." | tee -a $log_file/orarun.log
                fi
                else
                    if [ -n "$SEM_VALUE_MAX" ]
                    then
                      #set the value of expected sem_value_max
                      #comamnd
                      if [ $? -ne 0 ]
                        then
                          echo "Errors occured during setting kernel parameter SEM_VALUE_MAX." | tee -a $log_file/orarun.log
                        fi
                    fi
             fi
        fi
 fi
       

#Create groups if they do not exist
if [ "`echo $CREATE_GROUPS | tr A-Z a-z`" = "true" ]
then
  echo " Creating groups ..." >> $log_file/orarun.log
   for group in $GROUP  
   do
      grep -qs ^$group: /etc/group || /usr/bin/mkgroup $group
     if [ $? -ne 0 ]
     then
      echo "An error occured while creating the group: $group" |tee -a $log_file/orarun.log
     
     fi
   done
fi


#Create the users if they do not exist
if [ "`echo $CREATE_USERS | tr A-Z a-z`" = "true" ]
then
   echo "Creating Users ...." >> $log_file/orarun.log
   for user_info in $USERS
   do        
       user=`echo $user_info | cut -d: -f1`
       login_dir=`echo $user_info | cut -d: -f2`
       login_shell=`echo $user_info | cut -d: -f3`
       echo "Creating $user with login directory $login_dir and login shell $login_shell " | tee -a $log_file/orarun.log
       id  $user || /usr/sbin/useradd -d $login_dir -s $login_shell -m $user
       if [ $? -ne 0 ]
       then
          echo "An error occured while creating the user $user " |tee -a $log_file/orarun.log
       fi
  done
fi

#Start the nscd daemon if not running
if [ "`echo $START_NSCD | tr A-Z a-z`" = "true" ]
then
   echo "Starting ncsd...." >> $log_file/orarun.log
   rm -rf awktemp
   /sbin/service nscd status > awktemp 2>&1

   VAR=`grep "running"  awktemp | awk -F. '{ print $1 }'`

   if [ "$VAR" = "" ]
   then
      VAR1=`grep "unrecognized"  awktemp | awk -F: '{ print $1 }'`
      if [ "$VAR1" = "" ]
      then
         /sbin/service nscd start
      else
         echo "nscd: unrecognized service " | tee -a $log_file/orarun.log
      fi
   fi
fi

#Set shell limits
if [ "`echo $SET_SHELL_LIMITS | tr A-Z a-z`" = "true" ]
then
 echo "Setting Shell limits ..." >> $log_file/orarun.log
 
      if [ -n "$MAX_PROCESSES_HARDLIMIT" ]
      then
        chdev -l sys0 -a maxuproc=$MAX_PROCESSES_HARDLIMIT
        if [ $? -ne 0 ]
        then
          echo "Errors occured during setting maximum user processes." | tee -a $log_file/orarun.log
        fi
      fi
      
     if [ -n "$MAX_STACK_SOFTLIMIT" ]
     then
       #comamnd
       if [ $? -ne 0 ]
        then
          echo "Errors occured during setting maximum stack limit." | tee -a $log_file/orarun.log
        fi
     fi
     
     if [ -n "$FILE_OPEN_MAX_HARDLIMIT" ]
     then
       #command
       if [ $? -ne 0 ]
        then
          echo "Errors occured during setting maximum number of files a user can open." | tee -a $log_file/orarun.log
        fi
     fi
fi
     	

#Set default and current runlevels correctly
if [ "`echo $CHANGE_CURRENT_RUNLEVEL | tr A-Z a-z`" = "true" ]
then
   telinit $DESIRED_CURRENT_RUNLEVEL
fi

if [ "`echo $CHANGE_DEFAULT_RUNLEVEL | tr A-Z a-z`" = "true" ]
then
    INITTAB_FILE="/etc/inittab"
    echo "Modifying $INITTAB_FILE to update the default runlevel" | tee -a $log_file/orarun.log
    typeset -i linenumber=`grep -n ":initdefault" $INITTAB_FILE | awk -F: '{ print $1 }'`
    typeset -i linesbefore=$linenumber-1
    head -n $linesbefore $INITTAB_FILE > $INITTAB_FILE.tmp
    echo "id:$DESIRED_DEFAULT_RUNLEVEL:initdefault:" >> $INITTAB_FILE.tmp
    typeset -i totallines=`wc -l $INITTAB_FILE | awk '{ print $1 }'`
    typeset -i linesafter=$totallines-$linenumber
    tail -n $linesafter $INITTAB_FILE >> $INITTAB_FILE.tmp 
    mv $INITTAB_FILE.tmp $INITTAB_FILE
    # tell init to re-examine the /etc/inittab file.
    telinit q
fi


#set inventory permissions
if [ "`echo $SET_INVENTORY_PERMISSIONS | tr A-Z a-z`" = "true" ]
then
   
      echo "setting permissions for the central inventory '$CENTRAL_INVENTORY'" |tee -a $log_file/orarun.log
      /bin/chmod 770 -R $CENTRAL_INVENTORY   
      /bin/chown -R $ORACLE_USER:$INSTALL_GROUP $CENTRAL_INVENTORY 
fi


#Setup virtual ip
if [ "`echo $SETUP_VIRTUAL_IP | tr A-Z a-z`" = "true" ]
then
 echo "Updating /etc/hosts with Virtual IP information ..." >> $log_file/orarun.log
 domain_name="`domainname`"     
#strip off quotes
 ip_host_list=`grep ^VIRTUAL_IP_INFO $resp_file | cut -d= -f2`
 ip_host_list=`echo $ip_host_list | cut -d\" -f2`
 ip_host_list=`echo $ip_host_list | cut -d\" -f1`  
 for ip_hosts in $ip_host_list
 do
  ip=`echo $ip_hosts | cut -d: -f1`
  host=`echo $ip_hosts | cut -d: -f2`
  
  echo $host | grep "$domain_name"
  if [ $? -eq 0 ]
  then
    fqhn="$host"
    host=`echo $fqhn | awk -F. '{ print $1 }'`
  else
    fqhn="$host.$domain_name"
  fi
  echo "$ip   $fqhn	$host" >> /etc/hosts
  if [ $? -ne 0 ]
  then
    echo "An error occured while trying to update /etc/hosts file with Virtual IP information." |tee -a $log_file/orarun.log
  fi     
 done
fi

#Setup private nodes
if [ "`echo $SETUP_PRIVATE_NODES | tr A-Z a-z`" = "true" ]
then
 echo "Updating /etc/hosts with private node information" >> $log_file/orarun.log
 domain_name="`domainname`"     
 ip_host_list=`grep ^PRIVATE_NODE_INFO $resp_file | cut -d= -f2`
 ip_host_list=`echo $ip_host_list | cut -d\" -f2`
 ip_host_list=`echo $ip_host_list | cut -d\" -f1`
 for ip_hosts in $ip_host_list
 do
  ip=`echo $ip_hosts | cut -d: -f1`
  host=`echo $ip_hosts | cut -d: -f2`
  echo $host | grep "$domain_name"
  if [ $? -eq 0 ]
  then
    fqhn="$host"
    host=`echo $fqhn | awk -F. '{ print $1 }'`
  else
    fqhn="$host.$domain_name"
  fi
  echo "$ip	$fqhn	$host" >> /etc/hosts
  if [ $? -ne 0 ]
  then
    echo "An error occured while trying to update /etc/hosts file with Private Node information." |tee -a $log_file/orarun.log
  fi     
 done
fi

#Change primary group for users
if [ "`echo $CHANGE_PRIMARY_GROUP | tr A-Z a-z`" = "true" ] 
then 
 echo "Changing primary group for users  ... " >> $log_file/orarun.log
 user_group_list=`grep ^USERS_PRIMARY_GROUP $resp_file | cut -d= -f2`

     #Strip off quotes
 user_group_list=`echo $user_group_list | cut -d\" -f2`
 user_group_list=`echo $user_group_list | cut -d\" -f1` 
 for user_groups in `echo $user_group_list`
  do
    # user_groups=`echo $user_groups | tr , \ `
     user=`echo $user_groups | cut -d: -f1`
     if id $user
     then
         primary_grp=`echo $user_groups | cut -d: -f2`
         #Check if the user has the correct primary group 
         existing_primary_group=`id -ng $user` 
         if [ "$existing_primary_group" != "$primary_group" ]
         then 
            # Change the primary group for the user
            group_ids=`grep "$primary_grp:" /etc/group | awk -F: '{ print $3 }'` 
            for group_id in $group_ids
            do
               in_primary_group_name=`grep ":$group_id:" /etc/group | awk -F: '{ print $1 }'`
               if [ "$in_primary_group_name" = "$primary_grp" ]
               then
                  primary_group_id=$group_id
               fi
           done
           /usr/sbin/usermod -g $primary_group_id $user 
           existing_grps=`id -nG $user`
           # replace all spaces in existing_grps by ,
           existing_grps=`echo $existing_grps | tr \  ,`
           /usr/sbin/usermod -G $existing_grps,$existing_primary_group $user 
           if [ $? -ne 0 ]
           then
              echo "User: $user could not be added to all the groups in the list $grp_list. " |tee -a $log_file/orarun.log
           fi
        fi
     else
         echo "$user does not exist. " | tee -a $log_file/orarun.log
     fi
  done
fi

#Add users to the required groups
if [ "`echo $ADD_USER_TO_GROUP | tr A-Z a-z`" = "true" ]
then
 echo "Adding users to required groups ... " >> $log_file/orarun.log
  user_group_list=`grep ^USERS_GROUPS $resp_file | cut -d= -f2`

     #Strip off quotes
 user_group_list=`echo $user_group_list | cut -d\" -f2`
 user_group_list=`echo $user_group_list | cut -d\" -f1` 
 for user_groups in `echo $user_group_list`
  do
    # user_groups=`echo $user_groups | tr , \ `
     user=`echo $user_groups | cut -d: -f1`
     if id $user
     then
         grp_list=`echo $user_groups | cut -d: -f2`
         #get the groups user belongs to
          existing_grps=`id -nG $user`
         # replace all spaces in existing_grps by ,
          existing_grps=`echo $existing_grps | tr \  ,`
          /usr/sbin/usermod -G $grp_list,$existing_grps $user 
          if [ $? -ne 0 ]
          then
              echo "User: $user could not be added to all the groups in the list $grp_list. " |tee -a $log_file/orarun.log
          fi
     else
        echo "$user does not exist." | tee -a $log_file/orarun.log
     fi
  done 
fi


#install of ocfs tools
#install_ocfs_packages ${INSTALL_PACKAGES_OCFS_TOOLS} "${PACKAGES_OCFS_TOOLS}" ${RPM_BASE_URL_OCFS_TOOLS} `uname -i`

#install of ocfs
#install_ocfs_packages ${INSTALL_PACKAGES_OCFS}  "${PACKAGES_OCFS}" ${RPM_BASE_URL_OCFS} `uname -p`


#loading of ocfs kernel module
if [ "`echo $INSTALL_OCFS_MODULE | tr A-Z a-z`" = "true" ]
then
#Add /sbin to PATH so that ifconfig can run
   PATH=$PATH:/sbin
   if [ -f /etc/ocfs.conf ]
   then
	echo "No need to populate /etc/ocfs.conf"
   else
     for private_node in $PRIVATE_NODES
     do
       private_ip=`grep "$private_node" /etc/hosts | awk ' { print $1 }'`
       if check_ifconfig "$private_ip"
       then
#This is the Private IP address which needs to go into /etc/ocfs.conf
 	    echo "node_name = $private_node" > /etc/ocfs.conf
	    echo "ip_address = $private_ip" >> /etc/ocfs.conf
	    echo "ip_port = 7000" >> /etc/ocfs.conf
	    echo "comm_voting = 1" >> /etc/ocfs.conf
         fi
     done
     /sbin/ocfs_uid_gen -c
   fi 
#Prepare the dependencies among kernel modules which can later be used by modprobe
   /sbin/depmod -a
   kernel_rel=`uname -r`
   cd /lib/modules/$kernel_rel
   LOAD_OCFS=/sbin/load_ocfs
   mkdir -p ocfs
   cd ocfs
   ln -s /lib/modules/$kernel_rel/kernel/drivers/addon/ocfs/ocfs.o ocfs.o
   typeset -i load_ocfs_updated=`grep "MODULE=" $LOAD_OCFS | grep -v "MODULE_SCRIPT" | awk '$1 !~ /#/ { print $0 }' | grep "/lib/modules/$kernel_rel/ocfs/ocfs.o" | wc -l`
   if [ $load_ocfs_updated -eq 0 ]
   then
 # Check if atleast the MODULE= line is present
       typeset -i module_line_present=`grep "MODULE=" $LOAD_OCFS | grep -v "MODULE_SCRIPT" |  wc -l`
       if [ $module_line_present -ne 0 ]
       then
#There should be only one such line
         typeset -i linenumber=`grep -n "MODULE=" $LOAD_OCFS | grep -v "MODULE_SCRIPT" | awk -F: '{ print $1 }'`
          head -n $linenumber $LOAD_OCFS > $LOAD_OCFS.tmp
          echo "MODULE=/lib/modules/$kernel_rel/ocfs/ocfs.o" >> $LOAD_OCFS.tmp
          typeset -i totallines=`wc -l $LOAD_OCFS | awk '{ print $1 }'`
          typeset -i linesafter=$totallines-$linenumber-1
          tail -n $linesafter $LOAD_OCFS >> $LOAD_OCFS.tmp
          mv $LOAD_OCFS.tmp $LOAD_OCFS
       else
          echo "Could not find MODULE= line in $LOAD_OCFS. Please update $LOAD_OCFS manually. Please add the following line at the appropriate place: MODULE=/lib/modules/$kernel_rel/ocfs/ocfs.o."
          updated_load_ocfs="false"
       fi
   fi
   chmod +x ${LOAD_OCFS}
   ${LOAD_OCFS}
fi


#Mount devices using required parameters
if [ "`echo $ENABLE_MOUNT | tr A-Z a-z`" = "true" ]
then
  echo "Mounting devices with required parameters ..." >> $log_file/orarun.log
   mount_info_list=$MOUNT_INFO
   for mount_info in `echo $mount_info_list`
   do
         type_info=`echo $mount_info | cut -d% -f1`
         device_info=`echo $mount_info | cut -d% -f2`
         mount_pt=`echo $mount_info | cut -d% -f3`
         mount_options=`echo $mount_info | cut -d% -f4`
#First updating /etc/fstab if not updated already
         grep $device_info /etc/fstab

         if [ $? != 0 ]
         then
#Update /etc/fstab
           echo "$device_info $mount_pt $type_info $mount_options 0 2" >> /etc/fstab
         fi
# Create the mount location if does not exist already
         if ! test -d "$mount_pt"
         then
             su $INSTALL_USER -c "mkdir -p $mount_pt"
             if  [ $? -ne 0 ]
             then
               echo "Could not create mount point $mount_pt" | tee -a $log_file/orarun.log
             fi
         fi 
         #If mount point is in use; mount point could be in format /scratch/dir or /scratch/dir/ 
         if mount -l | grep "$mount_pt[/]\?[[:space:]]\+"
         then
           #if the reqd device is already  mounted on the given mount point umount and mount again, else if someother device is mounted, then error out. |||ly device can be in same format at mt pt.
           if mount -l | grep "$mount_pt[/]\?[[:space:]]\+" | grep "$device_info[/]\?[[:space:]]\+"
            then
                 echo "Unmounting the device..."
                 if ! umount $mount_pt
                 then
                     echo "Unmounting of $device_info failed, check if the device is in use." | tee -a $log_file/orarun.log
                 else
                     mount -t $type_info $device_info $mount_pt -o $mount_options
                     if [ $? -ne 0 ]
                     then
                        echo "Mounting $device_info on mountpoint $mount_pt with parameter $mount_options failed." | tee -a $log_file/orarun.log
                      fi
                 fi
            else
                echo "Some other filesystem is already mounted on $mount_pt. Specify another mount point or try unmounting the file system from $mount_pt."| tee -a $log_file/orarun.log
            fi
         else
           if ! mount -t $type_info $device_info $mount_pt -o $mount_options
           then
              echo "Mounting $device_info on mountpoint $mount_pt with parameter $mount_options failed." | tee -a $log_file/orarun.log
            fi
         fi
  done

fi

#install the required packages
if [ "`echo $INSTALL_PACKAGES | tr A-Z a-z`" = "true" ]
then
    if [ "`echo $USE_YUM | tr A-Z a-z`" = "true" ]
   then
	http_proxy=http://$HTTP_PROXY:$HTTP_PORT/
        export http_proxy
        ftp_proxy=http://$FTP_PROXY:$FTP_PORT/
        export ftp_proxy
	if [ -z "$YUM_CONF_LOCATION" -o ! -r "$YUM_CONF_LOCATION" ]
        then
                curr_dir=`pwd`
                echo "\n Creating the yum.conf file $curr_dir/yum.conf.. \n "
                YUM_LOG_DIR="/var/yum"
                if [ ! -e $YUM_LOG_DIR ]
                then
                   mkdir -p $YUM_LOG_DIR
                fi
                if [ ! -e $YUM_CACHE_LOC ]
                then
                   mkdir -p $YUM_CACHE_LOC
                fi
                prefix=""  
                if [ "$protocol" != "http" -o "$protocol" != "ftp:" ]
              then
                prefix="file://localhost"
              fi
                cat <<EOF > $curr_dir/yum.conf
[main]
cachedir=$YUM_CACHE_LOC
debuglevel=2
errorlevel=2
logfile=$YUM_LOG_DIR/yum.log
pkgpolicy=newest
tolerant=0
exactarch=1

[base]
baseurl=$prefix$YUM_REPOSITORY_URL
EOF
                YUM_CONF_LOCATION=$curr_dir/yum.conf
        fi
	if [ -n "$PACKAGES" ]
        then
           for package in $PACKAGES $GLIBC_PACKAGE $OCFS_PACKAGES
            do
                yum -y -c $YUM_CONF_LOCATION install $package
                if ! rpm --quiet -q $package
                then
                echo "Package: $package could not be installed" |tee -a $log_file/orarun.log
                fi
            done
        fi
  
    else
#USE RPM TO INSTALL PACKAGES
         echo "Installing packages using rpm ..." >> $log_file/orarun.log
	for rpm_name in $RPM_FILENAMES
        do
           url="$RPM_BASE_URL/$rpm_name"
           if [ -n $url ]
           then
              protocol="`expr $url : '\(....\)'`"
              if [ "$protocol" = "http" ]
              then
                 rpm -Uvh $url --httpproxy $HTTP_PROXY --httpport $HTTP_PORT
              elif [ "$protocol" = "ftp:" ]
              then
                 rpm -Uvh $url --ftpproxy $FTP_PROXY --ftpport $FTP_PORT
              else
                 rpm -Uvh $url
              fi
           fi
        done
	for package in $PACKAGES $GLIBC_PACKAGE $OCFS_PACKAGES
        do
          if ! rpm --quiet -q $package
          then
           echo "Package: $package could not be installed." |tee -a $log_file/orarun.log
          fi
       done
   fi	
fi

#install the oracle packages : bug fix 7378320
if [ "`echo $ORACLE_PACKAGES_ENABLE | tr A-Z a-z`" = "true" ]
then
#export all the env vars required for installing the packages
	if [ -n "$EXPORT_RPM_VARS" ]
	then
		for var in $EXPORT_RPM_VARS
		do
			export $var
		done
	fi

#install the packages from rpm location
        if [ -n "$ORACLE_PACKAGES" ]
        then
           for package in $ORACLE_PACKAGES
            do
		oraclepackage="$ORACLE_RPM_LOCATION/$package"
		echo Installing Package $oraclepackage
		rpm -Uvh $oraclepackage
		returncode=$?
            done
        fi
fi

#install the oracle packages : bug fix 7378320
if [ "`echo $REMOVE_USER_FROM_GROUP_ENABLE | tr A-Z a-z`" = "true" ]
then
	echo "Removing user '$REMOVE_USER' from group '$REMOVE_FROM_GROUP' ..."
	existing_user_groups=`id -nG $REMOVE_USER | grep $REMOVE_FROM_GROUP`
	if [ "$existing_user_groups" = "" ]; 
	then 
		echo "User '$REMOVE_USER' not in group '$REMOVE_FROM_GROUP'"
	else
		modified_groups=`echo $existing_user_groups | sed "s/$REMOVE_FROM_GROUP//g"  | sed "s/  / /g" | sed "s/ /,/g"`
		/usr/sbin/usermod -G $modified_groups $REMOVE_USER
	fi
fi

exit $EXIT_CODE ;
