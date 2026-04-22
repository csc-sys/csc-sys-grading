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
typeset -A roster_map
awk 'BEGIN { FPAT = "([^,]*)|(\"[^\"]*\")" }
     NR > 1 && $5 == "Student" {
         name = $1; gsub(/"/, "", name)
         user = toupper($3); gsub(/"/, "", user)
         print user, name
     }' $roster | while read -r user name; do
    roster_map[$user]=$name
done

# Merge: all roster students + any score entries not in roster
typeset -A seen
{
    for user in ${(k)roster_map}; do
        echo $user
        seen[$user]=1
    done
    for user in ${(k)score_map}; do
        (( seen[$user] )) || echo $user
    done
} | sort | while read -r user; do
    name=${roster_map[$user]:-__MISSING__}
    if [[ -n ${score_map[$user]} ]]; then
        printf "%-12s %-35s %2d/%d\n" $user "$name" ${score_map[$user]} $outof
    else
        printf "%-12s %-35s --/%d\n" $user "$name" $outof
    fi
done
