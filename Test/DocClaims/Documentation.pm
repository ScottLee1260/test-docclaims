package Test::DocClaims::Documentation;

# Copyright (c) 2009-2016 Scott E. Lee. All rights reserved.
# This program my be used under the Perl License OR the MIT License.
# This program is free software. You may copy or redistribute it under the
# same terms as Perl itself.

use 5.008;
use strict;
use warnings;

use Test::DocClaims::Lines;

our @ISA = qw< Test::DocClaims::Lines >;

# Keys in the blessed hash
#   {lines}     array of Test::DocClaims::Line objects
#   {current}   the current index into {lines}
#   {this_line}  a hash of info about the line about to be added:
#     {path}       path of the file
#     {lnum}       lnum of the file
#     {type}       type of the file
#     {linetype}   type of the line, overrides type if it is defined
#                    eg: "=pod" sets to "pod"; "=cut" sets to undef
#   {parse_pod} true if this file can have POD
#   {in_pod}    true if current line is POD

1;

__END__

=head1 NAME

Test::DocClaims::Documentation - An example Perl module.

=head1 SYNOPSIS

  use Test::DocClaims::Documentation;
  $foo = Test::DocClaims::Documentation->new();
  $foo->foo();

=head1 DESCRIPTION

=head2 States of the class

=head2 States of the Object

=head2 Methods, Functions and Operators

=over 4

=item new [ I<STRING> ]

This method creates a new object.

=item tostring

This method returns a string representation of the object.

=item cmp I<PATH>

Like the cmp Perl built in, it returns -1, 0 or 1.

=back

=head1 BUGS

=head1 SEE ALSO

=head1 COPYRIGHT

Copyright (c) Scott E. Lee

