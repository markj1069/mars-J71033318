#--------------------------------------------------------------------------------------------------
#
# Process the unique features of the Barclays transactions
#
#--------------------------------------------------------------------------------------------------

function barclays() {

[[ $OLS_DEBUG ]] && ols_err "$PGMID" 1000 $EX_OK "$(date +"%H:%M:%S") ${FUNCNAME[0]} Begin bank processing."

# Save the arguments to barclays.
declare    -r    txn_in="$1"
declare    -r    txn_out="$2"

# Create temporary work files
declare    -r    txn_date_desc_cat="$OLS_TMP_DIR/txn_date_desc_cat.csv"
declare    -r    txn_amt="$OLS_TMP_DIR/txn_amt.csv"
declare    -r    txn_checkno="$OLS_TMP_DIR/txn_checkno.csv"

# Get the six columns from the transaction file we need.

[[ $OLS_DEBUG ]] && ols_err "$PGMID" 1000 $EX_OK "$(date +"%H:%M:%S")" "${FUNCNAME[0]} Begin csvcut operations."
csvcut --columns="1,2,3" "$txn_in" >"$txn_date_desc_cat"  #2>/dev/null  # Get Date and Description
csvcut --columns="4"     "$txn_in" >"$txn_amt"            #2>/dev/null  # Get amount column


[[ $OLS_DEBUG ]] && ols_err $PGMID 1000 $EX_OK "$(date +"%H:%M:%S")" "Create pseudo Check No. column."
# Create an empty catagory column to add to the transaction file.
cnt=$(cat "$txn_in" | wc --lines)        # How big is this csv?

printf "%s\n" "Check No." >"$txn_checkno"  # Empty the check number column
for (( i=2; i<=cnt; i++ )) do              # Build empty check number and catagory columns
    printf "%s\n" "-" >>"$txn_checkno"     # consisting of cnt rows of a dash
done # for (( i=2;

[[ $OLS_DEBUG ]] && ols_err $PGMID 1000 $EX_OK "$(date +"%H:%M:%S")" "Begin cvsjoin operation"

# Join the pieces of the transaction into standard form. There is no memo from barclays.
csvjoin -d, --snifflimit=0 "$txn_date_desc_cat" "$txn_checkno" "$txn_amt" >"$txn_out"

[[ $OLS_DEBUG ]] && ols_err "$PGMID" 1000 $EX_OK "$(date +"%H:%M:%S") ${FUNCNAME[0]} End bank processing."

} # barclays
