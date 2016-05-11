package flex_blog;

use strict;
# Assign global variables.
use vars qw(
    $query $Flex_WPS $AUBBC_mod %back_ends
    %user_data %err %cfg %user_action
    %btn %usr %msg
    );
use exporter;
%user_action = (
        palm  => $usr{anonuser},
        palm2  => $usr{anonuser},
        blog => $usr{anonuser},
        admin => $usr{admin},
        view => $usr{admin},
        view2 => $usr{admin},
        add_post => $usr{admin},
        add_post2 => $usr{admin},
        save_set => $usr{admin}
        );

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

my $id = $query->param('id') || '';
my $bmover = $query->param('move') || '';

sub palm {

my $blog_html = '';
$AUBBC_mod->settings(href_target => 1);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM `flex_blog` WHERE `blog_loc` = 'h' ORDER BY `date` DESC ;");
$sth->execute;
while(my @row = $sth->fetchrow) {
$row[2] = $AUBBC_mod->do_all_ubbc($row[2]);
$blog_html .= <<HTML;
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td>
<a href="$cfg{pageurl}/index.$cfg{ext}?op=palm2,flex_blog;id=$row[0]">$row[2]</a>
</td>
</tr>

</table>
HTML

}
$sth->finish();
print <<HTML;
Content-type: text/html


<html>
<head>
<meta name="description" content="Palm Pilot News Veiw" />
<title>$cfg{pagetitle} - Palm Pilot</title>
</head>
<body>
<h3><font color="#000070">$cfg{pagetitle}</font></h3>
<p>News on the go!</p>
$blog_html
<p>-----------------------</p>
</body>
</html>
HTML
}

sub palm2 {

my $blog_html = '';
my $desc = '';
$AUBBC_mod->settings(href_target => 1);
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM `flex_blog` WHERE `id` = $id LIMIT 1 ;");
$sth->execute;
while(my @row = $sth->fetchrow) {
$desc = $row[2];
$row[2] = $AUBBC_mod->do_all_ubbc($row[2]);
$row[3] = $AUBBC_mod->do_all_ubbc($row[3]);

$row[3] =~ s{\<\/?aubbc\>}{}g;
$blog_html .= <<HTML;
<table border="0" cellpadding="0" cellspacing="0" width="100%">
 <tr>
  <td>
<big><b>$row[2]</b></big><hr>
$row[3]
  </td>
 </tr>
</table>
HTML

}
$sth->finish();
print <<HTML;
Content-type: text/html


<html>
<head>
<meta name="description" content="Palm Pilot News Description - $desc" />
<title>$cfg{pagetitle} - $desc</title>
</head>
<body>
<h3><font color="#000070">$cfg{pagetitle}</font></h3>
<p>News on the go!</p>
$blog_html
<p><a href="$cfg{homeurl}/palm/">Other News</a><br>
-----------------------
</p>
</body>
</html>
HTML
}

