#!perl

use strict;
use warnings;
use Test::More tests => 1;

BEGIN { use_ok('Test::DocClaims'); }

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

