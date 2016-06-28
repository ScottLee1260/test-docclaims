package TestTester;

# Copyright (c) Scott E. Lee

# How do you test a test module? Simple. Just override the methods in
# Test::Builder used to report status and instead of printing the status,
# put it into an array of findings. Then compare that array of findings to
# an array of expected findings. That is how this module works.

use strict;
use warnings;

# Make sure it is loaded before we try to override its methods, otherwise
# we will get a redefined error when it does load.
use Test::DocClaims::Lines;

use base qw( Exporter );
our @EXPORT = qw< files_from_data findings_match >;

# Read a set of files from the __DATA__ section into a hash and return a
# ref to this hash. This can be used as the first parameter to
# findings_match().
sub files_from_data {
    my $package     = shift || caller;
    my $data_handle = $package . "::DATA";
    my @files       = split /^FILE:<(.+?)>.*$/m, join "", <$data_handle>;
    close $data_handle;
    shift @files;    # remove leading null element
    return {@files};
}

sub findings_match {
    my $files;
    $files = shift if ref $_[0] eq "HASH";
    my $test_subr = shift;
    my @expect    = @{ shift() };
    my $name      = shift;

    # Get the files that are used in this test. If a hash of files was not
    # passed as the first parameter, read them from the __DATA__ section of
    # the caller's package.  This will be used to make it look like they
    # exist in the file system by replacing
    # Test::DocClaims::Lines::_read_file().
    if ( !$files ) {
        $files = files_from_data(caller);
    }

    # Run the test, but capture the results into @findings instead of
    # printing them.
    my @findings;
    {
        my $ok = sub { push @findings, [ $_[1] ? "ok" : "not ok", $_[2] ]; };
        my $diag = sub { push @findings, @_[ 1 .. $#_ ] };
        my $read = sub {
            my $path = shift;
            if ( exists $files->{$path} ) {
                return [ split /^/m, $files->{$path} ];
            } else {
                die "cannot read $path: No such file or directory\n";
            }
        };

        no strict "refs";
        no warnings "redefine";
        local *{"Test::Builder::ok"}                  = $ok;
        local *{"Test::Builder::diag"}                = $diag;
        local *{"Test::DocClaims::Lines::_read_file"} = $read;
        $test_subr->();
    }

    # Check the findings against @expect.
    my $tb = Test::DocClaims->builder;
    my $i  = 0;
    while ( @findings && @expect ) {
        my $finding = shift @findings;
        my $expect  = shift @expect;
        $i++;
        if ( ref $finding && ref $finding ne "ARRAY" ) {
            my ( undef, $file, $line ) = caller;
            die "item $i in \@expect not scalar or array ref"
                . " at $file line $line\n";
        }
        if ( ref $finding && ref $expect ) {
            if (   $finding->[0] ne $expect->[0]
                || $finding->[1] ne $expect->[1] )
            {
                my $fail = $tb->ok( 0, $name );
                _diff( $tb, $i, $finding, $expect, \@findings );
                return $fail;
            }
        } elsif ( ref $finding && !ref $expect ) {
            my $fail = $tb->ok( 0, $name );
            _diff( $tb, $i, $finding, $expect, \@findings );
            return $fail;
        } elsif ( !ref $finding && ref $expect ) {
            my $fail = $tb->ok( 0, $name );
            _diff( $tb, $i, $finding, $expect, \@findings );
            return $fail;
        } elsif ( _cmp_no_white( $finding, $expect ) ) {
            my $fail = $tb->ok( 0, $name );
            _diff( $tb, $i, $finding, $expect, \@findings );
            return $fail;
        }
    }
    if (@findings) {
        my $finding = shift @findings;
        my $fail = $tb->ok( 0, $name );
        _diff( $tb, $i, $finding, undef, \@findings );
        return $fail;
    } elsif (@expect) {
        my $fail = $tb->ok( 0, $name );
        _diff( $tb, $i, undef, $expect[0], [] );
        return $fail;
    }
    return $tb->ok( 1, $name );
}

sub _cmp_no_white {
    my $a = shift;
    my $b = shift;
    $a =~ s/\s+$//;
    $b =~ s/\s+$//;
    return $a cmp $b;
}

# Generate the diff message when the two don't match.
sub _diff {
    my $tb       = shift;
    my $i        = shift;
    my $finding  = shift;
    my $expect   = shift;
    my @findings = @{ shift() };
    my @lines;
    foreach my $item ( $finding, $expect ) {
        push @lines, _diff_line($item);
    }
    $tb->diag("   at item $i\n");
    $tb->diag("         got: $lines[0]\n");
    $tb->diag("    expected: $lines[1]\n");
    if (@findings) {
        $tb->diag("Additional findings:\n");
        foreach my $j ( 1 .. 5 ) {
            $tb->diag( _diff_line( shift @findings ) );
            last unless @findings;
        }
    }
}

# Convert one item in the findings or expect list to text.
sub _diff_line {
    my $item = shift;
    if ( ref $item ) {
        my $item1 = $item->[1];
        $item1 = "" unless defined $item1;
        return "$item->[0] $item1";
    } elsif ( defined $item ) {
        my $text = $item;
        $text =~ s/\s+$//;
        return "'$text'";
    } else {
        return "missing";
    }
}

1;
