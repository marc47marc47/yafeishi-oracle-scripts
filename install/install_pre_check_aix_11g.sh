##  参考： http://www.askmaclean.com/archives/aix%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F%E4%B8%8A%E5%AE%89%E8%A3%85oracle%E6%95%B0%E6%8D%AE%E5%BA%93%E5%BF%85%E4%B8%8D%E5%8F%AF%E5%B0%91%E7%9A%84%E5%87%A0%E9%A1%B9%E6%A3%80%E6%9F%A5%E5%B7%A5%E4%BD%9C-2.html

## The following operating system filesets are required for AIX 5L:
## bos.adt.base
## bos.adt.lib
## bos.adt.libm
## bos.perf.libperfstat 5.3.9.0 or later
## bos.perf.perfstat
## bos.perf.proctools
## xlC.aix50.rte.10.1.0.0 or later
## gpfs.base 3.2.1.8 or later
##
## The following operating system filesets are required for AIX 6.1:
## bos.adt.base
## bos.adt.lib
## bos.adt.libm
## bos.perf.libperfstat 6.1.2.1 or later
## bos.perf.perfstat
## bos.perf.proctools
## xlC.aix61.rte:10.1.0.0 or later
## xlC.rte.10.1.0.0 or later
## gpfs.base 3.2.1.8 or later
## 
## The following operating system filesets are required for AIX 7.1: 
## bos.adt.base
## bos.adt.lib
## bos.adt.libm
## bos.perf.libperfstat
## bos.perf.perfstat
## bos.perf.proctools
## xlC.aix61.rte.10.1.0.0 or later
## xlC.rte.10.1.0.0 or later
## gpfs.base 3.3.0.11 or later

echo "------------------- check aix OS packages if install "
OSpackagesOK=true
if /usr/bin/test -x /usr/bin/lslpp
then
  for PACKAGE in "bos.adt.base" "bos.adt.lib" "bos.adt.libm" "bos.perf.perfstat" "bos.perf.libperfstat" "bos.perf.proctools"
  do
    if [ `/usr/bin/lslpp -l | /usr/bin/grep -c $PACKAGE` != 0 ]
    then
      STATE=`/usr/bin/lslpp -l | /usr/bin/grep $PACKAGE | /usr/bin/awk '{print $3}' | /usr/bin/sed '2,$d'`
      if [ $STATE != "COMMITTED" ]
      then
         if [ $STATE != "APPLIED" ]
         then
            /usr/bin/echo "$PACKAGE"NotApplied
            OSpackagesOK=false
         fi
      fi
    else
      /usr/bin/echo "$PACKAGE"NotInstalled
      OSpackagesOK=false
    fi
  done
else
  /usr/bin/echo "NoAccess"

  OSpackagesOK=false
fi
if [ $OSpackagesOK = true ]
then
   /usr/bin/echo "All required OS packages are installed"
fi

###########   patches 
## for AIX 5L:
## IZ42940
## IZ49516
## IZ52331
## for AIX 6L:
## IZ41855
## IZ51456
## IZ52319
## IZ97457
## IZ89165
## for AIX 7L:
## IZ87216
## IZ87564
## IZ89165
## IZ97035
ospachtes5="IZ42940 IZ49516 IZ52331"
ospachtes6="IZ41855 IZ51456 IZ52319 IZ97457 IZ89165"
ospachtes7="IZ87216 IZ87564 IZ89165 IZ97035"
echo "------------------- check aix OS patches if install "
OSpackagesOK=true
if /usr/bin/test oslevel
then 
	osver4char=`/usr/bin/oslevel -r| /usr/bin/awk -F- '{print $1}'`
else
	osver4char="0000"
