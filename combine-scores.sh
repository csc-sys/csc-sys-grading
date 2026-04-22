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
while IFS=, read -r user sc outof _; do
    score_map[$user]=$sc
    outof_map[$user]=$outof
done < $scores

# Read roster, skip header, skip non-students
tail -n +2 $roster | while IFS=, read -r name _ user _ role _; do
    [[ $role == *Student* ]] || continue
    # Strip surrounding quotes from name and user
    name=${name//\"/}
    user=${user//\"/}
    user=${(U)user}
    sc=${score_map[$user]:-0}
    outof=${outof_map[$user]:-${outof_map[(v)*]:-44}}
    printf "%-12s %-35s %2d/%d\n" $user "$name" $sc $outof
done | sort
