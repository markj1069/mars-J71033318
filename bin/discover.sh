#--------------------------------------------------------------------------------------------------
#
# Process the unique features of the Discover transactions
#
#--------------------------------------------------------------------------------------------------

function discover() {

[[ $OLS_DEBUG ]] && ols_err $PGMID 1000 $EX_OK "$(date +"%H:%M:%S") ${FUNCNAME[0]} Begin bank processing."
# Save the arguments to discover.
txn_in="$1"
txn_out="$2"


#---------------------------------------------------------------------------------------------------
#
# Create temporary files
#
#---------------------------------------------------------------------------------------------------

txn_date_desc="$OLS_TMP_DIR/txn_date_desc.tsv"
txn_amt="$OLS_TMP_DIR/txn_amt.tsv"
txn_cat="$OLS_TMP_DIR/txn_cat.tsv"
txn_checkno="$OLS_TMP_DIR/txn_checkno.tsv"
txn_negate="$OLS_TMP_DIR/txn_negatge.tsv"

# Get the six columns from the transaction file we need.

csvcut --columns="1,3" "$txn_in" >"$txn_date_desc" 2>/dev/null  # Get Data & Descripton
csvcut --columns="4"   "$txn_in" >"$txn_amt"       2>/dev/null  # Get Amount column
csvcut --columns="5"   "$txn_in" >"$txn_cat"       2>/dev/null  # Get Catagory column

# Create an empty catagory column to add to the transaction file.
cnt=$(cat "$txn_in" | wc --lines)        # How big is this csv?
printf "%s\n" "Check No." >"$txn_checkno"                       # Empty the check number column
for (( i=2; i<=cnt; i++ )) do         # Build an empty check number column
    printf "%s\n" "-" >>"$txn_checkno"         # consisting of cnt rows of a dash
done # for (( i=2;

# Join the pieces of the transaction into standard form.
csvjoin --snifflimit=0 "$txn_date_desc" "$txn_cat" "$txn_checkno" "$txn_amt" >"$txn_negate"

txn_awk_negate="$OLS_TMP_DIR/txn_negatge.awk"
cat >"$txn_awk_negate" <<'/*'
BEGIN {

# Setup for a CSV.
    FS=","
   OFS=","

} # BEGIN

{ $5 = -$5 }  # Negate the amount in column 5.

{ print $0 }
/*

awk --file="$txn_awk_negate" "$txn_negate" >"$txn_out"  # Reverse the amount values.

[[ $OLS_DEBUG ]] && ols_err "$PGMID" 1000 $EX_OK "$(date +"%H:%M:%S") ${FUNCNAME[0]} End bank processing."

}  # discover
