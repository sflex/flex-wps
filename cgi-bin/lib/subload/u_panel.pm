package u_panel;

use strict;
use vars qw(
    %user_data %cfg
    $Flex_WPS %back_ends
    %msg %usr %nav
    );
use Flex_Porter;

sub sub_action {
  return ( main => 1, user => 1, pm_alert => 1);
}

sub main {
my @data = ();
my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM mainmenu WHERE `active` = \'1\'');
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

return main_menu(@data);
}

sub user {
 my $user_panel = '<ul class="pure-menu-list">'."\n"; # "$msg{my} Account"
 my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM usermenu');
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
 elsif ($usr{user} eq $row[5] && ($user_data{sec_level} eq $usr{user}
 || $user_data{sec_level} eq $usr{admin} || $user_data{sec_level} eq $usr{mod})) {
   # Link Print              Link      Title    image 1  image 2
   $user_panel .= menu_item($row[2],$row[1],$row[3],$row[4]);
   }
}
$sth->finish;

$user_panel .= '</ul>'."\n";

return $user_panel;
}

sub pm_alert {
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
$sth->finish();

# menu content
$printlist = '<div class="pure-menu-heading"'.$incount.' New Message(s)</div>'."\n"
        .'<ul class="pure-menu-list">'."\n"
        .$pmlist
        .'</ul>'."\n"
        if $incount;

} # no anonuser
return $printlist;
}

sub main_menu {
my (@menu_content) = @_;
my $main_menu    = '<ul class="pure-menu-list">'."\n";

foreach (@menu_content) {
# Add special images to the main menu
my ($title, $link, $image1, $image2) = split (/\|/, $_);
if($image1 && $image2) { $main_menu .= menu_item($link, $title, $image1, $image2);
} elsif ($image1) { $main_menu .= menu_item($link, $title, $image1, '');
} elsif ($image2) { $main_menu .= menu_item($link, $title, '', $image2);
} else { $main_menu .= menu_item($link, $title, '', ''); }
}

$main_menu .= '</ul>'."\n";

return $main_menu;
}

sub menu_item {
my ($page, $title, $image, $image1) = @_;
my $logout = '';
$logout = ' onclick="return ConfirmThis();"'
 if $title eq $nav{logout};
# Default
my $menu = "<img class=\"pure-img-responsive img-l mrt5\" src=\"$cfg{themesurl}/$cfg{default_theme}/images/dot.gif\" alt=\"\" /><a href=\"$page\" class=\"img-l pure-menu-link\"$logout>$title</a><p class=\"clear\"></p>\n";
if ($image && $image1) { # Link & Dot image
$menu = "<img class=\"pure-img-responsive img-l mrt5\" src=\"$cfg{imagesurl}/$image1\" alt=\"\" /><a href=\"$page\" class=\"img-l pure-menu-link\"$logout><img class=\"img-l pure-img-responsive\" src=\"$cfg{imagesurl}/$image\" alt=\"$title\" /></a><p class=\"clear\"></p>\n";
} elsif (!$image1 && $image) { # Link image
$menu = "<img class=\"pure-img-responsive img-l mrt5\" src=\"$cfg{themesurl}/$cfg{default_theme}/images/dot.gif\" alt=\"\" /><a href=\"$page\"$logout><img class=\"img-l pure-img-responsive\" src=\"$cfg{imagesurl}/$image\" alt=\"$title\" /></a><p class=\"clear\"></p>\n";
} elsif (!$image && $image1) { # Dot image
$menu = "<img class=\"pure-img-responsive img-l mrt5\" src=\"$cfg{imagesurl}/$image1\" alt=\"\" /><a href=\"$page\" class=\"img-l pure-menu-link\"$logout>$title</a><p class=\"clear\"></p>\n";
}

 return '<li class="pure-menu-item">'."\n".$menu.'</li>'."\n";

}
1;