sub blog {
 my $page = $query->param('page') || 0;
 my $plain = $query->param('plain') || 0;
 $page = $Flex_WPS->untaint2(value => $page, pattern => '\d',);
 $page = 0 if ! $page;
 my $page_start = $cfg{flex_blog}[0];
 my $do_page = '';
 if ($page eq 0) {
   $do_page = '&#60;&#60;Last';
 }
  else {
  $do_page = $page - $page_start;
  my $link = "$cfg{pageurl}/index.$cfg{ext}?op=blog,flex_blog;page=$do_page";
  $do_page = "<a href=\"$link\">&#60;&#60;Last</a>";
 }
my $next_page = $page_start + $page;
my $link = "$cfg{pageurl}/index.$cfg{ext}?op=blog,flex_blog;page=$next_page";
 $next_page = <<HTML;
$do_page |
 <a href="$link">Next&#62;&#62;</a>
HTML

my $admin_link = '';
$admin_link = &admin_menu ." | <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;move=h\" target=\"\">Add Blog Post</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 );

my $blog_html = '';
$AUBBC_mod->settings(href_target => 1);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM `flex_blog` WHERE `blog_loc` = 'h' ORDER BY `date` DESC LIMIT $page , $page_start ;");
$sth->execute;
while(my @row = $sth->fetchrow) {
if ($row[0]) {
$row[2] = $AUBBC_mod->do_all_ubbc($row[2]);
$row[3] = $AUBBC_mod->do_all_ubbc($row[3]);
$row[5] = $Flex_WPS->format_date($row[5], 3); # date

$row[3] =~ s{\<\/?aubbc\>}{}g;

my $admin_linkmove = '';
$admin_linkmove =
"<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;move=r;id=$row[0]\" target=\"\">Move To Blog Draft</a> |
 <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;id=$row[0]\" onclick=\"javascript:return confirm('Are you sure you want to Delete this item?')\">Delete This Post</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 ) && $row[6] eq 'h';

my $edit_link = "<small>Last Edited: $row[5]</small><br /><a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;id=$row[0]\" target=\"\">Edit Blog Post</a><br />" if $admin_link;
$blog_html .= <<HTML;
<table border="0" width="100%" class="navtable" cellspacing="0" cellpadding="3">
<tr>
<td valign="top">$edit_link$admin_linkmove</td>
</tr>
<tr>
<td valign="top">
<img align="left" src="$cfg{imagesurl}/icon/$row[4]" alt="" />&nbsp;&nbsp;<b>$row[2]</b><hr />
$row[3]
</td>
</tr>
</table>
<br />
HTML
 }
}
$sth->finish();

$link = ($blog_html)
 ? "<a href=\"$link\">Next&#62;&#62;</a>"
 : '';

$next_page = <<HTML;
$do_page |
 $link
HTML

#if ($blog_html) {
#$cfg{theme_description} = $blog_html;
#$cfg{theme_description} =~ s{<\/?(?s).*?\/?>}{ }g;
#$cfg{theme_description} =~ s{\[\/?.+?\]}{ }g;
#$cfg{theme_description} =~ s{(?:\r?\n|\s?\s)}{ }g;
# if (length($cfg{theme_description}) > 150) {
#  $cfg{theme_description} = substr($cfg{theme_description}, 0, 150);
#  $cfg{theme_description} =~ s/(.*)\s.*/$1/;
# }
#$cfg{theme_keywords} = $cfg{theme_description};
# if (length($cfg{theme_keywords}) > 69) {
#  $cfg{theme_keywords} = substr($cfg{theme_keywords}, 0, 69);
#  $cfg{theme_keywords} =~ s/(.*)\s.*/$1/;
# }
#}

$Flex_WPS->print_page(
        markup       => $admin_link . $blog_html . $next_page,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Services '.$page,
        );
}
sub admin_menu {
return <<HTML;
<b>Flex-Blog Administrator</b><br /><hr />
<a href="$cfg{pageurl}/index.$cfg{ext}?op=admin,flex_blog" target=\"\">Blog Settings</a> |
 <a href="$cfg{pageurl}/index.$cfg{ext}?op=view,flex_blog" target=\"\">Blog Draft's</a> |
 <a href="$cfg{pageurl}/index.$cfg{ext}?op=view2,flex_blog" target=\"\">Blog Main Page</a>
HTML
}

