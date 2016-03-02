package Test::DocClaims;

# Copyright (C) 2009-2016 Scott E. Lee

use 5.008009;
use strict;
use warnings;
use Carp;

use Test::DocClaims::Lines;
our $VERSION = '0.01';

use Test::Builder::Module;
our @ISA    = qw< Test::Builder::Module >;
our @EXPORT = qw<
    doc_claims
>;

sub doc_claims {
    my ( $test_spec, $doc_spec, $name ) = @_;
    $name = "documentations claims are tested" unless defined $name;
    my $test = Test::DocClaims::Lines->new($test_spec);
    my $doc  = Test::DocClaims::Lines->new($doc_spec);
    my @error;
    my ( $test_line, $doc_line );
    my @skipped_code;
    while (1) {
        $test_line = $test->current_line;
        $doc_line  = $doc->current_line;

        # Skip over the line if it is blank or is a non-POD line in a file
        # that supports POD.
        if ( $test_line &&
                ( ( $test_line->has_pod && !$test_line->is_pod ) ||
                $test_line->text =~ /^\s*$/ ) )
        {
            push @skipped_code, $test_line if $test_line->text =~ /\S/;
            $test->advance_line;
            $test_line = $test->current_line;
            redo;
        }
        if ( $doc_line &&
                ( ( $doc_line->has_pod && !$doc_line->is_pod ) ||
                $doc_line->text =~ /^\s*$/ ) )
        {
            $doc->advance_line;
            $doc_line = $doc->current_line;
            redo;
        }

        last if $test->is_eof || $doc->is_eof;
        next if $test_line->text eq $doc_line->text;
        my $tb = Test::DocClaims->builder;
        my $fail = $tb->ok( 0, $name );
        _diff_error( $test_line, $doc_line, $name );
        return $fail;
    } continue {
        $test->advance_line;
        $doc->advance_line;
        @skipped_code = ();
    }
    if ( !$test->is_eof || !$doc->is_eof ) {
        my $tb = Test::DocClaims->builder;
        my $fail = $tb->ok( 0, $name );
        _diff_error( $test->current_line, $doc->current_line, $name );
        return $fail;
    } else {
        my $tb = Test::DocClaims->builder;
        return $tb->ok( 1, $name );
    }
}

sub _diff_error {
    my ( $test_line, $doc_line, $name ) = @_;
    my @error;
    my $prefix = "     got";
    foreach my $line ( $test_line, $doc_line ) {
        if ( ref $line ) {
            my $text = $line->text;
            push @error, "$prefix: '$text'";
            push @error, "at " . $line->path . " line " . $line->lnum;
            ( $error[-1], $error[-2] ) = ( $error[-2], $error[-1] )
                if $prefix =~ /got/;
        } else {
            push @error, "missing";
        }
        $prefix = "expected";
    }
    my $tb = Test::DocClaims->builder;
    $tb->diag( map { "    $_\n" } @error );
}

1;

__END__

=head1 NAME

Test::DocClaims - Help assure that documentation claims are tested

=head1 SYNOPSIS

  use Test::More;
  eval "use Test::DocClaims";
  plan skip_all => "Test::DocClaims required for testing documentation claims"
    if $@;
  plan tests => 1;
  doc_claims( "t/MyModule.t", "lib/MyModule.pm", "doc claims" );

=head1 DESCRIPTION

A module should have documentation that defines its interface. All claims in
that documentation should have corresponding tests to verify that they are
true. Test::DocClaims is designed to help assure that those tests are written
and maintained.

It would be great if software could read the documentation, enumerate all
of the claims made and then read (or even write) the test suite to assure
that those claims are properly tested.
However, that level of Artificial Intelegence does not yet exist.
So, humans must be trusted to enumerate the claims and write the tests.

How can Test::DocClaims help?
As the code and its documentation evolve, the test suite can fall out of
sync, no longer testing the new or modified claims.
This is where Test::DocClaims can assist.
This is done by copying the documentation into the test suite (as POD or
comments) and below each claim write a test for that claim.
Test::DocClaims compairs the documentation in the code with the documentation
in the test suite and reports discrepencies.
This will act as a trigger to remind the human to update the test suite.
It is up to the human to actually edit the tests, not just the sync up the
documentation.

=head2 Functions

=over 4

=item doc_claims I<TEST_SPEC> I<MODULE_SPEC> [ I<TEST_NAME>  ]

Verify that the lines of documentation in TEST_SPEC match the ones in
MODULE_SPEC.
The TEST_SPEC and MODULE_SPEC arguments specify a list of one or more files.
Each can be:

  - a string which is the path to a file relative to the test program
  - a ref to a hash with these keys:
    - path:    path to a file relative to the test program (required)
    - type:    file type ("perl", "pod", "t" or "md") (optional)
    - has_pod: true if the file can have POD (optional)
    - test:    true if it is a test suite file (optional)
    - blank:   true to preserve blank lines (optional)
    - white:   true to preserve amount of white space at beginning of
               lines (optional)
  - a ref to an array, each element is a path or hash as above

If a list of files is given, those files are precessen in order and the
documentation in each is concatinated.
This is useful when a module requires many tests that are best split into
multiple files in the test suite.
Note that the path mentioned above can also be a wildcard, which is expanded by the glob built-in function.
For example:

  doc_claims("../lib/Foo.pm", "Foo-*.t");

If a wildcard is used, be sure that the generated list of files is in the
correct order. It may be useful to number them (such as Foo-01-SYNOPSIS.t,
Foo-02-DESCRIPTION.t, etc).

=back

=head1 SEE ALSO

Test::Pod
Test::Pod::Coverage
Devel::Coverage

=head1 AUTHOR

Scott E. Lee, E<lt>ScottLee@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2016 by Scott E. Lee

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
