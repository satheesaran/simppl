package Host;
#-----------------------------------------------------------------------------
# Description     : This is the Module containing commonly used functions 
#                   related to host. This is the class which deals with Host
#                   functions. All the method in this class could be accessed
#                   only using object for host.
# Total Functions : 2
# Parent Class    : Volume class - providing functions related to Volume ops
#                   Peer class - providing functions related to peer ops
# Functions       : constructor and a destructor
#                   new() and destroy()
# Author          : Satheesaran Sundaramoorthi <sasundar@redhat.com>
#------------------------------------------------------------------------------
use strict;
use warnings;
use Net::SSH::Expect;
use Volume;
use Utils;
our @ISA = qw( Volume Utils );

#------------------------------------------------------------------------------
# Function Name : new
# Description   : This function is the constructor and it creates a host object
#                 containing console log object and ssh connection object
# Args          : hostname/ip, password, username
# Return value  : host object (hashreference) containing sshconn object, 
#                 consolelog handle
#------------------------------------------------------------------------------                 
sub new {
    my $class = shift;
    my $host  = shift;
    my $pass  = shift;
    my $user  = shift;
    my $hostobj = {};        # This is the ref that will be blessed
    my $ssh;
    my ($logdir,$dir,$file);
    my $console;

    # Setting the default user and password
    unless( defined($pass) ) {
        $pass = "redhat";
    }
    unless( defined($user) ) {
        $user = "root";
    }
    eval {
        $ssh = Net::SSH::Expect->new (
            host => $host, 
            password=> $pass, 
            user => $user, 
            raw_pty => 1,
            no_terminal => 1 
        );
        $ssh->login();
    };
    if( $@ ) {
        print "Error: $@";
        return 1;
    }

    # disable terminal translations and echo on the SSH server
    # executing on the server the stty command:
    $ssh->exec("stty raw -echo");

    $hostobj->{sshconn} = $ssh;

    # Create a console log
    $logdir = "../../logs";
    chomp($dir = `ls -1t $logdir | head -1`);
    $file = open( $console, ">>$logdir/$dir/console-$host" );
    unless( defined($file) ) {
        $ssh->close();
        return 1;
    }
    $hostobj->{consolelog} = $console;

    bless( $hostobj, $class );    
}

sub destroy {
    my $self = shift;
    my $ssh = $self->{sshconn};
    my $conslog = $self->{consolelog};
    
    # Close the console log handle
    print $conslog "\nCLOSING CONSOLE LOG\n";
    close($conslog);

    $ssh->close();
}

1;
