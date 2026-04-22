#!/bin/zsh -f

PROG=$0
usage () {
    echo "usage: $PROG LOGFOLDER LABNAME"
    echo "Copies logs from LOGFOLDER to /home/<user>/grading/LABNAME.log"
    exit 2
}

(( $# == 2 )) || usage

logfolder=${1:a}
labname=$2

for logfile in $logfolder/*.log; do
    tarname=${logfile:t:r}          # e.g. jsmith_-traininglab-part1.tar
    # extract username: everything up to and including the trailing underscore
    usr=${tarname//-${labname}*/}
    home=/home/$usr
    if [[ ! -d $home ]]; then
        echo "[SKIP] no home dir for $usr"
        continue
    fi
    mkdir -p $home/grading
    cp $logfile $home/grading/$labname.log
    echo "[SENT] $usr"
done
