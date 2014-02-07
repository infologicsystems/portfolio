# 
#-------------------------------------------------------------------------
# Author: Mike <mike-src@users.sourceforge.net>
#
# Last modified: 2003/03/18
#
# File header based on Util.pm
#  Developed by VPOP Technologies, Inc. <admin@vpop.net>
#  Author: Paul Sisson <psisson@users.sourceforge.net>
#-------------------------------------------------------------------------
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation,
# Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#-------------------------------------------------------------------------
# See user documentation at the end of this file. Search for =head
#-------------------------------------------------------------------------

package Payment::Tax;
require 5.006001;

use Carp;

use strict;
use vars qw($VERSION $IP_REGEX $CUR_REGEX %CONFIG);

($VERSION) = '$Revision: 1.4 $' =~ /Revision: ([\d.]+)/;

#=======================================================================
# static class variables

$IP_REGEX  = "\\d+\\.\\d+\\.\\d+\\.\\d+";
$CUR_REGEX = "\\d+|\\d+\\.\\d{1,2}|\\.\\d{1,2}";

#=======================================================================
# new() - constructor

sub new {
	my $pkg   = shift;
	my $class = ref($pkg) || $pkg;
	my %args  = @_;
    my @req   = qw(config);
	my $self = {};

    if (my @missing = grep { !defined($args{$_}) } @req) {
        _croak("Missing critical args: " .join(', ', @missing));
    }

	# get config values
	unless (ref($args{config}) eq 'HASH') {
        _croak("Arg 'config' is not a hashref");
	}

	%CONFIG = %{$args{config}};

	bless $self, $class;

	$self->init();

	return $self;
}

sub init {
    my($ob) = @_;

    $ob->{debug}=0;

}

#=======================================================================
# PUBLIC METHODS
#=======================================================================

# taxtable_prop ( country, state, prop )
# returns: value. state value overrides country value
sub taxtable_prop {
    my($ob,$country,$state,$prop) = @_;

    my($v,$v1,$v2);

    $v1 = $CONFIG{taxtable}{uc $country}{$prop};
    $v2 = $CONFIG{taxtable}{uc $country}{uc $state}{$prop};

    if ($ob->{debug}) {
	printf(STDERR "taxtable %s %s [%s] [%s]\n",$country,$state,$v1,$v2);
    }

    if ($v2 eq "") {
	$v=$v1;
    } else {
	$v=$v2;
    }

    return $v;

}

# tax1_rate ( country, state )
# returns: tax rate percentage
sub tax1_rate {
    my($ob,$country,$state) = @_;

    my($tm,$taxr);

    $tm = $ob->tax1_mode($country,$state);

    if ($tm==0) {
	$taxr = 0;
    } else {
	$taxr = $ob->taxtable_prop($country,$state,"rate1");
    }
    return $taxr;
}

# tax1_name ( country, state )
# returns: tax name
sub tax1_name {
    my($ob,$country,$state) = @_;

    return $ob->taxtable_prop($country,$state,"taxname1");
}

# tax1_mode ( country, state )
# returns: tax mode
sub tax1_mode {
    my($ob,$country,$state) = @_;

    return $ob->taxtable_prop($country,$state,"taxmode1");
}

# tax2_rate ( country, state )
# returns: tax rate percentage
sub tax2_rate {
    my($ob,$country,$state) = @_;


    my($tm,$taxr);

    $tm = $ob->tax2_mode($country,$state);

    if ($tm==0) {
	$taxr = 0;
    } else {
	$taxr = $ob->taxtable_prop($country,$state,"rate2");
    }
    return $taxr;
}

# tax2_name ( country, state )
# returns: tax name
sub tax2_name {
    my($ob,$country,$state) = @_;

    return $ob->taxtable_prop($country,$state,"taxname2");
}

# tax2_mode ( country, state )
# returns: tax mode
sub tax2_mode {
    my($ob,$country,$state) = @_;

    return $ob->taxtable_prop($country,$state,"taxmode2");
}

#=======================================================================

