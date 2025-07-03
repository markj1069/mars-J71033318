# Remove extra commas from the transaction file.

function pre_process() {

    [[ $OLS_DEBUG ]] && ols_err "$PGMID" 1000 $EX_OK "$(date +"%H:%M:%S") ${FUNCNAME[0]} Begin"

    local txn_in="$1"                    # Save input file.
    local txn_out="$2"                    # Put the pre-processed file in txn_out.

    local txn_no_head="$OLS_TMP_DIR/txn_no_head.csv"
    local txn_tsv="$OLS_TMP_DIR/txn_tsv.tsv"
    local txn_no_comma="$OLS_TMP_DIR/txn_no_comma.tsv"


# Convert the csv to a tsv for sed processing. 
    csvformat --delimiter "," --out-tabs --quotechar '"' "$txn_in" >"$txn_tsv"

# Replace extra commas with an underscore.
    sed -e 's/,/_/g' "$txn_tsv" >"$txn_no_comma"

# Convert the tsv back into a csv for follow-on processing
    sed -e 's/\t/,/g' "$txn_no_comma" >"$txn_out"

    [[ $OLS_DEBUG ]] && ols_err "$PGMID" 1000 $EX_OK "$(date +"%H:%M:%S") ${FUNCNAME[0]} End"

}  # pre_process
