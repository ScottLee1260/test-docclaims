#!perl

use strict;
use warnings;
use lib "lib";
use Test::More tests => 2;
use lib "t/lib";
use TestTester;

BEGIN { use_ok("Test::DocClaims"); }

=head1 NAME

Test::DocClaims::Lines - An example Perl module.

=head1 SYNOPSIS

 use Test::DocClaims::Lines;
 $foo = Test::DocClaims::Lines->new();
 $foo->foo();

=cut

 use Test::DocClaims::Lines;
 my $foo = Test::DocClaims::Lines->new("lib/Test/DocClaims.pm");
 isa_ok( $foo, "Test::DocClaims::Lines" );

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

