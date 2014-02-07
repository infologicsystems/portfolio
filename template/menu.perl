#!/usr/local/bin/perl
 eval "exec /usr/local/bin/perl -S $0 $*"
    if $running_under_some_shell;
			# this emulates #! processing on NIH machines.
			# (remove #! line above if indigestible)

#eval '$'.$1.'$2;' while $ARGV[0] =~ /^([A-Za-z_]+=)(.*)/ && shift;
			# process any FOO=bar switches
# %W% %G%
# File: menu
# Last Modification: 93/04/20
# Author: Michael Moscovitch
# Description:
# Project:
# History:
#
&init();
&menu'main();
exit(0);

sub init {
    local($tmp,@perlpath,$home);
    $[ = 0;			# set array base to 0
#    $, = ' ';			# set output field separator
#    $\ = "\n";			# set output record separator
    $| = 1;			# force flush after every write

#    $ENV{'PATH'} = '/bin:/usr/bin:/usr/local/bin';
    $ENV{'SHELL'} = '/bin/sh' if $ENV{'SHELL'} ne '';
    $ENV{'IFS'} = '' if $ENV{'IFS'} ne '';

    $tmp=$ENV{'PERLPATH'};
    if (defined($tmp)) {
	@perlpath = split(':',$tmp,99);
#	print "@perlpath\n";
	@INC=(@INC,@perlpath);
    }
}

package menu;

sub main {
#	require 'simlib.pl';

#	if ($#ARGV < $[) {
#		print "usage: \n";
#		exit 0;	
#	}
	&defaults();
	&argparse(@ARGV);

#	$startdir = &simlib'getpwd();	# directory in which process was invoked

	optloop: {
		&menu();
	}
	exit(0);
}


sub defaults {
	$true=1;
	$false=0;
	$verbose=$false;
	$debug=$false;
	$tmp="/var/tmp";
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
		elsif ($arg eq "-debug") { $debug=$true; }
		elsif ($arg eq "-noop") { $state=$arg; }
		else { @opts[$#opts + 1]=$arg; }
	}
}

#
# utilities front end menu
#
#


sub menu {
	local($selection,$more,$job);

	$job = &main_intro();

	$more = $true;

	while ($more) {
		$selection = &tolower(&main_menu($job));

		if ("$selection" eq "x") {
			$more = $false;
		} elsif ("$selection" eq "1") { # function 1
			&menu_option_1($job);
		} elsif ("$selection" eq "2") { # function 2
			&menu_option_2($job);
		} else {
		}
	}

	exit 0;
}


#
#      ------------ Display  Menu --------------
#
sub main_intro {
	local($s);

	printf("\n");
	printf("#6CAE Utilities\n");
	printf("#6-------------------------------\n");
	printf("\n");

	$s = &get_job_number();
	return $s;
}

#
# get job number
#
sub get_job_number {
	local($s,$more,$defjob);

	$more = $true;

	$defjob = &guess_job_number();

	while ($more) {
		printf(" Enter the Job Number");
		if ($defjob eq "") {
			printf(" ==> ");
			$s = &readln();
		} else {
			printf(" [%s] ",$defjob);
			$s = &readln();
			if ($s == "") {
				$s = $defjob;
			}
		}
		if (&verify_job_number($s)) {
			printf("\n");
			printf("That does not look like a valid job number\n");
			printf("Please enter only the first 8 digits\n");
			printf("\n");
 		} else {
			$more = $false;
		}
	}
	printf("\n");
	return $s;
}

sub verify_job_number {
	local($job) = @_;

	if (length($job) != 8) {
		return 1;
	}
	if ($job =~ /^\d\d\d\d\d\d\d\d/) {
		return 0;
	}
	return 1;
}

sub main_menu {
	local($job) = @_;
	local($s);

print <<EOF;

#6Utilities Main Menu
#6********************************

      Current job: $job

      Function 1                                               < 1 >

      Function 2                                               < 2 >

      Exit                                                     < X >

EOF

	printf("Select From Above Options ? ");
	$s = &readln();	
	printf("\n");
	return $s;
}

sub menu_option_1 {
	printf("option 1\n");
}

sub menu_option_2 {
	printf("option 2\n");
}

#
# option not available message
#

sub option_notavailable {
	printf("This option is not available yet.\n");
}

#
# utility functions
#

sub fnewer {
	local($f1,$f2) = @_;
	local(@s1,@s2);

	@s1 = stat($infile);
	@s2 = stat($outfile);

#	printf("%d %d\n",$s1[9],$s2[9]);}
	if ($s1[9] >= $s2[9]) {
		return $true;
	}
	return $false;
}

sub check_file {
	local($infile,$outfile) = @_;

	if (! -e $infile) {
			return 1;
	}

	if (-e $outfile) {

		if (&fnewer($infile,$outfile)) {
		# check if file is newer
			system("cp $infile $outfile");
		}
	} else {
		system("cp $infile $outfile");
	}
	return 0;
}


sub boolean_prompt {
	local($prompt) = @_;
	local($l,$more);

	$more = $true;

	while ($more) {
		printf("%s",$prompt);
		$l = &readln();
		$l = &tolower($l);
		if ($l eq "y" || $l eq "yes") {
			return $true;
		} elsif ($l eq "n" || $l eq "no") {
			return $false;
		}
	}
	return $false;
}

sub readln {
	local($l,$c,$more);
	$l = "";
	$c = "";
	$more = $true;
	while ($more) {
		$c = getc;
		if ($c ne "\n") {
			$l = $l . $c;
		} else {
			$more = $false;
		}
	}
	return $l;
}

sub tolower {
	local($s) = @_;
	$s =~ y/A-Z/a-z/;
	return $s;
}

sub getpwd {
        local($dir);

        chop($dir = `pwd`);
        return $dir;
}


# guess the job number from the current directory path
sub guess_job_number {
	local($cwd,$d);
	$cwd = &getpwd();

	# search the directory patch backwards until we find
	# something that looks like a job number
	foreach $d (reverse(split('/',$cwd))) {
		if (&verify_job_number($d) == 0) {
			return $d;
		}
	}
	# if we don't find anything, then return empty string
	return "";
}

#
#
#

sub ftp_put {
	local($host,$user,$password,$dir,$file,$destfile) = @_;

	# check if file exists
	if (-e $file) {
		# transfer to host
		printf("Opening connection to %s\n",$host) if $verbose;
		open(P1,"|$ftp -n $host");
		printf(P1 "user $user $password\n");
		if ($dir ne "") {
			printf(P1 "cd %s\n",$dir);
		}
		printf(P1 "binary\n");
		printf(P1 "put %s %s\n",$file,$destfile);
		printf(P1 "bye\n");
		close(P1);
		if ($status == 0) {
			return 0;
		} else {
			return 2;
		}
	} else {
		return 1;
	}
	return 0;
}
