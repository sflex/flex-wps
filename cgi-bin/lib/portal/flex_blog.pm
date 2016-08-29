package flex_blog;
# TODO: review code
use strict;
# Assign global variables.
use vars qw(
    $query $Flex_WPS $AUBBC %back_ends
    %user_data %err %cfg %user_action
    %btn %usr %msg
    );
use Flex_Porter;
%user_action = (
        palm  => $usr{anonuser},
        palm2  => $usr{anonuser},
        blog => $usr{anonuser},
        admin => $usr{admin},
        view => $usr{admin},
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

# This is an old support for palm pilot and old mobile devices
# plain HTML view for mobile devices
sub palm {

my $blog_html = '';
$AUBBC->add_a_setting('href_target', ' target="_blank"');
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
'SELECT * FROM `flex_blog` WHERE `blog_loc` = \'h\' ORDER BY `date` DESC ;');
$sth->execute;
while(my @row = $sth->fetchrow) {
$row[2] = $AUBBC->parse_bbcode($row[2]);
 $blog_html .= <<"HTML";
<h2><a href="$cfg{pageurl}/index.$cfg{ext}?op=palm2,flex_blog;id=$row[0]">$row[2]</a></h2><hr>
HTML

}
$sth->finish();
 print <<"HTML";
Content-type: text/html


<html>
<head>
<meta name="description" content="Palm Pilot News Veiw">
<title>$cfg{pagetitle} - Palm Pilot</title>
</head>
<body>
<div>
<h1><font color="#000070">$cfg{pagetitle}</font></h1>
<p>News on the go!</p>
$blog_html
<p>-----------------------</p>
</div>
</body>
</html>
HTML
}

sub palm2 {

my $blog_html = '';
my $desc = '';
$AUBBC->add_a_setting('href_target', ' target="_blank"');
$id = $Flex_WPS->untaint2(value => $id, pattern => '\d',);

if ($id) {
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM `flex_blog` WHERE `id` = $id LIMIT 1 ;");
$sth->execute;
while(my @row = $sth->fetchrow) {
$desc = $row[2];
$row[2] = $AUBBC->parse_bbcode($row[2]);
$row[3] = $AUBBC->parse_bbcode($row[3]);

$row[3] =~ s{\<\/?aubbc\>}{}g;
$blog_html .= <<HTML;
<h2>$row[2]</h2>
<p>$row[3]</p>
HTML

}
$sth->finish();
}

print <<HTML;
Content-type: text/html


<html>
<head>
<meta name="description" content="Palm Pilot News Description - $desc" />
<title>$cfg{pagetitle} - $desc</title>
</head>
<body>
<div>
<h1><font color="#000070">$cfg{pagetitle}</font></h1>
<p>News on the go!</p>
$blog_html
<p><a href="$cfg{homeurl}/palm/">Other News</a><br>
-----------------------
</p></div>
</body>
</html>
HTML
}

sub blog {
 my $page = $query->param('page') || 0;
 $page = $Flex_WPS->untaint2(value => $page, pattern => '\d',);
 $page = 0 if ! $page || $page >= 999999999;
 my $page_start = $cfg{flex_blog}[0];
 my $do_page = '';
 if ($page eq 0) {
   $do_page = '<a class="pure-button pure-button-disabled" href="#">&#60;&#60;Last</a>';
 }
  else {
  $do_page = $page - $page_start;
  my $link = "$cfg{pageurl}/index.$cfg{ext}?op=blog,flex_blog;page=$do_page";
  $do_page = "<a class=\"pure-button pure-button-active\" href=\"$link\" target=\"_self\">&#60;&#60;Last</a>";
 }
my $next_page = $page_start + $page;
my $link = "$cfg{pageurl}/index.$cfg{ext}?op=blog,flex_blog;page=$next_page";
 $next_page = <<"HTML";
$do_page <a class="pure-button pure-button-active" href="$link">Next&#62;&#62;</a>
HTML

my $admin_link = '';
$admin_link = &admin_menu ." <a class=\"pure-button pure-button-active\" href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;move=h\" target=\"_self\">Add Blog Post</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 );

my $blog_html = '';
$AUBBC->add_a_setting('href_target', ' target="_blank"');
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM `flex_blog` WHERE `blog_loc` = 'h' ORDER BY `date` DESC LIMIT $page , $page_start ;");
$sth->execute;
while(my @row = $sth->fetchrow) {
if ($row[0]) {
$row[2] = $AUBBC->parse_bbcode($row[2]);
$row[3] = $AUBBC->parse_bbcode($row[3]);
$row[5] = $Flex_WPS->format_date($row[5], 3); # date

$row[3] =~ s{\<\/?aubbc\>}{}g;

my $admin_linkmove = '';
$admin_linkmove =
"<a class=\"pure-input-1 pure-button pure-button-active\" href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;move=r;id=$row[0]\" target=\"_self\">Move To Blog Draft</a>
 <a class=\"pure-input-1 pure-button pure-button-active\" href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;id=$row[0]\" onclick=\"return ConfirmDelete();\">Delete This Post</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 ) && $row[6] eq 'h';
 
my ($edit_link,$edit_link_last) = ('','');
$edit_link_last = '</fieldset>' if $admin_link;
$edit_link = <<"HTML" if $admin_link;
<fieldset>
<legend><small>Last Edited: $row[5]</small></legend>
<a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;id=$row[0]" target="_self">Edit Blog Post</a>
HTML
$blog_html .= <<"HTML";
$edit_link$admin_linkmove
 <fieldset>
  <legend><h3 class="content-subhead">&nbsp;<img class="pure-img-responsive img-l" src="$cfg{imagesurl}/icon/$row[4]" alt="icon" />&nbsp;&nbsp;<b>$row[2]</b>&nbsp;</h3></legend>
<p>$row[3]</p>
</fieldset>
$edit_link_last
<br />
HTML
 }
}
$sth->finish();
    
$link = ($blog_html)
 ? '<a class="pure-button pure-button-active" href="'.$link.'">Next&#62;&#62;</a>'
 : '';

$next_page =$do_page.' '.$link;

$Flex_WPS->print_page(
        markup       => $admin_link . $blog_html . $next_page,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Flex-Blog Home View',
        );
}

