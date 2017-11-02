#!/usr/bin/env perl
use File::Copy qw(copy);
use File::Basename;
use Cwd 'abs_path';

$homedir=$ENV{HOME};
$sourcedir=dirname(abs_path($0));

$manifest="$sourcedir/manifest.conf";

open (FH,$manifest) or die "Cannot read manifest file manifest.conf!\n";


printf "* Re-creating files \n";
print "* Target = $homedir \n";
print "* Source = $sourcedir \n\n";

while (<FH>) {
	chomp;
	next if /^\#/;
	next if /^\s*$/;

	my ($action, $source, $target)=split /\s+/;

	$target =~ s/~/$homedir/;
	$source = "$sourcedir/$source";

	warn "Cannot read $source" if ! -r $source;

	if ($action eq "symlink") {
		printf "- Linking $source to $target\n";

		if ( -l "$target" ) { 
			unlink $target or warn "X Existing $target link cannot be removed."; 
		} elsif ( -e "$target" ) { 
			warn "X Existing $target is a file and will not be removed."; 
			next;
		}

		symlink($source, $target) or warn "X Cannot symlink $source to $target \n";

	} elsif ($action eq "copy") {

		printf "- Copying $source to $target\n";
		copy $source, $target or warn "X Cannot copy $source to $target \n";	

	} else {

		warn "X No clue on how to $action $source to $target \n";

	}	
}
