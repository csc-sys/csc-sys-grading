#!/bin/zsh -f

PROG=$0
usage () {
    echo "usage: $PROG ROSTER.csv SCORES.csv"
    exit 2
}

(( $# == 2 )) || usage

roster=$1
scores=$2

# Build associative array of scores keyed by username
typeset -A score_map outof_map
outof=0
while IFS=, read -r user sc oof _; do
    score_map[$user]=$sc
    outof=$oof
done < $scores

# Parse quoted CSV roster with awk, extract username+name for students
awk 'BEGIN { FPAT = "([^,]*)|(\"[^\"]*\")" }
     NR > 1 && $5 == "Student" {
         name = $1; gsub(/"/, "", name)
         user = toupper($3); gsub(/"/, "", user)
         print user, name
     }' $roster | sort | while read -r user name; do
    sc=${score_map[$user]:-0}
    printf "%-12s %-35s %2d/%d\n" $user "$name" $sc $outof
done
