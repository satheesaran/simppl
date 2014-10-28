#------------------------------------------------------------------------------
# Function Name : test001
# Description   : Check whether the glusterd service is running automatically
#------------------------------------------------------------------------------
sub test001 {
    my $log  = shift;
    my $host = shift;
    my %stat;

    # Start Logging and it increments the total test
    $log->start( "test001 - check glusterd is chkconfiged to ON" );

    # Execute chkconfig command
    ($status,$result) = $host->execute("chkconfig --list glusterd");
    if( $status == 0 ) {
        my @content = split( /\s+/, $result );
        for( @content ) {
            if( $_ =~ m/:/ ) {
                my $key = $`;
                my $val = $';
                chomp( $key );
                chomp( $val );
                $stat{$key} = $val;
            }
        }
    } else {
        $log->fail( "Error while executing chkconfig command" );
        goto ENDL;
    }

    # Run levels 0,1,6 should be OFF
    if ( ($stat{0} =~ m/off/i) and 
         ($stat{1} =~ m/off/i) and 
         ($stat{6} =~ m/off/i) ) {
        $log->comment( "glusterd was chkconfiged to OFF in run-levels 0,1,6" );
    } else {
        $log->fail( "glusterd was chkconfiged to ON on run-levels 0,1,6" );
        goto ENDL;
    } 

    # Run levels 2,3,4,5 should be ON
    if ( ($stat{2} =~ m/on/i) and 
         ($stat{3} =~ m/on/i) and 
         ($stat{4} =~ m/on/i) and 
         ($stat{5} =~ m/on/i)) {
        $log->comment( "glusterd was chkconfiged to ON in run-levels 2,3,4,5" );
    } else {
        $log->fail( "glusterd was chkconfiged to OFF on run-levels 2,3,4,5" );
        goto ENDL;
    }

    # Pass the test and it increments the pass test count
    $log->pass( "test001 - glusterd was chkconfiged as expected" );
    ENDL:
}

#------------------------------------------------------------------------------
# Function Name : test002
# Description   : glusterd should create lockfile when its started & delete the
#                 same when its not running
#------------------------------------------------------------------------------
sub test002 {
    my $log    = shift;
    my $host   = shift;
    my $status = undef;
    my $res    = undef;

    # Start Logging and it increments the total test
    $log->start( "test002 - check glusterd lockfile" );
    
    # Start GlusterD service, if its not running earlier
    ( $status, $res ) = $host->execute( "pidof glusterd" );
    if( $status != 0 ) {
        $log->comment( "Starting glusterd as its not running" );
        $host->serviceStart( "glusterd" );
    }

    # Check for the lock file
    $status = undef;
    $status = $host->isFilePresent( "/var/lock/subsys/glusterd" );
    if( $status == 1 ) {
        $log->comment( "Lock file is available" );
    } else {
        $log->fail( "Lock file is not available in /var/lock/subsys/glusterd" );
        goto ENDL;
    }

    # Stop glusterd on the node
    $status = undef;
    $log->comment( "Stopping glusterd" );
    $host->serviceStop( "glusterd" );
    

    #Verifying whether glusterd is really stopped
    $status = undef;
    $res = undef;
    ($status, $res) = $host->execute( "pidof glusterd" );
    if( $status != 0 ) {
        $log->comment( "glusterd was stopped" );
    } else {
        $log->fail( "glusterd was not stopped" );
        goto ENDL;
    }
    
    # Check for the lock file
    $status = undef;
    $status = $host->isFilePresent( "/var/lock/subsys/glusterd" );
    if( $status != 0 ) {
        $log->fail( "Lock file is available even after stopping glusterd" );
        goto ENDL;
    } else {
        $log->comment( "Lock file is not available after stopping glusterd" );
    }

    # Pass the test and it increments the pass test count
    $log->pass( "test002 - Lock file is present when glusterd is started !!" );

    ENDL:
}

#------------------------------------------------------------------------------
# Function Name : Test_BasicTest01_Suite
# Description   : This is the test handler for single node glusterd cases
# Args          : host object, log object
# Return Values : None
#------------------------------------------------------------------------------
sub Test_BasicTest01_Suite {
    $log  = shift;
    @hosts = @_;

    # Only one RHSS Node is required for single host test suite
    $host = $hosts[0];
    &test001( $log, $host);
    &test002( $log, $host);
}
return 1;
