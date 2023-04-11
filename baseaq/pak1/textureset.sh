#!/bin/bash

TDIR=$1

#export TDIR="e2u1"
aws s3 ls s3://gameassets.aq2world.com/action/textures/${TDIR}/ | grep jpg | awk '{print $4}' > temp/${TDIR}
sed 's-^-softlink textures/'${TDIR}'/-g' temp/${TDIR} > temp/${TDIR}-1
paste temp/${TDIR}-1 temp/${TDIR} > temp/${TDIR}-temp
sed 's-.jpg	-.wal textures/q2converted/-g' temp/${TDIR}-temp > temp/${TDIR}-2
sed 's-.jpg-.wal-g' temp/${TDIR}-2 > temp/${TDIR}-final

