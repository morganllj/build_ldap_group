#!/usr/bin/perl -w
# 
# morgan@morganjones.org
# build an ldap group with the results of an aribitrary group
# this is a work-around for application that doesn't support dynamic groups

use strict;
use Net::LDAP;
use Data::Dumper;
use Getopt::Std;

sub print_usage();

my %opts;
getopts('hc:', \%opts);

$opts{c} || print_usage();
$opts{h} && print_usage();

require $opts{c};

print "starting at ", `date`, "\n";;

our $filter;
our $group;
our $binddn;
our $bindpass;
our $base;
our $host;


my $ldap = Net::LDAP->new($host);
my $r = $ldap->bind(dn=>$binddn, password=>$bindpass);
$r->code && die "unable to bind to ldap: ", $r->error;


print "searching ", $filter, "...\n";
my $sr = $ldap->search(base=>$base, 
		       filter=>$filter);
$sr->code && die $sr->error;

my $lref = $sr->as_struct;

my @members;
for my $dn (keys %$lref) {
    push @members, $dn;
}

print "returned ", $#members + 1, " users\n";
print "\nmodifying ", $group, "...\n";

my $mr = $ldap->modify ($group,
			changes => [
				  replace => [ "uniqueMember" => [@members] ]
				   ] );
$mr->code && die "modify failed: ", $mr->error;

print "\nfinished at ", `date`;


sub print_usage() {
    print "usage: $0 -c <config file> \n";
    print "\t-c <config file> configuration file\n";
    print "\n";
    exit;
}
