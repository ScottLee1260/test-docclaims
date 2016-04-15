package Test::DocClaims;

# Copyright (C) Scott E. Lee

use 5.008009;
use strict;
use warnings;
use Carp;
use File::Find;

use Test::DocClaims::Lines;
our $VERSION = '0.01';

use Test::Builder::Module;
our @ISA    = qw< Test::Builder::Module >;
our @EXPORT = qw<
    doc_claims
    all_doc_claims
>;

our $doc_file_re = qr/\.(pl|pm|pod|md)$/i;
our @doc_ignore_list;

=head1 NAME

Test::DocClaims - Help assure documentation claims are tested

=head1 SYNOPSIS

To automatically scan for source files containing POD, find the
corresponding tests and verify that those tests match the POD, create the
file t/doc_claims.t with the following lines:

  use Test::More;
  eval "use Test::DocClaims";
  plan skip_all => "Test::DocClaims not found" if $@;
  all_doc_claims();

Or, for more control over the POD files and which tests correspond to them:

  use Test::More;
  eval "use Test::DocClaims";
  plan skip_all => "Test::DocClaims not found" if $@;
  plan tests => 2;
  doc_claims( "lib/Foo/Bar.pm", "t/doc-Foo-Bar.t",
    "doc claims in Foo/Bar.pm" );
  doc_claims( "lib/Foo/Bar/Baz.pm", "t/doc-Foo-Bar-Baz.t",
    "doc claims in Foo/Bar/Baz.pm" );

If a source file (lib/Foo/Bar.pm) contains:

  =head2 add I<arg1> I<arg2>

  This adds two numbers.

  =cut

  sub add {
      return $_[0] + $_[1];
  }

then the corresponding test (t/doc-Foo-Bar.t) might have:

  =head2 add I<arg1> I<arg2>

  This adds two numbers.

  =cut

  is( add(1,2), 3, "can add one and two" );
  is( add(2,3), 3, "can two one and three" );

=head1 DESCRIPTION

A module should have documentation that defines its interface. All claims in
that documentation should have corresponding tests to verify that they are
true. Test::DocClaims is designed to help assure that those tests are written
and maintained.

It would be great if software could read the documentation, enumerate all
of the claims made and then read (or even write) the test suite to assure
that those claims are properly tested.
However, that level of artificial intelligence does not yet exist.
So, humans must be trusted to enumerate the claims and write the tests.

How can Test::DocClaims help?
As the code and its documentation evolve, the test suite can fall out of
sync, no longer testing the new or modified claims.
This is where Test::DocClaims can assist.
This is done by copying the documentation into the test suite (as POD or
comments) and below each claim write a test for that claim.
Test::DocClaims compares the documentation in the code with the documentation
in the test suite and reports discrepancies.
This will act as a trigger to remind the human to update the test suite.
It is up to the human to actually edit the tests, not just the sync up the
documentation.

=head1 FUNCTIONS

=head2 doc_claims I<MODULE_SPEC> I<TEST_SPEC> [ I<TEST_NAME>  ]

Verify that the lines of documentation in TEST_SPEC match the ones in
MODULE_SPEC.
The TEST_SPEC and MODULE_SPEC arguments specify a list of one or more files.
Each of the arguments can be one of:

  - a string which is the path to a file or a wildcard which is
    expanded by the glob built-in function.
  - a ref to a hash with these keys:
    - path:    path or wildcard (required)
    - type:    file type ("perl", "pod", "t" or "md") (optional)
    - has_pod: true if the file can have POD (optional)
    - test:    true if it is a test suite file (optional)
    - blank:   true to preserve blank lines (optional)
    - white:   true to preserve amount of white space at beginning of
               lines (optional)
  - a ref to an array, where each element is a path, wildcard or hash
    as above

If a list of files is given, those files are read in order and the
documentation in each is concatenated.
This is useful when a module requires many tests that are best split into
multiple files in the test suite.
For example:

  doc_claims( "lib/Foo/Bar.pm", "t/Bar-*.t", "doc claims" );

If a wildcard is used, be sure that the generated list of files is in the
correct order. It may be useful to number them (such as Foo-01-SYNOPSIS.t,
Foo-02-DESCRIPTION.t, etc).

(TODO explain type, has_pod, test, etc.)

=cut

