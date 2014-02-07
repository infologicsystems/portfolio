#!/bin/csh -f
# %W% %G%
# File: 
# Last Modification: yy/mm/dd
# Author: Michael Moscovitch
# Description:
# Project:
# History:
#
# argument parsing routine
set state=0
set opts
while ($#argv > 0)
	set arg="$argv[1]"
	shift argv
#	get argument if there is one
	switch ($state)
	case "-mode":
#		set the value of mode
		set mode="$arg"
		breaksw
	default:
		breaksw
	endsw
	switch ($state)
	case "0":
#		looking for keyword, go to next switch
		breaksw
	default:
#		got argument for keyword above, go back to while
		set state=0
		continue
	endsw
#	search for keyword
	switch ("$arg")
	case "-mode":
		set state="$arg"
		breaksw
	case "-flag":
#		define the flag1 variable
		set flag1
		breaksw
	case "-help":
	case "-usage":
#		display some help
		echo "usage:"
		echo " example1 [-mode mode] [-flag]"
		exit 0
		breaksw
	default:
		set opts=($opts "$arg")
		breaksw
	endsw
end

