#--------------------------------------------------------------------------------------------------
#
# Process the standard format for the transaction file.
#
#--------------------------------------------------------------------------------------------------

function std() {

[[ $OLS_DEBUG ]] && ols_err $PGMID 1000 $EX_OK "Begin Process Standard transactions."


# Save the arguments to std.
txn_in="$1"
txn_out="$2"

cp "$txn_in" "$txn_out"              # No special processing required

[[ $OLS_DEBUG ]] && ols_err $PGMID 1000 $EX_OK "End Process Standard transactions."

}  # std
