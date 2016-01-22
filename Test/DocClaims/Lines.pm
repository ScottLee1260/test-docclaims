package Test::DocClaims::Lines;

# Copyright (c) 2009-2016 Scott E. Lee. All rights reserved.
# This program my be used under the Perl License OR the MIT License.
# This program is free software. You may copy or redistribute it under the
# same terms as Perl itself.

use 5.008;
use strict;
use warnings;

use Test::DocClaims;
use Test::DocClaims::Line;

# Keys in the blessed hash
#   {lines}      array of Test::DocClaims::Line objects
#   {current}    the current index into {lines}
#   {this_line}  a hash of info about the line about to be added:
#     {path}       path of the file
#     {lnum}       lnum of the file
#     {type}       type of the file
#     {linetype}   type of the line, overrides type if it is defined
#                    eg: "=pod" sets to "pod"; "=cut" sets to undef

sub new {
    my $class = shift;
    my $self = bless {}, ref($class) || $class;
    $self->{lines}     = [];
    $self->{current}   = 0;
    $self->{this_line} = {};
    foreach my $path (@_) {
        $self->add_file($path);
    }
    return $self;
}

sub add_file {
    my $self = shift;
    my $path = shift;
    if ( open my $fh, "<", $path ) {
        my $line_num = 0;
        my @lines    = <$fh>;
        close $fh;
        $self->add_lines( \@lines, $path );
    } else {
        my $tb = Test::DocClaims->builder;
        $tb->diag("cannot read $path: $!\n");
    }
    return $self;
}

# Take an array of lines and convert to an array of Test::DocClaims::Line
# objects and add them to the list.
sub add_lines {
    my $self  = shift;
    my $lines = shift;
    my $path  = shift;
    my %attrs = $self->file_pre( $lines, \$path );
    $attrs{path}     = $path unless defined $attrs{path};
    $attrs{type}     = ""    unless defined $attrs{type};
    $attrs{linetype} = undef unless defined $attrs{linetype};
    my $lnum = 0;
    foreach my $text (@$lines) {
        %{ $self->{this_line} } = %attrs;
        $self->{this_line}{text} = $text;
        $self->{this_line}{lnum} = ++$lnum;
        $self->line_pre();
        $self->add_line();
        $self->line_post();
    }
    $self->file_post();
}

sub add_line {
    my $self = shift;
    if ( %{ $self->{this_line} } ) {
        if ( defined $self->{this_line}{linetype} ) {
            $self->{this_line}{type} = delete $self->{this_line}{linetype};
        }
        push @{ $self->{lines} }, $self->new_line( %{ $self->{this_line} } );
    }
    $self->{this_line} = {};
}

sub new_line {
    my $self = shift;
    return Test::DocClaims::Line->new(@_);
}

sub advance_line {
    my $self = shift;
    $self->{current}++;
    return $self->{current} < scalar @{ $self->{lines} };
}

sub file_pre {
    my $self  = shift;
    my $lines = shift;
    my $path  = shift;
    my %attrs;
    if ( length $$path ) {
        $attrs{type} = "perl"  if $$path =~ /\.p[lm]$/i;
        $attrs{type} = "pod"   if $$path =~ /\.pod$/i;
        $attrs{type} = "md"    if $$path =~ /\.md$/i;
        $attrs{type} = "t"     if $$path =~ /\.t$/i;
    }
    $self->{parse_pod} = $attrs{type} && $attrs{type} =~ /^(perl|pod|t)$/;
    $self->{in_pod} = 0;
    return %attrs;
}

sub file_post {
    my $self = shift;
}

sub line_pre {
    my $self = shift;
    if ( $self->{parse_pod} ) {
        if ( $self->{this_line}{type} ne "t" ||
            $self->{this_line}{text} !~ /^#[@?] / )
        {
            if ( $self->{this_line}{text} =~ /^=(\S+)/ ) {
                my $cmd = $1;
                if ( $cmd eq "pod" ) {
                    $self->{this_line} = {};    # discard this line
                    $self->{in_pod}    = 1;
                } elsif ( $cmd eq "cut" ) {
                    $self->{in_pod} = 0;
                } else {
                    $self->{in_pod} = 1;
                }
            }
            $self->{this_line}{type} = "pod" if $self->{in_pod};
            $self->{this_line} = {} unless $self->{in_pod};
        }
    }
}

sub line_post {
    my $self = shift;
}

sub current_line {
    my $self = shift;
    return ( $self->context(0) )[0];
}

sub prev_line {
    my $self = shift;
    return ( $self->context(-1) )[0];
}

sub context {
    my $self   = shift;
    my $offset = shift;
    my $count  = shift;
    $count = 1 unless defined $count;
    my $size  = scalar( @{ $self->{lines} } );
    my $first = $self->{current} + $offset;
    my $last  = $self->{current} + $offset + $count - 1;
    $first = 0 if $first < 0;
    my @list;
    for ( my $i = $first ; $i <= $last ; $i++ ) {
        last if $i >= $size;
        push @list, $self->{lines}[$i];
    }
    return @list;
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

