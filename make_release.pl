#!/usr/bin/perl

use 5.008;
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use File::Path qw< rmtree >;

Getopt::Long::Configure(qw< bundling_override >);
GetOptions(
    'help|h' => sub { pod2usage(1) },
    'man'    => sub { pod2usage( -verbose => 2 ), exit 0 },
    'v+' => \( my $verbose = 0 ),
) or pod2usage(2);

chdir "src" or die "cannot chdir src: $!\n";

my $version = get_version();
print "VERSION = '$version'\n";
check_changes_file($version);

print "Generating README\n";
add_version( "../README", "README" );

rmtree "Test-DocClaims-$version";
unlink "Test-DocClaims-$version.tar";
unlink "Test-DocClaims-$version.tar.gz";
unlink "MANIFEST";
unlink "MANIFEST.bak";
foreach my $cmd (
    "perl Makefile.PL ",
    "make",
    "make test",
    "make manifest",
    "make dist",
    )
{
    print "> $cmd\n";
    system $cmd and die "command failed\n";
}

sub add_version {
    my $in  = shift;
    my $out = shift;
    my @text = map { $_ =~ s/\$VERSION\b/$version/g ; $_ } read_file($in);
    open my $fh, ">", $out or die "cannot write $out: $!\n";
    print $fh @text;
    close $fh;
}

sub get_version {
    my $path;
    foreach my $line (read_file("Makefile.PL")) {
        if ( $line =~ /VERSION_FROM\s*=>\s*['"](.+?)['"]/ ) {
            $path = $1;
        }
    }
    if ($path) {
        foreach my $line (read_file($path)) {
            if ( $line =~ /our\s+\$VERSION\s*=\s*['"](.+?)['"]/ ) {
                return $1;
            }
        }
        die "did not find VERSION in $path\n";
    } else {
        die "did not find VERSION_FROM in Makefile.PL\n";
    }
}

sub check_changes_file {
    my $version = shift;
    my @lines = read_file("Changes");
    shift @lines;
    shift @lines until $lines[0] =~ /^(\S+)/;
    die "./Changes version ($1) does not match '$version'\n"
        unless $1 eq $version;
}

sub read_file {
    my $path = shift;
    my @lines;
    open my $fh, "<", $path or die "cannot read $path: $!\n";
    @lines = <$fh>;
    close $fh;
    return @lines;
}

__END__

=head1 NAME

make_release.pl - make a new release of the CPAM module

=head1 SYNOPSIS

make_release.pl [--help] [--man]

=head1 OPTIONS

=over 8

=item B<--help> or B<-h>

Print a short usage synopsis.

=item B<--man>

Print the full command manual entry.

=back

=head1 DESCRIPTION

Make a new release of the CPAM module.
It will:

  determine the new version number
  make sure src/Changes has that version
  regenerate the src/MANIFEST file
  add the version number to the src/README file
  make the *.tar.gz file.

=cut
