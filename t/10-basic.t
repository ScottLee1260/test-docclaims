#!perl

use strict;
use warnings;
use Test::More tests => 2;

BEGIN { use_ok("Test::DocClaims"); }

my @results;
sub _ok   { push @results, [ "ok", $_[1], $_[2] ]; }
sub _diag { push @results, [ "diag", $_[1] ]; }

{
    no strict "refs";
    no warnings "redefine";
    local *{"Test::Builder::ok"}   = \&_ok;
    local *{"Test::Builder::diag"} = \&_diag;
    doc_claims( "t/90-DocClaims-Foo.t", "Something/Foo.pm", "run test" );
}
is_deeply( \@results, [
    ["ok", 1, "run test"],
], "no errors" ) or diag explain @results;

#-----------------------------------------------------------------------------
no warnings 'redefine';
use Carp;

my $files;

sub Test::DocClaims::Lines::_read_file {
    my $self = shift;
    my $path = shift;
    if (!$files) {
        my @list = split /^FILE:<(.+?)>.*$/m, join "", <DATA>;
        $files = { @list[1 .. $#list] }; # remove leading null element
    }
    if ( exists $files->{$path} ) {
        return [ split /^/, $files->{$path} ];
    } else {
        croak "cannot read $path: no such file\n";
    }
}

__DATA__
FILE:<Something/Foo.pm>-------------------------------------------------------
package Foo;

use strict;
use warnings;

=head1 NAME

Something::Foo - An example Perl module

=head1 SYNOPSIS

  use Something::Foo;
  $foo = Something::Foo->new();
  $foo->dosomething();

=head1 DESCRIPTION

This module does something.

=head2 Constructor

=over 4

=item new [ I<STRING> ]

This method creates a new object.

=cut

sub new {
    my $class = shift;
    my $text = shift;
    my $self = bless { text => $text }, ref($class) || $class;
    return $self;
}

=back

=head1 BUGS

I was once told that all programs with more than ten lines have a bug.

=cut

1;
FILE:<t/90-DocClaims-Foo.t>---------------------------------------------------
#!perl

use strict;
use warnings;
use Test::More tests => 173;

=head1 NAME

Something::Foo - An example Perl module

=head1 SYNOPSIS

  #@code
  use Something::Foo;
  $foo = Something::Foo->new();
  $foo->dosomething();
  #@

=head1 DESCRIPTION

This module does something.

=cut

is($foo->dosomething, "results", "Foo does something");

=head2 Constructor

=over 4

=item new [ I<STRING> ]

This method creates a new object.

=cut

my $foo = Something::Foo->new("test");
isa_ok($foo, "Something::Foo", "constructor works");

=back

=head1 BUGS

I was once told that all programs with more than ten lines have a bug.

=cut
