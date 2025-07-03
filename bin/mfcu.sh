#--------------------------------------------------------------------------------------------------
#
# Process the unique features of the MFCU transactions
#
#--------------------------------------------------------------------------------------------------

function mfcu() {

[[ $OLS_DEBUG ]] && ols_err $PGMID 1000 $EX_OK "$(date +"%H:%M:%S") ${FUNCNAME[0]} Begin bank processing."


# Save the arguments to mfcu.
declare    -r    txn_in="$1"          # Save input transaction file.
declare    -r    txn_out="$2"         # Save output transaction file.
declare    -r    txn_use="$OLS_TMP_DIR/txn_use.csv"
declare    -r    txm_amt_awk="$OLS_TMP_DIR/txn_amt.awk"
declare    -r    txn_amt_fix="$OLS_TMP_DIR/txn_amt_fix.csv"

# Insure all amounts are in column 5.
cat >"$txm_amt_awk" <<'/*'
# Setup for a CSV.
BEGIN {

    FS=","
   OFS=","

}  # BEGIN

$6 > 0 { $5 = $6 }  # Move deposits values into amount column

{ print $0 }

/*
awk --file="$txm_amt_awk" "$txn_in" >"$txn_amt_fix"


# Get the six columns from the transaction file we need.

txn_memo="$OLS_TMP_DIR/txn_memo.csv"
txn_date_desc="$OLS_TMP_DIR/txn_date_desc.csv"
txn_checkno="$OLS_TMP_DIR/txn_checkno.csv"
txn_cat="$OLS_TMP_DIR/txn_cat.csv"
txn_amt="$OLS_TMP_DIR/txn_amt.csv"


[[ $OLS_DEBUG ]] && ols_err $PGMID 1000 $EX_OK "$(date +"%H:%M:%S")" "Begin csvcut operations."

csvcut --columns="2,3"   "$txn_amt_fix" >"$txn_date_desc"     2>/dev/null  # Get Date and Description
csvcut --columns="4"     "$txn_amt_fix" >"$txn_memo"          2>/dev/null  # Get memmo column
csvcut --columns="5"     "$txn_amt_fix" >"$txn_amt"           2>/dev/null  # Get amount
csvcut --columns="8"     "$txn_amt_fix" >"$txn_checkno"       2>/dev/null  # Get Check No.


#[[ $OLS_DEBUG ]] && ols_err $PGMID 1000 $EX_OK "$(date +"%H:%M:%S")" "Create pseudo catagory column."
# Create an empty catagory column to add to the transaction file.
cnt=$(cat "$txn_in" | wc --lines)        # How big is this csv?

printf "%s\n" "Catagory" >"$txn_cat"  # Header record
for (( i=2; i<=cnt; i++ )) do         # Build empty check number and catagory columns
     printf "%s\n" "-" >>"$txn_cat"   # consisting of cnt rows of a dash
done # for (( i=1;

[[ $OLS_DEBUG ]] && ols_err $PGMID 1000 $EX_OK "$(date +"%H:%M:%S")" "Begin cvsjoin operation"

# Join the pieces of the transaction into standard form. There is no memo from MFCU.
csvjoin --snifflimit=0 "$txn_date_desc" "$txn_cat" "$txn_checkno" "$txn_amt" "$txn_memo" >"$txn_out"

[[ $OLS_DEBUG ]] && ols_err $PGMID 1000 $EX_OK "$(date +"%H:%M:%S") ${FUNCNAME[0]} End bank processing."

}  # mfcu
