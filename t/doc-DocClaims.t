#!perl

use strict;
use warnings;
use lib "lib";
use Test::More tests => 2;
use lib "t/lib";
use TestTester;

BEGIN { use_ok("Test::DocClaims"); }
ok 1;

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
