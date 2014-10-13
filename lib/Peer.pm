package Peer;
#-----------------------------------------------------------------------------
# Description     : This is the class containing commonly used functions
#                   related to peers. 
# Parent class    : Utils
# Child class     : Host
# Total Functions : 5 
# Functions       : peerProbe()
#                   peerDetach()
#                   getPeerUUID()
#                   getPeerCount()
#                   getPeerStatus()
# Author          : Satheesaran Sundaramoorthi <sasundar@redhat.com>
#------------------------------------------------------------------------------

use strict;
use warnings;
use parent 'Utils';
#------------------------------------------------------------------------------
# Function Name : peerProbe
# Description   : probes for a peer in a cluster
# Args          : $host [in]
# Return value  : 0 in case of success and 1 if unable to probe a peer
#------------------------------------------------------------------------------
sub peerProbe {
    my $self = shift;
    my $host = shift;
    my $res;
    my $uuid;
    my $peerCount;
    my $newPeerCount;
    my $peersHashRef;
    my $status;
    my $actualHost;
    my $actualState;

    # Get the current peer count
    $peerCount = $self->getPeerCount();
    unless( defined($peerCount) ) {
        return 1;
    }

    ($status,$res) = $self->execute( "gluster peer probe $host" );
    if( $res != m/success/i ) {
        return 1;
    }
   
    # check for return value
    if( $status != 0 ) {
        return 1;
    } 
    
    # Check for the increment in peer count value
    $newPeerCount = $self->getPeerCount();
    unless( defined($newPeerCount) ) {
        return 1;
    }
    if( $newPeerCount != ($peerCount+1) ) {
        return 1;
    }
        
    # check for a value in command history file
    ($status,$res) = $self->execute( 
                       "tailf -1 /var/log/glusterfs/.cmd_log_history" );
    unless( $res =~ m/peer probe $host : SUCCESS/i ) {
        return 1;
    }
    if( $status != 0 ) {
        return 1;
    }

    # get the peer UUID
    $uuid = $self->getPeerUUID( $host );

    # Check if there is a corresponding file
    unless( $self->isFilePresent( "/var/lib/glusterd/peers/$uuid" ) ) {
        return 1;
    }

    # Check the content of the file - /var/lib/glusterd/peers/<uuid>
    $actualHost = $self->getValueFromFile( "/var/lib/glusterd/peers/$uuid",
                                            "hostname1", "=" );
    $actualState = $self->getValueFromFile( "/var/lib/glusterd/peers/$uuid",
                                            "state", "=" );
    unless( defined($actualHost)  ) {
        return 1;
    }
    unless( defined($actualState)  ) {
        return 1;
    }

    if( $actualHost ne $host ) {
         return 1;
    }
    
    # Peer in cluster ( connected) is represented by number 3
    if( $actualState != 3 ) {
        return 1;
    }
 

    # check for the status of peer
    ($status,$peersHashRef) = $self->getPeerStatus( $host );
    if( $status == 1 ) {
        return 1;
    }
    
    # check the status of host from output of getPeerStatus
    unless( $peersHashRef($host) ) {
        return 1;
    }

    # value 0 represents the host is connected and up
    if( $peersHashRef->{$host} != 0 ) {
        return 1;
    }
    return 0; 
}

#------------------------------------------------------------------------------
# Function Name : peerDetach
# Description   : Detaches the peer from the cluster
# Args          : $host [in]
# Return value  : 0 in case of success and 1 if unable to probe a peer
#------------------------------------------------------------------------------
sub peerDetach {
    my $self = shift;
    my $host = shift;
    my $res;
    my $peerCount;
    my $newPeerCount;
    my $status;
   
    # Get the peer count

    # Get the uuid of the peer

    # Execute the peer detach command 
    ($status,$res) = $self->execute( "gluster peer detach $host" );
    if( $res != m/success/i ) {
        return 1;
    }

    # check for return value
    if( $status != 0 ) {
        return 1;
    } 

    # check for a value in command history file
    ($status,$res) = $self->execute( 
                       "tailf -1 /var/log/glusterfs/.cmd_log_history" );
    if( $res =~ m/peer detach $host : SUCCESS/i ) {
        return 0;
    }

    # Check that the peer count has reduced by 1
   
    # Check that there is no file - /var/lib/glusterd/peers/<uuid>

    # Return 1 in case of failure
    return 1;
    
}

