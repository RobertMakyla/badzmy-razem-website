#!/bin/bash

gitIgnoredSecretDir=secret

HOST=$(       cat ${gitIgnoredSecretDir}/host.txt      ) # ftp://XXX.XXX.pl
USER=$(       cat ${gitIgnoredSecretDir}/user.txt      ) # XXX
PASS=$(       cat ${gitIgnoredSecretDir}/pass.txt      ) # XXX
TARGETDIR=$(  cat ${gitIgnoredSecretDir}/targetdir.txt ) # /public_html/XXX/XXX

SOURCEDIR='temporary-target-dir'

lftp -f "
    open $HOST
    user $USER $PASS
    mirror --reverse --delete --verbose $SOURCEDIR $TARGETDIR
    bye
"