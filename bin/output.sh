#-h- output Version: VERSION  Release Date: RELEASE_DATE

function output() {

    if [[ -z "$OLS_SYSOUT" ]]; then
        output_file="$1"
        full_file="$(readlink -f $output_file)"
        OLS_SYSOUT="$full_file"       # Save the output file in OLS_SYSOUT.
    else
        ols_err "$PGMID" 1003 EX_USAGE "run-txn: output: Only one --output option allowed."
    fi

    return $EX_OK


} # output