sub doc_claims {
    my ( $doc_spec, $test_spec, $name ) = @_;
    $name = "documentations claims are tested" unless defined $name;
    my $doc  = Test::DocClaims::Lines->new($doc_spec);
    my $test = Test::DocClaims::Lines->new($test_spec);
    my @error;
    my ( $test_line, $doc_line );
    my @skipped_code;
    while ( !$doc->is_eof && !$test->is_eof ) {
        $doc_line  = $doc->current_line;
        $test_line = $test->current_line;

        # Skip over the line if it is blank or is a non-POD line in a file
        # that supports POD.
        my $last = 0;
        while ( ( $doc_line->has_pod && !$doc_line->is_pod )
            || $doc_line->text =~ /^\s*$/ )
        {
            if ( $doc->advance_line ) {
                $doc_line = $doc->current_line;
            } else {
                $last = 1;
                last;
            }
        }
        while ( ( $test_line->has_pod && !$test_line->is_pod )
            || $test_line->text =~ /^\s*$/ )
        {
            push @skipped_code, $test_line if $test_line->text =~ /\S/;
            if ( $test->advance_line ) {
                $test_line = $test->current_line;
            } else {
                $last = 1;
                last;
            }
        }
        last if $last;

        if ( $test_line->text eq $doc_line->text ) {
            $test->advance_line;
            $doc->advance_line;
            @skipped_code = ();
        } else {
            my $tb = Test::DocClaims->builder;
            my $fail = $tb->ok( 0, $name );
            _diff_error( $test_line, $doc_line, $name );
            return $fail;
        }
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
            push @error, "$prefix: eof";
        }
        $prefix = "expected";
    }
    my $tb = Test::DocClaims->builder;
    $tb->diag( map { "    $_\n" } @error );
}

sub all_doc_claims {
    my $doc_arg  = shift;
    my $test_arg = shift;
    my @docs     = _find_docs($doc_arg);
    my $tb       = Test::DocClaims->builder;
    $tb->plan( tests => scalar @docs );
    foreach my $doc_file (@docs) {
        my $test_file = _find_tests( $doc_file, $test_arg );
        if ( length $test_file ) {
            doc_claims( $doc_file, $test_file, "doc claims in $doc_file" );
        } else {
            $tb->ok( 0, "doc claims in $doc_file" );
            $tb->diag("    no tests file(s) found");
        }
    }
}

sub _find_docs {
    my $dirs = shift;
    $dirs = [qw< lib bin scripts >] unless defined $dirs;
    $dirs = [$dirs] unless ref $dirs;
    my @files;
    find(
        {
            wanted => sub {
                return if -l $_ || !-f $_;
                my $path = $_;
                if ( $path =~ m/$doc_file_re/ ) {
                    push @files, $path
                        unless grep { $path =~ /$_/ } @doc_ignore_list;
                }
            },
            no_chdir => 1
        },
        grep {
            -e $_
        } @$dirs
    );
    return sort @files;
}

sub _find_tests {
    my $path = shift;
    my $dirs = shift;
    $dirs = [qw< t >] unless defined $dirs;
    $dirs = [$dirs]   unless ref $dirs;

    # Construct a list of file names to look for. If the input path is
    # "lib/Foo/Bar" then @names becomes "lib-Foo-Bar", "Foo-Bar", "Bar".
    # One could argue that "lib-Foo-Bar" shouldn't be in the list, but it
    # shouldn't cause problems and dealing with the general case would
    # require a complex algorithm.
    $path =~ s/\.\w+$//;
    my @names;
    while (1) {
        push @names, map { my $p = $_; $p =~ s{/}{-}g; $p } $path;
        $path =~ s{^[^/]*/}{} or last;
    }

    # Note that the pattern is returned with single quotes ('). This helps
    # with the case where there is a space in the path. Unfortunately, glob
    # interprets a space to mean separation of multiple patterns unless the
    # pattern is quoted.
    foreach my $dir (@$dirs) {
        foreach my $pat (qw< doc-N-[0-9]*.t doc-N.t N.t >) {
            foreach my $name (@names) {
                ( my $pattern = $pat ) =~ s/N/$name/;
                $pattern = "$dir/$pattern";
                if ( $pat =~ /[*]/ ) {
                    my @list = glob "'$pattern'";
                    return "'$pattern'" if @list;
                } elsif ( -f $pattern ) {
                    return "'$pattern'";
                }
            }
        }
    }
    return "";
}

=head1 SEE ALSO

L<Test::Pod>,
L<Test::Pod::Coverage>,
L<Devel::Coverage>,
L<Test::Pod::Snippets>,
L<POD::Tested>,
L<Test::Synopsis>,
L<Test::Synopsis::Expectation>,
L<Test::Inline>.

=head1 AUTHOR

Scott E. Lee, E<lt>ScottLee@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2016 by Scott E. Lee

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;

