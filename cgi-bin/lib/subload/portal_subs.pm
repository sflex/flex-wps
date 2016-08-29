package portal_subs;

use strict;
use vars qw(
    %user_data %cfg %usr
    $Flex_WPS $AUBBC_mod %back_ends
    %nav %msg
    );
use Flex_Porter;

# %sub_action
# %sub_action = ( portal_subs_user_status => 1 );

sub sub_action {
  return ( portal_subs_user_status => 1);
}

# ---------------------------------------------------------------------
# Display a box with current user status.  - Flex - Updated
# ---------------------------------------------------------------------
sub portal_subs_user_status {
# Get visitor log. - done, test more
        my ($guests, $users, $buddy)  = ('0', '0', '0');
        my $DATE = time || 'DATE';
        my %pre_log = ();
        $DATE -= 60 * 15;

my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT `stats_info` FROM stats_log WHERE `date` > $DATE;");
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow)  {
       my (undef, $ip, $domain, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, $uid, $sec_level) = split(/\|/, $row[0]);
        # possible bug in $ip because stats_log has a default name if there is none when lodded.
        $ip = '' if $ip eq 'R-A';
        $domain = '' if $domain eq 'R-H';
        $ip = $ip || $domain || '';

        if ($sec_level eq $usr{anonuser}) {
            if (!$pre_log{$ip}) {
                $guests++;
                $pre_log{$ip} = 1;
                }
        }
}
$sth->finish();
#clear the hash to maybe speed up the program
%pre_log = ();

my $buds = '';

my $date = $Flex_WPS->get_date();
$date -= 60 * 15;

$sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT `id`, `user_id` FROM auth_session WHERE `date` >= $date;");
$sth->execute || die("Couldn't exec sth!");

while(my @row = $sth->fetchrow)  {

  $users++ if $row[0];
  if ($user_data{sec_level} ne $usr{anonuser}) {
  my $u_name = check_user($row[1], '');
my (@iid) = split (/\,/, $user_data{buddys});
if (@iid) {
     foreach my $crap (@iid) {
        if ($crap eq $row[1]) {
          $buddy++;
          $buds .= "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=view_profile,user;username=$row[1]\">$u_name</a>, ";
        }
     }
    }
  $cfg{online_members} .= "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=view_profile,user;username=$row[1]\">$u_name</a>, ";
 }
}
$sth->finish();

# END

# Get members stats - done, test more
my ($most_online, $member_count, $last_registered)  = ('0', '0', '0');
my $sth = "SELECT * FROM whosonline";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow)  {
  $member_count = $row[1] if $row[1];
  $most_online = $row[2] if $row[2];
  $last_registered = $row[3] if $row[3];
}
$sth->finish();
# END

# Most online check
my $current_most = $users + $guests;
    if ($current_most > $most_online) {
         $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `whosonline` SET `mostonline` = '$current_most' WHERE `id` =1 LIMIT 1 ;");
         $most_online = $current_most;
    }
# END

if ($user_data{sec_level} ne $usr{anonuser}) {
# Whos Online Menu
        #require theme;
        my $user_status = $Flex_WPS->box_header($nav{who_is_online});
        my $voter = '';
        $voter = "<hr noshade />You have $user_data{votes} votes." if $user_data{votes};
                $user_status .= <<HTML;
<tr>
<td class="cat">$msg{logged_in_asC}<br /><center><a href=\"$cfg{pageurl}/index.$cfg{ext}?op=view_profile,user">$user_data{uid}</a><small>/($user_data{nick})</small></center></td>
</tr>
<tr>
<td class="cat"><center><a href="$cfg{pageurl}/index.$cfg{ext}?op=view_pm,PM"><img src="$cfg{imagesurl}/forum/message.gif" alt="$nav{im_index}" border="0" /></a></center>
$voter<hr noshade width="65%" /></td>
</tr>
HTML
$buds .= '<br />' if $buds;
# Show online users and guests.
# $msg{guestsC} $guests<br>

        $user_status .= <<HTML;
<tr>
<td class="cat">
$msg{guestsC} $guests<br />
Buddys: $buddy<br />
$buds
$msg{membersC} $users<br />
$cfg{online_members}<br />
<b>Most Online: $most_online
<hr noshade />
$msg{member_countC} $member_count<br />
Newest Member:<br /><center>$last_registered</center></b></td>
</tr>
HTML

        $user_status .= $Flex_WPS->box_footer();
# END
        #return $user_status;
        return $user_status;
        }
}

sub check_user {
my ($memid, $option) = @_;
return '' unless $memid;
my $check = 0;
my $query1 = "SELECT uid, nick FROM members WHERE memberid='$memid'";
$query1 = "SELECT memberid FROM members WHERE memberid='$memid'" if $option eq 1;
$query1 = "SELECT memberid FROM members WHERE uid='$memid'" if $option eq 2;
my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute || die("Couldn't exec sth!");
while(my @user_data = $sth->fetchrow)  {
$check = $user_data[0];
$check .= '<small>/(' . $user_data[1] . ')</small>' if $user_data[1];
 }
 $sth->finish();
return '' unless $check;
return $check;
}

sub portal_subs_wheather {
 if (! $ENV{'QUERY_STRING'}) {
  return <<HTML;
<script src='http://voap.weather.com/weather/oap/33710?template=DRIVV&amp;par=null&amp;unit=0&amp;key=c41d7df35f7d59e4949930c3e9e63461' type="text/javascript">
</script>
HTML
 }
}
1;
