package Test::DocClaims::Line;

# Copyright (c) 2009-2016 Scott E. Lee. All rights reserved.
# This program my be used under the Perl License OR the MIT License.
# This program is free software. You may copy or redistribute it under the
# same terms as Perl itself.

use 5.008;
use strict;
use warnings;
use Carp;

# Keys in the blessed hash
#   {text}     text of the line
#   {path}     path of the file
#   {lnum}     line number of the line
#   {type}     type of text, eg "pod", "perl"
#   {...}      other attributes

use overload
    '""' => 'text',
    ;

sub new {
    my $class = shift;
    my %attr  = @_;
    my $self  = bless \%attr, ref($class) || $class;
    foreach my $a (qw< text path lnum >) {
        croak "missing $a key in " . __PACKAGE__ . "->new"
            unless exists $self->{$a};
    }
    return $self;
}

sub attr {
    my $self = shift;
    my $attr = shift;
    my $old  = $self->{$attr};
    $self->{$attr} = shift if @_;
    return $old;
}

sub text { my $self = shift; $self->attr( "text", @_ ) }
sub path { my $self = shift; $self->attr( "path", @_ ) }
sub lnum { my $self = shift; $self->attr( "lnum", @_ ) }
sub type { my $self = shift; $self->attr( "type", @_ ) }

1;

__END__

=head1 NAME

Test::DocClaims::Line - An example Perl module.

=head1 SYNOPSIS

  use Test::DocClaims::Line;
  $foo = Test::DocClaims::Line->new();
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
