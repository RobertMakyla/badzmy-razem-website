#!/bin/bash

gitIgnoredSecretDir=secret

[[ ! -f ${gitIgnoredSecretDir}/host.txt      ]] &&  echo "Missing host.txt" && exit 1
[[ ! -f ${gitIgnoredSecretDir}/user.txt      ]] &&  echo "Missing user.txt" && exit 1
[[ ! -f ${gitIgnoredSecretDir}/pass.txt      ]] &&  echo "Missing pass.txt" && exit 1
[[ ! -f ${gitIgnoredSecretDir}/targetdir.txt ]] &&  echo "Missing targetdir.txt" && exit 1

HOST=$(       cat ${gitIgnoredSecretDir}/host.txt      ) # ftp://XXX.XXX.pl
USER=$(       cat ${gitIgnoredSecretDir}/user.txt      ) # XXX
PASS=$(       cat ${gitIgnoredSecretDir}/pass.txt      ) # XXX
TARGETDIR=$(  cat ${gitIgnoredSecretDir}/targetdir.txt ) # /public_html/XXX/XXX

SOURCEDIR=target

if [ -d ${SOURCEDIR} ] ; then
   echo "${SOURCEDIR} dir exists, so it will be synchronized with ${HOST}${TARGETDIR}"
else
   echo "${SOURCEDIR} dir doesn't exists. Use generate.sh to generate webpage in dir ${SOURCEDIR}"
   exit 1
fi

lftp -f "
    open $HOST
    user $USER $PASS
    mirror --reverse --delete --verbose $SOURCEDIR $TARGETDIR
    bye
"