package Utils;
use strict;
use warnings;
use Net::SSH::Expect;

#-----------------------------------------------------------------------------
# Description     : This is the Module containing commonly used functions
# Total Functions : 7
# Functions       : serviceStart()
#                   serviceStop()
#                   serviceRestart()
#                   isFilePresent()
#                   getValueFromFile()
#                   isKeyInFile()
#                   execute()
# Author          : Satheesaran Sundaramoorthi <sasundar@redhat.com>
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Function Name : serviceStart
# Description   : starts the service in the machine 
# Args          : $service[in] - service to be started
# Return value  : returns 0 in case of success, 
#                 returns 1 in case of failure
#------------------------------------------------------------------------------
sub serviceStart {
    my $self    = shift;
    my $service = shift;
    my $res;
    my $status;

    ($status,$res) = $self->execute( "service $service start" );
    if( $res =~ m/started/i ) {
        return 0;
    } else {
        return 1;
    }

    # check for the return status
    if( $status == 0 ) {
        return 0;
    } else { 
        return 1;
    }
}

#------------------------------------------------------------------------------
# Function Name : serviceStop
# Description   : stops the service in the machine 
# Args          : $service[in] - service to be stopped
# Return value  : returns 0 in case of success, 
#                 returns 1 in case of failure
#------------------------------------------------------------------------------
sub serviceStop() {
    my $self    = shift;
    my $service = shift;
    my $res;
    my $status;

    ($status,$res) = $self->execute( "service $service stop" );
    if( $res =~ m/stopped/i ) {
        return 0;
    } else {
        return 1;
    }
    
    # check for the return status
    if( $status == 0 ) {
        return 0;
    } else { 
        return 1;
    }
}

#------------------------------------------------------------------------------
# Function Name : serviceRestart
# Description   : starts the service in the machine 
# Args          : $service[in] - service to be restarted
# Return value  : returns 0 in case of success, 
#                 returns 1 in case of failure
#------------------------------------------------------------------------------
sub serviceRestart {
    my $self    = shift;
    my $service = shift;
    my $res;
    my $status;

    ($status,$res) = $self->execute( "service $service restart" );
    
    # checking for return status
    if( $status == 0 ) {
        return 0;
    } else { 
        return 1;
    }
}

#------------------------------------------------------------------------------
# Function Name : isFilePresent
# Description   : checks whether the given file is available 
# Args          : $filename[in] - absolute file name of the file to be checked
# Return value  : returns 0 in case of failure, 
#                 returns 1 in case of success
#------------------------------------------------------------------------------
sub isFilePresent {
   my $self = shift;
   my $file = shift;
   my $res;
   my $status;

   ($status,$res) = $self->execute( "ls -l $file" );
   if( $res =~ m/no such file or directory/i ) {
       return 0;
   } else {
       return 1;
   }

   # check for return status
    if( $status == 0 ) {
        return 0;
    } else { 
        return 1;
    }
}

#------------------------------------------------------------------------------
# Function Name : getValueFromFile
# Description   : get the value for the key in file, when file contains 
#                 key-value as pairs
# Args          : $file[in] - absolute path of a filename
#                 $key[in]  - this is the key whose value is required
#                 $delimiter - this is the value which delimits key & value
# Return value  : $value, if the key is having a value, else returns undef
#------------------------------------------------------------------------------
sub getValueFromFile {
    my $self = shift;
    my $file = shift;
    my $key  = shift;
    my $delimiter = shift;
    my $res;
    my $value;
    my $status;

    ($status,$res) = $self->execute( "grep -i $key $file" );
    
    # check for return status
    if( $status != 0 ) {
        return undef;
    }

    # if delimiter is not defined, then the outcome is just to check for the
    # occurence of key and no value is required
    unless( defined($delimiter) ) {
       return 1
    }

    if( $res =~ m/$delimiter/ ) {
        $value = $';
        $value =~ s/^\s+//;
        $value =~ s/\s+$//;
        return $value;
    } else {
        return undef;
    }    

}

#------------------------------------------------------------------------------
# Function Name : isKeyInFile
# Description   : checks whether the key is just present in the file 
# Args          : $filename [in] - absolute path of a filename
#                 $key [in]      - key to be checked in the file
# Return value  : returns 1 if the key term is available in the file
#                 returns 0 in case of failure
#------------------------------------------------------------------------------
sub isKeyInFile {
    my $self = shift;
    my $file = shift;
    my $key  = shift;
    my $ret;

    $ret = $self->getValueFromFile( $file, $key );
    unless( defined($ret) ) {
        return 0;
    }

    return 1;
}

#------------------------------------------------------------------------------
# Function Name : execute
# Description   : Executes the given command in the remote machine 
# Args          : command to execute in remote machine
# Return value  : Returns the outcome of the command
#------------------------------------------------------------------------------
sub execute {
    my $self    = shift;
    my $cmd     = shift;
    my $timeout = shift;
    my $sshconn = $self->{sshconn};
    my $conslog = $self->{consolelog};
    my $format  = "-" x 80;
    my $res;
    my $status;

    # Log the command
    print $conslog $format."\n";
    print $conslog (localtime)."---- Command sent : $cmd\n";
    if( defined($timeout) ) {
        $res = $sshconn->exec( $cmd, $timeout );
    } else {
        $res = $sshconn->exec( $cmd );
    }
    $sshconn->read_all();

    # sleep for a sec
    sleep 1;
    # get the return value of the command
    $status = $sshconn->exec( 'echo $?' );
    if( defined($res) ) {
        print $conslog (localtime)."---- Response received: $res";
    }
    print $conslog (localtime)."---- Return status    : $status\n\n";
    return ($status,$res);
}

1;
