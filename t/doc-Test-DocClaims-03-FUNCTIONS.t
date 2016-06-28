#!perl

use strict;
use warnings;
use Test::More tests => 1;

BEGIN { use_ok('Test::DocClaims'); }

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
