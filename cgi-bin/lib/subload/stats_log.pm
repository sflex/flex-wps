package stats_log;
#
# Site logging script for Flex-WPS
# By: Nicholas A.
#
use strict;
use vars qw(
    %user_data %cfg
    $Flex_WPS $AUBBC %back_ends
    );
use Flex_Porter;

sub sub_action {
  return (stats_log_log => 1,);
}

sub stats_log_log {
my $A_PID = $$ || 'PID';
my $DATE = Flex_CGI::expire_calc('now','') || 'DATE';

my $REMOTE_ADDR = $ENV{'REMOTE_ADDR'} || 'R-A';
my $REMOTE_HOST = $ENV{'REMOTE_HOST'} || 'R-H';
my $SCRIPT_NAME = $ENV{'SCRIPT_NAME'} || 'S-N';
my $GATEWAY_INTERFACE = $ENV{'GATEWAY_INTERFACE'} || 'G-I';
my $DOCUMENT_ROOT = $ENV{'DOCUMENT_ROOT'} || 'D-R';

my $SERVER_PORT = $ENV{'SERVER_PORT'} || 'S-P';
my $REMOTE_PORT = $ENV{'REMOTE_PORT'} || 'R-P';

# Not to safe. So we convert some bad characters
# The convetion may make the entries bigger for Black Hole Check.
# But its not that BIG of a deal. =D

my $SERVER_PROTOCOL = $AUBBC->script_escape($ENV{'SERVER_PROTOCOL'}) || 'TCP';
my $REQUEST_METHOD = $AUBBC->script_escape($ENV{'REQUEST_METHOD'}) || 'R-M';
my $QUERY_STRING = $AUBBC->script_escape($ENV{'QUERY_STRING'}) || 'Q-S';
my $HTTP_REFERER = $AUBBC->script_escape($ENV{'HTTP_REFERER'}) || 'H-R';
my $HTTP_ACCEPT_LANGUAGE = $AUBBC->script_escape($ENV{'HTTP_ACCEPT_LANGUAGE'}) || 'A-L';
my $CONTENT_TYPE = $AUBBC->script_escape($ENV{'CONTENT_TYPE'}) || 'C-T';
my $HTTP_USER_AGENT = $AUBBC->script_escape($ENV{'HTTP_USER_AGENT'}) || 'U-A';
my $CONTENT_LENGTH = $AUBBC->script_escape($ENV{'CONTENT_LENGTH'}) || 'C-L';
my $HTTP_COOKIE = $AUBBC->script_escape($ENV{'HTTP_COOKIE'}) || 'H-C';

# Maintain stats_log table size 1mb, just tuncate table for now
# was thinking of compressing and storing archives, that will need more work
my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SHOW TABLE STATUS LIKE \'stats_log\'');
 $sth->execute;
 my $Data_length = ($sth->fetchrow)[6]; # just the 7th element of the array
 $sth->finish;
 $Flex_WPS->SQL_Edit($cfg{Portal_backend}, 'TRUNCATE `stats_log`')
  if ($Data_length >= 1048576);

# path used in Error_Log.pm
$cfg{errorlog2} = $cfg{datadir} . '/fatal_error.log';
# ban will complain a lot to fatal error log
$cfg{error2_size} = -s $cfg{errorlog2};
# clear oversized log
$Flex_WPS->array2file(
        file => $cfg{errorlog2},
        ) if ($cfg{error2_size} >= 524288);
        
# make array of details
push (my @stats,
   join ('|',  $A_PID,       $REMOTE_ADDR,
        $REMOTE_HOST,     "$SERVER_PORT/$REMOTE_PORT", $SERVER_PROTOCOL, $SCRIPT_NAME,
        $GATEWAY_INTERFACE,  $REQUEST_METHOD, $DOCUMENT_ROOT,   $QUERY_STRING,
        $HTTP_REFERER,       $HTTP_ACCEPT_LANGUAGE, $CONTENT_TYPE,    $HTTP_USER_AGENT,
        $CONTENT_LENGTH, $HTTP_COOKIE, $user_data{uid}, $user_data{sec_level})
        );

# System Black Hole
my $Max_Post = 1024 * $cfg{max_upload_size} + 100;
my $Hole_length = "@stats";
$Hole_length = length($Hole_length); # length in bytes

    if ($Hole_length > $Max_Post) {
         # Very large requests are not logged and give an error.
         $cfg{core_error} = 'Request entity too large at System Black Hole';
    }
     else {
     $Hole_length = $back_ends{$cfg{Portal_backend}}->quote("@stats");
     $DATE = $back_ends{$cfg{Portal_backend}}->quote($DATE);
       # Normal Logging
        $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO `stats_log` VALUES ( NULL , $DATE , $Hole_length );");
    }
    check_ban();
    #my $date = $Flex_WPS->get_date();
#$Flex_WPS->SQL_Edit($backend, "INSERT INTO pmin VALUES (NULL,'3','stats log','$date','Logging','Message logged.','1');");
}

# New Ban style
# Check ban should be added in the user register,
# so ban names and emails are not in registerd members
sub check_ban {
my $host = $ENV{REMOTE_ADDR} || $ENV{REMOTE_HOST} || '';
my $ban = 0;
# Faster and is case insensitive
if ($host && $user_data{uid} && $user_data{email}) {
     $host = "($host|$user_data{uid}|$user_data{email})";
     }
      elsif ($host) {
        $host = "($host|$user_data{uid})";
      }
     
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT `banid` FROM `ban` WHERE `banid` REGEXP '^$host' AND `last_date` <> '1' LIMIT 1");
$sth->execute or die($DBI::errstr);
while(my @row = $sth->fetchrow)  {
# Check for banned usernames, emails and IP addresses.
$ban = $row[0] if ($row[0]);
}
$sth->finish;

      if($ban) {
      # Track Ban
      my $DATE = time || 'DATE';
      $ban = $back_ends{$cfg{Portal_backend}}->quote($ban);

      $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `ban` SET `count` =count + 1, `last_date` = '$DATE' WHERE `banid` = $ban LIMIT 1 ;");
      $cfg{core_error} = 'You are band from this site at site ban'." IP:$ENV{'REMOTE_ADDR'}";
      }

$cfg{check_ban} = 1;

}

1;
