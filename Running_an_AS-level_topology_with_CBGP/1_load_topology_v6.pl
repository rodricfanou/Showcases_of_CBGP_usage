#!/usr/bin/perl
# ===================================================================
# @(#)perl-example.pl
#
# @author Roderick Fanou
# @date Feb 15, 2016
# @lastdate March 2, 2018
# ===================================================================

use strict;
use lib ".";

use CBGP 0.3;

# -----[ perl_core ]-------------------------------------------------
# Simple example that feeds C-BGP with a 2 router configuration then
# dumps the BGP routing tables
# -------------------------------------------------------------------
sub perl_core($)
{
	my $cbgp = shift;
	open (OUTFILE, ">>output_config.log");
    	# Feed configuration
    	$cbgp->send("set autoflush on\n");
    	$cbgp->send("bgp topology load 01_topology_to_load.txt\n");
    	$cbgp->send("bgp topology install\n");
    	$cbgp->send("bgp topology policies\n");
    	$cbgp->send("bgp topology run\n");
    	$cbgp->send("sim run\n");
    
    
	print "Topology loaded \n";
	open(NETSFILE,"<02_networks_to_add.unix.txt");
	#my $first = $ARGV[0];
	my $i = 0; 
	
	while (<NETSFILE>)
	{
		$i++;
		#next if $i < $first;
		my($netsline) = $_;
		#chomp($netsline);
        print("$netsline\n");
		$cbgp->send("$netsline\n");
		$cbgp->send("sim run\n");
		#last if ($i==$first+$ARGV[1]);
	}
	close(NETSFILE);

    
	#print "Networks added \n";
    $cbgp->send("sim run\n");
	print "Simulation executed\n";
	#print "Configuration OK\n";    
    $cbgp->send("print \"CONFIGURATION OK\\n\"\n");
	# Expect "CONFIGURATION OK"
    $_= $cbgp->expect(1);
    chomp;
    if ($_ ne "CONFIGURATION OK") {
        die "Beeeeeh !!!";
    }
    print "Configuration OK\n";



    	# Request a routing table dump
	$cbgp->send("bgp options show-mode mrt\n");

	open(MYINPUTFILE,"<ASes_in_topo.txt");
	my $j = 0;
        while (<MYINPUTFILE>)
	{
		$j++;

		my($line) = $_;
        chomp($line);
		#print($line); 
		$cbgp->send("bgp router $line show rib * --output=ribs/RIB-$line.txt\n");
	}
	close(MYINPUTFILE);


	print "Paths written \n";
}


# -----[ main ]------------------------------------------------------
# -------------------------------------------------------------------

my $cbgp= CBGP->new("/home/roderick/src/cbgp-2.3.2/src/cbgp");

$cbgp->spawn;

perl_core($cbgp);

$cbgp->finalize;

while (my $res= $cbgp->expect(0)) {
    print STDERR "Debug: expect \"$res\"\n";
}



