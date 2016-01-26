package Test::DocClaims::Line;

# Copyright (c) 2009-2016 Scott E. Lee. All rights reserved.
# This program my be used under the Perl License OR the MIT License.
# This program is free software. You may copy or redistribute it under the
# same terms as Perl itself.

use 5.008;
use strict;
use warnings;

# Keys in the blessed hash
#   {text}     text of the line
#   {path}     path of the file
#   {lnum}     line number of the line
#   {type}     type of text, eg "pod", "perl"
#   {...}      other attributes

use overload
    '""'   => 'text',
    'bool' => sub { 1 },
    ;

sub new {
    my $class = shift;
    my %attr  = @_;
    my $self  = bless \%attr, ref($class) || $class;
    foreach my $k (qw< file text lnum orig >) {
        die "missing $k key in " . __PACKAGE__ . "->new"
            unless exists $self->{$k};
    }
    die "'file' key in " . __PACKAGE__ . "->new is not hash"
        unless exists $self->{file};
    foreach my $k (qw< path type has_pod >) {
        die "missing $k key in " . __PACKAGE__ . "->new file hash"
            unless exists $self->{file}{$k};
    }
    return $self;
}

sub path    { $_[0]->{file}{path} }
sub type    { $_[0]->{file}{type} }
sub has_pod { $_[0]->{file}{has_pod} }

sub lnum    { $_[0]->{lnum} }
sub text    { $_[0]->{text} }
sub orig    { $_[0]->{orig} }
sub comment { $_[0]->{comment} }
sub is_pod  { $_[0]->{is_pod} }

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
