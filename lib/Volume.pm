package Volume;

#------------------------------------------------------------------------------
# Package Name : Volume
# Description  : This Module provides all useful functions wrt volumes
# Total Methods:
# Methods      :
# Author       : Satheesaran Sundaramoorthi <sasundar@redhat.com>
# Date         : 21-Nov-2013
# Revisions    :
# Total Functions     : 9
# Available functions : setVolOption( .. )
#                       getVolOption( .. )
#                       startVolume( .. )
#                       stopVolume( .. )
#                       createVolume( .. )
#                       stopAllVolumes( .. )
#                       purgeAllVolumes( .. )
#                       getFreeBrick( .. )
#                       cleanBricks( .. )
#------------------------------------------------------------------------------

#----------------------------
# Pragmatic Module
#----------------------------
use strict;
use warnings;

#----------------------------
# Utils Module Required
#----------------------------
use Utils;
our @ISA = qw( Utils );

sub getFreeBrick {
    my $self      = shift;
    my %bricks    = %{$self->{bricks}};
    my $freebrick = undef;

    for( keys(%bricks) ) {
        if( $bricks{$_} == 0 ) {
            $freebrick = $self->{hostname}.":".$_;
            $self->{bricks}->{$_} = 1;
            return $freebrick;
        }
    }
    return undef;
}

#------------------------------------------------------------------------------
# Function Name : createVolume
# Description   : creates the volume based on type input.
# Arguments     : $host  - Invoked host
#                 @hosts - List of host objects
#                 $vol   - Volume name
#                 $type  - type & configuration of volume
#                    Type 1 - Distributed volume - 1 brick/1 Host with 1 host
#                    Type 2 - Replicate volume   - 1 brick/1 Host with 2 hosts
#                    Type 3 - Dist-Repl volume   - 2 bricks/1 Host with 2 hosts 
#------------------------------------------------------------------------------
sub createVolume {
    my $host  = shift;
    my @hosts = @{shift @_};
    my $vol  = shift;
    my $type = shift;
    my $totalBricks   = undef;
    my $bricksPerHost = undef
    my $status = undef;
    my $res    = undef;

    if( $type > 6 ) {
        my $totalBricks   = shift;
        my $bricksPerHost = shift;
    }
    
    # Type 1 creates a distributed volume with a single brick on the same host
    if( $type == 1 ) {
        my $brick = $host->getFreeBrick();
        my $tag = time();
        $tag    = "brick".$tag;

        unless( defined($brick) ) {
            return 1;
        }
        ($status, $res) = $host->execute( "gluster volume create $vol $brick/$tag" );
        if( $status == 0 ) {
            return 0;
        } else { 
            return 1;
        }
    }

    # Type 2 creates a replicate volume with - 2 hosts,1 brick per host
    if( $type == 2 ) {
        my $host1 = shift @hosts;
        my $host2 = shift @hosts;
        my $tag;
        $tag = time();
        $tag = "brick".$tag;

        unless( defined($host1) and defined($host2) ) {
            return 1;
        }
        my $brick1 = $host1->getFreeBrick();
        my $brick2 = $host2->getFreeBrick();
        unless( defined($brick1) and defined($brick2) ) {
            return 1;
        }
        my $cmd = "gluster volume create $vol replica 2 $brick1/$tag $brick2/$tag";
        ($status, $res) = $host->execute( $cmd );
        if( $status == 0 ) {
            return 0;
        } else {
            return 1;
        }
    }

    # Type 3 creates distribute-replicate volume with - 2 hosts,2 brick per host    
    my @bricks;
    if( $type == 3 ) {
        for( @hosts,@hosts ) {
            my $brick = $_->getFreeBrick();
            unless( defined($brick) ) {
                return 1;
            }
            push( @bricks, $brick );
        }
        my $cmd = "gluster volume create $vol replica 2 @bricks";
        ($status, $res) = $host->execute( $cmd );
        if( $status == 0 ) {
            return 0;
        } else {
            return 1;
        }
    }

    # Type 4 created distribute volume with - 2 hosts, 1 brick per host
    if( $type == 4 ) {

    }
}

#------------------------------------------------------------------------------
# Function Name: startVolume
# Description  : starts the volume
#------------------------------------------------------------------------------
sub startVolume {
    my $host   = shift;
    my $vol    = shift;
    my $status = undef;
    my $res    = undef;
    
    unless( defined($vol) ) {
        return 1;
    }
    ($status, $res) = $host->execute( "gluster volume start $vol" );
    if( $status == 0 ) {
        return 0;
    } else {
        return 1;
    }
}

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
sub stopVolume {
    my $host   = shift;
    my $vol    = shift;
    my $status = undef;
    my $res    = undef;
    
    unless( defined($vol) ) {
        return 1;
    }
    ($status, $res) = $host->execute( "gluster volume stop $vol --mode=script" );
    if( $status == 0 ) {
        return 0;
    } else {
        return 1;
    }
}

#------------------------------------------------------------------------------
# Function Name: getVolOption
# Description  : Gets the value of the option on the volume
# Args         : host object[in], volume-name[in], option[in]
# Return value : $value of the option if successful, else undef
#------------------------------------------------------------------------------
sub getVolOption {
    my $self    = shift;
    my $vol     = shift;
    my $option  = shift;
    my $res;
    my $val;
    my $status;

    # Send the command and get the result
    ($status,$res) = $self->execute( "gluster volume info | grep $option" );
    
    # Check for return status
    if( $status != 0 ) {
        return undef;
    }

    # Check for pattern "="
    if( $res =~ m/:/ ) {
        $val = $';
    } else {
        return undef;
    }

    # Replace Leading and trailing blank space
    chomp($val);
    $val =~ s/^\s*//;
    $val =~ s/\s*$//;

    return $val;
}

