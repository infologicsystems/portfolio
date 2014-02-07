#!/usr/local/bin/perl
 eval "exec /usr/local/bin/perl -S $0 $*"
    if $running_under_some_shell;
			# this emulates #! processing on NIH machines.
			# (remove #! line above if indigestible)

#eval '$'.$1.'$2;' while $ARGV[0] =~ /^([A-Za-z_]+=)(.*)/ && shift;
			# process any FOO=bar switches
# %W% %G%
# File: 
# Last Modification: yy/mm/dd
# Author: Michael Moscovitch
# Description:
# Project:
# History:
#
&init();
&skel'main();
exit(0);

sub init {
    local($tmp,@perlpath,$home);
    $[ = 0;			# set array base to 0
#    $, = ' ';			# set output field separator
#    $\ = "\n";			# set output record separator
    $| = 1;			# force flush after every write

    $ENV{'PATH'} = '/bin:/usr/bin';
    $ENV{'SHELL'} = '/bin/sh' if $ENV{'SHELL'} ne '';
    $ENV{'IFS'} = '' if $ENV{'IFS'} ne '';

    $tmp=$ENV{'PERLPATH'};
    if (defined($tmp)) {
	@perlpath = split(':',$tmp,99);
#	print "@perlpath\n";
	@INC=(@INC,@perlpath);
    }
}

package skel;

sub main {
#	require 'simlib.pl';

	if ($#ARGV < $[) {
		print "usage: \n";
		exit 0;	
	}
	&defaults();
	&argparse(@ARGV);

#	$startdir = &simlib'getpwd();	# directory in which process was invoked

	optloop: {
	}
	exit(0);
}


sub defaults {
	$true=1;
	$false=0;
	$verbose=$false;
}

# parse command line arguments
sub argparse {
	local(@arglist) = @_;
	local($state) = "0";
	local($dummy);
	@opts = ();
	foreach $arg (@arglist) {
		#print $arg,"\n";
		if ($state ne "0") {
			if ($state eq "-noop") { $dummy=$arg; }
			elsif ($state eq "-noop") { $dummy=$arg; }
			$state="0";
			next;
		}
		if ($arg eq "-v") { $verbose=$true; }
		elsif ($arg eq "-noop") { $state=$arg; }
		else { @opts[$#opts + 1]=$arg; }
	}
}

#
