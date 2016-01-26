package Test::DocClaims;

# Copyright (c) 2009-2016 Scott E. Lee. All rights reserved.
# This program my be used under the Perl License OR the MIT License.
# This program is free software. You may copy or redistribute it under the
# same terms as Perl itself.

use 5.008;
use strict;
use warnings;
use Carp;

use Test::DocClaims::Lines;

our $VERSION = 0.001;

use Test::Builder::Module;
our @ISA    = qw< Test::Builder::Module >;
our @EXPORT = qw<
    doc_claims
>;

sub doc_claims {
    my ( $test_spec, $doc_spec, $name ) = @_;
    $name = "documentations claims are tested" unless defined $name;
    my $test = Test::DocClaims::Lines->new($test_spec);
    my $doc  = Test::DocClaims::Lines->new($doc_spec);
    my @error;
    my ( $test_line, $doc_line );
    my @skipped_code;
    while (1) {
        $test_line = $test->current_line;
        $doc_line  = $doc->current_line;
#warn "??? T: ", $test_line->text, "\n" if $test_line;
#warn "???    has_pod ", $test_line->has_pod, "\n" if $test_line;
#warn "???    is_pod ", $test_line->is_pod, "\n" if $test_line;
#warn "???    lnum ", $test_line->lnum, "\n" if $test_line;
#warn "??? D: ", $doc_line->text, "\n" if $doc_line;
#warn "???    has_pod ", $doc_line->has_pod, "\n" if $doc_line;
#warn "???    is_pod ", $doc_line->is_pod, "\n" if $doc_line;
#warn "???    lnum ", $doc_line->lnum, "\n" if $doc_line;
        if ( $test_line && $test_line->has_pod && !$test_line->is_pod ) {
            push @skipped_code, $test_line;
            $test->advance_line;
            $test_line = $test->current_line;
#warn "??? test not pod\n";
            redo;
        }
        if ( $doc_line && $doc_line->has_pod && !$doc_line->is_pod ) {
            $doc->advance_line;
            $doc_line = $doc->current_line;
#warn "??? doc not pod\n";
            redo;
        }
        last if $test->is_eof || $doc->is_eof;
        next if $test_line->text eq $doc_line->text;
        # ???

        return _diff_error( $test_line, $doc_line, $name ); 
    } continue {
        $test->advance_line;
        $doc->advance_line;
        @skipped_code = ();
#warn "??? advance_line\n";
    }
    if ( !$test->is_eof || !$doc->is_eof ) {
        return _diff_error( $test->current_line, $doc->current_line, $name ); 
    } else {
        my $tb = Test::DocClaims->builder;
        return $tb->ok( 1, $name );
    }
}

sub _diff_error {
    my ( $test_line, $doc_line, $name ) = @_;
    my @error;
    my $prefix = "   got";
    foreach my $line ( $test_line, $doc_line ) {
        if ( ref $line ) {
            my $text = $line->orig;
            $text =~ s/\s+$//;
            push @error, "$prefix: '$text'";
            push @error, "at " . $line->path . " line " . $line->lnum;
        } else {
            push @error, "missing";
        }
        $prefix = "expect";
    }
    my $tb = Test::DocClaims->builder;
    my $fail = $tb->ok( 0, $name );
    $tb->diag( map { "    $_\n" } @error );
    return $fail;
}

1;

__END__

=head1 NAME

Test::DocClaims - Help assure that documentation claims are tested

=head1 SYNOPSIS

  use Test::DocClaims;
  $foo = Test::DocClaims->new();
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