#------------------------------------------------------------------------------
# Function Name: setVolOption
# Description  : Set the option on the volume
# Args         : host object,volume-name[in], option[in], value[in], 
#                [validate[in]]
#                validate [boolean] - verifies that the option is set or not
# Return value : (0, undef) in case of success and 
#                (1, error_string) in case of any failure
#------------------------------------------------------------------------------
sub setVolOption {
    my $self    = shift;
    my $vol     = shift;
    my $option  = shift;
    my $value   = shift;
    my $validate= shift;
    my $res     = shift;
    my $new_val;
    my $old_val;
    my $status;

    # Make validate flag is 0, if there are no arguments passed for it
    unless( defined($validate) ) {
        $validate = 0;
    }

    # This is the counter check to check whether the version in info file is
    # incremented
    $old_val = $self->getValueFromFile( "/var/lib/glusterd/vols/$vol/info", 
                                        "version", "=" );

    # Send the command and get the result
    ($status,$res) = $self->execute("gluster volume set $vol $option $value");

    # check for return status
    if( $status != 0 ) {
        return (1,"return value is:$res");
    }

    # Verify the response
    if( $res !~ m/success/i ) {
        return (1, $res);
    }

    # if validation is required then Validate the value
    if( $validate ) {
        my $actual_value = $self->getVolOption( $vol, $option );
        if( defined($actual_value) ) {
            # when actual value is same as the value we set
            # checking whether value is string
            if( $value =~ m/[a-z]/i ) {
                return (0,undef) if( $actual_value eq $value );
                return (1,"expectedval is <$value>, but actualval <$actual_value>");
            } else {
                # when actual value is numeric 
                return (0,undef) if( $actual_value == $value );
                return (1,"expectedval is <$value>, but actualval <$actual_value>");
            }
        } else {
            return (1, "getVolOption Failed" );
        }
    }

    # This is the counter check to check whether the version in info file is
    # incremented
    $new_val = $self->getValueFromFile( "/var/lib/glusterd/vols/$vol/info", 
                                        "version", "=" );

    if( $new_val != ($old_val+1) ) {
        return (1, "version not incremented" );
    }
        
    # This part is reached when validate is not required and option
    # was set successfully on the volume
    return (0, undef);
}

sub cleanAllBricks {
    my $host   = shift;
    my @hosts  = @{shift @_};
    my $status = undef;
    my $res    = undef;
   
    # we don't care abt the host, as all host objects are in hosts array
    $host = undef;

    for $host(@hosts) {
        for my $brick( keys(%{$host->{bricks}}) ) {
            ($status,$res) = $host->execute( "rm -rf $brick/*" );
            if( $status == 0 ) {
                $host->{bricks}->{$brick} = 0;
            } else {
                return 1;
            }
        }
    }
    return 0;
}
        
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
sub deleteVolume {
    my $host   = shift;
    my $vol    = shift;
    my $status = undef;
    my $res    = undef;
    my $cmd;

    # Arguments validation
    unless( defined($vol) ) {
        return 1;
    }

    # gluster command to delete the volume
    $cmd = "gluster volume delete $vol --mode=script";
    ($status, $host) = $host->execute( $cmd );
    
    if( $status == 0 ) {
        return 0;
    } else {
        return 1;
    }

}

#------------------------------------------------------------------------------
# Function Name :
# Description   : Stops and deletes the volume
#------------------------------------------------------------------------------
sub purgeVolume {
    my $host = shift;
    my $vol  = shift;
    my $res  = undef;

    # Arguments validation
    unless( defined($vol) ) {
        return 1;
    }
   
    # stop the volume
    $res = $host->stopVolume( $vol );
    if( $res != 0 ) {
        return 1;
    }

    # Delete the volume
    $res = $host->deleteVolume( $vol );
    if( $res != 0 ) {
        return 1;
    }
    
    return 0;
}

#------------------------------------------------------------------------------
# Function Name : getAllVolNames
# Descriptions  : Gets all the volume names available in the cluster
#------------------------------------------------------------------------------
sub getAllVolNames {
    my $host   = shift;
    my $status = undef;
    my $res    = undef;
    my @vols   = ();

    # Get the list of volumes
    ($status, $res) = $host->execute( "gluster volume list" );
    if( $status != 0 ) {
        return @vols;
    }

    @vols = split( /\n/, $res );
    return @vols;
}
    

#------------------------------------------------------------------------------
# Function Name :
#------------------------------------------------------------------------------
sub stopAllVolumes {
    my $host   = shift;
    my @vols   = ();
    my $status = undef;

    # Get all vol names
    @vols = $host->getAllVolNames();
    
    if( @vols == 0 ) {
        return 0;
    }

    # stop the volumes
    for my $vol( @vols ) {
        $status = $host->stopVolume( $vol );
        if( $status != 0 ) {
            return 1;
        }
    }
   
}

#------------------------------------------------------------------------------
# Function Name :
#------------------------------------------------------------------------------
sub purgeAllVolumes {
    my $host    = shift;
    my $hostref = shift;
    my $status  = undef;
    my @vols    = ();
    # Arguments validation
    unless( defined($hostref) ) {
        return 1;
    }

    @vols = $host->getAllVolNames();
    for my $vol( @vols ) {
        $status = $host->stopVolume($vol);
        $status = $host->deleteVolume($vol);
        if( $status != 0 ) {
            return 1;
        }
    }

    # clean the bricks
    $host->cleanAllBricks( $hostref );
    return 0;
}


1;