sub admin_menu {
return <<"HTML";
<h1>Flex-Blog Administrator</h1>
<a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=admin,flex_blog" target="_self">Setting's</a>
 <a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=view,flex_blog" target="_self">Draft's</a>
 <a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=blog,flex_blog" target="_self">Main Page</a>
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
my $option_pages = <<'HTML';
          <option value="0">Off</option>
          <option value="1">1</option>
          <option value="2">2</option>
          <option value="3">3</option>
          <option value="5">5</option>
          <option value="10">10</option>
          <option value="15">15</option>
          <option value="20">20</option>
HTML
$blog_html .= <<"HTML";
<b>Flex-Blog Settings Edit</b><br />
Here you can edit how many items show on each page and Home page.<br />

<div class="pure-g">
    <div class="pure-u-1-12 pure-table all-c"><b>Edit</b></div>
    <div class="pure-u-1-12 pure-table all-c"><b>Main</b></div>
    <div class="pure-u-1-12 pure-table all-c"><b>Draft</b></div>
    <div class="pure-u-1-12 pure-table all-c"><b>Home</b></div>
</div>
<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="save_set,flex_blog" />
<input type="hidden" name="id" value="$cfg{flex_blog}[3]">
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button onclick="return ConfirmThis();" type="submit" class="pure-button pure-button-primary">Edit</button>
     </div>
     <div class="pure-u-1-12 all-c">
       <select name="main_page">
          <option value="$cfg{flex_blog}[0]" selected>$cfg{flex_blog}[0]</option>
          $option_pages
        </select>
        </div>
        <div class="pure-u-1-12 all-c">
        <select name="draft_page">
          <option value="$cfg{flex_blog}[1]" selected>$cfg{flex_blog}[1]</option>
          $option_pages
        </select>
        </div>
        <div class="pure-u-1-12 all-c">
        <select name="home_page">
          <option value="$cfg{flex_blog}[2]" selected>$cfg{flex_blog}[2]</option>
          $option_pages
        </select>
        </div>
    </div>
    </fieldset>
    </form>
</small>
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
   $do_page = '<a class="pure-button pure-button-disabled" href="#">&#60;&#60;Last</a>';
  }
   else {
   $do_page = $page - $page_start;
   my $link = "$cfg{pageurl}/index.$cfg{ext}?op=view,flex_blog;page=$do_page";
   $do_page = '<a class="pure-button pure-button-active" href="'.$link.'">&#60;&#60;Last</a>';
   }
my $next_page = $page_start + $page;
my $link = "$cfg{pageurl}/index.$cfg{ext}?op=view,flex_blog;page=$next_page";

my $admin_link = '';
$admin_link = &admin_menu ." <a class=\"pure-button pure-button-active\" href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;move=r\" target=\"_self\">Add Blog Draft</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 );

my $blog_html = '';
$AUBBC->add_a_setting('href_target', ' target="_blank"');
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM `flex_blog` WHERE `blog_loc` = 'r' ORDER BY `date` DESC LIMIT $page , $page_start ;");
$sth->execute;
while(my @row = $sth->fetchrow) {
if ($row[0]) {
$row[2] = $AUBBC->parse_bbcode($row[2]);
$row[3] = $AUBBC->parse_bbcode($row[3]);
$row[5] = $Flex_WPS->format_date($row[5], 3); # date

$row[3] =~ s{\<\/?aubbc\>}{}g;

my $admin_linkmove = '';
$admin_linkmove = "<a class=\"pure-button pure-button-active\" href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;move=h;id=$row[0]\" target=\"\">Move To Main Page</a>
 <a class=\"pure-button pure-button-active\" href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;id=$row[0]\" onclick=\"return ConfirmDelete();\">Delete This Post</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 ) && $row[6] eq 'r';
 
my ($edit_link,$edit_link_last) = ('','');
$edit_link_last = '</fieldset>' if $admin_link;
$edit_link = <<"HTML" if $admin_link;
<fieldset>
<legend><small>Last Edited: $row[5]</small></legend>
<a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;id=$row[0]" target="_self">Edit Blog Draft</a>
HTML
 
$blog_html .= <<"HTML";
$edit_link$admin_linkmove
<fieldset>
  <legend>&nbsp;<img class="pure-img img-l" src="$cfg{imagesurl}/icon/$row[4]" alt="icon" />&nbsp;&nbsp;<b>$row[2]</b>&nbsp;</legend>
<p>$row[3]</p>
</fieldset>
$edit_link_last
<br />
HTML
 }
}
$sth->finish();

