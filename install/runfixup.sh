#!/bin/sh
#
# $Header: opsm/cvutl/runfixup.sh /st_has_11.2.0/1 2011/01/12 15:16:23 agorla Exp $
#
# runfixup.sh
#
# Copyright (c) 2007, 2011, Oracle and/or its affiliates. All rights reserved. 
#
#    NAME
#      runfixup.sh - This script is used to run fixups on a node
#
#    DESCRIPTION
#      <short description of component this file declares/defines>
#
#    NOTES
#      <other useful comments, qualifications, etc.>
#
#    MODIFIED   (MM/DD/YY)
#    agorla      01/10/11 - XbranchMerge agorla_bug-10008427 from main
#    agorla      08/18/10 - bug#10023742 - donot echo id cmd
#    nvira       05/04/10 - fix the id command
#    dsaggi      01/27/10 - Fix 8729861
#    nvira       06/24/08 - remove sudo
#    dsaggi      05/29/08 - remove orarun.log before invocation
#    dsaggi      10/24/07 - Creation
#
AWK=/bin/awk
ECHO=/bin/echo
ID=/usr/bin/id
GREP=/bin/grep

RUID=`$ID -u 1> /dev/null 2>&1`
status=$?

if [ "$status" != "0" ];
then
  RUID=`$ID | $AWK -F\( '{print $1}' | $AWK -F= '{ print $2}'`
else
RUID=`$ID -u`
fi

if [ -z "$RUID" ];
then
  $ECHO "Failed to get effective user id. export ID=<PATH-TO-ID> to get effective ID and then rerun the command"
  exit 1
fi 

if [ "${RUID}" != "0" ];then
	  $ECHO "You must be logged in as root (uid=0) when running $0."
	    exit 1
fi


EXEC_DIR=`dirname $0`

RMF="/bin/rm -f"

#  Remove old orarun.log before invocation
$RMF ${EXEC_DIR}/orarun.log

${EXEC_DIR}/orarun.sh ${EXEC_DIR}/fixup.response  ${EXEC_DIR}/fixup.enable ${EXEC_DIR}
