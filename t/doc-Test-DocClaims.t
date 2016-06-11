#!perl

use strict;
use warnings;
use Test::More tests => 1;

BEGIN { use_ok('Test::DocClaims'); }

=head1 NAME

Test::DocClaims - Help assure documentation claims are tested

=head1 SYNOPSIS

To automatically scan for source files containing POD, find the
corresponding tests and verify that those tests match the POD, create the
file t/doc_claims.t with the following lines:

=for DC_TODO

  use Test::More;
  eval "use Test::DocClaims";
  plan skip_all => "Test::DocClaims not found" if $@;
  all_doc_claims();

=for DC_TODO

Or, for more control over the POD files and which tests correspond to them:

=for DC_TODO

  use Test::More;
  eval "use Test::DocClaims";
  plan skip_all => "Test::DocClaims not found" if $@;
  plan tests => 2;
  doc_claims( "lib/Foo/Bar.pm", "t/doc-Foo-Bar.t",
    "doc claims in Foo/Bar.pm" );
  doc_claims( "lib/Foo/Bar/Baz.pm", "t/doc-Foo-Bar-Baz.t",
    "doc claims in Foo/Bar/Baz.pm" );

=for DC_TODO

If a source file (lib/Foo/Bar.pm) contains:

  =head2 add I<arg1> I<arg2>

  This adds two numbers.

  =cut

  sub add {
      return $_[0] + $_[1];
  }

=for DC_TODO

then the corresponding test (t/doc-Foo-Bar.t) might have:

  =head2 add I<arg1> I<arg2>

  This adds two numbers.

  =cut

  is( add(1,2), 3, "can add one and two" );
  is( add(2,3), 5, "can add two and three" );

=for DC_TODO

=head1 DESCRIPTION

A module should have documentation that defines its interface. All claims in
that documentation should have corresponding tests to verify that they are
true. Test::DocClaims is designed to help assure that those tests are written
and maintained.

=for DC_TODO

It would be great if software could read the documentation, enumerate all
of the claims made and then generate the tests to assure
that those claims are properly tested.
However, that level of artificial intelligence does not yet exist.
So, humans must be trusted to enumerate the claims and write the tests.

=for DC_TODO

How can Test::DocClaims help?
As the code and its documentation evolve, the test suite can fall out of
sync, no longer testing the new or modified claims.
This is where Test::DocClaims can assist.
First, a copy of the POD documentation must be placed in the test suite.
Then, after each claim, a test of that claim should be inserted.
Test::DocClaims compares the documentation in the code with the documentation
in the test suite and reports discrepancies.
This will act as a trigger to remind the human to update the test suite.
It is up to the human to actually edit the tests, not just sync up the
documentation.

=for DC_TODO

The comparison is done line by line.
Trailing white space is ignored.
Any white space sequence matches any other white space sequence.
Blank lines as well as "=cut" and "=pod" lines are ignored.
This allows tests to be inserted even in the middle of a paragraph by
placing a "=cut" line before and a "=pod" line after the test.

=for DC_TODO

Additionally, a special marker, of the form "=for DC_TODO", can be placed
in the test suite in lieu of writing a test.
This serves as a reminder to write the test later, but allows the
documentation to be in sync so the Test::DocClaims test will pass with a
todo warning.
Any text on the line after DC_TODO is ignored and can be used as a comment.

=for DC_TODO

Especially in the SYNOPSIS section, it is common practice to include
example code in the documentation.
In the test suite, if this code is surrounded by "=begin DC_CODE" and "=end
DC_CODE", it will be compared as if it were part of the POD, but can run as
part of the test.
For example, if this is in the documentation

  Here is an example:

    $obj->process("this is some text");

=for DC_TODO

this could be in the test

  Here is an example:

  =begin DC_CODE

  =cut

  $obj->process("this is some text");

  =end DC_CODE

=for DC_TODO