sub admin {
my $blog_html = &admin_menu;
$blog_html .= '<hr /><br /><center><b>Post was added.</b></center><br />' if $id eq 'added';
$blog_html .= '<hr /><br /><center><b>Settings where saved.</b></center><br />' if $id eq 'set';
$blog_html .= '<hr /><br /><center><b>Post was moved to the Main page.</b></center><br />' if $id eq 'moved';
$blog_html .= '<hr /><br /><center><b>Post was moved to the Draft page.</b></center><br />' if $id eq 'moveh';
$blog_html .= '<hr /><br /><center><b>Post was Edited.</b></center><br />' if $id eq 'Edited';
$blog_html .= '<hr /><br /><center><b>Post was Deleted.</b></center><br />' if $id eq 'deleted';
$blog_html .= <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Flex-Blog Settings Edit</p>
Here you can edit how many items show on each page and Home page.<br />
</td>
</tr></table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>Main</b></td>
    <td width="26%"><b>Draft</b></td>
    <td width="17%"><b>Home Page</b></td>
    <td width="19%"></td>
  </tr>
</table>
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="save_set,flex_blog">
<input type="hidden" name="id" value="$cfg{flex_blog}[3]">
  <tr align="center">
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')">
    </td>
    <td width="26%">
       <select name="main_page">
          <option value="$cfg{flex_blog}[0]" selected>$cfg{flex_blog}[0]</option>
          <option value="0">Off</option>
          <option value="1">1</option>
          <option value="2">2</option>
          <option value="3">3</option>
          <option value="5">5</option>
          <option value="10">10</option>
          <option value="15">15</option>
          <option value="20">20</option>
        </select>
      </td>
    <td width="26%">
       <select name="draft_page">
          <option value="$cfg{flex_blog}[1]" selected>$cfg{flex_blog}[1]</option>
          <option value="0">Off</option>
          <option value="1">1</option>
          <option value="2">2</option>
          <option value="3">3</option>
          <option value="5">5</option>
          <option value="10">10</option>
          <option value="15">15</option>
          <option value="20">20</option>
        </select>
      </td>
    <td width="17%">
       <select name="home_page">
          <option value="$cfg{flex_blog}[2]" selected>$cfg{flex_blog}[2]</option>
          <option value="0">Off</option>
          <option value="1">1</option>
          <option value="2">2</option>
          <option value="3">3</option>
          <option value="5">5</option>
          <option value="10">10</option>
          <option value="15">15</option>
          <option value="20">20</option>
        </select>
      </td>
      <td>&nbsp;</td>
  </tr>
 </form>
</table>
HTML

$Flex_WPS->print_page(
        markup       => $blog_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Flex-Blog Administrator View',
        );
}

sub view {
my $page = $query->param('page') || 0;
$page = $Flex_WPS->untaint2(value => $page, pattern => '\d',);
$page = 0 if ! $page;
my $page_start = $cfg{flex_blog}[1];
my $do_page = '';
  if ($page eq 0) {
   $do_page = '&#60;&#60;Last';
  }
   else {
   $do_page = $page - $page_start;
   my $link = "$cfg{pageurl}/index.$cfg{ext}?op=view,flex_blog;page=$do_page";
   $do_page = "<a href=\"$link\">&#60;&#60;Last</a>";
   }
my $next_page = $page_start + $page;
my $link = "$cfg{pageurl}/index.$cfg{ext}?op=view,flex_blog;page=$next_page";

my $admin_link = '';
$admin_link = &admin_menu ." | <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;move=r\" target=\"\">Add Blog Draft</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 );

my $blog_html = '';
$AUBBC_mod->settings(href_target => 1);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM `flex_blog` WHERE `blog_loc` = 'r' ORDER BY `date` DESC LIMIT $page , $page_start ;");
$sth->execute;
while(my @row = $sth->fetchrow) {
if ($row[0]) {
$row[2] = $AUBBC_mod->do_all_ubbc($row[2]);
$row[3] = $AUBBC_mod->do_all_ubbc($row[3]);
$row[5] = $Flex_WPS->format_date($row[5], 3); # date

$row[3] =~ s{\<\/?aubbc\>}{}g;

my $admin_linkmove = '';
$admin_linkmove = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;move=h;id=$row[0]\" target=\"\">Move To Main Page</a> |
 <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;id=$row[0]\" onclick=\"javascript:return confirm('Are you sure you want to Delete this item?')\">Delete This Post</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 ) && $row[6] eq 'r';
 
my $edit_link = " <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;id=$row[0]\" target=\"\">Edit Blog Draft</a>" if $admin_link;
$blog_html .= <<HTML;
<table border="0" width="100%" class="navtable" cellspacing="0" cellpadding="3">
<tr>
<td valign="top"><small>Last Edited: $row[5]</small><br />$edit_link <br /> $admin_linkmove</td>
</tr>
<tr>
<td valign="top">
<img align="left" src="$cfg{imagesurl}/icon/$row[4]" alt="" />&nbsp;&nbsp;<b>$row[2]</b><hr />
$row[3]
</td>
</tr>
</table>
<br />
HTML
 }
}
$sth->finish();

$link = ($blog_html)
 ? "<a href=\"$link\">Next&#62;&#62;</a>"
 : '';

$next_page = <<HTML;
$do_page |
 $link
HTML

$Flex_WPS->print_page(
        markup       => $admin_link . $blog_html . $next_page,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Flex-Blog Draft View',
        );
}

