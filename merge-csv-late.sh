#!/bin/zsh

(( $# == 2 )) || { echo "usage: $0 score.csv score-late.csv"; exit 2 }

sc=$1
scl=$2

get_user_score () {
  user=$1
  s=$(grep "^$1,[0-9]" $2 || echo "0,0,0")
  s=(${(s/,/)s})
  score=$s[2]
  outof=$s[3]
}

for user in $(cut -d',' -f1 "$@" | sort -u); do
  get_user_score $user $sc
  origscore=$score
  origoutof=$outof
  get_user_score $user $scl
  newscore=$score
  outof=$((outof > origoutof ? outof : origoutof))
  newscore=$((newscore < origscore ? origscore : newscore))

  bonus=$((newscore - outof))
  bonus=$((bonus < 0 ? 0 : bonus))

  origscore=$((origscore > outof ? outof : origscore))
  newscore=$((newscore > outof ? outof : newscore))
  
  if (( newscore > origscore )); then
    (( origscore = origscore + (newscore - origscore) * 60 / 100 ))
  fi
  (( origscore += bonus ))
  echo "$user,$origscore,"
done
