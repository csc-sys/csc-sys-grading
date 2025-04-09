#!/bin/zsh -f

PROG=$0
labs=(traininglab-part1 traininglab-part2 mini-x86-parsing mini-x86-alu mini-x86-cmu stacklab asmlab dictlab shelllab cachelab locksmith malloclab proxylab)

usage () {
  echo "usage: $PROG LABNAME DESTDIR [USER...]"
  echo "  LABNAME is one of:"
  for lab in $labs; do
    echo "    - $lab"
  done
  echo "  USER is either a username (blah42) or a user's home folder (/home/blah42)"
  echo "example: $PROG $labs[1] ~/$labs[1]-subs/ /home/*"
  exit 2
}

(( $# < 3 )) && usage

lab=$1
(( $labs[(Ie)$lab] )) || usage
destdir=$2
mkdir -p $destdir || usage

shift 2

try () {
  out_file=$(strace -f -t -e trace=openat,open,creat -o "| grep 'O_WRONLY\\|creat' | cut -d'\"' -f2" "$@" 2> /dev/null)
  if (( $? == 0 )); then
    echo "[PASS] $usr"
    true
  else
    echo "[FAIL] $usr"
    [[ -e $out_file ]] && rm -f $out_file
    false
  fi
}

if [[ -d $1 ]]; then
  dirs=($@[@])
else
  ## assuming we're passed a roster
  (( $# == 1 )) || usage
  dirs=($(cut -d':' -f3 $1 | tr 'A-Z' 'a-z' | sed 's/$//'))  # used to be: s/$/_/
fi

for usr in $dirs; do
  usr=${usr:t}
  home=/home/$usr
  case $lab; in
    traininglab-part1)
      try tar cf $destdir/$usr-$lab.tar -C $home/traininglab/shell .;;
    traininglab-part2)
      # files=($home/traininglab/*(N.))
      try tar cf $destdir/$usr-$lab.tar -C $home/traininglab-part2 .;;
    stacklab)
      try tar --ignore-failed-read -cf $destdir/$usr-$lab.tar -C $home/ --exclude=Makefile stacklab/ --transform='s@^stacklab/@@' .history .gdb_history .stacklab;;
    locksmith)
      try tar cf $destdir/$usr-$lab.tar -C $home/submissions $usr-locksmith.txt;;
    *)
      try cp -af $home/submissions/$usr-$lab.tar $destdir/;;
  esac
done

[[ $SUDO_UID && $SUDO_GID ]] && chown -R $SUDO_UID:$SUDO_GID $destdir
