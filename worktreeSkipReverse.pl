#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/

use strict;
use warnings;
use feature qw(say);
use File::Find; 
use File::Basename;
use Cwd;
use POSIX qw(floor);

my $theFile= "worktreeSkipReverseFiles.txt";
system("git ls-files -v . | grep \"\^S\" >$theFile");

# read each line from the file into an array
open my $handleIn, '<', $theFile or die "Could not open file '$theFile' $!";
chomp (my @linesIn = <$handleIn>);
close $handleIn;
# process each line from the array
foreach my $line (@linesIn) {
    chomp($line);
    # remove the "S " at the start of each line (indicating a skipped worktree file)
    my $n=2;
    $line =~ s/^.{$n}//s;
    say $line;
    # encase filename / filepath in quotes to handle spaces
    system("git update-index --no-skip-worktree \"$line\"");
}

exit;
