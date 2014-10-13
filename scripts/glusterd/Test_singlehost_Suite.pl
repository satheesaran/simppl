#------------------------------------------------------------------------------
# Function Name : test001
# Description   :
# Args          :
# Return Value  :
#------------------------------------------------------------------------------
sub test001 {
    my $log  = shift;
    my $host = shift;

    # Start Logging and it increments the total test
    $log->start( "test001 - check glusterd" );

    # Pass the test and it increments the pass test count
    $log->pass( "test001 passed !!" );
}

#------------------------------------------------------------------------------
# Function Name : test002
# Description   :
# Args          :
# Return Value  :
#------------------------------------------------------------------------------
sub test002 {
    my $log  = shift;
    my $host = shift;

    # Start Logging and it increments the total test
    $log->start( "test002 - check glusterd" );
    
    $host->execute( "service glusterd status" );

    # Pass the test and it increments the pass test count
    $log->fail( "test002 failed !!" );

}


#------------------------------------------------------------------------------
# Function Name : Test_singlehost_Suite
# Description   : This is the test handler for single node glusterd cases
# Args          : host object, log object
# Return Values : None
#------------------------------------------------------------------------------
sub Test_singlehost_Suite {
    $log  = shift;
    @hosts = @_;

    # Only one RHSS Node is required for single host test suite
    $host = $hosts[0];

    &test001( $log, $host);
    &test002( $log, $host);
}

return 1;
