package home_blog;

use strict;
use vars qw(
    %user_data %cfg %usr
    $Flex_WPS $AUBBC %back_ends
    %nav %msg
    );
use Flex_Porter;

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
  return (view => 1);
}

sub view {
 if ($cfg{flex_blog}[2]) {
 
my $admin_link = '';
$admin_link = "<a class=\"small pure-button pure-button-active\" href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;move=h\" target=\"_self\">Add Blog Post</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 );

my $blog_html = '';
#$AUBBC_mod->settings(href_target => 1);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM `flex_blog` WHERE `blog_loc` = 'h' ORDER BY `date` DESC LIMIT $cfg{flex_blog}[2] ;");
$sth->execute;
while(my @row = $sth->fetchrow) {
$row[2] = $AUBBC->parse_bbcode($row[2]);
$row[3] = $AUBBC->parse_bbcode($row[3]);
$row[5] = $Flex_WPS->format_date($row[5], 3); # date

$row[3] =~ s{\<\/?aubbc\>}{}g;

my $admin_linkmove = '';
$admin_linkmove =
"<a class=\"small pure-button pure-button-active\" href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;move=r;id=$row[0]\">Move To Blog Draft</a>
 <a class=\"small pure-button pure-button-active\" href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;id=$row[0]\" onclick=\"return ConfirmDelete();\">Delete This Post</a></p>"
 if $admin_link && $row[6] eq 'h';

my $edit_link = '';
$edit_link = <<"HTML" if $admin_link;
<h2 class="wid1 pad content-subhead small">Last Edited: $row[5]</h2>
<p>
<a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;id=$row[0]">Edit Blog Post</a>

HTML
$blog_html .= <<"HTML";
$edit_link$admin_linkmove
<h2 class="wid1 brdr pad content-subhead">&nbsp;<img class="pure-img-responsive img-l" src="$cfg{imagesurl}/icon/$row[4]" alt="" />&nbsp;&nbsp;$row[2]&nbsp;</h2>
<p class="img-c iflow wid1 brdr pad">$row[3]</p>
<hr />
HTML
}
$sth->finish();

        return <<"HTML";
$admin_link
$blog_html
HTML

 }
}

1;
