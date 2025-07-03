#-h- input Version VERSION, date RELEASE_DATE

function input() {

    input_file="$1"

    if [[ -z "$input_file" ]]; then
        ols_err "$PGMID" 1001 "$EX_USAGE" "run-txn: input: Argument #1 missing, input_file."
        ols_set_excode $EX_USAGE
        ols_end
    fi

    full_file="$(readlink -f $input_file)"

    if [[ ! -f "$full_file" ]]; then
        ols_err "$PGMID" 1002 $EX_MISSINGFILE "run-txn: input: input_file $full_file does not exist or is not a normal file."
    fi

    OLS_SYSIN+=("$full_file")        # Put this input file in the OLS_SYSIN array.

    return $EX_OK

} # input