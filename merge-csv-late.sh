#!/bin/zsh

weights=(100. 60. 40.)

(( $# >= 2 )) || { echo "usage: $0 score.csv score-late.csv [...]"; exit 2 }


get_user_score () {
  user=$1
  s=$(grep "^$1,[0-9]" $2 || echo "0,0,0")
  s=(${(s/,/)s})
  score=$s[2]
  outof=$s[3]
}


for user in $(cut -d',' -f1 "$@" | sort -u); do
    maxscore=0
    currentscore=0
    i=1
    for sc in "$@"; do
        get_user_score $user $sc
        if (( maxscore < score )); then
            currentscore=$((currentscore + (score - maxscore) * weights[i] / 100. ))
            maxscore=$score
        fi
        ((++i))
    done
    typeset -i round
    (( round = currentscore * 100 ))
    echo "$user,$((round / 100)).$((round % 100)),"
done
