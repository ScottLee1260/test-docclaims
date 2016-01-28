package Test::DocClaims::Lines;

# Copyright (c) 2009-2016 Scott E. Lee. All rights reserved.
# This program my be used under the Perl License OR the MIT License.
# This program is free software. You may copy or redistribute it under the
# same terms as Perl itself.

use 5.008;
use strict;
use warnings;
use Carp;

use Test::DocClaims::Line;

# Tell croak to skip over calls from here.
our @CARP_NOT = qw< Test::DocClaims >;

# Keys in the blessed hash
#   {lines}      array of Test::DocClaims::Line objects
#   {current}    the current index into {lines}

sub new {
    my $class     = shift;
    my $file_spec = shift;
    my $self      = bless {}, ref($class) || $class;
    $self->{lines}   = [];
    $self->{current} = 0;
    foreach my $attrs ( $self->_file_spec_to_list($file_spec) ) {
        $self->_add_file($attrs);
    }
    return $self;
}

# Convert a file spec arg to a list of attribute hashes representing the
# files.
sub _file_spec_to_list {
    my $self = shift;
    my $arg  = shift;
    $arg = [$arg] unless ref $arg eq "ARRAY";
    foreach my $item (@$arg) {
        if ( ref $item eq "HASH" ) {
            croak "file spec is hash, but it has no 'path' key"
                unless length $item->{path};
            my %default = $self->_attrs_of_file( $item->{path} );
            foreach my $key ( keys %default ) {
                $item->{$key} = $default{$key} unless defined $item->{$key};
            }
        } else {
            $item = { path => $item, $self->_attrs_of_file($item) };
        }
    }
    return @$arg;
}

# Each attribute hash has at least these keys:
#   path    the path of the file
#   type    the type of the file, eg "perl", "pod", "t", etc.
#   has_pod true if it should be pares as POD
#   test    true if it is a test file and may have "#@" and "@?" lines
#   blank   true if blank lines are preserved
#   white   true if amount of white space at beginnig of lines is preserved
sub _attrs_of_file {
    my $self = shift;
    my $path = shift;
    my %attrs;
    if ( $path =~ /\.p[lm]$/ ) {
        $attrs{type}    = "perl";
        $attrs{has_pod} = 1;
        $attrs{test}    = 0;
        $attrs{blank}   = 0;
        $attrs{white}   = 0;
    } elsif ( $path =~ /\.pod$/ ) {
        $attrs{type}    = "pod";
        $attrs{has_pod} = 1;
        $attrs{test}    = 0;
        $attrs{blank}   = 0;
        $attrs{white}   = 0;
    } elsif ( $path =~ /\.t$/ ) {
        $attrs{type}    = "t";
        $attrs{has_pod} = 1;
        $attrs{test}    = 1;
        $attrs{blank}   = 0;
        $attrs{white}   = 0;
    } elsif ( $path =~ /\.md$/ ) {
        $attrs{type}    = "md";
        $attrs{has_pod} = 0;
        $attrs{test}    = 0;
        $attrs{blank}   = 0;
        $attrs{white}   = 0;
    } else {
        $attrs{type}    = "";
        $attrs{has_pod} = 0;
        $attrs{test}    = 0;
        $attrs{blank}   = 0;
        $attrs{white}   = 0;
    }
    return %attrs;
}

sub _add_file {
    my $self  = shift;
    my $attrs = shift;
    my $lines = $self->_read_file($attrs->{path});
    my $lnum  = 0;
    my $is_pod = 0;
    my $flag = "";
    foreach my $text (@$lines) {
        my %hash = ( orig => $text, lnum => ++$lnum );
        if ( $attrs->{test} && $text =~ s/^\s*(#([@?])([a-z]*))( |$)// ) {
            my ( $comment, $char2, $f ) = ( $1, $2, $3 );
            $hash{comment} = $comment;
            $flag = $f;
        } elsif ( $attrs->{has_pod} ) {
            $hash{is_pod} = $is_pod;
            if ( $text =~ /^=(\w+)/ ) {
                my $cmd = $1;
                if ( $cmd eq "pod" ) {
                    $hash{is_pod} = 0;    # pod starts with next line
                    $is_pod = 1;
                } elsif ( $cmd eq "cut" ) {
                    $hash{is_pod} = 0;
                    $is_pod = 0;
                } else {
                    $hash{is_pod} = 1;
                    $is_pod = 1;
                }
                $flag = "";
            }
        }
        $hash{flag} = $flag;
        $text =~ s/\s+$//;    # remove CRLF, NL and trailing white space
        $text =~ s/^\s+/ / if !$attrs->{white};
        $hash{text} = $text;
        $hash{file} = $attrs;
        push @{ $self->{lines} }, Test::DocClaims::Line->new(%hash);
    }
    return $self;
}

sub _read_file {
    my $self = shift;
    my $path = shift;
    my @lines;
    if ( open my $fh, "<", $path ) {
        @lines = <$fh>;
        close $fh;
    } else {
        croak "cannot read $path: $!\n";
    }
    return \@lines;
}

sub is_eof {
    my $self = shift;
    return $self->{current} >= scalar( @{ $self->{lines} } );
}

sub advance_line {
    my $self = shift;
    $self->{current}++;
}

sub current_line {
    my $self = shift;
    return undef if $self->is_eof;
    return $self->{lines}[ $self->{current} ];
}

1;

__END__

=head1 NAME

Test::DocClaims::Lines - An example Perl module.

=head1 SYNOPSIS

  use Test::DocClaims::Lines;
  $foo = Test::DocClaims::Lines->new();
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

