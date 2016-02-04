#!perl

use strict;
use warnings;
use lib "lib";
use Test::More tests => 173;

BEGIN { use_ok('Test::DocClaims::Lines'); }
can_ok('Test::DocClaims::Lines', 'new');

my @data = (
[ 0,     "",    undef, 'package code1;'],
[ 0,     "",    undef, ''],
[ 1,     "",    undef, '=head1 HEADING'],
[ 1,     "",    undef, ''],
[ 1,     "",    undef, 'code1 - some test code'],
[ 1,     "",    undef, ''],
[ 1,     "",    undef, '    example();'],
[ 1,     "",    undef, ''],
[ 0,     "",    undef, '=cut'],
[ 0,     "",    undef, ''],
[ 0,     "",     '#@', '#@   this is more POD'],
[ 0,     "",     '#?', '#?   POD with no test written yet'],
[ 0,     "",    undef, ''],
[ 0, "code", '#@code', '  #@code'],
[ 0, "code",    undef, '  use Bar;'],
[ 0,     "",     '#@', '  #@'],
[ 0,     "",    undef, ''],
[ 0,     "",    undef, 'sub example {'],
[ 0,     "",    undef, '    return 42;'],
[ 0,     "",    undef, '}'],
[ 0,     "",    undef, ''],
);

my ( $lines, $line );

my $path = "t/Foo.t";
eval { $lines = Test::DocClaims::Lines->new($path); };
is($@, "", "does not die") or diag $@;
isa_ok($lines, "Test::DocClaims::Lines");

my $lnum = 0;
foreach my $entry (@data) {
    my ( $is_pod, $flag, $comment, $expect ) = @$entry;
    $lnum++;
    my $where = "at $path line $lnum";
    ok(!$lines->is_eof, "is_eof $where");
    $line = $lines->current_line;
    isa_ok($line, "Test::DocClaims::Line", "isa_ok $where");
    is($line->orig, $expect . "\n", "orig $where");
    is(!!$line->has_pod, !!1, "has_pod $where");
    is(!!$line->is_pod, !!$is_pod, "is_pod $where");
    is($line->flag, $flag, "flag $where");
    is($line->comment, $comment, "comment $where");
    my $text = $expect;
    $text =~ s/^\s*#[@?][a-z]*( |$)//;
    $text =~ s/^\s+/ /;
    is($line->text, $text, "text $where");

    $lines->advance_line;
}
ok($lines->is_eof);

#-----------------------------------------------------------------------------
no warnings 'redefine';

sub Test::DocClaims::Lines::_read_file {
    my $self = shift;
    my $path = shift;
    return [ map { $_->[3] . "\n" } @data ];
}

