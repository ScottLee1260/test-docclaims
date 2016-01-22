package Test::DocClaims::Tests;

# Copyright (c) 2009-2016 Scott E. Lee. All rights reserved.
# This program my be used under the Perl License OR the MIT License.
# This program is free software. You may copy or redistribute it under the
# same terms as Perl itself.

use 5.008;
use strict;
use warnings;

use Test::DocClaims::Lines;

our @ISA = qw< Test::DocClaims::Lines >;

# Keys in the blessed hash
#   {lines}     array of Test::DocClaims::Line objects
#   {current}   the current index into {lines}

sub match {
    my $self = shift;
    my $doc  = shift;
    my $skip = 0;

    # Skip blank lines in both files.
    {
        if ( $doc->current_line->text =~ /^\s*$/ ) {
            return () unless $doc->advance_line;
            redo;
        }
        if ( ref $self->current_line && $self->current_line->text =~ /^(#[@?] )?\s*$/ ) {
            redo if $self->advance_line;
        }
    }

    my $doc_line  = $doc->current_line->text;
    $doc_line  =~ s/^\s+|\s+$//g;
    if ( !ref $self->current_line ) {
        return (
            "     got: missing",
            "in " . $self->prev_line->path,
            "expected: '$doc_line'",
            "at " . $doc->current_line->path .
                " line " . $doc->current_line->lnum,
            );
    }
    my $test_line = $self->current_line->text;
    if ( $test_line  =~ s/^#([@?]) // ) {
        $skip = 1 if $1 eq "?";
    }
    $test_line =~ s/^\s+|\s+$//g;
#print STDERR "??? doc_line='$doc_line'\n";
#print STDERR "   test_line='$test_line'\n";
    # TODO report skipped test if $skip
    return () if $doc_line eq $test_line;

    return (
        "     got: '$test_line'",
            "at " . $self->current_line->path .
                " line " . $self->current_line->lnum,
        "expected: '$doc_line'",
            "at " . $doc->current_line->path .
                " line " . $doc->current_line->lnum,
        );
}

sub clean_line {
    my $lines = shift;
    my $text  = $lines->current_line->text;
    $text =~ s/^\s+|\s+$//g;
    return $text;
}

1;

__END__

=head1 NAME

Test::DocClaims::Documentation - An example Perl module.

=head1 SYNOPSIS

  use Test::DocClaims::Documentation;
  $foo = Test::DocClaims::Documentation->new();
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

