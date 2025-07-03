#! /usr/bin/env bash

#source ../lib/olaus_begin.sh
source ../lib/olaus_def.sh
source ../lib/errmsg.sh
source ../lib/olaus_end.sh
source ../lib/setexcode.sh
source ../lib/rmtmpfile.sh



# run-tst -- Run a test in the test library

declare -r FILENAME="$1"
declare -r PGMID="OLSTST"


printf "%s\n" "OLSTST0001I $( date '+%T' ) Begin $FILENAME"

if [[ -z "$FILENAME" ]]
then
    errmsg 7001 $EX_SOFTWARE "run-test: missing argument 1, No script file to run"
else
    bash $FILENAME
    RC=$?
    setexcode $RC
fi

printf "%s\n" "OLSTST0002I $( date '+%T' ) End $FILENAME"

exit $EX_CODE
