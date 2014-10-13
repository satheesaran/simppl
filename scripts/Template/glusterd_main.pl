#!/usr/bin/perl


#------------------------------------------------------------------------------
# Objective : Automation of glusterd test cases
# Author    : Satheesaran Sundaramoorthi <sasundar@redhat.com>
# Date      : 18-Nov-2014
#------------------------------------------------------------------------------

#----------------------------
# Pragmatic modules
#----------------------------
use strict;
use warnings;

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

#----------------------------
# Test Suites to include
#----------------------------
require "Test_singlehost_Suite.pl";

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
    my @hosts;                # array to contain hosts objects

    # Create a Log object
    $log = new Logger();

    # the hosts are added to the array @hosts.
    # Array index starts from zero and so one less than the number of entry in 
    # the array becomes index to the host obj
    # For.eg. if this entry 10.70.x.x is 4th entry in the hosts.conf file
    # Then, $hosts[3] - gets you the corresponding host object.
    push( @hosts, new Host("10.70.37.133") );

    # Create a seperate log for console 
    # Call the Test Handler routine
    Test_singlehost_Suite( $log, @hosts );

    # Document the results
    
    # Close the log object
    $log->close();
}

#----------------------------
# Test Execution Starts here
# Call glusterd_main func
#----------------------------
&glusterd_main();
