#!/bin/bash

make -f ../bin/test.mk TEST=$1 clean
make -f ../bin/test.mk TEST=$1 init
make -f ../bin/test.mk TEST=$1 run

cmp -s $1_results.txt ../out/$1_results.txt
STATUS=$?
if [ $STATUS -eq 0 ]; then
  echo "PASS!"
  # match
elif [ $STATUS -eq 1 ]; then
  echo "FAIL"
  exit 88
  # compare
else
  echo "ERROR. Unexpected result when comparing to the reference output!"
  exit 89
fi

if [ "$SECONDS" -eq 1 ]
then
  units=second
else
  units=seconds
fi
echo "This script has been running for $SECONDS $units."
