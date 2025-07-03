#--------------------------------------------------------------------------------------------------
#
# Process the unique features of the Bank of America transactions
#
#--------------------------------------------------------------------------------------------------

function boamc() {

# Save the arguments to boa.
txn="$1"
txn_out="$2"

# Get the six columns from the transaction file we need.

#---------------------------------------------------------------------------------------------------
#
# Create temporary files
#
#---------------------------------------------------------------------------------------------------

txn_tsv="$OLS_TMP_DIR/txn_tsv"
txn_date="$OLS_TMP_DIR/txn_date.csv"
txn_desc="$OLS_TMP_DIR/txn_desc.csv"
txn_amt="$OLS_TMP_DIR/txn_amt.csv"
txn_cat="$OLS_TMP_DIR/txn_cat.csv"
txn_checkno="$OLS_TMP_DIR/txn_checkno.csv"


csvformat --delimiter="," --out-tabs "$txn" >"$txn_tsv"
csvcut --tabs --columns="1" "$txn_tsv" >"$txn_date"      2>/dev/null  # Get Data
csvcut --tabs --columns="3" "$txn_tsv" >"$txn_desc"      2>/dev/null  # Get Description
csvcut --tabs --columns="5" "$txn_tsv" >"$txn_amt"       2>/dev/null  # Get Amount column

# Create an empty catagory column to add to the transaction file.
cnt=$(cat "$txn" | wc --lines)        # How big is this csv?

>"$txn_checkno"                       # Empty the check number column
for (( i=1; i<=cnt; i++ )) do         # Build empty check number and catagory columns
    printf "%s\n" "-" >>"$txn_checkno"  # consisting of cnt rows of a dash
    printf "%s\n" "-" >>"$txn_cat"      # consisting of cnt rows of a dash
done # for (( i=1;

# Join the pieces of the transaction into standard form.
csvjoin --tabs --snifflimit=0 "$txn_date" "$txn_desc" "$txn_cat" "$txn_checkno" "$txn_amt" >"$txn_out"

} # boa
