#!/usr/bin/perl -w
# steps:
# 1. get all code from VSS; select all (including ignored) and commit to git
# 2. run this file (worktree skip user specified files)
# 3. add template git ignore file (this won't ignore files from step 1, it'll ignore newly created build files)
# 4. clean all and then rebuild all
# 5. run this script to worktree-skip files that building changes (.DLL, .pdb, .log, .txt, .cache)
#
# git keeps a record of all files that it is skipping locally ("worktree skip record")
# run worktreeSkipReverse.pl to remove files from the "worktree skip record"
#
# runs with Strawberry Perl: http://strawberryperl.com/
#
# GOW commands to find only files then sort them by size (du sizes in kb)
# $> gfind vss2017_11p0_vstudio2015/ -type f -exec du -a {} ; >listFilesAndTheirSizes.textlog
# $> gsort -n listFilesAndTheirSizes.textlog >listFilesAndTheirSizesSorted.textlog

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

# Use gitigore from the start!
my $userSpecified = 0;

############### add files that have changed since last commit to "worktree skip record" ###############
my $theFile= "worktreeSkip.textlog";
# list all files that have changed since last commit
system("git diff --name-only >$theFile");

# read each line from the file into an array
open my $handleIn, '<', $theFile or die "Could not open file '$theFile' $!";
chomp (my @linesIn = <$handleIn>);
close $handleIn;
# process each line from the array (add each file to the "worktree skip record")
foreach my $line (@linesIn) {
    chomp($line);
    say "";
    say "DIFF: $line";
    # don't add changed source files to the "worktree skip record"; exit script if source file found  
    ($name,$path,$suffix) = fileparse($line,qr"\..[^.]*$");
    if (($suffix eq ".cs") || ($suffix eq ".cpp") || ($suffix eq ".hpp") || ($suffix eq ".h") || ($suffix eq ".pl") || ($suffix eq ".bat") || ($suffix eq ".odt")) {
        say $name;
        say $path;
        say $suffix;
        # exception "*.i.cs": not a source file, don't exit (add to "worktree skip record")
        if ((substr($name,-2) eq ".i") && ($suffix eq ".cs")){
            say "'.i.cs' extension; adding to 'worktree skip record'";
        }
        elsif ((substr($name,-2) eq ".g") && ($suffix eq ".cs")){
            say "'.g.cs' extension; adding to 'worktree skip record'";
        }
        elsif ((substr($name,-2) eq "_h") && ($suffix eq ".h")){
            say "'_h.h' extension; adding to 'worktree skip record'";
        }
        else {
            say "WARNING: source file found ... not adding to 'worktree skip record' ... exiting";
            exit 1;
        }
    }
    if (-d $line) { say "DIFFDIR: $line"; next; }
    # add file to "worktree skip record"; encase filename / filepath in quotes to handle spaces
    system("git update-index --skip-worktree \"$line\"");
}

############### user specified files to be added to "worktree skip record" ###############
if ($userSpecified == 1){
    say "";
    say "WARNING: adding many files to 'worktree skip record' bloats .git/ and causes malloc/mmap errors on my 32-bit 4GB ram DVR ... use gitignore file instead";
    say "SKIPPING user specified files";
    ## find all files (that user wishes to ignore locally) from current and sub directories
    #find( \&filesWanted, '.'); 
    ## process each line from the array (add each file to the "worktree skip record")
    #foreach my $line (@contentSkip) {
    #    chomp($line);
    #    # remove the "./" at the start of each line (indicating a skipped worktree file)
    #    my $n=2;
    #    $line =~ s/^.{$n}//s;
    #    say "USER: $line";
    #    # add file to "worktree skip record"; encase filename / filepath in quotes to handle spaces
    #    system("git update-index --skip-worktree \"$line\"");
    #}
}

exit 0;

############### sub
sub filesWanted{
    my $res;
    my $tagLetter;
    my $file = $File::Find::name;
    if (-f $file) {
        $res = `git ls-files -v $file`; 
        $tagLetter = substr($res, 0, 1); # skipped?
    }
    else {
        $tagLetter = "directory, don't analyse me";
    }
    if ($file !~ /^\.\/\.git/) { say "found $file"; }
    # ignore .git directory explicitly, ignore directories in general, ignore files tagged as skipped
    if ( ($file !~ /^\.\/\.git/) && (-f $file) && ($tagLetter ne 'S') ){
        if ($file =~ /\.user$/) { push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.cache$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.tlog$/) { push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.db$/) { push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.log$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.txt$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.suo$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.pch$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.mdp$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.ncb$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.clw$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.obj$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.exe$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.aps$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.cpl$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.awk$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.exp$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.lib$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.idb$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.opt$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.pdb$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.map$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.res$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.ilk$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.scc$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.bsc$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.sbr$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.dll$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.tlb$/){ push @contentSkip, $file; say "skipping $file"; }
    }
}
