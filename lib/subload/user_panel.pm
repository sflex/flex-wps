package user_panel;

use strict;
use vars qw(
    %user_data %cfg
    $Flex_WPS $AUBBC_mod %back_ends
    %msg %usr %nav
    );
use exporter;

sub sub_action {
  return ( user_panel_main => 1, user_panel_user => 1, user_panel_pm_alert => 1);
}

sub user_panel_main {
my @data = ();
my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM mainmenu WHERE `active` = '1'");
$sth->execute;
while(my @row = $sth->fetchrow) {

$row[4] = '' if ! $row[4];
$row[3] = '' if ! $row[3];

 if ($row[2] && $row[1]) {
  $row[2] = $Flex_WPS->eval_theme_tags($row[2]);
  push (@data,
    join ('|', $row[1], $row[2], $row[3], $row[4])
        );
 }
}
$sth->finish;
my $mainmenu = main_menu(@data);
print $mainmenu;
}

sub user_panel_user {
        # Get help topic.
#         my $script_name = $ENV{SCRIPT_NAME};
#         $script_name =~ s(^.*/)();
#         my ($topic, undef) = split (/\./, $script_name);

        my $user_panel = $Flex_WPS->box_header(''); # "$msg{my} Account"

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

$user_panel .= $Flex_WPS->box_footer();

print $user_panel if $user_data{sec_level} eq $usr{admin};
}

sub user_panel_pm_alert {
my $pmlist = '';
my $printlist = '';
my $incount = 0;

if ($user_data{uid} ne $usr{anonuser}) {
#require theme;
 # Text and word Wrap, default Perl Module!
 use Text::Wrap;
 $Text::Wrap::columns = 25; # Wrap at 25 characters for menu

my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM `pmin` WHERE `memberid` = '$user_data{id}' AND `new` = '1'");
$sth->execute;
while(my @row = $sth->fetchrow) {
# build message
if ($row[6]) {
$incount++;
my $subject = wrap('', '', $row[4]);
$pmlist .= menu_item("$cfg{pageurl}/index.$cfg{ext}?op=view_pm,PM", $subject, '', "icon/exclamation.gif");
 }
}
$sth->finish(); #}
if ($incount) {
$printlist = $Flex_WPS->box_header("$incount New Message(s)");
$printlist .= $pmlist;
$printlist .= $Flex_WPS->box_footer();
print $printlist;
 }
}
}

sub main_menu {
my (@menu_content) = @_;
my $main_menu    = $Flex_WPS->box_header($nav{main_menu});

foreach (@menu_content) {
# Add special images to the main menu
my ($title, $link, $image1, $image2) = split (/\|/, $_);
if($image1 && $image2) { $main_menu .= menu_item($link, $title, $image1, $image2);
} elsif ($image1) { $main_menu .= menu_item($link, $title, $image1, '');
} elsif ($image2) { $main_menu .= menu_item($link, $title, '', $image2);
} else { $main_menu .= menu_item($link, $title, '', ''); }
}

$main_menu .= $Flex_WPS->box_footer();

return $main_menu;
}

sub menu_item {
my ($page, $title, $image, $image1) = @_;
my $logout = '';
$logout = ' onclick="javascript:return confirm(\'Are you sure you want to Logout?\')"'
        if $title eq $nav{logout};
# Default
my $menu = "<img src=\"$cfg{themesurl}/$cfg{default_theme}/images/dot.gif\" alt=\"$title\" />&nbsp;<a href=\"$page\" class=\"menu\"$logout>$title</a>";
if ($image && $image1) { # Link & Dot image
$menu = "<img src=\"$cfg{imagesurl}/$image1\" alt=\"$title\" />&nbsp;<a href=\"$page\"$logout><img src=\"$cfg{imagesurl}/$image\" border=\"0\" alt=\"$title\" /></a>";
} elsif (!$image1 && $image) { # Link image
$menu = "<img src=\"$cfg{themesurl}/$cfg{default_theme}/images/dot.gif\" alt=\"$title\" />&nbsp;<a href=\"$page\"$logout><img src=\"$cfg{imagesurl}/$image\" border=\"0\" alt=\"$title\" /></a>";
} elsif (!$image && $image1) { # Dot image
$menu = "<img src=\"$cfg{imagesurl}/$image1\" alt=\"$title\" />&nbsp;<a href=\"$page\" class=\"menu\"$logout>$title</a>";
}

        return <<HTML;
<div class="cat">$menu</div>
HTML

}
1;
