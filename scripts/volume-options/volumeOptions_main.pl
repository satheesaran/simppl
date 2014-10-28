#!/usr/bin/perl

#------------------------------------------------------------------------------
# Objective : Automation of test cases related to volume options
# Author    : Satheesaran Sundaramoorthi <sasundar@redhat.com>
# Date      : 27-Oct-2014
#------------------------------------------------------------------------------

#----------------------------
# Pragmatic modules
#----------------------------
use strict;
use warnings;
use Data::Dumper;

#----------------------------
# General Modules
#----------------------------
use FindBin;

#----------------------------
# Include Custom libraries
# directories
#----------------------------
BEGIN {
    my $cwd = $FindBin::Bin;
    chdir($cwd);
    use lib "../../lib";
}

#----------------------------
# Custom modules
#----------------------------
use Logger;            # Contains useful functions for logging
use Host;              # For SSH connection mechanisms
use Volume;

#----------------------------
# Test Suites to include
#----------------------------
# Add more suites here. Suites are the collection of test cases
require "Test_BasicTest01_Suite.pl";

#----------------------------
# Global Constants
#----------------------------

#----------------------------
# Global Variables
#----------------------------

#----------------------------
# Preloaded Modules
#----------------------------


#------------------------------------------------------------------------------
# Function Name : TestSetup
# Description   : Sets up the required environment for all the tests
# Args          : None
# Return Value  : None
#------------------------------------------------------------------------------
sub TestSetup {
    my $log    = shift;
    my @hosts  = @_;
    my $ret    = undef;
    my $host   = $hosts[0];
    my $status = undef;
    #-----------
    # Step-1 Create bricks, if not already present
    #-----------
    for my $host( @hosts ) {
        $log->comment( "Performing setup on host - ".$host->getHostName() );
        $ret = $host->setup();
        if( $ret == 0 ) {
            $log->comment( "Setup completed" );
        } else {
            $log->comment( "Setup failed, aborting the test run" );
            return 1;
        }
    }
   
    #--------------
    # Step-2 Clean volumes,bricks if they are already available
    #-------------
    my @vols = $host->getAllVolNames();
    if( @vols > 0 ) {
        $log->comment( "Cleaning Volumes" );
        $status = $host->purgeAllVolumes( \@hosts );   
        if( $status != 0 ) {
            return 1;
        }
    } else {
        $host->cleanAllBricks( @hosts );
    }

    return 0;
}

#------------------------------------------------------------------------------
# Function Name : TestCleanup
# Description   : Cleans up the required environment for all the tests
# Args          : None
# Return Value  : None
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function Name : volumeOptions_main 
# Description   : This the main function which calls other test cases
# Args          : None
# Return Value  : None
#------------------------------------------------------------------------------
sub volumeOptions_main {
    # Generate LogFile Name
    my $log;                  # to contain log object
    my @hosts;                # array to contain hosts objects
    
    #--------
    # step1 - Create a Log object
    #--------
    $log = new Logger();

    #--------
    # step2 - create host objects.
    #--------
    my $host = new Host("10.70.37.55") ;
    push( @hosts, $host );
    $host = new Host("10.70.37.216");
    push( @hosts, $host );

    #--------
    # step3 - perform setup on all the hosts
    #--------
    &TestSetup( $log, @hosts );
    
    #--------
    # step4 - call the test suites
    #--------
    # Call the Test Handler routine
    #Test_BasicTest01_Suite( $log, @hosts );

    #my $res = $host->startVolume( "test" );
    #if( $res ) {
    #    print "Error in stopping volume";
    #} else {
    #    print "volume stoppped";
    #}
    #my $ret = $host->createVolume(\@hosts,"vol",2);
    #if( $ret == 0 ) {
    #    print "Volume createad";
    #} else {
    #    print "volume creation faukled";
    #}
#
#    $ret = $host->createVolume(\@hosts,"vol2",2);
#    if( $ret == 0 ) {
#        print "Volume createad";
#    } else {
#        print "volume creation faukled";
#    }


    #my $ref = $host->{bricks};
    #print "ref is $ref";

    # Document the results
    $log->printResults();

    # Close the log object
    $log->close();
}

#----------------------------
# Test Execution Starts here
# Call glusterd_main func
#----------------------------
&volumeOptions_main();
