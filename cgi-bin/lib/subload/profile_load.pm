package profile_load;
#
#
use strict;
use vars qw(
    %user_data %cfg
    $Flex_WPS $AUBBC_mod %back_ends
    );
use Flex_Porter;

sub sub_action {
  return (load_pro => 1);
}

sub load_pro {
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT `upic`, `profile`, `sign`, `std_settings` FROM `std_list` WHERE `user_id` = '$user_data{id}' LIMIT 1 ;"
);
$sth->execute;
while (my @row = $sth->fetchrow) {
if ($row[0]) {
$user_data{upic} = $row[0];
$user_data{profile} = $row[1];
$user_data{sign} = $row[2];
$user_data{std_settings} = $row[3];
 }
}
$sth->finish();
}
1;
