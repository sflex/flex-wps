package home_blog;

use strict;
use vars qw(
    %user_data %cfg %usr
    $Flex_WPS $AUBBC_mod %back_ends
    %nav %msg
    );
use exporter;

my ($blog_page, $draft_page, $home_view) = ('5','15','5');
unless (exists $cfg{flex_blog}) {
# Get flex_blog Module Settings
my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM module_settings WHERE module_name=\'flex_blog\'');
$sth->execute || die($DBI::errstr);
while(my @row = $sth->fetchrow)  {
($blog_page, $draft_page, $home_view) = split(/\|/, $row[2]);
$cfg{flex_blog} = [$blog_page, $draft_page, $home_view, $row[0]];
}
$sth->finish();
}

sub sub_action {
  return ( home_blog_view => 1);
}

sub home_blog_view {
 if ($cfg{flex_blog}[2]) {
 
my $admin_link = '';
$admin_link = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;move=h\" target=\"\">Add Blog Post</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 );

my $blog_html = '';
$AUBBC_mod->settings(href_target => 1);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM `flex_blog` WHERE `blog_loc` = 'h' ORDER BY `date` DESC LIMIT $cfg{flex_blog}[2] ;");
$sth->execute;
while(my @row = $sth->fetchrow) {
$row[2] = $AUBBC_mod->do_all_ubbc($row[2]);
$row[3] = $AUBBC_mod->do_all_ubbc($row[3]);
$row[5] = $Flex_WPS->format_date($row[5], 3); # date
my $admin_linkmove = '';
$admin_linkmove =
"| <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;move=r;id=$row[0]\" target=\"\">Move To Draft Page</a> |
 <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;id=$row[0]\" onclick=\"javascript:return confirm('Are you sure you want to Delete this item?')\">Delete This Post</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 ) && $row[6] eq 'h';

$row[3] =~ s{\<\/?aubbc\>}{}g;
my $edit_link = "<small>Last Edited: $row[5]</small><br /><a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;id=$row[0]\" target=\"\">Edit This Post</a>" if $admin_link;
$blog_html .= <<HTML;
<div class="navtable">
$edit_link $admin_linkmove
<img align="left" src="$cfg{imagesurl}/icon/$row[4]" alt="" />&nbsp;&nbsp;<b>$row[2]</b><hr />
$row[3]
</div>
<br />
HTML

}
$sth->finish();

        print <<HTML;
<hr />
$admin_link
$blog_html
HTML

 }
}

1;
