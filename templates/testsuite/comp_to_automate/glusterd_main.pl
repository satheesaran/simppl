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
# Include Custom libraries
# directories
#----------------------------
use lib "../../lib";

#----------------------------
# Custom modules
#----------------------------
use Logger;            # Contains useful functions for logging
use SSHConnect;        # For SSH connection mechanisms

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
 
    # Default options for test variables ( count, suite-to-run ) 
   
    # Create SSH Connection object to hosts

    # Call the Test Handler routine

    # Document the results
    
    # Close the log object
    $log->close();
}

#----------------------------
# Test Execution Starts here
# Call glusterd_main func
#----------------------------
&glusterd_main();
