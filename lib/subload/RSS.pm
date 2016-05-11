package RSS;

use strict;
use vars qw(
    $Flex_WPS $AUBBC_mod
    %user_data %cfg
    %back_ends %usr
    );
use exporter;

# %sub_action
# %sub_action = ( menu => 1,);

sub sub_action {
  return ( menu => 1 );
}

my $feed_mod = 3;
my $default_feed = 1;
my $request_feed = 0;
sub menu {
my $user_html = '';
my $admin_html = '';
if($user_data{sec_level} eq $usr{admin} || $user_data{uid} eq $feed_mod) {
    $admin_html = qq(<center><a href="$cfg{pageurl}/index.$cfg{ext}?op=admin,RSS"><font color=red>RSS Admin</font></a></center>);
}
    if ($user_data{uid} ne $usr{anonuser}) {
         $user_html = qq(<center><a href="$cfg{pageurl}/index.$cfg{ext}?op=settings,RSS"><font color=red>RSS Settings</font></a>);
         $user_html .= qq( | <a href="$cfg{pageurl}/index.$cfg{ext}?op=view_pm,send;to=$feed_mod"><font color=red>Request Feed</font></a>) if $request_feed;
         $user_html .= qq(</center>);
    }
        # We want to do it in an iframe incase the xml provider lags
        my $user_status = $Flex_WPS->box_header('RSS Feed');
        $user_status .= <<HTML;
<tr>
<td valign="top">
$admin_html
<iframe width="173" height="250" src="$cfg{pageurl}/index.$cfg{ext}?op=feeds,RSS;id=$default_feed" marginwidth="1" marginheight="1" frameborder="1"></iframe><br />
$user_html
</td>
</tr>
HTML
        $user_status .= $Flex_WPS->box_footer();

        print $user_status;

}
1;