sub view2 {
my $page = $query->param('page') || 0;
$page = $Flex_WPS->untaint2(value => $page, pattern => '\d',);
$page = 0 if ! $page;
my $page_start = $cfg{flex_blog}[0];
my $do_page = '';
  if ($page eq 0) {
   $do_page = '&#60;&#60;Last';
  }
   else {
   $do_page = $page - $page_start;
   my $link = "$cfg{pageurl}/index.$cfg{ext}?op=view2,flex_blog;page=$do_page";
   $do_page = "<a href=\"$link\">&#60;&#60;Last</a>";
   }
my $next_page = $page_start + $page;
my $link = "$cfg{pageurl}/index.$cfg{ext}?op=view2,flex_blog;page=$next_page";

my $admin_link = '';
$admin_link = &admin_menu ." | <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;move=h\" target=\"\">Add Blog Post</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 );

my $blog_html = '';
$AUBBC_mod->settings(href_target => 1);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM `flex_blog` WHERE `blog_loc` = 'h' ORDER BY `date` DESC LIMIT $page , $page_start ;");
$sth->execute;
while(my @row = $sth->fetchrow) {
if ($row[0]) {
$row[2] = $AUBBC_mod->do_all_ubbc($row[2]);
$row[3] = $AUBBC_mod->do_all_ubbc($row[3]);
$row[5] = $Flex_WPS->format_date($row[5], 3); # date

$row[3] =~ s{\<\/?aubbc\>}{}g;

my $admin_linkmove = '';
$admin_linkmove = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;move=r;id=$row[0]\" target=\"\">Move To Blog Draft</a> |
 <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;id=$row[0]\" onclick=\"javascript:return confirm('Are you sure you want to Delete this item?')\">Delete This Post</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 ) && $row[6] eq 'h';

my $edit_link = " <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;id=$row[0]\" target=\"\">Edit Blog Post</a>" if $admin_link;
$blog_html .= <<HTML;
<table border="0" width="100%" class="navtable" cellspacing="0" cellpadding="3">
<tr>
<td valign="top"><small>Last Edited: $row[5]</small><br />$edit_link <br /> $admin_linkmove</td>
</tr>
<tr>
<td valign="top">
<img align="left" src="$cfg{imagesurl}/icon/$row[4]" alt="" />&nbsp;&nbsp;<b>$row[2]</b><hr />
$row[3]
</td>
</tr>
</table>
<br />
HTML
 }
}
$sth->finish();

$link = ($blog_html)
 ? "<a href=\"$link\">Next&#62;&#62;</a>"
 : '';

$next_page = <<HTML;
$do_page |
 $link
HTML

$Flex_WPS->print_page(
        markup       => $admin_link . $blog_html . $next_page,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Flex-Blog Home View',
        );
}

