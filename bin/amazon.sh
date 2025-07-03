function amazon () {

# Get the six columns from the transaction file we need.

[[ $OLS_DEBUG ]] && ols_err $PGMID 1000 $EX_OK "$(date +"%H:%M:%S") ${FUNCNAME[0]} Begin"

txn_in="$1"
txn_out="$2"

csvcut --columns="1,3,4,5,6,7" "$txn_in" >"$txn_out"

[[ $OLS_DEBUG ]] && ols_err $PGMID 1000 $EX_OK "$(date +"%H:%M:%S") ${FUNCNAME[0]} End"


} # amazon
