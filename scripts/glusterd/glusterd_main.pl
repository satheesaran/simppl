#!/usr/bin/perl

#------------------------------------------------------------------------------
# Objective : Automation of glusterd test cases
# Author    : Satheesaran Sundaramoorthi <sasundar@redhat.com>
# Date      : 18-Nov-2013
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
require "Test_Configuration_Suite.pl";

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

#------------------------------------------------------------------------------
# Function Name : TestCleanup
# Description   : Cleans up the required environment for all the tests
# Args          : None
# Return Value  : None
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function Name : glusterd_main 
# Description   : This the main function which calls other test cases
# Args          : None
# Return Value  : None
#------------------------------------------------------------------------------
sub glusterd_main {
    # Generate LogFile Name
    my $log;                  # to contain log object
    my @servers;
    my @clients;
    my $hostfh;
    
    # Create a Log object
    $log = new Logger();

    # The hosts information are taken in from 'hosts' file
    eval {
        open( $hostfh, "hosts" ) or die( "No hosts founds" );
    };
    if( $@ ) {
        $log->error( "Error: $@ : add hosts to hosts file in local dir" );
        print(" Error: $@ : add hosts to hosts file in local dir\n\n" );
        $log->close();
        exit(1);
    }

    # Read the host info from the local host file
    while( <$hostfh> ) {
        if( m/:server/i ) {
            push( @servers, new Host($`) );
        } elsif (m/:client/i ) {
            push( @clients, new Host($`) );
        }
    }
    close( $hostfh );

    # Perform setup, which creates the bricks, volumes,etc
    # as of now setup is ignored, as no volume is actually required
    #$host->setup();

    # Call the Test Handler routine
    Test_Configuration_Suite( $log, @servers );

    # Document the results
    $log->printResults();

    # Close Host objects
    for( @servers ) {
        $_->destroy();
    }

    # Close the log object
    $log->close();
}

#----------------------------
# Test Execution Starts here
# Call glusterd_main func
#----------------------------
&glusterd_main();