sub add_post {
# the UBBC image selector.
require UBBC;
# Print the UBBC panel.
my $ubbc_panel = UBBC::print_ubbc_panel();

my $add_ok = &admin_menu.'<hr />';

my @row = ('','','','','','');
my @row2 = ('','','','','','');
if ($id) {
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM flex_blog WHERE `id` = $id LIMIT 1 ;");
$sth->execute;
@row = $sth->fetchrow;
$sth->finish();
@row2 = @row;
}
my $ubbc_image_selector = UBBC::print_ubbc_image_selector($row[4]);

if ($row[3]) {
$row[3] =~ s/<\/textarea>/&#60;\/textarea&#62;/g;
$row[3] =~ s/(<aubbc>(?s)(.*?)<\/aubbc>)/
        my $ret = $AUBBC_mod->html_to_text( $2 );
        $ret ? '<aubbc>'.$ret."<\/aubbc>" : $1;
        /exigo;
$row[3] = $AUBBC_mod->script_escape( $row[3], 1 );
}

         my $post_html = <<HTML;
$add_ok
<table width="100%" border="0" cellspacing="0" cellpadding="1">
<tr>
<td><form action="" method="post" name="creator">
<table border="0">
<tr>
<td><b>$msg{subjectC}</b></td>
<td><input type="text" name="subject" value="$row[2]" size="40" maxlength="100" /></td>
</tr>
<tr>
<td><b>$msg{symbolC}</b></td>
<td>
$ubbc_image_selector
<textarea wrap="off" name="message" rows="20" cols="70">$row[3]</textarea></td>
</tr>
<tr>
<td><b>$msg{ubbc_tagsC}</b></td>
<td valign="top">
$ubbc_panel
</td>
</tr>
<tr>
<td align="center" colspan="2">
<input type="hidden" name="id" value="$row[0]" />
<input type="hidden" name="move" value="$bmover" />
<input type="hidden" name="op" value="add_post2,flex_blog" />
<br />
<input type="submit" value="$btn{submit}" />
<input type="reset" value="$btn{reset}" /></td>
</tr>
</table>
</form>
</td>
</tr>
</table>
HTML
if ($id) {
$row2[2] = $AUBBC_mod->do_all_ubbc($row2[2]);
$row2[3] = $AUBBC_mod->do_all_ubbc($row2[3]);
$row2[5] = $Flex_WPS->format_date($row2[5], 3); # date

$row2[3] =~ s{\<\/?aubbc\>}{}g;

my $admin_linkmove = '';
$admin_linkmove =
"<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;move=r;id=$row2[0]\" target=\"\">Move To Blog Draft</a> |
 <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;id=$row2[0]\" onclick=\"javascript:return confirm('Are you sure you want to Delete this item?')\">Delete This Post</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 ) && $row2[6];

my $edit_link = "<small>Last Edited: $row2[5]</small><br /><a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;id=$row2[0]\" target=\"\">Edit Blog Post</a><br />";

$post_html .= <<HTML;
<hr /><big><b>Unedited Message:</b></big><hr />
<table border="0" width="100%" class="navtable" cellspacing="0" cellpadding="3">
<tr>
<td valign="top">$edit_link$admin_linkmove</td>
</tr>
<tr>
<td valign="top">
<img align="left" src="$cfg{imagesurl}/icon/$row2[4]" alt="" />&nbsp;&nbsp;<b>$row2[2]</b><hr />
$row2[3]
</td>
</tr>
</table>
<br />
HTML
}
# <IFRAME width="650" height="400" SRC="$cfg{pageurl}/index.$cfg{ext}?op=print_thread,Forum;cat=$cat;subcat=$subcat;thread=$thread;sticky=$sticky;id=4" marginwidth="1" marginheight="1" border="1" frameborder="1"></IFRAME>

$Flex_WPS->print_page(
        markup       => $post_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Add Blog Post',
        );
}

