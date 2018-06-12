#!/usr/bin/perl -w
# steps:
# 1. get all code from VSS; inital commit select all (including ignored) to git
# 2. add the template git ignore file for visual studio
# 3. clean all and then rebuild all
# 4. run this script to worktree-skip files that building changes (.DLL, .pdb, .log, .txt, .cache)
#
# git keeps a record of all files that it is skipping locally ("worktree skip record")
# run worktreeSkipReverse.pl to remove files from the "worktree skip record"
#
# runs with Strawberry Perl: http://strawberryperl.com/

use strict;
use warnings;
use feature qw(say);
use File::Find; 
use File::Basename;
use Cwd;
use POSIX qw(floor);

my @contentSkip;
my $name;
my $path;
my $suffix;

############### add files that have changed since last commit to "worktree skip record" ###############
my $theFile= "worktreeSkipFiles.txt";
# list all files that have changed since last commit
system("git diff --name-only >$theFile");

# read each line from the file into an array
open my $handleIn, '<', $theFile or die "Could not open file '$theFile' $!";
chomp (my @linesIn = <$handleIn>);
close $handleIn;
# process each line from the array (add each file to the "worktree skip record")
foreach my $line (@linesIn) {
    chomp($line);
    say $line;
    # don't add source files that have changed to the "worktree skip record"
    ($name,$path,$suffix) = fileparse($line,qr"\..[^.]*$");
    if (($suffix eq ".cs") || ($suffix eq ".cpp") || ($suffix eq ".hpp") || ($suffix eq ".h")|| ($suffix eq ".pl") || ($suffix eq ".bat")) {
        say "WARNING: Source file ... exiting";
        exit;
    }
    # add file to "worktree skip record"; encase filename / filepath in quotes to handle spaces
    system("git update-index --skip-worktree \"$line\"");
}

############### user specified files to be added to "worktree skip record" ###############
# find all files (that user wishes to ignore locally) from current and sub directories
find( \&filesWanted, '.'); 
# process each line from the array (add each file to the "worktree skip record")
foreach my $line (@contentSkip) {
    chomp($line);
    # remove the "./" at the start of each line (indicating a skipped worktree file)
    my $n=2;
    $line =~ s/^.{$n}//s;
    say $line;
    # add file to "worktree skip record"; encase filename / filepath in quotes to handle spaces
    system("git update-index --skip-worktree \"$line\"");
}
exit;

sub filesWanted{
    my $file = $File::Find::name;
    if ($file =~ /\.suo$/){
        push @contentSkip, $file;
    }
    if ($file =~ /\.user$/){
        push @contentSkip, $file;
    }
    if ($file =~ /\.db$/){
        push @contentSkip, $file;
    }
}