$link = ($blog_html)
 ? '<a class="pure-button pure-button-active" href="'.$link.'">Next&#62;&#62;</a>'
 : '';

 $next_page =$do_page.' '.$link;

$Flex_WPS->print_page(
        markup       => $admin_link . $blog_html . $next_page,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Flex-Blog Draft View',
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
        my $ret = $AUBBC->html_to_text( $2 );
        $ret ? '<aubbc>'.$ret."<\/aubbc>" : $1;
        /exigo;
#$row[3] = $AUBBC->script_escape( $row[3], 1 );
}

         my $post_html = <<"HTML";
$add_ok
<small>
<form class="pure-form pure-form-stacked" method="post" name="creator">
<input type="hidden" name="id" value="$row[0]" />
<input type="hidden" name="move" value="$bmover" />
<input type="hidden" name="op" value="add_post2,flex_blog" />
    <fieldset>

        <label for="subject"><b>$msg{subjectC}</b></label>
        <input id="subject" class="pure-input-1" type="text" name="subject" placeholder="$msg{subjectC}.." value="$row[2]" />

        <label for="icon"><b>$msg{symbolC}</b></label>
        $ubbc_image_selector

        <label for="message"><b>$msg{textC}</b></label>
        <textarea id="message" placeholder="$msg{textC}.." name="message" rows="25" class="oflow pure-input-1">$row[3]</textarea>

        <label for="bbct"><b>$msg{ubbc_tagsC}</b></label>
        <div id="bbct">$ubbc_panel</div>
        <input onclick="return ConfirmThis();" class="pure-button pure-button-primary" type="submit" value="$btn{submit}" />&nbsp;&nbsp;&nbsp;<input onclick="return ConfirmThis();" class="pure-button pure-button-active" type="reset" value="$btn{reset}" />
    </fieldset>
</form>
</small>
HTML

if ($id) {
$row2[2] = $AUBBC->parse_bbcode($row2[2]);
$row2[3] = $AUBBC->parse_bbcode($row2[3]);
$row2[5] = $Flex_WPS->format_date($row2[5], 3); # date

$row2[3] =~ s{\<\/?aubbc\>}{}g;

my $admin_linkmove = '';
$admin_linkmove =
"<a class=\"pure-button pure-button-active\" href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;move=r;id=$row[0]\" target=\"_self\">Move To Blog Draft</a>
 <a class=\"pure-button pure-button-active\" href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_post2,flex_blog;id=$row[0]\" onclick=\"return ConfirmDelete();\">Delete This Post</a><hr />"
 if $Flex_WPS->check_access(
 class_sub => 'flex_blog::view-adminlink',
 sec_lvl   => $usr{admin},
 ) && $row2[6];

my ($edit_link,$edit_link_last) = ('','');
$edit_link_last = '</fieldset>' if $admin_linkmove;
$edit_link = <<"HTML" if $admin_linkmove;
<fieldset>
<legend><small>Last Edited: $row2[5]</small></legend>
<a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=add_post,flex_blog;id=$row2[0]" target="_self">Edit Blog Post</a>
HTML
$post_html .= <<"HTML";
$edit_link$admin_linkmove
 <fieldset>
  <legend>&nbsp;<img class="pure-img img-l" src="$cfg{imagesurl}/icon/$row2[4]" alt="icon" />&nbsp;&nbsp;<b>$row2[2]</b>&nbsp;</legend>
<p>$row2[3]</p>
</fieldset>
$edit_link_last
<br />
HTML

}

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
        my $ret = $AUBBC->script_escape( $2 );
        $ret ? '<aubbc>'.$ret."<\/aubbc>" : $1;
        /exigo;
$subject = $AUBBC->script_escape($subject);
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
$subject = $AUBBC->script_escape($subject);
$message =~ s/(<aubbc>(?s)(.*?)<\/aubbc>)/
        my $ret = $AUBBC->script_escape( $2 );
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
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `module_settings` SET `settings` = $main_page WHERE `id` = $id LIMIT 1 ;");

# Redirect to user_actions page.
print $query->redirect(
        -location => "$cfg{pageurl}/index.$cfg{ext}?op=admin,flex_blog;id=set"
        );
}

1;

__END__

=pod

=head1 Super Mod Paths

Administrator areas:
flex_blog::view-adminlink
flex_blog::admin
flex_blog::view
flex_blog::add_post
flex_blog::add_post2
flex_blog::save_set
        
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