fi
if /usr/bin/test -x /usr/sbin/instfix
then
	if [ $osver4char -eq "5200" ]
	then
		for patch in $ospachtes5
		do
			if [ `/usr/sbin/instfix -ik $patch 2>&1 | /usr/bin/grep -ic "no"` != 0 ]
			then
				/usr/bin/echo "$patch" for "$osver4char" is Not Installed!
				OSpatchesOK=false
			fi
		done
	elif [ $osver4char -eq "6100" ]	
	then
		for patch in $ospachtes6
		do
			if [ `/usr/sbin/instfix -ik $patch 2>&1 | /usr/bin/grep -ic "no"` != 0 ]
			then
				/usr/bin/echo "$patch" for "$osver4char" is Not Installed!
				OSpatchesOK=false
			fi
		done	
	elif [ $osver4char -eq "7100" ]	
	then
		for patch in $ospachtes7
		do
			if [ `/usr/sbin/instfix -ik $patch 2>&1 | /usr/bin/grep -ic "no"` != 0 ]
			then
				/usr/bin/echo "$patch" for "$osver4char" is Not Installed!
				OSpatchesOK=false
			fi
		done	
	fi
else
	/usr/bin/echo "NoAccess!!!"	
	OSpackagesOK=false
fi
if [ $OSpatchesOK = true ]
then
   /usr/bin/echo "PatchesFound"
fi

##   Shell Limit (As Shown in smit)	Recommended Value
##   Soft FILE size	-1 (Unlimited)
##   Soft CPU time	-1 (Unlimited)
##   Note: This is the default value.
##   Soft DATA segment	-1 (Unlimited)
##   Soft STACK size	-1 (Unlimited)
##   Soft Real Memory size	-1 (Unlimited)
##   Processes (per user)	-1 (Unlimited)
echo "------------------- check aix OS ulimit configuration "
TIMEOK=false
TIME=`/usr/bin/ulimit -t`
if /usr/bin/test -z "$TIME"
then
	/usr/bin/echo TimeNotDef
elif [ $TIME != "unlimited" ]
then
	/usr/bin/echo TimeTooSmall
else
TIMEOK=true
fi

FILEOK=false
FILE=`/usr/bin/ulimit -f`
if /usr/bin/test -z "$FILE"
then
	/usr/bin/echo FileNotDefined
elif [ $FILE != "unlimited" ]
then
	/usr/bin/echo FileTooSmall
else
FILEOK=true
fi

DATAOK=false
DATA=`/usr/bin/ulimit -d`
if /usr/bin/test -z "$DATA"
then
	/usr/bin/echo DataNotDefined
elif [ $DATA = "unlimited" ]
then
DATAOK=true
elif [ $DATA -ge 1048576 ]
then
DATAOK=true
else
	/usr/bin/echo DataTooSmall
fi

STACKOK=false
STACK=`/usr/bin/ulimit -s`
if /usr/bin/test -z "$STACK"
then
	/usr/bin/echo StackNotDefined
elif [ $STACK = "unlimited" ]
then
STACKOK=true
elif [ $STACK -ge 32768 ]
then
STACKOK=true
else
	/usr/bin/echo StackTooSmall
fi

NOFILESOK=false
NOFILES=`/usr/bin/ulimit -n`
if /usr/bin/test -z "$NOFILES"
then
	/usr/bin/echo NoFilesNotDefined
elif [ $NOFILES = "unlimited" ]
then
NOFILESOK=true
elif [ $NOFILES -ge 4096 ]
then
NOFILESOK=true
else
	/usr/bin/echo NoFilesTooSmall
fi

MEMORYOK=false
MEMORY=`/usr/bin/ulimit -m`
if /usr/bin/test -z "$MEMORY"
then
	/usr/bin/echo MemoryNotDefined
elif [ $MEMORY = "unlimited" ]
then
MEMORYOK=true
elif [ $MEMORY -ge 2045680 ]
then
MEMORYOK=true
else
	/usr/bin/echo MemoryTooSmall
fi

if [ $TIMEOK = true -a $FILEOK = true -a $DATAOK = true -a $STACKOK = true -a $NOFILESOK = true -a $MEMORYOK = true ]
then
/usr/bin/echo ulimitOK
fi

