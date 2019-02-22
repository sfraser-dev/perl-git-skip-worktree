#!/usr/bin/perl -w
# STEPS:
# 1. get all code from VSS in git wrapper
# 2. run this script (assume unchanged user specified files; visual studio not running)
# 3. add template git ignore file (this won't ignore files from step 1, it'll ignore newly created build files)
# 4. clean all and then rebuild all
# 5. run this script to 'assume unchanged' files that building changes (.DLL, .pdb, .log, .txt, .cache, etc ...)
#
# GIT REPO STRUCTURE: 
# Best to have one "pure" repo containing all VSS code.
# The "pure" repo should not have an ignore file (nor assumeUnchanged files).
# An ignore file in "pure" would, for example, ignore new .libs/.dlls added by other users.
# My working repos should pull from the "pure" repo and then push elsewhere (eg: debian -> laptop -> VSS).
#
# TRACK: 
# git keeps a record of all files that it is assuming unchanged locally ("assume unchanged record")
# run assumeUnchangedReverse.pl to remove files from the "assume unchanged record"
#
# NOTES:  
# Trying different solutions to make git VSS code wrapper cleaner as VSS has many binary files in it that change after building
#
# i) adding many files to 'worktree skip record' bloats .git/ and causes malloc/mmap errors on my 32-bit 4GB ram DVR";
#
# ii) using Git LFS can separate selected large files but Git then become unusably slow on Windows
# 
# iii) .git/info/exclude is a local ignore file; but it will not ignore files that are already in the repo
# (even creating "empty" repo, setting up exclude files, only files added locally will be ignored (not files added into the repo from laptop)
#
# iv) like note three, .gitignore only ignores files that are not already in the repo (files commited previously remain tracked)
#
# v) using '--assume-unchanged' changes tortoise git icon from green tick to grey tick
#
# vi) if getting a copy/paste of VSS code from another developer can just use the ignore file (commit first)
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

# Use gitigore from the start!
my $userSpecified = 1;

############### run this after a clean all / rebuild all (to see what binary files change after a rebuild
############### add files that have changed since last build to "assume unchanged record" ###############
my $theFile= "assumeUnchanged.textlog";
# list all files that have changed since last build
system("git diff --name-only >$theFile");

# read each line from the file into an array
open my $handleIn, '<', $theFile or die "Could not open file '$theFile' $!";
chomp (my @linesIn = <$handleIn>);
close $handleIn;
# process each line from the array (add each file to the "assume unchanged record")
foreach my $line (@linesIn) {
    chomp($line);
    say "";
    say "DIFF: $line";
    # don't add changed source files to the "assume unchanged record"; exit script if source file found  
    ($name,$path,$suffix) = fileparse($line,qr"\..[^.]*$");
    if (($suffix eq ".cs") || ($suffix eq ".cpp") || ($suffix eq ".hpp") || ($suffix eq ".h") || ($suffix eq ".pl") || ($suffix eq ".bat") || ($suffix eq ".odt")) {
        say $name;
        say $path;
        say $suffix;
        # exception "*.i.cs": not a source file, don't exit (add to "assume unchanged record")
        if ((substr($name,-2) eq ".i") && ($suffix eq ".cs")){
            say "'.i.cs' extension; adding to 'assume unchanged record'";
        }
        elsif ((substr($name,-2) eq ".g") && ($suffix eq ".cs")){
            say "'.g.cs' extension; adding to 'assume unchanged record'";
        }
        elsif ((substr($name,-2) eq "_h") && ($suffix eq ".h")){
            say "'_h.h' extension; adding to 'assume unchanged record'";
        }
        else {
            say "WARNING: source file found ... not adding to 'assume unchanged record' ... exiting";
            exit 1;
        }
    }
    if (-d $line) { say "DIFFDIR: $line"; next; }
    # add file to "assume unchanged record"; encase filename / filepath in quotes to handle spaces
    system("git update-index --assume-unchanged \"$line\"");
}

############### user specified files to be added to "assume unchanged record" ###############
if ($userSpecified == 1){
    say "";
    say "SKIP: user specified file";
    # find all files (that user wishes to ignore locally) from current and sub directories
    find( \&filesWanted, '.'); 
    # process each line from the array (add each file to the "assume unchanged record")
    foreach my $line (@contentSkip) {
        chomp($line);
        # remove the "./" at the start of each line (indicating a skipped worktree file)
        my $n=2;
        $line =~ s/^.{$n}//s;
        say "USER: $line";
        # add file to "assume unchanged record"; encase filename / filepath in quotes to handle spaces
        system("git update-index --assume-unchanged \"$line\"");
    }
}

exit 0;

############### sub
sub filesWanted{
    my $res;
    my $tagLetter;
    my $file = $File::Find::name;
    if (-f $file) {
        $res = `git ls-files -v $file`; 
        $tagLetter = substr($res, 0, 1); # assume unchanged?
    }
    else {
        $tagLetter = "directory, don't analyse me";
    }
    say "found $file"; 
    if ( ($tagLetter ne 'h') ){
        if ($file =~ /\.zip$/) { push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /_h\.h$/) { push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.user$/) { push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.cache$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.db$/) { push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.tlog$/) { push @contentSkip, $file; say "skipping $file"; }
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
        if ($file =~ /\.bin$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.DLL$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.nupkg$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.sbr$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.pdf$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.iobj$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.ipch$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /\.chm$/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /SampleGrabber_dlldata\.c/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /VisualDVR\.exe\.embed\.manifest/){ push @contentSkip, $file; say "skipping $file"; }
        if ($file =~ /VisualDVR_manifest\.rc/){ push @contentSkip, $file; say "skipping $file"; }
        }
}
