#!/bin/zsh -f

SCRIPT_PATH="${0:A:h}"
SANDBOX=$SCRIPT_PATH/sandbox.sh

exec 3>&1

PROG=$0
usage () {
    echo "usage: $PROG HANDOUT SCOREFILE LOGFOLDER [TARBALLS...]"
    echo "HANDOUT is either a folder or a tarball."
    exit
}

extracted_files=()

# extract-files tarball pattern.  Files overwritten ar backuped using a .BAK suffix;
# files extracted are touched to make sure that the newly extracted files are newer.
extract-files () {
    extracted_files=(
       $(tar --warning=none --backup=simple --suffix=.BAK --touch --wildcards -xvf "$1" "$2" 2>&1 \
          | tee -a $logfile \
          | grep -v BAK)
    )
}

# This is for **/*.BAK to fail silently if no BAK files exist.
setopt null_glob

# Delete all files in $extracted_files, restoring the .BAK files.
restore-files () {
    for f in $extracted_files; do
      [[ -f $f ]] && rm $f
    done
    for f in **/*.BAK; do
      mv $f ${f/.BAK/}
    done
}

# Debug flag
if [[ $1 == '-x' ]]; then
  setopt xtrace
  shift
fi

(( $# > 3 )) || usage

handout=${1:a}
scorefile=${2:a}
touch $scorefile || exit 2
logfolder=${3:a}
mkdir -p $logfolder || exit 2
shift 3

# Put the score in scorefile, possibly removing the file beforehand.
# Adjust to correctly extract username. 
save-score () {
    username=${${1:t}/_*/}
    username=${(U)username}
    sed -i "/^$username,/d" $scorefile
    echo "$username,$2," >> $scorefile
}

# Save the output in $logfile, but print only one dot per line; shows progress without clutter.
dotoutput () {
  stdbuf -o0 "$@" 2>&1 | stdbuf -i0 -o0 tee -a $logfile | stdbuf -i0 -o0 sed 's/.*//' | stdbuf -i0 -o0 tr '\n' '.'
  ret=$pipestatus[1]
  echo
  return $ret
}

# handout either provided as folder or tarball.
if [[ -d $handout ]]; then
    orig=$handout
else
    orig=$(mktemp -d)
    tar xvf $handout --strip-components=1 -C $orig/ || exit 1
    cleanup=1
fi

startpath=$PWD
for f in "$@"; do
    cd $startpath
    f=${f:A}
    echo "Grading ${f:t}"
    logfile=$logfolder/${f:t}.log
    rm -f $logfile
    cd $orig
    extract-files $f '*' # I use to restrict the files being extracted
    echo 'COMPILING PROJECT...' | tee -a $logfile
    dotoutput $SANDBOX make
    (( $? == 0 )) || {
        echo 'COMPILATION FAILED.'
        continue
    }
    echo 'RUNNING DRIVER...' | tee -a $logfile
    touch tests/.agreement-accepted &> /dev/null
    dotoutput timeout --foreground -k 8 120 $SANDBOX make test
    score=$(tail -n5 $logfile | sed -n '/.*FINAL.*/ { s@.*FINAL[^[:space:]]*[[:space:]]*\([0-9]*\)[[:space:]]*/.*@\1@p;q }')
    echo "SCORE: $score"
    save-score $f $score
    restore-files
done

if (( cleanup )); then rm -fR $orig; fi
