package parallel_menu;

use strict;
use vars qw(
    %user_data %cfg
    $Flex_WPS $AUBBC_mod %back_ends
    %msg %usr %nav
    );
use Flex_Porter;

sub sub_action {
  return ( parallel_menu_user => 1);
}


sub parallel_menu_user {
        # Get help topic.
#         my $script_name = $ENV{SCRIPT_NAME};
#         $script_name =~ s(^.*/)();
#         my ($topic, undef) = split (/\./, $script_name);

        my $user_panel = '';

        # Print help link.
#         $user_panel .=
#             menu_item("$cfg{pageurl}/help.$cfg{ext}?topic=$topic", $nav{help});
        # Print register link for guests only.

my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM usermenu");
$sth->execute;
while(my @row = $sth->fetchrow) {
#my %cp=(row => $row[0],row1 => $row[1],row2 => $row[2],row3 => $row[3],row4 => $row[4],row5 => $row[5],row6 => $row[6]);
$row[2] = $Flex_WPS->eval_theme_tags($row[2]);
# Print admin links if user is authorized.
if ($user_data{sec_level} eq $usr{admin} && ($usr{admin} eq $row[5] || $usr{mod} eq $row[5])) {
   $user_panel .= menu_item($row[2],$row[1],$row[3],$row[4]); }
# Print mod links if user is authorized.
elsif ($user_data{sec_level} eq $usr{mod} && $usr{mod} eq $row[5]) {
   $user_panel .= menu_item($row[2],$row[1],$row[3],$row[4]); }
# Print link if user is authorized.
elsif ($user_data{sec_level} eq $usr{anonuser} && $usr{anonuser} eq $row[5]) {
   # Link Print              Link      Title    image 1  image 2
   $user_panel .= menu_item($row[2],$row[1],$row[3],$row[4]); }
elsif ($usr{user} eq $row[5] &&
($user_data{sec_level} eq $usr{user} || $user_data{sec_level} eq $usr{admin} || $user_data{sec_level} eq $usr{mod})) {
   # Link Print              Link      Title    image 1  image 2
   $user_panel .= menu_item($row[2],$row[1],$row[3],$row[4]);
   }
}
$sth->finish;

#$user_panel .= $Flex_WPS->box_footer();

return '<div class="bga">'.$user_panel.'</div>';
}

sub menu_item {
my ($page, $title, $image, $image1) = @_;
my $logout = '';
$logout = ' onclick="javascript:return confirm(\'Are you sure you want to Logout?\')"'
        if $title eq $nav{logout};
# Default
my $menu = "| &nbsp;<a href=\"$page\" class=\"nav\"$logout>$title</a> &nbsp;";
if ($image && $image1) { # Link & Dot image
$menu = "| &nbsp;<a href=\"$page\"$logout><img src=\"$cfg{imagesurl}/$image\" border=\"0\" alt=\"$title\" /></a> &nbsp;";
} elsif (!$image1 && $image) { # Link image
$menu = "| &nbsp;<a href=\"$page\"$logout><img src=\"$cfg{imagesurl}/$image\" border=\"0\" alt=\"$title\" /></a> &nbsp;";
} elsif (!$image && $image1) { # Dot image
$menu = "| &nbsp;<a href=\"$page\" class=\"nav\"$logout>$title</a> &nbsp;";
}
        return $menu;
}
1;
