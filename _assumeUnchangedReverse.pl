#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/

use strict;
use warnings;
use feature qw(say);
use File::Find; 
use File::Basename;
use Cwd;
use POSIX qw(floor);

my $theFile= "assumeUnchangedReverse.textlog";
# list the git "assume unchanged record"
system("git ls-files -v . | grep \"\^h\" >$theFile");

# read each line from the file into an array
open my $handleIn, '<', $theFile or die "Could not open file '$theFile' $!";
chomp (my @linesIn = <$handleIn>);
close $handleIn;
# process each line from the array
foreach my $line (@linesIn) {
    chomp($line);
    # remove the "h " at the start of each line (indicating an assume-unchanged file)
    my $n=2;
    $line =~ s/^.{$n}//s;
    say $line;
    # remove file from "assume unchanged record"; encase filename / filepath in quotes to handle spaces
    system("git update-index --no-assume-unchanged \"$line\"");
}

exit 0;