Example code that uses print or say and has a comment at the end will also
match a call to is() in the test.
For example, this in the documentation POD

  The add function will add two numbers:

    say add(1,2)             # 3
    say add(50,100)          # 150

=for DC_TODO

will match this in the test.

  The add function will add two numbers:

  =begin DC_CODE

  =cut

  is(add(1,2), 3);
  is(add(50,100), 150);

  =end DC_CODE

=for DC_TODO

When comparing code inside DC_CODE markers, all leading white space is
ignored.

=for DC_TODO

When the documentation file type does not support POD (such as mark down
files, *.md) then the entire file is assumed to be documentation and must
match the POD in the test file.
For these files, leading white space is ignored.
This allows a leading space to be added in the POD if necessary.

=for DC_TODO

=head1 FUNCTIONS

=head2 doc_claims I<DOC_SPEC> I<TEST_SPEC> [ I<TEST_NAME>  ]

Verify that the lines of documentation in I<TEST_SPEC> match the ones in
I<DOC_SPEC>.
The I<TEST_SPEC> and I<DOC_SPEC> arguments specify a list of one or more
files.
Each of the arguments can be one of:

=for DC_TODO

  - a string which is the path to a file or a wildcard which is
    expanded by the glob built-in function.
  - a ref to a hash with these keys:
    - path:    path or wildcard (required)
    - has_pod: true if the file can have POD (optional)
  - a ref to an array, where each element is a path, wildcard or hash
    as above

=for DC_TODO

If a list of files is given, those files are read in order and the
documentation in each is concatenated.
This is useful when a module file requires many tests that are best split
into multiple files in the test suite.
For example:

=for DC_TODO

  doc_claims( "lib/Foo/Bar.pm", "t/Bar-*.t", "doc claims" );

=for DC_TODO

If a wildcard is used, be sure that the generated list of files is in the
correct order. It may be useful to number them (such as Foo-01-SYNOPSIS.t,
Foo-02-DESCRIPTION.t, etc).

=for DC_TODO

=head2 all_doc_claims [ I<DOC_DIRS> [ I<TEST_DIRS> ] ]

This is the easiest way to test the documentation claims.
It automatically searches for documentation and then locates the
corresponding test file or files.
By default, it searches the lib, bin and scripts directories and their
subdirectories for documentation.
For each of these files it looks in (by default) the t
directory for one or more matching files.
It does this with the following patterns, where PATH is the path of the
documentation file with the suffix removed (e.g., .pm or .pl) and slashes
(/) converted to dashes (-).
The patterns are tried in this order until one matches.

=for DC_TODO

  doc-PATH-[0-9]*.t
  doc-PATH.t
  PATH-[0-9]*.t
  PATH.t

=for DC_TODO

If none of the patterns match, the left most directory of the PATH is
removed and the patterns are tried again.
This is repeated until a match is found or the PATH is exhausted.
If the pattern patches multiple files, these files are processed in
alphabetical order and their documentation is concatenated to match against
the documentation file.

=for DC_TODO

If I<DOC_DIRS> is missing or undef, its default value of
[qw< lib bin scripts >] is used.
If I<TEST_DIRS> is missing or undef, its default value of
[qw< t >] is used.

=for DC_TODO

When searching for documentation files, any file with one of these suffixes
is used:

=for DC_TODO

   *.pl
   *.pm
   *.pod
   *.md

=for DC_TODO

Also, any file who's first line matches /^#!.*perl/i is used.

=for DC_TODO

The number of tests run is determined by the number of documentation files
found.
Do not set the number of tests before calling all_doc_claims because it
will do that automatically.

=for DC_TODO


=head1 SEE ALSO

L<Devel::Coverage>,
L<POD::Tested>,
L<Test::Inline>.
L<Test::Pod>,
L<Test::Pod::Coverage>,
L<Test::Pod::Snippets>,
L<Test::Synopsis>,
L<Test::Synopsis::Expectation>.

=head1 AUTHOR

Scott E. Lee, E<lt>ScottLee@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2016 by Scott E. Lee

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.

