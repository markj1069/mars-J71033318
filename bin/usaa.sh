#--------------------------------------------------------------------------------------------------
#
# Process the unique features of the Bank of America transactions
#
#--------------------------------------------------------------------------------------------------

function usaa() {

[[ $OLS_DEBUG ]] && ols_err "$PGMID" 1000 $EX_OK "$(date +"%H:%M:%S") ${FUNCNAME[0]} Begin bank processing."

# Save the arguments to USAA.
txn_in="$1"
txn_out="$2"

# Get the six columns from the transaction file we need.

txn_tabs="$OLS_TMP_DIR/txn_tabs.tsv"
txn_date_desc="$OLS_TMP_DIR/txn_date_desc.csv"
txn_cat="$OLS_TMP_DIR/txn_cat.csv"
txn_amt="$OLS_TMP_DIR/txn_amt.csv"
txn_checkno="$OLS_TMP_DIR/txn_checkno.csv"

[[ $OLS_DEBUG ]] && ols_err "$PGMID" 1000 $EX_OK "$(date +"%H:%M:%S") ${FUNCNAME[0]} Begin csvcut processing."

csvcut --columns="1,2" "$txn_in" >"$txn_date_desc"      2>/dev/null  # Get Date and Description
csvcut --columns="4"   "$txn_in" >"$txn_cat"            2>/dev/null  # Get catagory column
csvcut --columns="5"   "$txn_in" >"$txn_amt"            2>/dev/null  # Get amount column 

# Create an empty catagory column to add to the transaction file.
cnt=$(cat "$txn_in" | wc --lines)        # How big is this csv?

printf "%s\n" "Check No." >"$txn_checkno"                         # Empty the check number column
for (( i=2; i<=cnt; i++ )) do           # Build empty check number and catagory columns
    printf "%s\n" "-" >>"$txn_checkno"  # consisting of cnt rows of a dash
done # for (( i=2;

# Join the pieces of the transaction into standard form. There is no memo from USAA.
csvjoin -d, --snifflimit=0 "$txn_date_desc" "$txn_cat" "$txn_checkno" "$txn_amt" >"$txn_out"

[[ $OLS_DEBUG ]] && ols_err "$PGMID" 1000 $EX_OK "$(date +"%H:%M:%S") ${FUNCNAME[0]} End bank processing."

}  # usaa
