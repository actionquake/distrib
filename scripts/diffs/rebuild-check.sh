#!/bin/bash

directoryArray=(default-configs default-game-content default-hdtextures default-mappack0 default-mappack1 default-pics default-sounds)

diffs=$(git diff --name-only HEAD^ HEAD)

cat <<EOF > diff.tmp
$diffs
EOF

for dir in ${directoryArray[@]}; do
    filediff=$(grep ${dir} diff.tmp)

    if [[ ${?} = 0 ]]; then
        echo "! Diff found in ${dir} !"
        echo ${dir} >> diff_found.tmp
    else
        echo "# No differences found between this commit and the last, exiting #"
        exit 0
    fi
done