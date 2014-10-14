package Logger;

#-----------------------------------------------------------------------------
# Description     : This is the Module containing commonly used functions for
#                   Logging. This is the base class for $log object
# Child Class     : None
# Parent Class    : None
# Total Functions : 7
# Functions       : new() - constructor for this class
#                   comment()
#                   start()
#                   pass()
#                   fail()
#                   error()
#                   close()
# Author          : Satheesaran Sundaramoorthi <sasundar@redhat.com>
#------------------------------------------------------------------------------

use strict;
use warnings;

#------------------------------------------------------------------------------
# Function Name : new
# Decription    : This method is never called directly. This is constructor for
#                 this class
#                 Creates a log directory, under '../../logs' folder and 
#                 creates a log file there
# Arg           : None
#------------------------------------------------------------------------------
sub new {
    my $class   = shift;
    my ( $ss, $min, $hh, $dd, $mon, $yy ) = localtime(time);
    my $logfilename;
    my $logdir = "../../logs";
    my $test    = {};             # hash ref contain all test related data
    my $fh;                       # file handle
    my $tag;
 
    # Create a unique logfilename with date & time combination
    $yy += 1900;                  # year calculated by localtime is from 1900
    $mon += 1;                    # month starts from 0 in case of localtime

    $tag = "${yy}${mon}${dd}_${hh}${min}${ss}";
    
    # Create a logdir
    $logdir = $logdir.'/'."Log".$tag;
    mkdir $logdir;
 
    # Create logfilename
    $logfilename = "log".$tag.'.log';

    # Create a Logfile
    open( $fh, ">> $logdir/$logfilename" ) or return 1;
    $test->{logfh}      = $fh;
    $test->{totalcount} = 0;
    $test->{passcount}  = 0;
    $test->{failcount}  = 0;
    bless( $test, $class ); 
}

#------------------------------------------------------------------------------
# Function Name : comment
# Description   : Logs the comment in the log file.
# Arg           : String to be logged
# Return value  : None
#------------------------------------------------------------------------------
sub comment {
    my $self    = shift;
    my $comment = shift;
    my $fh      = $self->{logfh};
    my $format  = "-" x 80;
    $format .= "\n";
    print $fh $format;
    print $fh "TEST COMMENT:\t$comment\n";
    print $fh $format;
}

#------------------------------------------------------------------------------
# Function Name : start
# Description   : Marks the start of the test in the log and also increments 
#                 the total number of test cases.
# Arg           : String to be logged
# Return value  : None
#------------------------------------------------------------------------------
sub start {
    my $self    = shift;
    my $comment = shift;
    my $fh      = $self->{logfh};
    my $format  = "+ - " x 26;
    $format .= "\n";
    print $fh "\n";
    print $fh (localtime).":\t".$format;
    print $fh (localtime).":\t"."TEST STARTED: $comment\n";
    print $fh (localtime).":\t".$format;

    # Incrementing the total number of tests
    $self->{totalcount} += 1;

}

#------------------------------------------------------------------------------
# Function Name : pass
# Description   : Marks the pass of the test in the log and also increments
#                 the total number of passed test cases.
# Arg           : String to be logged
# Return value  : None
#------------------------------------------------------------------------------
sub pass {
    my $self    = shift;
    my $comment = shift;
    my $fh      = $self->{logfh};
    my $format  = "#" x 40;
    $format .= "\n";
    print $fh (localtime).":\t".$format;
    print $fh (localtime).":\t"."TEST PASSED: $comment\n";
    print $fh (localtime).":\t".$format;

    # Incrementing the total number of passed tests
    $self->{passcount} += 1;

}

#------------------------------------------------------------------------------
# Function Name : fail
# Description   : Marks the failure of the test in the log and also increments
#                 the total number of failed test cases.
# Arg           : String to be logged
# Return value  : None
#------------------------------------------------------------------------------
sub fail {
    my $self    = shift;
    my $comment = shift;
    my $fh      = $self->{logfh};
    my $format  = "#" x 40;
    $format .= "\n";
    print $fh (localtime).":\t".$format;
    print $fh (localtime).":\t"."TEST FAILED: $comment\n";
    print $fh (localtime).":\t".$format;

    # Incrementing the total number of failed tests
    $self->{failcount} += 1;
}

#------------------------------------------------------------------------------
# Function Name : error
# Description   : Marks any error in the logs message.
# Arg           : String to be logged
# Return value  : None
#------------------------------------------------------------------------------
sub error {
    my $self    = shift;
    my $comment = shift;
    my $fh      = $self->{logfh};
    my $format  = "*-*" x 20;
    $format .= "\n";
    print $fh $format;
    print $fh "TEST ERROR: $comment\n";
    print $fh $format;
}

#------------------------------------------------------------------------------
# Function Name : close
# Description   : closes the log file.
# Arg           : String to be logged
# Return value  : None
#------------------------------------------------------------------------------
sub close {
    my $self = shift;
    my $fh = $self->{logfh};
    print $fh (localtime)."\t:END OF LOG - LogFile is closed\n";
    close( $fh );
}

#-----------------------------
# Helper functions
#-----------------------------
sub getPassCount {
    my $self = shift;
    return $self->{passcount};
}
sub getTotalCount {
    my $self = shift;
    return $self->{totalcount};
}
sub getFailCount {
    my $self = shift;
    return $self->{failcount};
}
1;
