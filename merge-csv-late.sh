#!/bin/zsh

(( $# == 2 )) || { echo "usage: $0 score.csv score-late.csv"; exit 2 }

sc=$1
scl=$2

get_user_score () {
  user=$1
  { grep "^$1,[0-9]" $2 || echo "0,0" } | cut -d, -f2
}

for user in $(cut -d',' -f1 "$@" | sort -u); do
  origscore=$(get_user_score $user $sc)
  newscore=$(get_user_score $user $scl)
  if (( newscore > origscore )); then
    (( origscore = origscore + (newscore - origscore) * 60 / 100 ))
  fi
  echo "$user,$origscore,"
done
