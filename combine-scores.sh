#!/bin/zsh -f

PROG=$0
usage () {
    echo "usage: $PROG ROSTER.csv SCORES.csv [SCORES2.csv ...]"
    exit 2
}

(( $# >= 2 )) || usage

roster=$1
shift

# Build score map: keep highest score per student across all score files.
# Use -1 as sentinel for "no submission".
typeset -A score_map
outof=0
for scores in "$@"; do
    while IFS=, read -r user sc oof _; do
        outof=$oof
        if [[ -z ${score_map[$user]} || $sc -gt ${score_map[$user]} ]]; then
            score_map[$user]=$sc
        fi
    done < $scores
done

# Parse quoted CSV roster with awk
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
