#! /usr/bin/env bash

declare    -r -x BEGIN_TIME=$(date +"%H:%M:%S")  # When did this script start?

#---------------------------------------------------------------------------------------------------
#
# Include Olaus Setup and Functions
#
#---------------------------------------------------------------------------------------------------
source $OLSLIB
source bin/amazon.sh
source bin/bank.sh
source bin/boamc.sh
source bin/barclays.sh
source bin/discover.sh
source bin/input.sh
source bin/mfcu.sh
source bin/output.sh
source bin/pre_process.sh
source bin/process.sh
source bin/std.sh
source bin/usaa.sh
source bin/ver_use_help.sh


declare    -r -x VERSION="0.0.3"
declare    -r -x REL_DATE="9999-99-99"
declare    -r -x BASENAME=$(basename $0)
declare    -r -x PGMID="TXN"                 # Use in error messages.
declare    -r -x script_name=${BASENAME%.*}  # What script are we running?
unset            OLS_DEBUG            # Insure OLS_DEBUG is unset at begining.
unset            OLS_LOG              # Insure OLS_LOG is unset at begining.
declare       -x OLS_LOG_FILE="$script_name.log"      # Default logfile name.

#---------------------------------------------------------------------------------------------------
#
# Create temporary files
#
#---------------------------------------------------------------------------------------------------

declare       -x txn_bank=''

declare    -r    txn_raw="$OLS_TMP_DIR/txn_raw.csv"
declare    -r -x txn_tsv_out="$OLS_TMP_DIR/txn_tsv_out"
declare    -r    txn_std="$OLS_TMP_DIR/txn_std.csv"
declare    -r    txn_pre="$OLS_TMP_DIR/txn_pre.csv"
declare    -r    txn_processed="$OLS_TMP_DIR/txn_pre.csv"


function log() {

    OLS_LOG=$SUCCESS
    OLS_LOG_FILE="$1"

    return

} # log

function verbose() {

    OLS_VERBOSE="$1"

    return

} # verbose


function debug() {

    OLS_DEBUG=$SUCCESS
    log $OLS_LOG_FILE
    return

} # debug


function OLS_EXTRA_OPTIONS () {

    local option="$1"
    OLS_EXTRA_OPT+=("$option")        # Put this input file in the OLS_SYSIN array.

    return $EX_OK

} # OLS_EXTRA_OPTIONS


#---------------------------------------------------------------------------------------------------
#
# Process script_name options and arguments
# Use getopt to process the command, format the argument in a consistant format.
#
#---------------------------------------------------------------------------------------------------

PARSED_ARGUMENTS=$(getopt -a -n txn -o b:i:o:qv --long bank:,input:,output:,debug,quiet,verbose,logfile:,log,version,usage,help -- "$@")
VALID_ARGUMENTS=$?

if [[ $VALID_ARGUMENTS -ne 0 ]]; then
    ols_err "$PGMID" 1004 $EX_USAGE "txn: Unrecoognized options in calling sequence."
    usage
    ols_set_excode $EX_USAGE
    exit
fi



eval set -- "$PARSED_ARGUMENTS"       # Reset the script arguments with the canonical format.

while :; do
    case $1 in #
        -b | --bank    ) bank    "$2";                    shift  2;;
        -i | --input   ) input   "$2";                    shift  2;;
        -o | --output  ) output  "$2";                    shift  2;;
             --debug   ) debug;                           shift   ;;
        -q | --quiet   ) verbose -1;                      shift   ;;
        -v | --verbose ) verbose +1;                      shift   ;;
             --logfile ) log     "$2";                    shift  2;;
             --log     ) log     "$OLS_LOG_FILE";         shift   ;;
             --version ) version; exit;                   shift   ;;
             --usage   ) usage;   exit;                   shift   ;;
             --help    ) help;    exit;                   shift   ;;
             --        ) shift;                           break   ;;
             *         ) usage;  exit $EX_USAGE           shift   ;;
    esac # case
done # while

[[ $OLS_DEBUG ]] && ols_err "$PGMID" 1000 $EX_OK "$BEGIN_TIME Begin $script_name"

# Process remaining input files.

for input_file in "$@"; do

    input_file="$1"
    input "$input_file"
    shift
    
done

[[ $OLS_DEBUG ]] && ols_err "$PGMID" 1000 $EX_OK "$(date +"%H:%M:%S") Check for copying input to output."

