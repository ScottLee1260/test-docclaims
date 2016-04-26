#!perl

use strict;
use warnings;
use Test::More tests => 1;

BEGIN { use_ok('Test::DocClaims::Line'); }

=head1 NAME

Test::DocClaims::Line - An example Perl module.

=for DC_TODO

=head1 SYNOPSIS

  use Test::DocClaims::Line;
  $foo = Test::DocClaims::Line->new();
  $foo->foo();

=for DC_TODO

=head1 DESCRIPTION

=head2 States of the class

=head2 States of the Object

=head2 Methods, Functions and Operators

=over 4

=item new [ I<STRING> ]

This method creates a new object.

=for DC_TODO

=item tostring

This method returns a string representation of the object.

=for DC_TODO

=item cmp I<PATH>

Like the cmp Perl built in, it returns -1, 0 or 1.

=for DC_TODO

=back

=head1 BUGS

=head1 SEE ALSO

=head1 COPYRIGHT

Copyright (c) Scott E. Lee
