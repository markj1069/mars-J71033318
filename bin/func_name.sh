#! /usr/bin/env bash

function func_name() {

printf "%s" "func_name"

# Set Olaus exit code for the calling script exit code
# and the return if the calling script tests the exit code.
ols_set_excode $EX_USERABORT
return $EX_USERABORT

} # func_name

cat <<=cut >/dev/null
=head1 Name

<func_name> - <One-line description of function's purpose>

=head1 Synopsis

E<lt>B<func_name>E<gt> [I<arg1>] ...

=head1 Description

A full description of the function and its features.

May include numerous subsections
(I<i.e.>, =head2, =head3, I<etc.>).

=head1 Arguments

=over 4

=item I<arg1>

(required|optional) Argument 1 description.

.
.
.

=back

=head1 Security

B<NOTE:> You must be the superuser to run this function.

B<WARNING:> This fuction contains security info.
Do not set world-readable. Better yet, redesign
so that security information is not saved
in your source code.

This function contains no security information.

=head1 Examples

Insert instructive examples here.

=head1 Notes & Caveats

What additional information would be useful to a programmer.

=head1 Diagnostics

A list of every error and warning message that the module can generate
(even the ones that will "never happen"), with a full explanation
of each problem, one or more likely causes, and any suggested remedies.

=head2 Exit Status

What is the list of possible exit statuses.

=head1 Configuration & Environment

=over 4

=item EX_CODE

Current exit code.

=back

=head1 Dependencies

A list of all of the other scripts that this script relies upon, including any
restrictions on versions, part of this script's distribution,
or must be installed separately.

=head1 Incompatabilities

A list of any functions that this function cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for system
or program resources, or due to internal limitations of BASH (for example,
many modules that use source code filters are mutually incompatible).

=head1 Files

A list of the files that are used by this function.

=head1 Standards

A list of the standards that his function complies with.

=head1 Version

Version 0.1.0

=head1 History

 Version  | Author         | Description     | Date       |
 0.1.0    | Mark J. Jensen | Initial Release | 2025-99-99 |

=head1 Bugs & Limitations

A list of known problems with the module, together with some indication of
whether they are likely to be fixed in an upcoming release.

Also, a list of restrictions on the features the module does provide: data types
that cannot be handled, performance issues and the circumstances in which they
may arise, practical limitations on the size of data sets, special cases that
are not (yet) handled, etc.

The initial template usually just has:

There are no known bugs in this module.

Please report problems to <Maintainer name(s)> (<contact address>)

Patches are welcome.

=head1 Resources

=over 4

=item Conway, Damian 2005

Damian Conway.
2005.
I<Ten Essential Development Practices>,
Retrieved March 15, 2007,
from L<http://www.perl.com/pub/a/2005/07/14/bestpractices.html>.

=item Barrett, I<et al.> 2005

Daniel J. Barrett, Richard E. Silverman, and Robert G. Byrnes.
2005.
I<SSH, the Secure Shell: The Definitive Guide>,
2nd Edition.
(Sebastopol: O'Reilly Media)

=item Robbins and Beebe 2005

Arnold Robbins and Nelson H. F. Beebe.
2005.
I<Classic Shell Scripting>.
(Sebastopol: O'Reilly Media)

=back

=head1 See Also

B<ols_begin>

=head1 Author

Mark J Jensen E<lt>mark@jensen.netE<gt>

=head1 Copyright & License

B<function> is licensed under
L<CC BY 4.0|https://creativecommons.org/licenses/by/4.0/?ref=chooser-v1>
by L<Mark J. Jensen|https://www.linkedin.com/in/jensenmark/>.

=head1 Source

B<func_name> may be found at [xxx](yyy).

=cut

