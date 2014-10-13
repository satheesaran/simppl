use FindBin;

sub BEGIN {
my $dir = $FindBin::Bin;
print "dir is $dir\n";
chdir( $dir );
}

use lib "../../lib";
use Logger;
use Host;

$log = new Logger();
$host = new Host( "10.70.37.47" );

#$out = $host->execute( "ls" );
#print $out;

$res = $host->getVolOption("dr-imgstore", "storage.owner-uid" );
if( defined($res) ) {
    print "value of uid is $res\n";
} else {
    print "Unable to get the uid";
}

if( $host->isFilePresent( "/var/lock/subsys/glusterd" ) ) {
    print "glusterd lock file is created when glusterd is up";
} 

$res = $host->serviceStop( "glusterd" );
if( $res == 0 ) {
    print "glusterd is stopped";
} else {
    print "unable to stop glusterd";
}


unless( $host->isFilePresent( "/var/lock/subsys/glusterd" ) ) {
    print "glusterd lock file is not available when glusterd is down";
}

$res = $host->getValueFromFile( "/var/lib/glusterd/vols/dr-imgstore/info", "version", "=" );
print "value is $res";

$res = $host->isKeyInFile( "/etc/redhat-storage-release", "2.1" );
if( $res ) {
    print "value is present";
} else {
    print "fail- value is absent" ;
}
