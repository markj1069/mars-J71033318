function version() {

# Print the release date and version number and exit with usage exit code.
    
    printf "\n%s\n\n" "$SCRIPT_NAME $REL_DATE Version: $VERSION"

    ols_set_excode $EX_OK

} # version


function usage() {

# Print the txn Synopsis and exit with a usage exit code.

    printf "%s\n\t%s\n\t%s\n\t%s\n" \
                  "$SCRIPT_NAME --bank=bank | -b bank [--input=input_file | -i input_file]" \
                  "--output=output_file | -o output_file [--help]" \
                  "[--log] [--log=log_file] [--quiet | -q] [--usage] [--debug]" \
                  "[--version] [--verbose] [--] [input_file ...]"

    ols_set_excode $EX_OK

} # usage

function help() {

# Print the txn help and exit with a usage exit code.

    version

    usage

cat <<'/*'

Options & Arguments

| Options         |  Option Value   | Description                                  |
|-----------------|-----------------|----------------------------------------------|
| --bank    | -b  |  bank           | Specify the bank of input file (required)    |
| --input   | -i  |  input_file     | Specify input source [Default: STDIN]        |
| --output  | -o  |  output_file    | Specify output destination (required)        |
| --debug         |                 | Include debugging info on STDOUT             |
| --quiet   | -q  |                 | Run silent, opposite of --verbose            |
| --verbose | -v  |                 | Opposite of --quiet                          |
| --logfile       |  log_file       | Log significant events to log_file           |
| --log           |                 | Log significant events to script_name.log    |
| --version       |                 | Print version information                    |
| --usage         |                 | Print the usage line for this program        |
| --help          |                 | Print summary for this program               |
|                 |                 |                                              |
| Arguments       |                 |                                              |
| input_file      |                 | Multiple input_files are supported           |

/*

    ols_set_excode $EX_OK


} # help
