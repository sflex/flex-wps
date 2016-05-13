package stats_log;
#
# Site logging script for Flex-WPS
# By: Nicholas A.
#
use strict;
use vars qw(
    %user_data %cfg
    $Flex_WPS $AUBBC_mod %back_ends
    );
use exporter;

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

my $SERVER_PROTOCOL = $AUBBC_mod->script_escape($ENV{'SERVER_PROTOCOL'}) || 'TCP';
my $REQUEST_METHOD = $AUBBC_mod->script_escape($ENV{'REQUEST_METHOD'}) || 'R-M';
my $QUERY_STRING = $AUBBC_mod->script_escape($ENV{'QUERY_STRING'}) || 'Q-S';
my $HTTP_REFERER = $AUBBC_mod->script_escape($ENV{'HTTP_REFERER'}) || 'H-R';
my $HTTP_ACCEPT_LANGUAGE = $AUBBC_mod->script_escape($ENV{'HTTP_ACCEPT_LANGUAGE'}) || 'A-L';
my $CONTENT_TYPE = $AUBBC_mod->script_escape($ENV{'CONTENT_TYPE'}) || 'C-T';
my $HTTP_USER_AGENT = $AUBBC_mod->script_escape($ENV{'HTTP_USER_AGENT'}) || 'U-A';
my $CONTENT_LENGTH = $AUBBC_mod->script_escape($ENV{'CONTENT_LENGTH'}) || 'C-L';
my $HTTP_COOKIE = $AUBBC_mod->script_escape($ENV{'HTTP_COOKIE'}) || 'H-C';

# Wait Some time befor loading Code.
# my $wait = '';
# my $host = $ENV{'REMOTE_ADDR'} || $ENV{'REMOTE_HOST'} || '';
# # Check Last time IP/domain accessed the site
# my $sth = "SELECT * FROM stats_log";
# $sth = $dbh->prepare($sth);
# $sth->execute || die("Couldn't exec sth!");
# while(my @row = $sth->fetchrow)  {
#        my ($date, undef, $ip, $domain, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef) = split(/\|/, $row[1]);
#         $ip = $ip || $domain || '';
#         if ($ip eq $host && $DATE < $date + 2) {
#             $wait = 1;
#             last;
#         }
# }
# $sth->finish();
#
# # Delay all unless admin.
# if ($wait && $user_data{sec_level} ne $usr{admin}) {
# #      while (1) { # This will loop forever!
# #      last if time () - $DATE > 2; # "last" stops the "while ()" in 2 seconds
# #      }
#        # better
#        sleep(2);
#    }

##############
#print "$A_PID , $DATE , $REMOTE_ADDR , $REMOTE_HOST , $SCRIPT_NAME , $GATEWAY_INTERFACE , $REQUEST_METHOD , $DOCUMENT_ROOT , $QUERY_STRING , $HTTP_REFERER , $HTTP_ACCEPT_LANGUAGE , $CONTENT_TYPE , $HTTP_USER_AGENT , $User_Name";

# Get new date - used for delay code only
# $DATE = time || 'DATE';

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
$sth->execute;
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
      $cfg{core_error} = 'You are band from this site at site ban IP: '.$ENV{'REMOTE_ADDR'};
      }
# Check ban IP's is running flag
$cfg{check_ban} = 1;

# if ($ENV{'REMOTE_ADDR'} eq '192.168.1.103') {
#     Crash_em();
# }
}

#sub Crash_em {
#print <<HEADER;
#Location: http://speedtest.tele2.net/1000GB.zip

#HEADER
  # http://speedtest.tele2.net/1000GB.zip

#    exit(0);
#}

1;
