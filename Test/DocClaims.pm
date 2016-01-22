package Test::DocClaims;

# Copyright (c) 2009-2016 Scott E. Lee. All rights reserved.
# This program my be used under the Perl License OR the MIT License.
# This program is free software. You may copy or redistribute it under the
# same terms as Perl itself.

use 5.008;
use strict;
use warnings;
use Carp;

use Test::DocClaims::Documentation;
use Test::DocClaims::Tests;

our $VERSION = 0.001;

use Test::Builder::Module;
our @ISA    = qw< Test::Builder::Module >;
our @EXPORT = qw<
    doc_claims
>;

sub doc_claims {
    my ( $doc_arg, $test_arg, $name ) = @_;
    $name = "documentations claims are tested" unless defined $name;
    my $tb = Test::DocClaims->builder;
    my ( $doc, $test );
    my @error;

    # Get the Test::DocClaims::Documentation object.
    eval {
        my $isa = eval { $doc_arg->ISA("Test::DocClaims::Documentation") };
        if ( !$@ && $isa ) {
            $doc = $doc_arg;
        } else {
            $doc = Test::DocClaims::Documentation->new($doc_arg);
        }
    };
    if ($@) {
        my $fail = $tb->ok( 0, $name );
        $tb->diag( map { "    invalid doc file parameter\n" } @error );
        return $fail;
    }

    # Get the Test::DocClaims::Tests object.
    eval {
        my $isa = eval { $test_arg->ISA("Test::DocClaims::Tests") };
        if ( !$@ && $isa ) {
            $test = $test_arg;
        } else {
            $test = Test::DocClaims::Tests->new($test_arg);
        }
    };
    if ($@) {
        my $fail = $tb->ok( 0, $name );
        $tb->diag( map { "    invalid test file parameter\n" } @error );
        return $fail;
    }

    while (1) {
        if ( my @error = $test->match($doc) ) {
            my $fail = $tb->ok( 0, $name );
            $tb->diag( map { "    $_\n" } @error );
            return $fail;
        }
        last unless $doc->advance_line;
        $test->advance_line;
    }
    return $tb->ok( 1, $name );
}

1;

__END__

=head1 NAME

Test::DocClaims - Help assure that documentation claims are tested

=head1 SYNOPSIS

  use Test::DocClaims;
  $foo = Test::DocClaims->new();
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
