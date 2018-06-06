#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/

use strict;
use warnings;
use feature qw(say);
use File::Find; 
use File::Basename;
use Cwd;
use POSIX qw(floor);

my $theFile= "worktreeSkipFiles.txt";
system("git diff --name-only >$theFile");

# read each line from the file into an array
open my $handleIn, '<', $theFile or die "Could not open file '$theFile' $!";
chomp (my @linesIn = <$handleIn>);
close $handleIn;
# process each line from the array
foreach my $line (@linesIn) {
    chomp($line);
    say $line;
    # encase filename / filepath in quotes to handle spaces
    system("git update-index --skip-worktree \"$line\"");
}

exit;