for file in "${OLS_SYSIN[@]}"; do
    if [[ "$file" == "$OLS_SYSOUT" ]]; then
        ols_err "$PGMID" 1005 $EX_USAGE "txn: Input and Output files can not be the same, $OLS_SYSOUT."
    fi
done


#---------------------------------------------------------------------------------------------------
#
#   Processing of txn arguments and options complete.
#   Time to get on to business
#
#---------------------------------------------------------------------------------------------------

[[ $OLS_DEBUG ]] && ols_err "$PGMID" 1000 $EX_OK "$(date +"%H:%M:%S") Print options and arguments to logfile."
# Print the status of the

    >"$OLS_LOG_FILE"

    printf "\n%s\n" "----------------------------------------------------------------------------------------------------" >>"$OLS_LOG_FILE"
    printf "%s\n"                                                                                                          >>"$OLS_LOG_FILE"
    printf "%s\n"   "Options and Arguments"                                                                                >>"$OLS_LOG_FILE"
    printf "%s\n"                                                                                                          >>"$OLS_LOG_FILE"
    printf "%s\n\n" "----------------------------------------------------------------------------------------------------" >>"$OLS_LOG_FILE"
    
    printf "%s\n" "Input file bank: $txn_bank"                             >>"$OLS_LOG_FILE"
    if ((${#OLS_SYSIN[@]} == 0)); then
        printf "%s\n" "Input file: STDIN"                                  >>"$OLS_LOG_FILE"
    else
        printf "%s\n" "Input files:"                                       >>"$OLS_LOG_FILE"
        for file in "${OLS_SYSIN[@]}"; do
            printf "\t%s\n" "$file"                                        >>"$OLS_LOG_FILE"
        done
    fi
    if [[ -n "$OLS_SYSOUT" ]]; then
        printf "%s\n" "Output file: $OLS_SYSOUT"                           >>"$OLS_LOG_FILE"
    else
        printf "%s\n" "Output file: STDOUT"                                >>"$OLS_LOG_FILE"
    fi

    printf "%s\n" "Debug Flag: $OLS_DEBUG"                                 >>"$OLS_LOG_FILE"
    printf "%s\n" "Verbose Flag: $OLS_VERBOSE"                             >>"$OLS_LOG_FILE"
    printf "%s\n" "Log Flag: $OLS_LOG"                                     >>"$OLS_LOG_FILE"
    printf "%s\n" "Log File: $OLS_LOG_FILE"                                >>"$OLS_LOG_FILE"


#---------------------------------------------------------------------------------------------------
#
#   Process tranaction csv file.
#   Time to get on to business
#
#---------------------------------------------------------------------------------------------------

txn_working="$OLS_TMP_DIR/working.tsv"  # Because some merchants put commas
                                        # into their transaction fields
                                        # convert transactions to a tab seperated variable
                                        # file.



#[[ $OLS_DEBUG ]] && ols_err "$PGMID" 1000 $EX_OK "$(date +"%H:%M:%S") Process txn_bank transactions."

# Look for Bank header records in OLS_SYSIN
date_rec=$(grep -n "Date," "${OLS_SYSIN[0]}")
date_num=${date_rec%:*}
tail --lines="+$date_num" "${OLS_SYSIN[0]}" >"$txn_raw"

csvclean -d, --length-mismatch "$txn_raw" >/dev/null #2>/dev/null

EX_CODE=$?
if (( EX_CODE != EX_OK )); then
    ols_err "$PGMID" 7008 $EX_DATAERR "File ${OLS_SYSIN[0]} is ill formed."
    exit $EX_DATAERR
fi


pre_process "$txn_raw" "$txn_pre"

[[ $OLS_DEBUG ]] && ols_err "$PGMID" 1000 $EX_OK "$(date +"%H:%M:%S") Pre-Process Complete."

case $txn_bank in

    amazon   ) amazon   "$txn_pre" "$txn_std"                                 ;;
    barclays ) barclays "$txn_pre" "$txn_std"                                 ;;
    boamc    ) boamc    "$txn_pre" "$txn_std"                                 ;;
    discover ) discover "$txn_pre" "$txn_std"                                 ;;
    mfcu     ) mfcu     "$txn_pre" "$txn_std"                                 ;;
    std      ) std      "$txn_pre" "$txn_std"                                 ;;
    usaa     ) usaa     "$txn_pre" "$txn_std"                                 ;;
    *        ) ols_err  "$PGMID" 1006 $EX_USAGE "Bank option is unknown."          ;;

