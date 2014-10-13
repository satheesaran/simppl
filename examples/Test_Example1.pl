use FindBin;

#----------------------------
# Include Custom libraries
# directories
#----------------------------
BEGIN {
    my $cwd = $FindBin::Bin;
        chdir($cwd);
            use lib "../../lib";
            }

use Logger;
use Data::Dumper;
use Host;

my $test = new Logger();
print Dumper($test);
my $status = 24;
my $temp = undef;

$test->comment( "This is my first comment" );
$test->start( "Started the case" );
$test->pass( "test passed" );
$test->fail( "test failed now" );
$test->close();
my $host = new Host( "10.70.37.55" );
print Dumper($host);
($status,$temp) = $host->execute( "gluster volume info" );
print "Status is $status";
print "Output is $temp";
print Dumper($test);