sub get_order_total {
    my($ob,$item_cost,$num_items,$country,$state) = @_;

    my($taxr1,$taxr2,$tm2,$tax1,$tax2,$total,$subtotal);
    my($tax1name,$tax2name);

    $taxr1 = $ob->tax1_rate($country,$state);
    $taxr2 = $ob->tax2_rate($country,$state);
    $tm2 = $ob->tax2_mode($country,$state);

    $tax1name = $ob->tax1_name($country,$state);
    $tax2name = $ob->tax2_name($country,$state);

    $subtotal    = fixcalc($item_cost * $num_items);
    $tax1 = $taxr1 ? $ob->get_tax($subtotal,$taxr1) : 0;
    if ($tm2==1) {
	$tax2 = $taxr2 ? $ob->get_tax($subtotal,$taxr2) : 0;
    } elsif ($tm2==2) {
	$tax2 = $taxr2 ? $ob->get_tax($subtotal+$tax1,$taxr2) : 0;
    }

    $total       = fixcalc($subtotal+$tax1+$tax2);

    return { tax1   => $tax1,
             tax2 => $tax2,
             tax1name => $tax1name,
             tax2name => $tax2name,
             subtotal       => $subtotal,
             total       => $total,
           };
}

# calculate the tax on the subtotal of a sale.
# this is the routine that you would normally call from 
# your application to do all the work
# the results are returned as a pointer to a hash.
sub calc_tax {
    my($ob,$amount,$country,$state) = @_;

    my($taxr1,$taxr2,$tm2,$tax1,$tax2,$total,$subtotal);
    my($tax1name,$tax2name);

    $taxr1 = $ob->tax1_rate($country,$state);
    $taxr2 = $ob->tax2_rate($country,$state);
    $tm2 = $ob->tax2_mode($country,$state);

    $tax1name = $ob->tax1_name($country,$state);
    $tax2name = $ob->tax2_name($country,$state);

    $subtotal    = fixcalc($amount);
    $tax1 = $taxr1 ? $ob->get_tax($subtotal,$taxr1) : 0;
    if ($tm2==1) {
	$tax2 = $taxr2 ? $ob->get_tax($subtotal,$taxr2) : 0;
    } elsif ($tm2==2) {
	$tax2 = $taxr2 ? $ob->get_tax($subtotal+$tax1,$taxr2) : 0;
    }

    $total       = fixcalc($subtotal+$tax1+$tax2);

    if ($ob->{debug}) {
	printf(STDERR "calc_tax %s %s %s\n",$tax1,$tax2,$total);
    }

    return { tax1 => $tax1,
             tax2 => $tax2,
             tax1name => $tax1name,
             tax2name => $tax2name,
             subtotal       => $subtotal,
             total       => $total,
           };
}


# round floating point values to 2 decimal places.
sub fixcalc {
    my($v) = @_;

    return sprintf("%.2f",$v);
}


#=======================================================================
# get_tax() - 

sub get_tax {
	my $self = shift;
    my ($total,$tax) = @_;

    return 0 unless $total && $tax;
    return sprintf("%.2f", $total * ($tax / 100));
}

#=========================================================================
# _croak() - handle errors

sub _croak {
    my $errmsg = shift;
    my ($pkg,$file,$line,$sub) = caller(1);

    Carp::croak "$pkg::$sub() line $line: $errmsg";
}

1;
=pod

=head1 SYNOPSIS

This module provides functions to calculate sales taxes. The tax rates are
defined in a tax table. The rate is determined from both the country and state.
It is also possible to define the second tax to be applied to the first tax
by setting the taxmode to the value 2 in the tax table.
(eg. GST/QST)
Combined taxes such as the HST are also supported by overriding the
tax1 rate with a new value for specific states/provinces.

This module was developed to provide more sophisticated sales tax calculation
routines. They were designed for the tax system in Canada but they should be
able to handle most countries and can easily be modified.

The descriptive names of the taxes can also be changed so that they
will display appropriately for each state/province when printed.

It is the responsibility of the user to verify that they have the
correct tax rates defined in the table.

The country and states are typically defined using the 2 letter codes.

=cut

