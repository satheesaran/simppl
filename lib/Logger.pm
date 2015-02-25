package Logger;

#-----------------------------------------------------------------------------
# Description     : This is the Module containing commonly used functions for
#                   Logging. This is the base class for $log object
# Child Class     : None
# Parent Class    : None
# Total Functions : 8 
# Functions       : new() - constructor for this class
#                   comment()
#                   start()
#                   pass()
#                   fail()
#                   error()
#                   close()
#                   printResults()
# Author          : Satheesaran Sundaramoorthi <sasundar@redhat.com>
#------------------------------------------------------------------------------

use strict;
use warnings;
use FindBin;

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
    my $currentlogdir = $logdir.'/'."Log".$tag;
    mkdir $currentlogdir;

    # Check for the directory called "latest", if its there delete it
    #if( -l "$logdir/latest" ) {
    #    unlink "$logdir/latest";
    #}

    # create soft link "latest" in logs pointing to current log directory
    #`ln -s $currentlogdir "$logdir/latest"`;
    
    # Create logfilename
    $logfilename = "log".$tag.'.log';
    
    # Get the current working directory
    my $cwd = $FindBin::Bin;
    $cwd =~ m/simppl/i;
    $cwd = $`.$&;
    $cwd = $cwd."/logs/Log$tag";
    
    # print logfile information in the console
    print "Logfile for this test could be found at - $cwd/$logfilename\n";

    # Create a Logfile
    open( $fh, ">> $currentlogdir/$logfilename" ) or return 1;
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
    print $fh (localtime).":\t".$format;
    print $fh (localtime).":\t"."TEST COMMENT:\t$comment\n";
    print $fh (localtime).":\t".$format;
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
    my $format  = "====" x 26;
    $format .= "\n";
    print $fh "\n";
    print $fh (localtime).":\t".$format;
    print $fh (localtime).":\t"."TEST STARTED: $comment\n";
    print $fh (localtime).":\t".$format;

    # Incrementing the total number of tests
    $self->{totalcount} += 1;

    print "\r###  Executing Test :".$self->{totalcount}." ###";
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
    my $format  = "#" x 60;
    $format .= "\n";
    print $fh (localtime).":\t".$format;
    print $fh (localtime).":\t"."# TEST PASSED: $comment\n";
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
    my $format  = "#" x 60;
    $format .= "\n";
    print $fh (localtime).":\t".$format;
    print $fh (localtime).":\t"."# TEST FAILED: $comment\n";
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
# Function Name : printResults
# Description   : Prints the statistics of test cases run, that passed & failed
# Arg           : Logger object
# Return value  : None
#------------------------------------------------------------------------------
sub printResults {
    my $self   = shift;
    my $format = "#" x 60;
    my $fh     = $self->{logfh};
    print $fh (localtime).":\t".$format."\n";
    print "\n\n".$format."\n";
    print $fh (localtime).":\t#    Test Cases Run:".$self->{totalcount}."\n";
    print "#    Test Cases Run:".$self->{totalcount}."\n";
    print $fh (localtime).":\t#    Passed        :".$self->{passcount}."\n";
    print "#    Passed        :".$self->{passcount}."\n";
    print $fh (localtime).":\t#    Failed        :".$self->{failcount}."\n";
    print "#    Failed        :".$self->{failcount}."\n";
    print $fh (localtime).":\t".$format."\n";
    print $format."\n";
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
    print $fh (localtime).":\tEND OF LOG - LogFile is closed\n";
    close( $fh );
}

1;
