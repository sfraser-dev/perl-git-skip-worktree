#!/usr/bin/perl -w
# run this after a clean and then a rebuild all

# runs with Strawberry Perl: http://strawberryperl.com/

use strict;
use warnings;
use feature qw(say);
use File::Find; 
use File::Basename;
use Cwd;
use POSIX qw(floor);

my @content;
my $name;
my $path;
my $suffix;

my $theFile= "worktreeSkipFiles.txt";
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
        say "WARNING: Source file. Exiting";
        exit;
    }
    # encase filename / filepath in quotes to handle spaces
    system("git update-index --skip-worktree \"$line\"");
}

# find all files (that user wishes to ignore locally) from current and sub directories
#find( \&filesWanted, '.'); 
# process each line from the array (add each file to the "worktree skip record")
#foreach my $line (@content) {
#    chomp($line);
#    # remove the "./" at the start of each line (indicating a skipped worktree file)
#    my $n=2;
#    $line =~ s/^.{$n}//s;
#    say $line;
#    # encase filename / filepath in quotes to handle spaces
#    system("git update-index --skip-worktree \"$line\"");
#}
exit;

sub filesWanted{
    my $file = $File::Find::name;
    if ($file =~ /\.suo$/){
        push @content, $file;
    }
    if ($file =~ /\.user$/){
        push @content, $file;
    }
}
