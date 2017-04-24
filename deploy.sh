#!/bin/bash

gitIgnoredSecretDir=secret

[[ ! -f ${gitIgnoredSecretDir}/host.txt      ]] &&  echo "Missing host.txt" && exit 1
[[ ! -f ${gitIgnoredSecretDir}/user.txt      ]] &&  echo "Missing user.txt" && exit 1
[[ ! -f ${gitIgnoredSecretDir}/pass.txt      ]] &&  echo "Missing pass.txt" && exit 1
[[ ! -f ${gitIgnoredSecretDir}/destinationDir.txt ]] &&  echo "Missing destinationDir.txt" && exit 1

HOST=$( cat ${gitIgnoredSecretDir}/host.txt      ) # ftp://XXX.XXX.pl
USER=$( cat ${gitIgnoredSecretDir}/user.txt      ) # XXX
PASS=$( cat ${gitIgnoredSecretDir}/pass.txt      ) # XXX
DST=$(  cat ${gitIgnoredSecretDir}/destinationDir.txt ) # /public_html/XXX/XXX

SRC=target

if [ -d ${SRC} ] ; then
   echo "Source dir '${SRC}' exists, so it will be synchronized with ${HOST}${DST}"
else
   echo "Source dir '${SRC}' doesn't exists. Use generate.sh to generate webpage in dir ${SRC}"
   exit 1
fi

lftp -f "
    open $HOST
    user $USER $PASS
    mirror --reverse --delete --verbose $SRC $DST
    bye
"