#------------------------------------------------------------------------------
# Function Name : getPeerStatus
# Description   : gets the peer status in the hash. Key as hostname and its
#                 status as values
# Arg           : $status, $hashref
# Return val    : $status - return status of the command,
#                 $hashref - reference to hash, containing key as hostname and
#                            value as its status
#------------------------------------------------------------------------------
sub getPeerStatus {
    my $self = shift;
    my $host = shift;
    my $res;
    my $status;
    my $tempHost;
    my $tempState;
    my $hashref = {};
    my @lines;

    # get the output from 'peer status' command
    ($status,$res) = $self->execute( "gluster peer status" );
    if( $status != 0 ) {
        return 1;
    }

    # Create a hash containing hostname as the key and its status as value
    # Status is 1, if its connected and 0 if in anyother state
    @lines = split( "\n", $res );
    for my $line( @lines ) {
        if( $line =~ m/Hostname:/i ) {
            $tempHost = $';
            $tempHost =~ s/^\s+//g;
            $tempHost =~ s/\s+$//g;
        }
        if( $line =~ m/state:/i ) {
            $tempState = $';
            if( $tempState =~ m/Peer in cluster (connected)/i ) {
                $hashref->{$tempHost} = 1; # Host is in connected status
            } else {
                $hashref->{$tempHost} = 0;
            }
        }
    }

    if( defined($host) ) {
        return (0,{ $host => $hashref->{$host} } );
    }
    return (0,$hashref ); 
}

#-------------------------------------------------------------------------------
# Function Name : getPeerUUID
# Description   : This function gets the UUID of the host in question
# Args          : hostname/ip
# Return val    : Returns undef if glusterd is non-operational or failure in 
#                 gluster peer status command. On success returns the UUID of 
#                 host
#------------------------------------------------------------------------------
sub getPeerUUID {
    my $self = shift;
    my $host = shift;
    my $res;
    my $status;

    ($status,$res) = $self->execute(
                       "gluster peer status|grep -A 2 $host|grep -i uuid");
    if( $status != 0 ) {
        return undef;
    }

    $res =~ m/:/;
    $res = $';
    $res =~ s/^\s+//;
    $res =~ s/\s+$//;
    return $res;
}

#------------------------------------------------------------------------------
# Function Name : getPeerCount
# Description   : gets the number of peers in the cluster using "gluster peer
#                 status" command. Compares it with output of "gluster pool
#                 list" command. Also checks for number of UUID files available
#                 in /var/lib/glusterd/peers
# Args          : None
# Return value  : Returns the number of peers, if successful
#                 Returns undef if there is any contradiction or glusterd is not
#                 operational
#------------------------------------------------------------------------------
sub getPeerCount {
    my $self = shift;
    my $cmd  = "gluster peer status";
    my $res;
    my $peerCount;
    my $actPeerCount;
    my $status;

    ($status,$res) = $self->execute( $cmd );
    if( $res =~ m/Number of Peers:/i ) {
        $peerCount = $';
    }
    if( $status != 0 ) {
        return undef;
    }

    $cmd = "ls /var/lib/glusterd/peers | wc -l";
    ($status,$actPeerCount) = $self->execute( $cmd );
    if( $peerCount != $actPeerCount ) {
        return undef;
    }
    if( $status != 0 ) {
        return undef;
    }

    $cmd = "gluster pool list | wc -l";   # This count also includes the header
    ($status,$actPeerCount) = $self->execute( $cmd );

    if( $status != 0 ) {
        return undef;
    }
    
    $actPeerCount -= 1;
    if( $peerCount != $actPeerCount ) {
        return undef;
    }
    return $peerCount;    
}

1;
