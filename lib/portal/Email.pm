package Email;
# ban's bots that dont read the robot.txt file
# v2 10/06/2011 - Fixed Duplicate entry error.
use strict;
use vars qw(
    %user_data %cfg %user_action
    $Flex_WPS %back_ends %usr
    );
use exporter;

%user_action = ( con_tacker => $usr{anonuser} );

sub con_tacker {
my $host = $ENV{REMOTE_ADDR} || $ENV{REMOTE_HOST} || '';
my $DATE = time || 'DATE';
my $ban = '';

$host = $back_ends{$cfg{Portal_backend}}->quote($host);

my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT `banid` FROM `ban` WHERE `banid` = $host LIMIT 1");
$sth->execute;
while(my @row = $sth->fetchrow)  {
# Check for banned usernames, emails and IP addresses.
$ban = $row[0] if ($row[0]);
}
$sth->finish;

$Flex_WPS->SQL_Edit($cfg{Auth_backend}, "INSERT INTO `ban` VALUES ( $host , '$DATE' , '1', '$DATE' );")
 if ! $ban;
 
$Flex_WPS->core_error('You are band from this site. IP:'.$ENV{'REMOTE_ADDR'});
}
1;