##   # /usr/sbin/no -a | fgrep ephemeral
##   Parameter		 	Recommended Value
##   maxuprocs			16384
##   ncargs				128
##   tcp_ephemeral_low	32768
##   tcp_ephemeral_high	65535
##   udp_ephemeral_low	32768
##   udp_ephemeral_high	65535
##   /usr/sbin/no -p -o tcp_ephemeral_low=9000 -o tcp_ephemeral_high=65500
##   /usr/sbin/no -p -o udp_ephemeral_low=9000 -o udp_ephemeral_high=65500	 
##   chdev -l sys0 -a ncargs=$NCARGS
##  no -a|grep  -E 'udp_sendspace|udp_recvspace|tcp_sendspace|tcp_recvspace|rfc1323|sb_max|ipqmaxlen|tcp_ephemeral|udp_ephemeral'
##   AIX 6.1:
##   
##   # ioo –o aio_maxreqs
##   aio_maxreqs = 65536
##   On AIX 5.3:
##   
##   # lsattr -El aio0 -a maxreqs -F value
##   maxreqs 65536 Maximum number of REQUESTS True

######  内存参数
##  vmo -p -o maxperm%=90
##  vmo -p -o minperm%=3
##  vmo -p -o maxclient%=90
##  vmo -p -o maxpin%=90
##  vmo -p -o strict_maxperm=0
##  vmo -p -o strict_maxclient=1
##  vmo -p -o lru_file_repage=0
##  vmo -r -o page_steal_method=1
##  vmo -a|grep  -E 'minperm|maxclient|maxperm|strict_maxclient|strict_maxperm|lru_file_repage|page_steal_method'

function check_osconfig
{

CHECK_TYPE="$1"
if [ "$CHECK_TYPE"x = "no"x ]
then 
	PARAM_VALUE=`/usr/sbin/no -a | grep $2 | /usr/bin/cut -d = -f 2`
	CHANGE_PARAM="/usr/sbin/no -p -o $2=$3"  
elif [ "$CHECK_TYPE"x = "os"x ]	
then
	PARAM_VALUE=`/usr/sbin/lsattr -El sys0 -a $2 -F value`
	CHANGE_PARAM="/usr/sbin/chdev -l sys0 -a $2=$3" 
elif [ "$CHECK_TYPE"x = "vmo"x ]	
then
	PARAM_VALUE=`/usr/sbin/vmo -a | grep $2 | /usr/bin/cut -d = -f 2`
	if [ "$2"x = "page_steal_method"x ]
	then 
		CHANGE_PARAM="/usr/sbin/vmo -r -o $2=$3" 
	else	
	CHANGE_PARAM="/usr/sbin/vmo -p -o $2=$3" 
	fi
fi	
## PARAM_VALUE=`${CAT_PARAM}`
if /usr/bin/test -z "$PARAM_VALUE"
then
	/usr/bin/echo -----------need to reset :  $2 is not set,you can use $CHANGE_PARAM to set it.
	return 1
elif [ $PARAM_VALUE -ge $3 ]
then
  /usr/bin/echo  $2=$3 is ok!!!
  STATUS=true
elif [ $PARAM_VALUE -lt $3 ]
then
   /usr/bin/echo ------------need to reset :   $2=$PARAM_VALUE is small, you can use $CHANGE_PARAM  to set it.
   STATUS=false
fi
return 0
}

echo "---------------------------- check no parameter value " 
check_osconfig no  tcp_ephemeral_low	9000
check_osconfig no  tcp_ephemeral_high	65535
check_osconfig no  udp_ephemeral_low	9000
check_osconfig no  udp_ephemeral_high	65535
check_osconfig no  tcp_recvspace   65536
check_osconfig no  tcp_sendspace   65536
check_osconfig no  udp_sendspace   65536
check_osconfig no  udp_recvspace   65536
check_osconfig no  rfc1323   1
check_osconfig no  sb_max   4194304 
check_osconfig no  ipqmaxlen   512
echo "--------------------------- check vmo parameter value " 
check_osconfig  vmo  maxperm%  90
check_osconfig  vmo  minperm%  3
check_osconfig  vmo  maxclient%  90
check_osconfig  vmo  maxpin%  90
check_osconfig  vmo  strict_maxperm  0
check_osconfig  vmo  strict_maxclient  1
check_osconfig  vmo  lru_file_repage  0
check_osconfig  vmo  page_steal_method  1
echo "--------------------------- check osconfig parameter value " 
check_osconfig os maxuproc  16384
check_osconfig os ncargs  256
check_osconfig os minpout  4096
check_osconfig os maxpout  8193
    





