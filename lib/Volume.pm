package Volume;

#------------------------------------------------------------------------------
# Package Name : Volume
# Description  : This Module provides all useful functions wrt volumes
# Total Methods:
# Methods      :
# Author       : Satheesaran Sundaramoorthi <sasundar@redhat.com>
# Date         : 21-Nov-2013
# Revisions    :
# Total Functions     : 2
# Available functions : setVolOption( .. )
#                       getVolOption( .. )
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

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
sub createVolume {
}

#------------------------------------------------------------------------------
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
    
    print "Stopping volume $vol \n";
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

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
sub deleteVolume {
}

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
sub purgeVolume {
}

1;