sub add_post2 {
my $subject = $query->param('subject') || '';
my $message = $query->param('message') || '';
my $icon = $query->param('icon') || '';
my $moved_to = '';
$message =~ s/&#60;\/textarea&#62;/<\/textarea>/g if $message;
if ($id && ! $subject && ! $message && ! $bmover) { # delete
$moved_to = 'deleted';
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM flex_blog WHERE `id` = $id");
}
 elsif ($id && $subject && $message) { # Edit
 $moved_to = 'Edited';
$message =~ s/(<aubbc>(?s)(.*?)<\/aubbc>)/
        my $ret = $AUBBC_mod->script_escape( $2 );
        $ret ? '<aubbc>'.$ret."<\/aubbc>" : $1;
        /exigo;
$subject = $AUBBC_mod->script_escape($subject);
 $subject = $back_ends{$cfg{Portal_backend}}->quote($subject);
 $message = $back_ends{$cfg{Portal_backend}}->quote($message);
 $icon = $back_ends{$cfg{Portal_backend}}->quote($icon);
 $id = $back_ends{$cfg{Portal_backend}}->quote($id);
my $date = $Flex_WPS->get_date();
$date = $back_ends{$cfg{Portal_backend}}->quote($date);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE flex_blog SET `user_id` = '$user_data{id}',
`subject` = $subject, `message` = $message, `symbol` = $icon , `date` = $date WHERE `id` = $id LIMIT 1 ;");
}
  elsif ($bmover && $subject && $message && ($bmover eq 'h' || $bmover eq 'r')) { # Add
  $moved_to = 'added';
$subject = $AUBBC_mod->script_escape($subject);
$message =~ s/(<aubbc>(?s)(.*?)<\/aubbc>)/
        my $ret = $AUBBC_mod->script_escape( $2 );
        $ret ? '<aubbc>'.$ret."<\/aubbc>" : $1;
        /exigo;
$subject = $back_ends{$cfg{Portal_backend}}->quote($subject);
$message = $back_ends{$cfg{Portal_backend}}->quote($message);
$icon = $back_ends{$cfg{Portal_backend}}->quote($icon);
$bmover = $back_ends{$cfg{Portal_backend}}->quote($bmover);
my $date = $Flex_WPS->get_date();
$date = $back_ends{$cfg{Portal_backend}}->quote($date);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO flex_blog VALUES (NULL,$user_data{id},$subject,$message,$icon,$date,$bmover);");
}
 elsif ($bmover && $bmover eq 'h' && $id) {
 $moved_to = 'moved';
 $id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE flex_blog SET `blog_loc` = 'h' WHERE `id` = $id LIMIT 1 ;");
}
 elsif ($bmover && $bmover eq 'r' && $id) {
 $moved_to = 'moveh';
 $id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE flex_blog SET `blog_loc` = 'r' WHERE `id` = $id LIMIT 1 ;");
 }
 
# Redirect to user_actions page.
print $query->redirect(
        -location => "$cfg{pageurl}/index.$cfg{ext}?op=admin,flex_blog;id=$moved_to"
        );
}

sub save_set {

my $main_page = $query->param('main_page') || 0;
my $draft_page = $query->param('draft_page') || 0;
my $home_page = $query->param('home_page') || 0;
$main_page = $back_ends{$cfg{Portal_backend}}->quote("$main_page|$draft_page|$home_page");
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `module_settings` SET `settings` = $main_page WHERE `id` = $id LIMIT 1 ;");

# Redirect to user_actions page.
print $query->redirect(
        -location => "$cfg{pageurl}/index.$cfg{ext}?op=admin,flex_blog;id=set"
        );
}

1;

__END__

=pod

=head1 COPYLEFT

flex_blog.pm, v1.06 01/21/2011 N.K.A.
Works with Flex-WPS Evolution 3 v1.0 series

mini blog, home page, draft, aubbc, palm,
post message view, module settings.

TODO: Need to combine all the views to 1 sub or remove 1 main.

Flex Web Portal System Evolution 3

Main Developer:
 N.K.A.
 shakaflex [at] gmail.com
 http://search.cpan.org/~sflex/

=cut