esac # txn_bank

# txn_std is in standard format.

process "$txn_std" "$txn_processed"

mv "$txn_processed" "$OLS_SYSOUT"













cat >/dev/null <</*
=head1 Name

B<txn> E<mdash> Process transaction file into Moneydance standard format

=head1 Synopsis

B<txn>
B<--bank>=bank | B<-b> bank
[B<--input>=F<input_file> | B<-i> F<input_file>]
B<--output>=F<output_file> | B<-o> F<output_file>
[B<--help>]
[B<--log>]
[B<--log=F<log_file>>]
[B<--quiet>]
[B<--usage>]
[B<--debug>]
[B<--version>]
[B<--verbose>]
[B<-->]
[F<input_file> ...]

=head1 Description

B<txn> converts bank and credit card tranaction file in CSV format
into a standard format for inporting into Moneydance.
The output format is a csv with columns:

 | Column | Value       |
 |--------|-------------|
 |   1    | Date        |
 |   2    | Description |
 |   3    | Category    |
 |   4    | Check No.   |
 |   5    | Amount      |
 |   6    | Memo        |

 Also, Description and Category are standardized.

=head1 Options & Arguments

 | Options         |  Option Value    | Description                                  |
 |-----------------|------------------|----------------------------------------------|
 | --bank    | -b  |  bank            | Specify the bank of input file (required)    |
 | --input   | -i  |  input_file      | Specify input source [Default: STDIN]        |
 | --output  | -o  |  output_file     | Specify output destination (required)        |
 | --debug         |                  | Include debugging info on STDOUT             |
 | --quiet   | -q  |                  | Run silent, opposite of --verbose            |
 | --verbose | -v  |                  | Opposite of --quiet                          |
 | --logfile       |  log_file        | Log significant events to log_file           |
 | --log           |                  | Log significant events to script_name.log    |
 | --version       |                  | Print version information                    |
 | --usage         |                  | Print the usage line for this program        |
 | --help          |                  | Print summary for this program               |
 |                 |                  |                                              |
 | Arguments       |                  |                                              |
 | input_file      |                  | Multiple input_files are supported           |

=head2 Options

=over 4

=item B<--bank>=bank | B<-b> bank

B<--bank> is required. It is not optional.
The bank option identifies the bank or credit card companyy
that provided the F<input_file>.
This is necessary because each organization has a different transaction format.
Support options are:

=over 4

=item * I<amazon>

Indicates the F<input_file> came from the Amazon Chase credit card account.

=item * I<discover>

Indicates the F<input_file> came from the Discover credit card account.

=back

=item [B<--input>=F<input_file> | B<-i> F<input_file>]

Input file, default is standard in, F<STDIN>.
Single dash,
C<->,
means read from F<STDIN>.

=item [B<--output>=F<output_file> | B<-o> F<output_file>]

The F<output_file> is required. It is not optional.

B<Note:> Do not use the same file as an input_file and as an output_file.

=item [B<--help>]

Print the help message to standard error, F<STDERR>, and exit.

=item [B<--log>]

Log significant events to B<F<script_name.log>>.

=item [B<--logfile>=F<log_file>]

Log significant events to B<F<script_name.log>>.

=item [B<--quiet>]

Only print fatal error messages to F<STDERR>.

=item [B<--usage>]

Print the usage message to standard error, F<STDERR>, and exit.

=item [B<--debug>]

Turn on the debug switch.

=item [B<--version>]

Print the version, copyright, and license message
to standard error, F<STDERR>, and exit.

=item [B<--verbose>]

Turn on the verbose switch.

=item [B<-->] File list marker

The the double dash, C<-->,
on the command line signals the end options.
The remaining items arguments,
even if some look like options.

=back

=head2 Arguments

Only file names are allowed to be arguments.
For all other items use options.

=over 4

=item [F<input_file>]

Input file, default is standard in, F<STDIN>.
Single dash,
C<->,
also means read from F<STDIN>.

=back

=head1 Security

B<NOTE:> You must be the superuser to run this script.

B<WARNING:> This script contains security info.
Do not set world-readable. Better yet, redesign
so that security information is not saved
in your source code.

This script does not need root/superuser/administrator
permission to function.

This script does not contain any security info.

=head1 Examples

B<txn> will most often be run with a single input file, I<e.g.>,

 txn -b Amazon Amazon-Chase-1009-20240820-act.csv >txn.csv

 

Insert instructive examples here.



=head1 Notes & Caveats


=head2 Warning: Input file and Output File Restriction

Do not use the same file as an input and output in the same command of B<E<lt>script_nameE<gt>>. You will
destroy your data. B<E<lt>script_nameE<gt>> checks for --input and --output being equal; however,
you should not do

E<0x10062> script_name --input=file_one >file_one E<0x10062>

=head2 csvkit

The csvkit commands produce a comma seprated variable file regardless of the input.
If you want to process a tab separated variable file,
you will need to use csvformat to convert it back to a tsv.
For example,

    csvcut --tabs --columns="1,3,4,5,6,7" input.tsv >hold.csv

    csvformat -d, --out-tabs hold.csv >out.tsv

=head1 Diagnostics

A list of every error and warning message that the script can generate
(even the ones that will E<ldquo>never happenE<rdquo>), with a full explanation
of each problem, one or more likely causes, and any suggested remedies.

=head2 TXN1064F

routine: Error message

=head3 Severity

Fatal Error, Exit Code 64

=head3 Explanation

The B<--bank> value is not known.

=head3 System Action

The system issues this error message and exits.

=head3 User Response

Use C<man txn> to determine the valid B<--bank> arguemnts.

=head3 Programmer Response

If the B<--bank> is a new source of transactions, update B<txn> to support it.

=head2 TXN1079F

routine: Error message

=head3 Severity

Fatal Error, Exit Code 79

=head3 Explanation

The B<--input> F<input_file> does not exist.

=head3 System Action

The system issues this error message and exits.

=head3 User Response

Rerun this command with the correct F<input_file>.

=head2 ZZZ9999X

routine: Error message

=head3 Severity

Fatal Error, Exit Code 16

=head3 Explanation

Why was this error message generated.

=head3 System Action

The system action depends upon the error conditions described in the accompanying messages.

=head3 User Response

See the specific error message to determine the user action.

=head3 Programmer Response

See the specific error message to determine the programmer action.

=head3 System Programmer Response

See the specific error message to determine the system programmer action.

=head1 Configuration & Environment

No environmental variables were hurt during the development of this script.

=head1 Dependencies

A list of all of the other scripts that
this script relies upon,
including any restrictions on versions,
part of this script's distribution,
or must be installed separately.

=head1 Incompatabilities

The programmer and user can not use this script with the following commands.
This restriction may be due to name conflicts in the interface, competition
for system or program resources, or internal limitations of BASH (for example,
many modules that use source code filters are mutually incompatible).

=head1 Files

A list of the files that are used by this script.

=head1 Standards

A list of the standards that this script complies with.

=head1 Version

Version 0.0.1

=head1 History

 Version  | Author         | Description     | Date       |
 0.0.1    | Mark J. Jensen | Initial Release | 2025-99-99 |

=head1 Bugs & Limitations

A list of known problems with the module, together with some indication of
whether they are likely to be fixed in an upcoming release.

Also, a list of restrictions on the features the module does provide:
data types that cannot be handled,
performance issues
and the circumstances in which they may arise,
practical limitations on the size of data sets,
special cases that are not (yet) handled, etc.

The initial release usually just has:

There are no known bugs in this script.

Please report problems to Mark Jensen.

Patches are welcome.

=head1 Incompatibilities

A list of any known scripts that this script cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for system
or program resources, or due to internal limitations of BASH.

=head1 Resources

=over 4

=item Barrett I<et al.> 2005

Daniel J. Barrett, Richard E. Silverman, and Robert G. Byrnes.
2005.
I<SSH, the Secure Shell: The Definitive Guide>,
2nd Edition.
(Sebastopol: OE<rsquo>Reilly Media)

=item Robbins and Beebe 2005

Arnold Robbins and Nelson H. F. Beebe.
2005.
I<Classic Shell Scripting>.
(Sebastopol: OE<rsquo>Reilly Media)

=back

=head1 See Also

B<ols_begin>

=head1 Copyright & License

B<txn> is licensed under
L<CC BY 4.0|https://creativecommons.org/licenses/by/4.0/?ref=chooser-v1>
by L<Mark J. Jensen|https://www.linkedin.com/in/jensenmark/>.

=head1 Author

Mark Jensen E<lt>mark@jensen.netE<gt>

=head1 Source

%Note%: Add the link for B<txn> after merging back into the master branch.
B<txn> may be found at [xxx](yyy).

=cut
/*