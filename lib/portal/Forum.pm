package Forum;
# Forum.pm v1.0 beta 1 - 1/24/2011 By: N.K.A.
#
# Works with Flex-WPS Evo3 1.0
# Not fully converted, needs testing & fixes
#
# v1.0C - 1/02/2008
# - Added print function for posts
# - Added view all posts to post & modify post
#
# Notes: next version will have rss feeds
#
# Version History:
# v1.0B - 12/29/2007
# - Added Category name to Forum link
#
# v1.0A - 12/26/2007
# 95% complete
#
# vX? - 09/22/2006
# 75% complete
#
# SELECT LAST_INSERT_ID() AS id
# ANALYZE TABLE `forum_subcat`
# OPTIMIZE TABLE `forum_subcat`
# FLUSH TABLE `forum_subcat`
# Does not fully use the mySQL Query as it should
# This is only a simple forum =P

use strict;
# Assign global variables.
use vars qw(
    %user_action %cfg %user_data
    %nav %msg $query %err %usr %btn
    $AUBBC_mod $Flex_WPS %back_ends
    );
use exporter;

# Define possible user actions and Commen security level.
%user_action = (
 cats => $usr{anonuser},
 subcat => $usr{anonuser},
 threads => $usr{anonuser},
 modify  => $usr{user},
 modify2 => $usr{user},
 post    => $usr{anonuser},
 post2   => $usr{user},
 vote_user => $usr{user},
 do_vote => $usr{user},
 add_cat => $usr{admin},
 add_cat2 => $usr{admin},
 delete_post => $usr{admin},
 delete_thread => $usr{admin},
 delete_subcat => $usr{admin},
 delete_cat => $usr{admin},
 add_subcat => $usr{admin},
 add_subcat2 => $usr{admin},
 move => $usr{admin},
 optimize => $usr{admin},
 print_thread => $usr{anonuser},
 );

my $cat   = $query->param('cat') || '';
my $subcat   = $query->param('subcat') || '';
my $start   = $query->param('start') || 0;
my $thread =  $query->param('thread') || '';
my $icon = $query->param('icon') || 'xx.gif';
my $lock = $query->param('lock') || 0;
my $sticky = $query->param('sticky') || 'forums';
my $location = $query->param('location') || '';
my $id = $query->param('id') || '';
my $answer = $query->param('answer') || '';

my $subject = $query->param('subject') || '';
my $message = $query->param('message') || '';

$cfg{max_items_per_page} = 10;
# TG: Honey Pot 2
#require TG;
#TG::checker();
# TG: End

if ($location && $location !~ m!\A([\w\,\|\+\s\_\#]+)\z!i) { $Flex_WPS->user_error($err{bad_input}); }
#$sticky = 'forums' if $sticky eq 'forums|poll';
if ($answer && $answer !~ m!\A([0-9]+)\z!i) { $Flex_WPS->user_error($err{bad_input}); }
if ($id && $id !~ m!\A([0-9]+)\z!i) { $Flex_WPS->user_error($err{bad_input}); }
if ($cat && $cat !~ m!\A([0-9]+)\z!i) { $Flex_WPS->user_error($err{bad_input}); }
if ($subcat && $subcat !~ m!\A([0-9]+)\z!i) { $Flex_WPS->user_error($err{bad_input}); }
if ($thread && $thread !~ m!\A([0-9]+)\z!i) { $Flex_WPS->user_error($err{bad_input}); }
if ($icon && $icon !~ m!\A([\w\.\,]+)\z!i) { $Flex_WPS->user_error($err{bad_input}); }
if ($lock && $lock !~ m!\A([0-9]+)\z!i) { $Flex_WPS->user_error($err{bad_input}); }
if ($start && $start !~ m!\A([0-9]+)\z!i) { $Flex_WPS->user_error($err{bad_input}); }
if ($sticky !~ m!\A(forums|articles|poll|download|link)\z!i) { $Flex_WPS->user_error($err{bad_input}); }

sub row_color {
my $row_color = shift;
($row_color eq ' class="tbl_row_dark"')
  ? return ' class="tbl_row_light"'
  : return ' class="tbl_row_dark"';
}

# View Catagorys
sub cats {
my (@cats);
my $board_index    = '';
my $total_threads  = 0;
my $total_messages = 0;
my $blank_space    = 0;

$sticky = 'forums|poll' if $sticky eq 'forums';
$sticky = 'forums|poll' if $sticky eq 'poll';
# Get cats By User Group
 my $sth = "SELECT * FROM forum_cat WHERE cat_type REGEXP '($sticky)' AND sec_level='$usr{anonuser}'";
 if ($user_data{sec_level} eq $usr{admin}) {
  $sth = "SELECT * FROM forum_cat WHERE cat_type REGEXP '($sticky)'";
 }
  elsif ($user_data{sec_level} eq $usr{mod}) {
  $sth = "SELECT * FROM forum_cat WHERE cat_type REGEXP '($sticky)' AND sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})'";
 }
  elsif ($user_data{sec_level} eq $usr{user}) {
  $sth = "SELECT * FROM forum_cat WHERE cat_type REGEXP '($sticky)' AND sec_level REGEXP '($usr{anonuser}|$usr{user})'";
 }

$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
 while(my @row = $sth->fetchrow) {
  push ( @cats, join ( "|", $row[0], $row[1], $row[2], $row[3], $row[4] ) );
 }
$sth->finish;

$Flex_WPS->user_error($err{bad_input})
 if ! @cats;


foreach (@cats) {
 my ($lid,  $cat_name, $last_post, $security_level, $stick) = split (/\|/, $_);
 
my $add_subcat = '';
$add_subcat = <<HTML if $user_data{sec_level} eq $usr{admin};
 - <a href="$cfg{pageurl}/index.$cfg{ext}?op=add_subcat,Forum;cat=$lid;sticky=$stick">Add SubCatagory</a> -
<a href="$cfg{pageurl}/index.$cfg{ext}?op=delete_cat,Forum;cat=$lid;sticky=$stick" onclick="javascript:return confirm('This will Delete the Catagory and any reply(s) in it. Delete Catagory?')">
<img src="$cfg{imagesurl}/button_cance.png" alt="$msg{delete}" border="0" /></a>
HTML

 $blank_space++;
 my $blank_html;
 $blank_html = ($blank_space == 1)
  ? '<tr class="tbl_row_dark">'
  : '<tr><td>&nbsp;</td></tr><tr class="tbl_row_dark">';

 $board_index .= <<HTML;
$blank_html
<td width="10" valign="top">&nbsp;</td>
<td colspan="5"><b>$cat_name</b>$add_subcat</td>
</tr>
HTML

my $row_color = ' class="tbl_row_dark"';
$sticky = $stick;
$sth = "SELECT * FROM forum_subcat WHERE cat_id='$lid' AND subcat_type='$sticky'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
# Alternate the row colors.
$row_color = row_color($row_color);

# get subcat pic.
my $new = "<img src=\"$cfg{imagesurl}/forum/off.gif\" alt=\"\" />";
if($sticky eq 'articles') {
$new = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=subcat,Forum;cat=$lid;subcat=$row[0];sticky=$sticky\"><img src=\"$cfg{imagesurl}/topics/$row[0].gif\" alt=\"\" border=\"0\" /></a>";
}

$total_threads += $row[4];
$total_messages += $row[5];

# my ($dt, ) = split (/\|/, $row[6]);
my $last_post = 'None/ Edited';
if($row[6] ne 'Self' && $row[6] =~ /\,/) {
 #$last_post =~ s/\|/\,/gso;
 $row[6] =~ s/(.*?)\,(.*?)\,(.*?)\,(.*?)\,(.*?)$//i;
 #my ($dt, $lcat, $lsubcat, $lthread, $lposter) = split (/\|/, $_);
 my $format_dt = $Flex_WPS->format_date($1, 5);
 $last_post = <<HTML;
$row[6]<a href="$cfg{pageurl}/index.$cfg{ext}?op=threads,Forum;cat=$2;subcat=$3;sticky=$sticky;thread=$4">$format_dt</a><br />$msg{by} $5
HTML
}
                
my $admin_dl_link = '';
$admin_dl_link = <<HTML if $user_data{sec_level} eq $usr{admin};
 - <a href="$cfg{pageurl}/index.$cfg{ext}?op=delete_subcat,Forum;subcat=$row[0];sticky=$sticky" onclick="javascript:return confirm('This will Delete the Sub Catagory and any reply(s) in it. Delete Sub Catagory?')">
<img src="$cfg{imagesurl}/button_cance.png" alt="$msg{delete}" border="0" /></a>
HTML
 
  $board_index .= <<HTML;
<tr$row_color>
<td width=10>$new</td>
<td>
<b><a href="$cfg{pageurl}/index.$cfg{ext}?op=subcat,Forum;cat=$lid;subcat=$row[0];sticky=$sticky">$row[2]</a></b>$admin_dl_link<br />
$row[3]</td>
<td width="15%" align="center">$row[4]</td>
<td width="15%" align="center">$row[5]</td>
<td width="15%" align="center"><small>$last_post</small></td>
<td width="20%">$row[7]</td>
</tr>
HTML

}
$sth->finish;

}
if ($sticky eq 'articles') {
$nav{forums} = $nav{articles};
$msg{forum_name} = $nav{categories};
$msg{threads} = $nav{articles};
}
#elsif ($sticky eq 'poll') { $nav{forums} = $nav{poll}; }
elsif ($sticky eq 'downloads') { $nav{forums} = $nav{downloads}; }
elsif ($sticky eq 'links') { $nav{forums} = $nav{links}; }

my $post_html = '';

if($user_data{sec_level} eq $usr{admin}) {
$post_html .= "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=add_cat,Forum\">Add Catagory</a> | <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=optimize,Forum\">Optimize Tables</a>";
}

$post_html .= <<HTML;
<table width="100%">
<tr>
<td align="right">
HTML

$post_html .= forums_search($nav{forums});

$post_html .= <<HTML;
</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<td><img src="$cfg{imagesurl}/icon/folder.png" width="17" height="15" border="0" alt="" />&nbsp;&nbsp;
$nav{forums}</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<td>
<table width="100%" border="0" cellspacing="2" cellpadding="4">
<tr class="tbl_header">
<td width="10">&nbsp;</td>
<td><b>$msg{forum_name}</b></td>
<td nowrap align="center"><b>$msg{threads}</b></td>
<td nowrap align="center"><b>$msg{posts}</b></td>
<td nowrap align="center"><b>$msg{last_post}</b></td>
<td nowrap><b>$msg{moderator}</b></td>
</tr>
$board_index
</table>
</td>
</tr>
</table>
<table width="100%">
<tr>
<td align="right">$total_messages $msg{posts}<br>
$total_threads $msg{threads}</td>
</tr>
</table>
HTML

$Flex_WPS->print_page(
        markup       => $post_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Forum',
        );
}

# View Sub Catagorys
sub subcat {

my $catname = '';
my $subcatname = '';
my $thread_ct = '';

# Get cat and subcat name By User Group
my $sth = "SELECT forum_cat.`cat_name` , forum_subcat.`subcat_name` , forum_subcat.`thread_ct`
FROM `forum_cat` , `forum_subcat`
WHERE forum_cat.`id` = '$cat'
AND forum_cat.`sec_level` = '$usr{anonuser}'
AND forum_subcat.`id` = '$subcat'";

if ($user_data{sec_level} eq $usr{admin}) {
$sth = "SELECT forum_cat.`cat_name` , forum_subcat.`subcat_name` , forum_subcat.`thread_ct`
FROM `forum_cat` , `forum_subcat`
WHERE forum_cat.`id` = '$cat'
AND forum_subcat.`id` = '$subcat'";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
$sth =~ s/AND forum_cat\.`sec_level` = '$usr{anonuser}'/AND forum_cat\.`sec_level` REGEXP '\($usr{anonuser}\|$usr{user}\|$usr{mod}\)'/;
}
 elsif ($user_data{sec_level} eq $usr{user}) {
$sth =~ s/AND forum_cat\.`sec_level` = '$usr{anonuser}'/AND forum_cat\.`sec_level` REGEXP '\($usr{anonuser}\|$usr{user}\)'/;
}

$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
$catname = $row[0];
$subcatname = $row[1];
$thread_ct = $row[2];
}
$sth->finish;

$Flex_WPS->user_error($err{bad_input})
 if ! $catname;

my (@messages);

$sth = "SELECT * FROM `forum_threads` WHERE `cat_id` = '$cat' AND `subcat_id` = '$subcat'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
my $last_date;
while(my @row = $sth->fetchrow)  {
if($row[13]) { $last_date = $row[13]; }
else { $last_date = $row[5]; }
        push (
                @messages,
                join (
                        "|",     $row[0],
                        $row[1], $row[2], $row[3],
                        $row[4], $last_date, $row[6],
                        $row[7], $row[8], $row[9],
                        $row[10], $row[11], $row[12],
                        $row[13], $row[14]
                )
            );
 }
$sth->finish;
# Sort messages.
my (@data, @sorted, @sorted_messages);
for (0 .. $#messages) {
        my @fields = split (/\|/, $messages[$_]);
        for my $i (0 .. $#fields) { $data[$_][$i] = $fields[$i]; }
}
@sorted = reverse sort { $a->[5] <=> $b->[5] } @data;
for (@sorted) {
        my $sorted_row = join ("|", @$_);
        push (@sorted_messages, $sorted_row);
}
        # Get all topics in this forum.
        my $post_msg = '';
        my $num_shown = 0;
        my $row_color = ' class="tbl_row_dark"';
 for (my $i = $start; $i <= $#sorted_messages; $i++) {

  # Alternate the row colors.
  $row_color = row_color($row_color);

  my ($lid,   $cat_id,     $subcat_id, $reply_ct, $view_ct,
  $date, $msg_type, $lock,     $sticky1, $ip, $poster,
  $subject, $message, $last_edited, $last_post)
  = split (/\|/, $sorted_messages[$i]);
  if (!$sticky1) {
   # Check if thread is hot or not.
   my $type;
   if ($reply_ct <= 2) { $type = "off"; }
   if ($reply_ct > 2 || $view_ct >= 10) { $type = "on"; }
   if ($reply_ct >=10 || $view_ct >= 25) { $type = "thread"; }
   if ($reply_ct >= 15 || $view_ct >= 75)  { $type = "hotthread"; }
   if ($reply_ct >= 25 || $view_ct >= 100) { $type = "veryhotthread"; }
   if ($lock) { $type = "locked"; }
                #if(!$type) { $type = "thread"; }

   # Thread page navigator.
   my $num_messages = $reply_ct + 1;
   my $count        = 0;
   my $pages = '';
   if ($num_messages > $cfg{max_items_per_page}) {
    while ($count * $cfg{max_items_per_page} < $num_messages) {
     my $view = $count + 1;
     my $strt = ($count * $cfg{max_items_per_page});
     if($strt) { $strt -= 1; }
     $pages .=
      " [<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=threads,Forum;cat=$cat;subcat=$subcat;thread=$lid;start=$strt;sticky=$sticky\">$view</a>]";
     $count++;
    }

  # $pages =~ s/\n$//g;
  $pages =
   "( <img src=\"$cfg{imagesurl}/icon/multipage.gif\" alt=\"\" /> $pages )";
 }

#   my $unseen = '';
my $new = "<img src=\"$cfg{imagesurl}/forum/off.gif\" alt=\"\" />";
#                 if ($unseen)
#                         {
#                                 $new = qq(<img src="$cfg{imagesurl}/forum/on.gif" alt="" />);
#                         }
if($last_post ne 'Self') {
 #$last_post =~ s/\|/\,/gso;
 $last_post =~ s/(.*?)\,(.*?)\,(.*?)\,(.*?)\,(.*?)$//i;
 #my ($dt, $lcat, $lsubcat, $lthread, $lposter) = split (/\|/, $_);
 my $format_dt = $Flex_WPS->format_date($1, 5);
 $last_post = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=threads,Forum;cat=$2;subcat=$3;sticky=$sticky;thread=$4\">$format_dt</a><br />$msg{by} $5";
}
 else {
  $last_post = 'No Replies/ Edited';
}

 $AUBBC_mod->settings( for_links => 1 );
 $subject = $AUBBC_mod->do_all_ubbc($subject);
 $AUBBC_mod->settings( for_links => 0 );
 
                $post_msg .= <<HTML;
<tr$row_color>
<td width="16"><img src="$cfg{imagesurl}/forum/$type.gif" alt="" /></td>
<td width="15"><img src="$cfg{imagesurl}/icon/$msg_type" alt="" border="0" align="middle"></td>
<td width="40%"><a href="$cfg{pageurl}/index.$cfg{ext}?op=threads,Forum;cat=$cat;subcat=$subcat;thread=$lid;sticky=$sticky"><b>$subject</b></a><br>$pages</td>
<td width="20%">$poster</td>
<td width="10%" align="center">$reply_ct</td>
<td width="10%" align="center">$view_ct</td>
<td width="20%" align="center"><small>$last_post</small></td>
</tr>
HTML

  $num_shown++;
  if ($num_shown >= $cfg{max_items_per_page}) { last; }
 } # no stick
}

# Thread page navigator.
my $num_messages = $thread_ct;
my $count        = 0;
my $pages = '';
if ($num_messages >= $cfg{max_items_per_page}) {
 while ($count * $cfg{max_items_per_page} < $num_messages) {
  my $view = $count + 1;
  my $strt = ($count * $cfg{max_items_per_page});
  #if($strt) { $strt -= 1; }
  $pages .=
   " [<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=subcat,Forum;cat=$cat;subcat=$subcat;start=$strt;sticky=$sticky\">$view</a>]";
  $count++;
 }

 $pages =
  "( <img src=\"$cfg{imagesurl}/icon/multipage.gif\" alt=\"\" /> $pages )";
}

my $post = '';
my $pages2 = '';
if ($sticky eq 'forums') {
$post = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=post,Forum;cat=$cat;subcat=$subcat;sticky=$sticky"><img src="$cfg{imagesurl}/forum/new_thread.gif" alt="$msg{new_thread}" border="0" /></a>);
} elsif ($sticky eq 'articles') {
$nav{forums} = $nav{articles};
$post = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=post,Forum;cat=$cat;subcat=$subcat;sticky=$sticky"><img src="$cfg{imagesurl}/forum/new_thread.gif" alt="$msg{new_thread}" border="0" /></a>&nbsp;&nbsp;&nbsp;&nbsp;<img src="$cfg{imagesurl}/topics/$subcat.gif" alt="" />);
$pages2 = '<br><br><b>' . $msg{pagesC} . '</b>' . $pages;
}
elsif ($sticky eq 'poll') {
      #  $nav{forums} = $nav{poll};
$post = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=post,Forum;cat=$cat;subcat=$subcat;sticky=$sticky"><img src="$cfg{imagesurl}/forum/new_thread.gif" alt="$msg{new_thread}" border="0" /></a>&nbsp;&nbsp;&nbsp;&nbsp;);
$pages2 = '<br><br><b>' . $msg{pagesC} . '</b>' . $pages;
        }
elsif ($sticky eq 'downloads') { $nav{forums} = $nav{downloads}; }
elsif ($sticky eq 'links') { $nav{forums} = $nav{links}; }


my $post_html = forums_search($nav{forums});
        $post_html .= <<HTML;
<table width="100%" border="0" cellspacing="1" cellpadding="2">
<tr>
<td valign="BOTTOM"><img src="$cfg{imagesurl}/icon/folder.png" width="17" height="15" border="0" alt="" />&nbsp;&nbsp;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=cats,Forum;sticky=$sticky">$nav{forums} - $catname</a>
<br />
<img src="$cfg{imagesurl}/forum/tline.gif" width="12" height="12" border="0" alt="" /><img src="$cfg{imagesurl}/icon/folder.png" width="17" height="15" border="0" alt="" />&nbsp;&nbsp;$subcatname</td>
<td align="right" valign="bottom">$post</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="2">
<tr>
<td>
<table width="100%" border="0" cellspacing="1" cellpadding="2">
<tr class="tbl_header">
<td width="16">&nbsp;</td>
<td width="15">&nbsp;</td>
<td width="40%"><b>$msg{subjectC}</b></td>
<td width="20%"><b>$msg{started_by}</b></td>
<td width="10%" align="center"><b>$msg{replies}</b></td>
<td width="10%" align="center"><b>$msg{views}</b></td>
<td width="20%" align="center"><b>$msg{last_post}</b></td>
HTML
$post_html .= $post_msg;

        $post_html .= <<HTML;
</table>
</td>
</tr>
</table>
<table border="0" width="100%">
<tr>
<td><b>$msg{pagesC}</b> $pages
</td>
<td align="right"></td>
</tr>
<tr>
<td colspan="2" align="right" valign="bottom">
<div align="right">
HTML

        # Make forum selector.
       # forum_selector();

        $post_html .= <<HTML;
</td>
</tr>
</table>
HTML

$Flex_WPS->print_page(
        markup       => $post_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Forum',
        );
}

# View Threads
sub threads {
# I guess you could say, what the fuck?
my (@messages);
my $subject = '';
my $type = '';
my $printmsg = '';
my $printmsg2 = '';
my $subcatname = '';
#my $count = 1;
my $row_ct = 1;
my $review_ct = 0;
my $pages;
my $catname = '';

# Get cat and subcat name By User Group
my $sth = "SELECT forum_cat.`cat_name` , forum_subcat.`subcat_name`
FROM `forum_cat` , `forum_subcat`
WHERE forum_cat.`id` = '$cat'
AND forum_cat.`sec_level` = '$usr{anonuser}'
AND forum_subcat.`id` = '$subcat'";

if ($user_data{sec_level} eq $usr{admin}) {
$sth = "SELECT forum_cat.`cat_name` , forum_subcat.`subcat_name`
FROM `forum_cat` , `forum_subcat`
WHERE forum_cat.`id` = '$cat'
AND forum_subcat.`id` = '$subcat'";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
$sth =~ s/AND forum_cat\.`sec_level` = '$usr{anonuser}'/AND forum_cat\.`sec_level` REGEXP '\($usr{anonuser}\|$usr{user}\|$usr{mod}\)'/;
}
 elsif ($user_data{sec_level} eq $usr{user}) {
$sth =~ s/AND forum_cat\.`sec_level` = '$usr{anonuser}'/AND forum_cat\.`sec_level` REGEXP '\($usr{anonuser}\|$usr{user}\)'/;
}

$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
$catname = $row[0];
$subcatname = $row[1];
}
$sth->finish;

$Flex_WPS->user_error($err{bad_input})
 if ! $catname;

my $current_location = "op+threads,Forum|cat+$cat|subcat+$subcat|thread+$thread|sticky+$sticky";

$sth = "SELECT * FROM forum_threads WHERE id='$thread'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
my $row_color = ' class="tbl_row_dark"';
while(my @row = $sth->fetchrow)  {
# Alternate the row colors.
$row_color = row_color($row_color);

if(!$start) {
if($sticky eq 'forums') {
$printmsg .= format_thread($row[5], $row[10], $row[9], $row[11], $row[12], $row[13], $row_color, $row[6], $row_ct, $row[0], $current_location);
 }
}
if($sticky eq 'articles') {
$printmsg .= article($row[0], $row[5], $row[10], $row[9], $row[11], $row[12], $row_color, $row[6], $row_ct, $current_location);
 }
if($sticky eq 'poll') {
$printmsg .= poll($row[0], $row[5], $row[10], $row[9], $row[11], $row[12], $row_color, $row[6], $row_ct, $row[15], $current_location);
 }
$row_ct++;
#$count += $row[4];
$review_ct = $row[3];
$subject = $row[11];
$type = $row[6];
 }
$sth->finish;
if(!$subject) { $Flex_WPS->user_error($err{bad_input}); }
                # Thread page navigator.
                my $num_messages = $review_ct + 1;
                my $counter        = 0;
                if ($num_messages > $cfg{max_items_per_page})
                {
                        while ($counter * $cfg{max_items_per_page} < $num_messages)
                        {
                                my $view = $counter + 1;
                                my $strt = ($counter * $cfg{max_items_per_page});
                                if($strt) { $strt -= 1; }
                                $pages .=
                                    qq( [<a href="$cfg{pageurl}/index.$cfg{ext}?op=threads,Forum;cat=$cat;subcat=$subcat;thread=$thread;start=$strt;sticky=$sticky">$view</a>]);
                                $counter++;
                        }

                        $pages =~ s/\n$//g;
                        $pages =
                            qq(( <img src="$cfg{imagesurl}/icon/multipage.gif" alt="" /> $pages ));
                }
                else { $pages = ''; }
# update view count

$Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `forum_threads` SET `view_ct` =view_ct + 1
WHERE `id` ='$thread' LIMIT 1 ;");

if (!$start) { $cfg{max_items_per_page} -= 1; }
my (@sorted_messages);
$sth = "SELECT * FROM forum_reply WHERE thread_id='$thread' ORDER BY date ASC";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
        push (
                @sorted_messages,
                join (
                        "|",     $row[0],
                        $row[1], $row[2], $row[3],
                        $row[4], $row[5], $row[6],
                        $row[7], $row[8], $row[9],
                        $row[10]
                )
            );
 }
$sth->finish;
# # Sort messages.
# my (@data, @sorted, @sorted_messages);
# for (0 .. $#reply)
# {
#         my @fields = split (/\|/, $reply[$_]);
#         for my $i (0 .. $#fields) { $data[$_][$i] = $fields[$i]; }
# }
# @sorted = sort { $a->[4] <=> $b->[4] } @data;
# for (@sorted)
# {
#         my $sorted_row = join ("|", @$_);
#         push (@sorted_messages, $sorted_row);
# }
if ($sticky eq 'articles') { $nav{forums} = $nav{articles}; }
#elsif ($sticky eq 'poll') { $nav{forums} = $nav{poll}; }
elsif ($sticky eq 'downloads') { $nav{forums} = $nav{downloads}; }
elsif ($sticky eq 'links') { $nav{forums} = $nav{links}; }
        # Get all topics in this forum.
        my $post_msg = '';
        my $num_shown = 0;
        if($start) { $row_ct = $start + 2; }
      #  my $row_color = qq( class="tbl_row_dark");
        for (my $i = $start; $i <= $#sorted_messages; $i++)
        {

                my (
                        $lid,   $cat_id,     $subcat_id, $thread_id, $date,
                        $icon, $ip, $poster,     $subject, $message, $last_edited
                    )
                    = split (/\|/, $sorted_messages[$i]);
                # Alternate the row colors.
                $row_color = row_color($row_color);

         $printmsg2 .= format_thread($date, $poster, $ip, $subject, $message, $last_edited, $row_color, $icon, $row_ct, $lid, $current_location);
         $row_ct++;
                $num_shown++;

                if ($num_shown >= $cfg{max_items_per_page}) { last; }
        }

          $AUBBC_mod->settings( for_links => 1 );
          $subject = $AUBBC_mod->do_all_ubbc($subject);
          $AUBBC_mod->settings( for_links => 0 );

        my $post_html = forums_search($nav{forums});
$post_html .= <<HTML;
<table width="100%" border="0" cellspacing="1" cellpadding="2" valign="top">
<tr>
<td valign="bottom"><img src="$cfg{imagesurl}/icon/folder.png" width="17" height="15" border="0" alt="" />&nbsp;&nbsp;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=cats,Forum;sticky=$sticky">$nav{forums} - $catname</a>
<br>
<img src="$cfg{imagesurl}/forum/tline.gif" width="12" height="12" border="0" alt="" /><img src="$cfg{imagesurl}/icon/folder.png" width="17" height="15" border="0" alt="" />&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=subcat,Forum;cat=$cat;subcat=$subcat;sticky=$sticky">$subcatname</a>
<br>
<img src="$cfg{imagesurl}/forum/tline2.gif" width="24" height="12" border="0" alt="" /><img src="$cfg{imagesurl}/icon/folder.png" width="17" height="15" border="0" alt="" />&nbsp;&nbsp;$subject</td>
<td align="right" valign="bottom">
HTML

$post_html .= move_sellector($thread);
#if($sticky eq 'forums') {
$post_html .= <<HTML;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=post,Forum;cat=$cat;subcat=$subcat;thread=$thread;start=$start;sticky=$sticky;quote="><img src="$cfg{imagesurl}/forum/reply.gif" alt="$msg{reply}" border="0" /></a>&nbsp;&nbsp;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=print_thread,Forum;cat=$cat;subcat=$subcat;thread=$thread;sticky=$sticky;id=3" target="_blank"><img src="$cfg{imagesurl}/forum/print.gif" alt="$msg{print_friendly}" border="0" /></a>&nbsp;&nbsp;notification
HTML
#}

$post_html .= <<HTML;
</td>
</tr>
</table>
<table class="menuback" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<td>
<table width="100%" border="0" cellspacing="1" cellpadding="2">
<tr class="tbl_header">
HTML
# <td>
# <table width="100%" border="0" cellspacing="0" cellpadding="0">
# <tr>
# <td><img src="$cfg{imagesurl}/forum/$type.gif" alt="" /></td>
# <td>


#if($sticky eq 'forums') { print qq(&nbsp;<b>$msg{authorC}</b>); }


# </td>
# </tr>
# </table>
# </td>
$post_html .= <<HTML;
<td><b>$nav{forums}: <img src="$cfg{imagesurl}/icon/$type" alt="" /> $subject</b></td>
</tr>
HTML
$post_html .= $printmsg;
if($sticky eq 'forums') { $post_html .= $printmsg2;}
        $post_html .= <<HTML;
</table>
</td>
</tr>
</table>
<a href="$cfg{pageurl}/index.$cfg{ext}?op=post,Forum;cat=$cat;subcat=$subcat;thread=$thread;start=$start;sticky=$sticky;quote="><img src="$cfg{imagesurl}/forum/reply.gif" alt="$msg{reply}" border="0" /></a>
HTML
if($sticky eq 'articles' || $sticky eq 'poll') { $post_html .= '<br />'; }
if($sticky eq 'forums') {
$post_html .= <<HTML;
<table border="0" width="100%" cellspacing="1" cellpadding="2">
<tr>
<td><b>$msg{pagesC}</b>
$pages
</td>
<td align="right">
<a href="$cfg{pageurl}/index.$cfg{ext}?op=post,Forum;cat=$cat;subcat=$subcat;thread=$thread;start=$start;sticky=$sticky;quote="><img src="$cfg{imagesurl}/forum/reply.gif" alt="$msg{reply}" border="0" /></a>notification
</td>
</tr>
</table>
<div align="right">
HTML

        # Make forum selector.
       # forum_selector();

        $post_html .= '</div>';
 } elsif ($printmsg2 && ($sticky eq 'articles' || $sticky eq 'poll')) {
 $post_html .= <<HTML;
<table border="0" width="100%" cellspacing="1" cellpadding="2">
<tr>
<td><b>$msg{pagesC}</b>
$pages
</td>
<td align="right">
<a href="$cfg{pageurl}/index.$cfg{ext}?op=post,Forum;cat=$cat;subcat=$subcat;thread=$thread;start=$start;sticky=$sticky;quote="><img src="$cfg{imagesurl}/forum/reply.gif" alt="$msg{reply}" border="0" /></a>notification
</td>
</tr>
</table>
<table class="menuback" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<td>
<table width="100%" border="0" cellspacing="1" cellpadding="2">
<tr class="tbl_header">
<td><b>$msg{topicC} <img src="$cfg{imagesurl}/icon/$type" alt="" /> $subject</b></td>
</tr>
$printmsg2
</table>
</td>
</tr>
</table>
<table border="0" width="100%" cellspacing="1" cellpadding="2">
<tr>
<td><b>$msg{pagesC}</b>
$pages
</td>
<td align="right">
<a href="$cfg{pageurl}/index.$cfg{ext}?op=post,Forum;cat=$cat;subcat=$subcat;thread=$thread;start=$start;sticky=$sticky;quote="><img src="$cfg{imagesurl}/forum/reply.gif" alt="$msg{reply}" border="0" /></a>notification
</td>
</tr>
</table>
<div align="right">
HTML
 }
$Flex_WPS->print_page(
        markup       => $post_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Forum',
        );

 }

sub modify {

# $sticky
 my $subject_form_field = '';
 my $message_form_field = '';
 my $image_select = '';
 my $frame_link = '';
 if ($location) {
 $location =~ s/\|(\d+)\z/\#0$1/;
 #my $loc_end = $1;
 #$location =~ s/\+/\=/gso if $location;
 $location =~ s/\s/\=/gso;
 $location =~ s/\|/;/gso;
 $frame_link = $location;
 $frame_link =~ s/\A(.*?)Forum;//g;
 $frame_link =~ s/\#\d+//g;
 #$location .= '#0' . $loc_end;
 }

my $sth = '';
# Posters Edits own Post
$sth = "SELECT msg_type, subject, message FROM forum_threads WHERE id='$thread' AND poster='$user_data{uid}'" if $thread && $user_data{sec_level} ne $usr{admin};
$sth = "SELECT msg_type, subject, message FROM forum_reply WHERE id='$cat' AND poster='$user_data{uid}'" if $cat && $user_data{sec_level} ne $usr{admin};
# Admin edits all
$sth = "SELECT msg_type, subject, message FROM forum_threads WHERE id='$thread'" if $thread && $user_data{sec_level} eq $usr{admin};
$sth = "SELECT msg_type, subject, message FROM forum_reply WHERE id='$cat'" if $cat && $user_data{sec_level} eq $usr{admin};
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
$image_select = $row[0] if $row[0];
$subject_form_field = $row[1] if $row[1];
$message_form_field = $row[2] if $row[2];

 }
$sth->finish;

#error::user_error($err{auth_failure}) if !$subject_form_field || !$message_form_field;
my $subj = $subject_form_field;
my $mess = $message_form_field;

$subj = $AUBBC_mod->do_all_ubbc($subj);
$mess = $AUBBC_mod->do_all_ubbc($mess);

$subject_form_field = $AUBBC_mod->html_to_text($subject_form_field);
$message_form_field = $AUBBC_mod->html_to_text($message_form_field);
$image_select = $AUBBC_mod->html_to_text($image_select);
# TG
#my $TG_trap = TG::trapper();

         my $post_html = <<HTML;
<table border="0" cellpadding="7" cellspacing="0" width="100%" class="navtable">
<tr>
<td><p class="texttitle"><img src="$cfg{imagesurl}/icon/$image_select" name="icons" width="15"
height="15" border="0" hspace="15" alt="" /> <a href="$cfg{pageurl}/index.$cfg{ext}?$location">$subj</a></p>
$mess</td>
</tr></table>
<table width="100%" border="0" cellspacing="0" cellpadding="1">
<tr>
<td><form action="$cfg{pageurl}/index.$cfg{ext}" method="post" name="creator">

<table border="0" />
<tr>
<td><b>$msg{subjectC}</b></td>
<td><input type="text" name="subject" value="$subject_form_field" size="40" maxlength="100"></td>
</tr>
<tr>
<td><b>$msg{symbolC}</b></td>
<td>
HTML

        # Print the UBBC image selector.
        require UBBC;
        my $ubbc_image_selector = UBBC::print_ubbc_image_selector($image_select);
        $post_html .= $ubbc_image_selector;

        $post_html .= <<HTML;
<textarea wrap="off" name="message" rows="25" cols="75">$message_form_field</textarea></td>
</tr>
<tr>
<td><b>$msg{ubbc_tagsC}</b></td>
<td valign="top">
HTML

        # Print the UBBC panel.
        my $ubbc_panel = UBBC::print_ubbc_panel();
        $post_html .= $ubbc_panel;

        $location =~ s/\=/\+/gso if $location;
        $location =~ s/\;/\|/gso if $location;
        $post_html .= <<HTML;
</td>
</tr>
notification check
<tr>
<td align="center" colspan="2"><input type="hidden" name="op" value="modify2,Forum">
<input type="hidden" name="location" value="$location">
<input type="hidden" name="cat" value="$cat">
<input type="hidden" name="thread" value="$thread">
Capcha Imagehtml<br>
<input type=submit value="$btn{send_message}">
<input type="reset" value="$btn{reset}"></td>
</tr>
</table>
</form>
</td>
</tr>
</table>
<IFRAME width="650" height="450" SRC="$cfg{pageurl}/index.$cfg{ext}?op=print_thread,Forum;$frame_link;id=4" marginwidth="1" marginheight="1" border="1" frameborder="1"></IFRAME>
HTML

$Flex_WPS->print_page(
        markup       => $post_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Forum Post',
        );
}
#
sub modify2 {

$subject = $AUBBC_mod->script_escape($subject);
$message = $AUBBC_mod->script_escape($message);

$icon = $Flex_WPS->untaint2(value => $icon, pattern => '\w\.');
$icon = 'xx.gif' if !$icon;

my $date = $Flex_WPS->get_date();
my $string = '';
# msg_type, subject, message
if ($thread && $subject && $message && $icon) {

my $poll = '';
if ($location =~ m/\bpoll\b\z/i) {
my @polls = split (/<br \/>/, $message);
    for (my $i = 0; $i < @polls; $i++) {
      $poll .= 0 . "\n" unless $polls[$i] eq '<br />';
    }
 }
     $string = "UPDATE `forum_threads` SET `msg_type` = '$icon',
`subject` = '$subject',
`message` = '$message', last_edited = '$date', poll = '$poll' WHERE `id` ='$thread' AND poster='$user_data{uid}' LIMIT 1 ;"
 if $user_data{sec_level} ne $usr{admin};
     $string = "UPDATE `forum_threads` SET `msg_type` = '$icon',
`subject` = '$subject',
`message` = '$message', last_edited = '$date', poll = '$poll' WHERE `id` ='$thread' LIMIT 1 ;"
 if $user_data{sec_level} eq $usr{admin};
          $Flex_WPS->SQL_Edit($cfg{Portal_backend},$string);
}
 elsif ($cat && $subject && $message && $icon) {
         $string = "UPDATE `forum_reply` SET `msg_type` = '$icon',
`subject` = '$subject',
`message` = '$message', last_edited = '$date' WHERE `id` ='$cat' AND poster='$user_data{uid}' LIMIT 1 ;"
 if $user_data{sec_level} ne $usr{admin};
         $string = "UPDATE `forum_reply` SET `msg_type` = '$icon',
`subject` = '$subject',
`message` = '$message', last_edited = '$date' WHERE `id` ='$cat' LIMIT 1 ;"
 if $user_data{sec_level} eq $usr{admin};
          $Flex_WPS->SQL_Edit($cfg{Portal_backend},$string);
 }

# Redirect
print $query->redirect(
       -location => $cfg{pageurl} . '/index.' . $cfg{ext} .
       '?op=modify,Forum;cat=' . $cat . ';thread=' . $thread . ';location=' . $location);

}

# Post Thread form
sub post {
if ($user_data{uid} eq $usr{anonuser}) {
# Redirect to the register page.
  print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=register,register');
  exit;
}
# $sticky
 my $subject_form_field = '';
 my $message_form_field = '';
 my $image_select = '';
 my $poster = '';
 my $sth = '';

if ($location) { # Get Quote
$sth = "SELECT msg_type, poster, subject, message FROM forum_threads WHERE id='$thread'" if $location eq 1;
$sth = "SELECT msg_type, poster, subject, message FROM forum_reply WHERE id='$id'" if $location eq 2;
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
$image_select = $row[0] if $row[0];
$poster = $row[1] if $row[1];
$subject_form_field = $row[2] if $row[2];
$message_form_field = $row[3] if $row[3];
 }
$sth->finish;

$subject_form_field = $AUBBC_mod->html_to_text($subject_form_field);
$subject_form_field = 'Re: ' . $subject_form_field;

$message_form_field = $AUBBC_mod->html_to_text($message_form_field);
$message_form_field = "\[quote=$poster\]$message_form_field\[/quote\]";
}
# TG
#my $TG_trap = TG::trapper();

        my $post_html = <<HTML;
<table width="100%" border="0" cellspacing="0" cellpadding="1">
<tr>
<td><form action="$cfg{pageurl}/index.$cfg{ext}" method="post" name="creator">

<table border="0" />
<tr>
<td><b>$msg{subjectC}</b></td>
<td><input type="text" name="subject" value="$subject_form_field" size="40" maxlength="100" /></td>
</tr>
<tr>
<td><b>$msg{symbolC}</b></td>
<td>
HTML

        # Print the UBBC image selector.
        require UBBC;
        $post_html .= UBBC::print_ubbc_image_selector($image_select);

$post_html .= <<HTML;
<textarea wrap="off" name="message" rows="25" cols="75">$message_form_field</textarea></td>
</tr>
<tr>
<td><b>$msg{ubbc_tagsC}</b></td>
<td valign="top">
HTML

        # Print the UBBC panel.
        $post_html .= UBBC::print_ubbc_panel();
        
        $post_html .= <<HTML;
</td>
</tr>
notification check
<tr>
<td align="center" colspan="2"><input type="hidden" name="op" value="post2,Forum" />
<input type="hidden" name="cat" value="$cat" />
<input type="hidden" name="subcat" value="$subcat" />
<input type="hidden" name="thread" value="$thread" />
<input type="hidden" name="sticky" value="$sticky" />
<input type="hidden" name="post" value="$thread" />Capcha Imagehtml<br />
<input type=submit value="$btn{send_message}" />
<input type="reset" value="$btn{reset}" /></td>
</tr>
</table>
</form>
</td>
</tr>
</table><hr />
<iframe width="650" height="450" src="$cfg{pageurl}/index.$cfg{ext}?op=print_thread,Forum;cat=$cat;subcat=$subcat;thread=$thread;sticky=$sticky;id=4" marginwidth="1" marginheight="1" border="1" frameborder="1">
</iframe>
HTML

$Flex_WPS->print_page(
        markup       => $post_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Forum Post',
        );
}

# Add it
sub post2 {

# remake and use below veriable
my $thread_name = '';
my $thread_ct = '';
my $post_ct = '';
my $reply_ct = 0;
my $catname = '';
my $added = '';
my $poll = '';
# input check, number check at top needed!
if(!$cat) { $Flex_WPS->user_error($err{bad_input}); }
if(!$subcat) { $Flex_WPS->user_error($err{bad_input}); }
if(!$subject) { $Flex_WPS->user_error($err{bad_input}); }
if(!$message) { $Flex_WPS->user_error($err{bad_input}); }

# Move date? or add...
my $date = $Flex_WPS->get_date();

$subject = $AUBBC_mod->script_escape($subject);
$message = $AUBBC_mod->script_escape($message);

$icon = $Flex_WPS->untaint2(value => $icon, pattern => '\w\.');
$icon = 'xx.gif' if !$icon;
if ($sticky eq 'poll') {
my @polls = split (/<br \/>/, $message);
$message = '';
    for (my $i = 0; $i < @polls; $i++) {
      $poll .= 0 . "\n" unless $polls[$i] eq '<br />';
      $message .= $polls[$i] . "<br />" if defined $polls[$i];
    }

}
# not admin
if($user_data{sec_level} ne $usr{admin}) {
$lock = 0;
#$sticky = 0;
 }
# sub cat settup
my $sth = "SELECT * FROM forum_subcat WHERE id='$subcat'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
$thread_ct = $row[4] + 1;
$post_ct = $row[5] + 1;
$catname = $row[1];
 }
$sth->finish;
if(!$catname || $catname ne $cat) { $Flex_WPS->user_error($err{bad_input}); }
my $strt='';
# Thread settup
if($thread) {
$sth = "SELECT * FROM forum_threads WHERE id='$thread'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
$thread_name = $row[0];
$reply_ct += $row[3] + 1; # replies
 }
$sth->finish;
if(!$thread_name) { $Flex_WPS->user_error($err{bad_input}); }
else { $thread_name = '';
my $reply_ct2 = $reply_ct + 1;
# if() { }
$strt = ($reply_ct / $cfg{max_items_per_page});
$strt =~ s/\.(.*?)$//i;
$strt = ($strt * $cfg{max_items_per_page});
if($strt) { $strt -= 1; }
$strt = ';start=' . $strt;

$Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `forum_threads` SET `reply_ct` = '$reply_ct',
`last_edited` = '$date',
`last_post` = '$date,$cat,$subcat,$thread$strt\\#$reply_ct2,$user_data{uid}' WHERE `id` ='$thread' LIMIT 1 ;");
# add reply to thread
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"INSERT INTO `forum_reply` ( `id` , `cat_id` , `subcat_id` , `thread_id` , `date` , `msg_type` , `ip` , `poster` , `subject` , `message` , `last_edited` )
VALUES (
NULL , '$cat', '$subcat', '$thread', '$date', '$icon', '$ENV{REMOTE_ADDR}', '$user_data{uid}', '$subject', '$message', NULL
);");
#$reply_ct += 1;
$thread = $thread . $strt . '\\#' . $reply_ct2;
$thread_ct = $thread_ct - 1;
     }
} else {
# New Thread
$post_ct = $post_ct - 1; # ?
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"INSERT INTO `forum_threads` ( `id` , `cat_id` , `subcat_id` , `reply_ct` , `view_ct` , `date` , `msg_type` , `lock` , `sticky` , `ip` , `poster` , `subject` , `message` , `last_edited` , `last_post` , `poll` , `dl_link` )
VALUES (
NULL , '$cat', '$subcat', '0', '0', '$date', '$icon', '$date' , NULL , '$ENV{REMOTE_ADDR}', '$user_data{uid}', '$subject', '$message', NULL , 'Self' , '$poll' , ''
);");

# get new thread id
$sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM `forum_threads` WHERE `cat_id`='$cat' AND `subcat_id`='$subcat' AND `lock`='$date'");
$sth->execute;
while(my @row = $sth->fetchrow)  { if($row[0]) { $thread = $row[0]; } }
$sth->finish;
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `forum_threads` SET `lock` = NULL WHERE `id` ='$thread' LIMIT 1 ;");
$thread .= '\\#1';
# RSS Feed Update
rss_feed();
}

# Subcat update
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `forum_subcat` SET `thread_ct` = '$thread_ct',
`post_ct` = '$post_ct',
`last_post` = '$date,$cat,$subcat,$thread,$user_data{uid}' WHERE `id` ='$subcat' LIMIT 1 ;");

#$Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `members` SET `xp` =xp + 1
#WHERE `memberid` ='$user_data{id}' LIMIT 1 ;");

# Redirect
print $query->redirect(
       -location => $cfg{pageurl} . '/index.' . $cfg{ext} .
       '?op=subcat,Forum;cat=' . $cat . ';subcat=' . $subcat . ';sticky=' . $sticky);

}
sub vote_user {
if (!$user_data{votes}) {
$Flex_WPS->user_error('You have no more votes till the next day.');
}
my ($avote, $tuser) = split(/\|/, $location);
if (!$avote || $avote !~ m!\A([0-9]+)\z!i) { $Flex_WPS->user_error($err{bad_input}); }
if (!$tuser || $tuser !~ m!\A([0-9A-Za-z\_]+)\z!i) { $Flex_WPS->user_error($err{bad_input}); }
require get_user;
$tuser = get_user::check_user($tuser,2);
if (!$tuser) { $Flex_WPS->user_error($err{bad_input}); }
my ($pos_vote, $neg_vote, $vtotal) = split(/\|/, $user_data{votes_used});
$pos_vote = 0 if !$pos_vote;
$neg_vote = 0 if !$neg_vote;
$vtotal = 0 if !$vtotal;

if ($avote eq 1) {
          $pos_vote++;
          $vtotal++;
          $Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `members` SET `xp` =xp + 1, `votes` =votes - 1, `votes_used` = '$pos_vote|$neg_vote|$vtotal' WHERE `memberid` ='$user_data{id}' LIMIT 1 ;");
          $Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `members` SET `xp` =xp + 1 WHERE `uid` ='$tuser' LIMIT 1 ;");
}
 else {
          $vtotal++;
          $neg_vote++;
          $Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `members` SET `xp` =xp + 1, `votes` =votes - 1, `votes_used` = '$pos_vote|$neg_vote|$vtotal' WHERE `memberid` ='$user_data{id}' LIMIT 1 ;");
          $Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `members` SET `xp` =xp - 1 WHERE `uid` ='$tuser' LIMIT 1 ;");
 }
# Redirect
print $query->redirect(
       -location => $cfg{pageurl} . '/index.' . $cfg{ext} .
       '?op=subcat,Forum;cat=' . $cat . ';subcat=' . $subcat . ';sticky=' . $sticky);
}

sub do_vote {
#if (!$user_data{votes}) {
#$Flex_WPS->user_error('You have no more votes till the next day.');
#}
my $poll = '';
my $sth = "SELECT poll FROM forum_threads WHERE id='$thread'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
 $poll = $row[0];
}
$sth->finish();

if ($poll) {
 my @polls = split (/\n/, $poll);
 $poll = '';
 for (my $i = 0; $i < @polls; $i++) {
  $poll .= ($i == $answer)
  ? $polls[$i] + 1 . "\n"
  : $polls[$i] . "\n";

}
#my ($pos_vote, $neg_vote, $vtotal) = split(/\|/, $user_data{votes_used});
#$pos_vote = 0 if !$pos_vote;
#$neg_vote = 0 if !$neg_vote;
#$vtotal = 0 if !$vtotal;
          #$vtotal++;
          $Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `forum_threads` SET `poll` = '$poll' WHERE `id` ='$thread' LIMIT 1 ;");
          #$Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `members` SET `xp` =xp + 1, `votes` =votes - 1, `votes_used` = '$pos_vote|$neg_vote|$vtotal'  WHERE `memberid` ='$user_data{id}' LIMIT 1 ;");
          }
# Redirect
print $query->redirect(
       -location => $cfg{pageurl} . '/index.' . $cfg{ext} .
       '?op=subcat,Forum;cat=' . $cat . ';subcat=' . $subcat . ';sticky=' . $sticky);
}

sub add_cat {

 my $seclvl2 = '';
    foreach (sort keys %usr) {
            my $bs = '';
            #$bs = ' selected' if $row[5] && $usr{$_} eq $row[5];
            $bs = ' selected' if $usr{$_} eq $usr{anonuser};
            $seclvl2 .= "<option value=\"$usr{$_}\"$bs>$usr{$_}</option>\n";
            }

my $post_html = <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Add <a href="$cfg{pageurl}/index.$cfg{ext}?op=cats,Forum">Forum</a> Catagory</p>
</td>
</tr></table>
<table width="76%" border="0" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="34%"><b>Title</b></td>
    <td width="33%"><b>Location</b></td>
    <td width="20%"><b>Security Level</b></td>
  </tr>
</table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="add_cat2,Forum" />
    <tr>
      <td width="12%">
        <input type="submit" name="Submit" value="Add New" />
      </td>
      <td width="32%">
           <input type="text" name="subject" />
      </td>
      <td width="33%">
        <select name="location">
          <option value="forums" selected>forums</option>
          <option value="articles">articles</option>
          <option value="poll">poll</option>
        </select>
      </td>
      <td width="10%">
         <select name="icon">
          $seclvl2
        </select>
      </td>
    </tr>
    </form>
  </table>
<hr />
HTML

$Flex_WPS->print_page(
        markup       => $post_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Forum',
        );
}
sub add_cat2 {

# INSERT INTO `forum_cat` (`id`, `cat_name`, `last_post`, `sec_level`, `cat_type`) VALUES (NULL, 'Users', NULL, 'User', 'forum');

if ($subject && $icon && $location) {
$subject = $AUBBC_mod->script_escape($subject);
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"INSERT INTO `forum_cat` (`id`, `cat_name`, `last_post`, `sec_level`, `cat_type`) VALUES (NULL, '$subject', NULL, '$icon', '$location');");
}
# Redirect
print $query->redirect(
       -location => $cfg{pageurl} . '/index.' . $cfg{ext} .
       '?op=cats,Forum;sticky=' . $sticky);

}
sub add_subcat {

 my $seclvl2 = '';
    foreach (sort keys %usr) {
            my $bs = '';
            #$bs = ' selected' if $row[5] && $usr{$_} eq $row[5];
            $bs = ' selected' if $usr{$_} eq $usr{anonuser};
            $seclvl2 .= "<option value=\"$usr{$_}\"$bs>$usr{$_}</option>\n";
            }

 my $post_html = <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Add <a href="$cfg{pageurl}/index.$cfg{ext}?op=cats,Forum">Forum</a> Subcatagory</p>
</td>
</tr></table>
<table width="76%" border="0" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="34%"><b>Title/Discription</b></td>
    <td width="33%"><b>Location</b></td>
    <td width="20%"><b>Moderators</b></td>
  </tr>
</table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="add_subcat2,Forum" />
<input type="hidden" name="cat" value="$cat" />
    <tr>
      <td width="12%">
        <input type="submit" name="Submit" value="Add New" />
      </td>
      <td width="32%">
           <input type="text" name="subject" /><br />
           <textarea name="message" rows="5" cols="20"></textarea>
      </td>
      <td width="33%">
        <input type="hidden" name="location" value="$sticky" />$sticky
      </td>
      <td width="10%">
        <input type="text" name="icon" />
      </td>
    </tr>
    </form>
  </table>
<hr />
HTML

$Flex_WPS->print_page(
        markup       => $post_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Forum',
        );

}
# INSERT INTO `forum_subcat` ( `id` , `cat_id` , `subcat_name` , `discription` , `thread_ct` , `post_ct` , `last_post` , `moderator` , `subcat_type` )
# VALUES (
# NULL , '5', 'Admin Chat', 'Administrators Discution', NULL , NULL , NULL , 'admin', 'forum'
# );
sub add_subcat2 {

if ($subject && $icon && $location) {

$subject = $AUBBC_mod->script_escape($subject);
$message = $AUBBC_mod->script_escape($message);
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"INSERT INTO `forum_subcat` ( `id` , `cat_id` , `subcat_name` , `discription` , `thread_ct` , `post_ct` , `last_post` , `moderator` , `subcat_type` )
VALUES (
NULL , '$cat', '$subject', '$message', NULL , NULL , 'Self' , '$icon', '$location'
);");
}
# Redirect
print $query->redirect(
       -location => $cfg{pageurl} . '/index.' . $cfg{ext} .
       '?op=cats,Forum;sticky=' . $sticky);
}

sub poll {
my ($liid, $date, $poster, $ip, $subject, $message, $row_color, $icon, $row_ct, $poll, $cur_location) = @_;
return unless $poster;
# Format date.
my $formatted_date = $Flex_WPS->format_date($date);

# Ip for admin's only
$ip = $msg{logged}
 if ($user_data{sec_level} ne $usr{admin});

my @messager = split (/<br \/>|<br>/, $message);
my @polls = split (/\n/, $poll);
my $total_votes = 0;

if (@polls) {
 foreach (@polls) { $total_votes = $total_votes + $_; }
}

my $poll_print = '<table border="0" style="width: 500px;" cellpadding="5" cellspacing="0" align="center" class="navtable">';
$row_color = ' class="tbl_row_dark"';

for (my $i = 0; $i < @messager; $i++) {

# Alternate the row colors.
$row_color = row_color($row_color);
$messager[$i] = $AUBBC_mod->do_all_ubbc($messager[$i]);
$poll_print .= "<tr$row_color><td><input type=\"radio\" name=\"answer\" value=\"$i\" /><b>$messager[$i]</b>";

 my ($percent, $pixel, $a, $b);
 if ($total_votes != 0) {
  $pixel = int((($polls[$i] / $total_votes) * 100) / 2);
  $percent = ($polls[$i] / $total_votes) * 100;
  
  my $c = int(10 * ($percent * 10 - int($percent * 10)));
  
  $b = int(10 * ($percent - int($percent)));
  $a = int($percent);

  $b++ if ($c >= 5);
 }
  else { $a = 0; $b = 0; }

 $percent = $a . '.' . $b;
 $pixel = 0 if (!$pixel);
 $poll_print .= <<HTML;
<br />
<img src="$cfg{imagesurl}/leftbar.gif" alt="" /><img src="$cfg{imagesurl}/mainbar.gif" width="$pixel" height="16" alt="" /><img src="$cfg{imagesurl}/rightbar.gif" alt="" />&nbsp;&nbsp;($percent%)
 </td>
</tr>
HTML
}
$poll_print .= '</table>';

 my $userinfo = get_userinfo($poster);
 $userinfo =~ s/\|(.*?)\z//g;
 my $sig = $1;


 $AUBBC_mod->settings( for_links => 1 );
 $subject = $AUBBC_mod->do_all_ubbc($subject);
 $AUBBC_mod->settings( for_links => 0 );
            # my $TG_trap = TG::trapper();
my $box = <<HTML;
<tr$row_color>
<td valign="top">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td width="100%"><a name="1"></a><img src="$cfg{imagesurl}/icon/$icon" alt="" />&nbsp;<b>$subject</b></td>
<td align="right" nowrap>&nbsp;<b>$msg{posted_onC}</b> $formatted_date</td>
</tr>
</table>
<hr noshade="noshade" size="1"><div style="float: right; width: 140px;">$userinfo</div>
<br>

<form action="$cfg{pageurl}/index.$cfg{ext}" method="post">
$poll_print

<input type="hidden" name="cat" value="$cat" />
<input type="hidden" name="subcat" value="$subcat" />
<input type="hidden" name="thread" value="$thread" />
<input type="hidden" name="sticky" value="$sticky" />
<input type="hidden" name="op" value="do_vote,Forum" />

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="submit" value="$btn{vote}" />
</form>
</td>
</tr>
<tr$row_color>
<td>
<hr noshade="noshade" size="1">
$sig
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td><img src="$cfg{imagesurl}/icon/ip.gif" alt="$msg{ip_address}" align="top"> $ip
HTML

# Print user actions.
if ($user_data{sec_level} ne $usr{anonuser}) {
$box .= <<HTML;
</td>
<td align="right"><a href="$cfg{pageurl}/index.$cfg{ext}?op=print_thread,Forum;cat=$cat;subcat=$subcat;thread=$thread;id=1" target="_blank"><img src="$cfg{imagesurl}/print.gif" alt="$msg{print_friendly}" border="0" /></a>&nbsp;&nbsp;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=post,Forum;cat=$cat;subcat=$subcat;thread=$thread;start=$start;sticky=$sticky;location=1"><img src="$cfg{imagesurl}/forum/quote.gif" alt="$msg{quote}" border="0" /></a>&nbsp;&nbsp;
HTML
}

# Print user actions.
if ($user_data{sec_level} eq ($usr{admin}||$poster)) {
$box .= <<HTML;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=modify,Forum;thread=$thread;location=$cur_location"><img src="$cfg{imagesurl}/forum/modify.gif" alt="$msg{edit_message}" border="0" /></a>
&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=delete_thread,Forum;cat=$cat;subcat=$subcat;thread=$thread;sticky=$sticky" onclick="javascript:return confirm('This will Delete any reply(s) to this thread. Delete Thread?')"><img src="$cfg{imagesurl}/icon/delete.gif" alt="$msg{delete}" border="0" /></a>
HTML
}

$box .= <<HTML;
</td>
</tr>
</table>
</td>
</tr>
HTML
return $box;
}
# Format articlee.
sub article {
my ($liid, $date, $poster, $ip, $subject, $message, $row_color, $icon, $row_ct, $cur_location) = @_;
return unless $poster;

$subject = $AUBBC_mod->do_all_ubbc($subject);
$message = $AUBBC_mod->do_all_ubbc($message);

# Format date.
my $formatted_date = $Flex_WPS->format_date($date);
# Ip for admin's only
if ($user_data{sec_level} ne $usr{admin}) { $ip = $msg{logged}; }

my $box = <<HTML;
<tr$row_color>
<td valign="top">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td><a name="1"></a><img src="$cfg{imagesurl}/icon/$icon" alt="" /></td>
<td width="100%">&nbsp;<b>$subject</b></td>
<td align="right" nowrap>&nbsp;<b>$msg{posted_onC}</b> $formatted_date</td>
</tr>
</table>
<hr noshade="noshade" size="1">
<table border="0" cellspacing="2" cellpadding="2" width="100%">
<tr>
<td><b>$msg{authorC}</b> <a href="$cfg{pageurl}/index.$cfg{ext}?op=view_profile;username=$poster">$poster</a><br>
<img src="$cfg{imagesurl}/topics/$subcat.gif" alt="" align="right">
$message</td>
</tr>
</table>
</td>
</tr>
<tr$row_color>
<td>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td><img src="$cfg{imagesurl}/icon/ip.gif" alt="$msg{ip_address}" align="top" /> $ip
HTML

# Print user actions.
#if ($user_data{sec_level} ne $usr{anonuser}) {
$box .= <<HTML;
</td>
<td align="right"><a href="$cfg{pageurl}/index.$cfg{ext}?op=print_thread,Forum;cat=$cat;subcat=$subcat;thread=$thread;id=1" target="_blank"><img src="$cfg{imagesurl}/print.gif" alt="$msg{print_friendly}" border="0" /></a>&nbsp;&nbsp;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=post,Forum;cat=$cat;subcat=$subcat;thread=$thread;start=$start;sticky=$sticky;location=1"><img src="$cfg{imagesurl}/forum/quote.gif" alt="$msg{quote}" border="0" /></a>&nbsp;&nbsp;
HTML
#}

# Print user actions.
if ($user_data{uid} ne $usr{anonuser} && ($user_data{sec_level} eq $usr{admin} || $poster eq $user_data{uid})) {
$box .= <<HTML;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=modify,Forum;thread=$liid;location=$cur_location"><img src="$cfg{imagesurl}/forum/modify.gif" alt="$msg{edit_message}" border="0" /></a>
&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=delete_thread,Forum;cat=$cat;subcat=$subcat;thread=$thread" onclick="javascript:return confirm('This will Delete any reply(s) to this thread. Delete Thread?')"><img src="$cfg{imagesurl}/button_cance.png" alt="$msg{delete}" border="0" /></a>);
HTML
}

$box .= <<HTML;
</td>
</tr>
</table>
</td>
</tr>
HTML
return $box;
}
# Format Thread to save space.
sub format_thread {
my ($date, $poster, $ip, $subject, $message, $last_edit, $row_color, $icon, $row_ct, $lid, $cur_location) = @_;
return unless $poster;

$subject = $AUBBC_mod->do_all_ubbc($subject);
$message = $AUBBC_mod->do_all_ubbc($message);

# Format date.
my $formatted_date = $Flex_WPS->format_date($date);
# Ip for admin's only
if ($user_data{sec_level} ne $usr{admin}) { $ip = $msg{logged}; }

if ($last_edit) {
  $last_edit = $Flex_WPS->format_date($last_edit);
  $last_edit = "<br><font color=red><b>*Edited:</b></font> <small>$last_edit</small><br>";
}
 else {
  $last_edit = '';
 }
             my $userinfo = get_userinfo($poster);
             $userinfo =~ s/\|(.*?)\z//gso;
             my $sig = $1;
# <td width="140" valign="top"><a name="$row_ct"></a>$userinfo
# </td>

 my $vote_user = '';
 if ($user_data{votes}) {
      $vote_user = <<HTML;
<table align="center" border="0" cellspacing="0" cellpadding="0" width="300">
<tr>
<form action="$cfg{pageurl}/index.$cfg{ext}" method="post">
<td align="center">++<input type="radio" name="location" value="1|$poster" />Up Vote &nbsp;&nbsp;--<input type="radio" name="location" value="2|$poster" />Down Vote
<input type="hidden" name="cat" value="$cat" />
<input type="hidden" name="subcat" value="$subcat" />
<input type="hidden" name="thread" value="$thread" />
<input type="hidden" name="sticky" value="$sticky" />
<input type="hidden" name="op" value="vote_user,Forum" />&nbsp;&nbsp;<input type="submit" value="$btn{vote}" /></td>
</form>
</tr>
</table>
HTML
 }
my ($jumper1, $jumper2) = ("<a name=\"0$lid\"></a>","<font color=DarkRed><b>[id://$thread#0$lid]</b></font>&nbsp;&nbsp;");
if ($row_ct == 1) {
 ($jumper1, $jumper2) = ('',"<font color=DarkRed><b>[id://$thread#1]</b></font>&nbsp;&nbsp;");
}
                my $box = <<HTML;
<tr$row_color>
<td valign="top">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td><img src="$cfg{imagesurl}/icon/$icon" alt="" /></td>
<td width="100%">$jumper1<a name="$row_ct"></a>&nbsp;<b>$subject</b></td>
<td>$jumper2</td>
<td align="right" nowrap>&nbsp;<b>$msg{posted_onC}</b> $formatted_date</td>
</tr>
</table><div style="position: relative; padding: 3px 5px 3px 5px;">
<hr noshade="noshade" size="1">
$vote_user
<div style="float: right; width: 18%; position: static">$userinfo</div>
$message$last_edit
</div>
</td>
</tr>
<tr$row_color>
<td><hr noshade="noshade" size="1">
$sig</td>
</tr>
<tr$row_color>
<td>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td><img src="$cfg{imagesurl}/icon/ip.gif" alt="$msg{ip_address}" valign="top"> $ip
HTML

#                 if ($user_data{uid} ne $usr{anonuser} && $username ne $usr{anonuser})
#                 {
#                         print $url_link . $email_link . $profile_link . $send_im_link .
#                             $icq_link;
#                 }
                if ($row_ct >= 2) {
                $box .= <<HTML;
</td>
<td align="right"><a href="$cfg{pageurl}/index.$cfg{ext}?op=print_thread,Forum;cat=$cat;subcat=$subcat;thread=$thread;id=2;lock=$lid" target="_blank"><img src="$cfg{imagesurl}/print.gif" alt="$msg{print_friendly}" border="0" /></a>&nbsp;&nbsp;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=post,Forum;cat=$cat;subcat=$subcat;thread=$thread;start=$start;sticky=$sticky;location=2;id=$lid"><img src="$cfg{imagesurl}/forum/quote.gif" alt="$msg{quote}" border="0" /></a>&nbsp;&nbsp;
HTML
                   }
                    elsif ($row_ct == 1){
                $box .= <<HTML;
</td>
<td align="right"><a href="$cfg{pageurl}/index.$cfg{ext}?op=print_thread,Forum;cat=$cat;subcat=$subcat;thread=$thread;id=1" target="_blank"><img src="$cfg{imagesurl}/print.gif" alt="$msg{print_friendly}" border="0" /></a>&nbsp;&nbsp;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=post,Forum;cat=$cat;subcat=$subcat;thread=$thread;start=$start;sticky=$sticky;location=1"><img src="$cfg{imagesurl}/forum/quote.gif" alt="$msg{quote}" border="0" /></a>&nbsp;&nbsp;
HTML
                    }
                # Print user actions.
                if ($user_data{uid} ne $usr{anonuser} && ($user_data{sec_level} eq $usr{admin} || $poster eq $user_data{uid})) {
                        $cur_location .= '|' . $lid;
                        #$box .= qq(<a href="$cfg{pageurl}/forum.$cfg{ext}?op=modify;board=board;thread=$thread;post=shit"><img src="$cfg{imagesurl}/forum/modify.gif" alt="$msg{edit_message}" border="0" /></a>);
                  if ($row_ct >= 2) {
$box .= <<HTML;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=modify,Forum;cat=$lid;location=$cur_location"><img src="$cfg{imagesurl}/forum/modify.gif" alt="$msg{edit_message}" border="0" /></a>&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=delete_post,Forum;cat=$cat;subcat=$subcat;thread=$thread;start=$lid" onclick="javascript:return confirm('Delete this Reply?')"><img src="$cfg{imagesurl}/button_cance.png" alt="$msg{delete}" border="0" /></a>
HTML
                  }
                   elsif ($row_ct == 1){
$box .= <<HTML;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=modify,Forum;thread=$lid;location=$cur_location"><img src="$cfg{imagesurl}/forum/modify.gif" alt="$msg{edit_message}" border="0" /></a>&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=delete_thread,Forum;cat=$cat;subcat=$subcat;thread=$thread" onclick="javascript:return confirm('This will Delete any reply(s) to this thread. Delete Thread?')"><img src="$cfg{imagesurl}/button_cance.png" alt="$msg{delete}" border="0" /></a>
HTML
                   }
                }

                $box .= <<HTML;
</td>
</tr>
</table>
</td>
</tr>
HTML
return $box;
}
sub get_userinfo {
my $poster = shift;
return if !$poster;
         my ($nick, $signature, $seclevel, $memberpic, $xp, $flag);
         my $query1 = "SELECT nick, seclevel FROM members WHERE uid = '$poster' LIMIT 0 , 30";

        my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
        $sth->execute;
        #login("$err{bad_username} $msg{search_or} $err{wrong_passwd}");
        while(my @row = $sth->fetchrow)  {
        $nick = $row[0] || 'Guest';
        $signature = 'Guest';
        $seclevel = $row[1] || 'Guest';
       # $memberpic = qq(<img src="$cfg{imagesurl}/avatars/$row[3]" border="0" alt="" /></a>) || 'Guest';
       # $xp = $row[4] || 100;
       # $flag = $row[5] || 'Guest';
        }
        $sth->finish();
        # Get member ranks.
        #require rank;
        #my @ranks = rank::load_ranks();
        #if(!$xp) { $xp = 0; }
        # Display member ranking.
        #my $ranking = $xp;

         my $member_info = '';
#        foreach (@ranks)
#        {
#        my ($r_num, $r_name) = split (/\|/, $_);
#           if ($ranking >= $r_num)
#           {
#           $member_info = $r_name;
#           if($cfg{forum_stars}) {
#           } else {
#           $member_info = qq(<font color="white" size="1">$r_name</font> <img src="$cfg{imagesurl}/rank/$member_info.gif" alt="$member_info" border="0" />);
#           }
#        }
#    }
        $flag = '' if !$flag;
        #$flag = qq(<img src="$cfg{imagesurl}/flags/$flag" style="border: none;" alt="" />) if $flag;
# Text and word Wrap, default Perl Module!
 use Text::Wrap
 $Text::Wrap::columns = 45; # Wrap at 45 characters
    $signature = wrap('', '', $signature);
    $signature = $AUBBC_mod->do_all_ubbc($signature);
        return <<HTML;
<b /><a href="$cfg{pageurl}/index.$cfg{ext}?op=view_profile,user;username=$poster">$poster</a></b><small>/($nick)</small><br />$seclevel<br />
<div style="padding: 4px 4px 4px 4px; border:1px solid #000000; background-color : #666666;">
$member_info<br />
</div>|$signature
HTML
}
sub delete_post {

if ($start && $cat && $subcat && $thread) {
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"DELETE FROM forum_reply WHERE id='$start' AND cat_id='$cat' AND subcat_id='$subcat' AND thread_id='$thread'");
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `forum_threads` SET `reply_ct`=reply_ct - 1, `last_post`='Self' WHERE `id`='$thread' LIMIT 1 ;");
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `forum_subcat` SET `post_ct`=post_ct - 1, `last_post`='Self' WHERE `id`='$subcat' LIMIT 1 ;");
}
print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=threads,Forum;cat=' . $cat . ';subcat=' . $subcat . ';thread=' . $thread . ';sticky=forum');

}

# delete cat.
sub delete_cat {

if ($cat) {
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"DELETE FROM forum_cat WHERE id='$cat' LIMIT 1;");
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"DELETE FROM forum_subcat WHERE cat_id='$cat'");
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"DELETE FROM forum_threads WHERE cat_id='$cat'");
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"DELETE FROM forum_reply WHERE cat_id='$cat'");
}
print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=cats,Forum;sticky=' . $sticky);
}

sub delete_subcat {

if ($subcat) {
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"DELETE FROM forum_subcat WHERE id='$subcat'");
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"DELETE FROM forum_threads WHERE subcat_id='$subcat'");
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"DELETE FROM forum_reply WHERE subcat_id='$subcat'");
}

print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=cats,Forum;sticky=' . $sticky);
}

sub delete_thread {

if ($cat && $subcat && $thread) {
my $reply = 0;
my $sth = "SELECT reply_ct FROM forum_threads WHERE id='$thread'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
$reply = $row[0] if $row[0];
 }
$sth->finish;

$Flex_WPS->SQL_Edit($cfg{Portal_backend},"DELETE FROM forum_threads WHERE id='$thread' AND cat_id='$cat' AND subcat_id='$subcat'");
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `forum_subcat` SET `thread_ct`=thread_ct - 1, `post_ct`=post_ct - $reply, `last_post`='Self' WHERE `id`='$subcat' LIMIT 1 ;");
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"DELETE FROM forum_reply WHERE thread_id='$thread'");
}
print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=subcat,Forum;cat=' . $cat . ';subcat=' . $subcat . ';sticky=' . $sticky);

}
sub move_sellector {
my $in_thread = shift;
# Get cats
if ($user_data{sec_level} eq $usr{admin}) {
my @cats = ();
my $sth = "SELECT id, cat_name FROM forum_cat WHERE cat_type='$sticky'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
        push ( @cats, join ( "|", $row[0], $row[1] ) );
}
$sth->finish;

return if (!@cats);
my $select = '';
foreach (@cats) {
 my ($lid,  $cat_name) = split (/\|/, $_);

$sth = "SELECT id, subcat_name FROM forum_subcat WHERE cat_id='$lid' AND subcat_type='$sticky'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
  $select .= "<option value=\"$lid|$row[0]\">$row[1]</option>\n";
}
$sth->finish;

 }
  return <<HTML;
<form action="$cfg{pageurl}/index.$cfg{ext}" method="post">
<b>$msg{move_toC}</b> <select name="location">
$select
</select>
<input type="hidden" name="thread" value="$in_thread" />
<input type="hidden" name="op" value="move,Forum" />
 <input type="image" src="$cfg{imagesurl}/icon/move.png" Border="0" name="submit" />
</form>
HTML
}
}
sub forums_search {
my $s_name = shift || '';
 return <<HTML;
<table class="navtable" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<form action="$cfg{pageurl}/index.$cfg{ext}" method="post" name="sbox" onSubmit="if (document.sbox.query.value=='') return false">
<td align="center">
<input type="text" name="query" size="15" class="text" />
<input type="hidden" name="what" value="forums" />
<input type="hidden" name="op" value="search,Search" />
&nbsp;&nbsp;<input type="submit" value="$msg{search} $s_name" />
</td>
</form></tr></table>
HTML
}
sub move {

# Move Tread
my ($in_cat, $in_subcat);
if ($location && $thread) {
$location =~ s/\A(.+?)\|(.+?)\z/$1$2/;
$in_cat = $1;
$in_subcat = $2;
my($past_cat, $past_subcat, $replys);
my $sth = "SELECT cat_id, subcat_id, reply_ct FROM forum_threads WHERE id='$thread'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
($past_cat, $past_subcat, $replys) = ($row[0],$row[1],$row[2]);

}
$sth->finish;

# move thread
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `forum_threads` SET `cat_id` = '$in_cat',
`subcat_id` = '$in_subcat' WHERE `id` ='$thread' ;");

# move replys to thread
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `forum_reply` SET `cat_id` = '$in_cat',
`subcat_id` = '$in_subcat' WHERE `thread_id` ='$thread' ;");

# change post count
$Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `forum_subcat` SET `thread_ct` =thread_ct - 1,
`post_ct` =post_ct - $replys, `last_post` = 'Self' WHERE `id` ='$past_subcat' ;");

$Flex_WPS->SQL_Edit($cfg{Portal_backend},"UPDATE `forum_subcat` SET `thread_ct` =thread_ct + 1,
`post_ct` =post_ct + $replys, `last_post` = 'Self' WHERE `id` ='$in_subcat' ;");
}

print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=subcat,Forum;cat=' . $in_cat . ';subcat=' . $in_subcat . ';sticky=forums');
}
# Needs testing
sub optimize {

my @info = ('forum_cat', 'forum_subcat', 'forum_threads', 'forum_reply');
my @stuff = ();
# SHOW TABLE STATUS LIKE $table
# OPTIMIZE TABLE $table
# FLUSH TABLES WITH READ LOCK
foreach my $table (@info) {
# SHOW TABLE STATUS LIKE $table
my $sth = "SHOW TABLE STATUS LIKE '$table'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {

# Note: I know the MyISAM name works for me, the php code i modeled this from used MYISAM in its code.
# So the BDB name has not been tested and could be wrong.
if ($row[9] && ($row[1] eq 'MyISAM' || $row[1] eq 'BDB')) {
                push ( @stuff, $row[0] );
      }
}
$sth->finish;
                  #$stuff .= "<br>";
                   }
                   my $optamize = '';
                   if (@stuff) {
                        #require SQLEdit;
                          foreach my $table (@stuff) {
                                  # OPTIMIZE TABLE $table
                                  $Flex_WPS->SQL_Edit($cfg{Portal_backend},"OPTIMIZE TABLE $table");
                                  $optamize .= 'OPTIMIZE TABLE ' . $table . '<br /><br />';
                          }
                          # FLUSH TABLES WITH READ LOCK
                          $Flex_WPS->SQL_Edit($cfg{Portal_backend},'FLUSH TABLES WITH READ LOCK');
                          $Flex_WPS->SQL_Edit($cfg{Portal_backend},"UNLOCK TABLES");
                   }
                    else {
                          $optamize = 'Nothing to Optimized';
                    }

        my $post_html = <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Optimize <a href="$cfg{pageurl}/index.$cfg{ext}?op=cats,Forum">Forum</a></p>
This will optimize only the Tables for the Forum.<br />
It is Recommended to Run this Page if there has been many Inserts or Edits to the Forum.<br />
The Optimizer will also check if the Forum Table need to be Optimized.
</td>
</tr></table>
$optamize
<hr />
HTML

$Flex_WPS->print_page(
        markup       => $post_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Forum',
        );

}

sub print_thread {
  # <a href="$cfg{pageurl}/index.$cfg{ext}?op=print_thread,Forum;cat=$cat;subcat=$subcat;thread=$thread">Print</a>
$cat = $back_ends{$cfg{Portal_backend}}->quote($cat);
$subcat = $back_ends{$cfg{Portal_backend}}->quote($subcat);
$thread = $back_ends{$cfg{Portal_backend}}->quote($thread);
$lock = $back_ends{$cfg{Portal_backend}}->quote($lock); # jump to
my @print_stuff = ();

my $query1 = '';
if ($id ne 2) {
$query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.date, forum_threads.poster, forum_threads.subject, forum_threads.message, forum_cat.id, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_cat.id=$cat AND forum_cat.sec_level = '$usr{anonuser}' AND forum_threads.id = $thread LIMIT 1;";
if ($user_data{sec_level} eq $usr{admin}) {
$query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.date, forum_threads.poster, forum_threads.subject, forum_threads.message, forum_cat.id, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_cat.id=$cat AND forum_threads.id = $thread";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
 $query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_threads.message, forum_cat.id, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_cat.id=$cat AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' AND forum_threads.id = $thread LIMIT 1;";
 }
  elsif ($user_data{sec_level} eq $usr{user}) {
  $query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_threads.message, forum_cat.id, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_cat.id=$cat AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user})' AND forum_threads.id = $thread LIMIT 1;";
  }

my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute;
# Get page content.
while(my @row = $sth->fetchrow)  {
   push (@print_stuff,
   join ('|', $row[6], $row[1], $row[0], $row[3], $row[4], $row[5], $row[7], $row[2], '1'));
 }
 $sth->finish();
}
my $limit_table = qq( AND forum_reply.thread_id=$thread);
$limit_table = qq( AND forum_reply.id=$lock LIMIT 1;) if $id eq '2';
if ($id ne 1) {
$query1 = "SELECT forum_reply.id, forum_reply.subcat_id, forum_reply.thread_id, forum_reply.date, forum_reply.poster, forum_reply.subject, forum_reply.message, forum_cat.id, forum_cat.cat_type FROM forum_reply, forum_cat WHERE forum_cat.id=$cat AND forum_cat.sec_level = '$usr{anonuser}'$limit_table";
if ($user_data{sec_level} eq $usr{admin}) {
$query1 = "SELECT forum_reply.id, forum_reply.subcat_id, forum_reply.thread_id, forum_reply.date, forum_reply.poster, forum_reply.subject, forum_reply.message, forum_cat.id, forum_cat.cat_type FROM forum_reply, forum_cat WHERE forum_cat.id=$cat$limit_table";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
 $query1 = "SELECT forum_reply.id, forum_reply.subcat_id, forum_reply.thread_id, forum_reply.date, forum_reply.poster, forum_reply.subject, forum_reply.message, forum_cat.id, forum_cat.cat_type FROM forum_reply, forum_cat WHERE forum_cat.id=$cat AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})'$limit_table";
 }
  elsif ($user_data{sec_level} eq $usr{user}) {
  $query1 = "SELECT forum_reply.id, forum_reply.subcat_id, forum_reply.thread_id, forum_reply.date, forum_reply.poster, forum_reply.subject, forum_reply.message, forum_cat.id, forum_cat.cat_type FROM forum_reply, forum_cat WHERE forum_cat.id=$cat AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user})'$limit_table";
  }
my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute;
# Get page content.
while(my @row = $sth->fetchrow)  {
   if ($id eq 4) {
   @print_stuff = ( join ('|', $row[7], $row[1], $row[2], $row[4], $row[5], $row[6], $row[8], $row[3], "0$row[0]"), @print_stuff );
   }
    else {
   push (@print_stuff,
   join ('|', $row[7], $row[1], $row[2], $row[4], $row[5], $row[6], $row[8], $row[3], $row[0]));
   }
 }
 $sth->finish();
}

my $html_print = '';
        foreach my $line_print (@print_stuff) {
                my ($cat_id, $sub_cat_id, $thread_id, $poster, $subjectt, $messagee, $type_id, $date_r, $jump_too) = split(/\|/, $line_print);
                $html_print .= format_print($cat_id, $sub_cat_id, $thread_id, $poster, $subjectt, $messagee, $type_id, $date_r, $jump_too);
        }

my $css_code = '';

if ($id ne 4) {
$css_code = qq(<script>
onload = window.print();
</script>);
}
if ($id eq 4) {
$css_code = qq(<meta http-equiv="Content-Type" content="text/html; charset=$cfg{codepage}">
<link rel="stylesheet" href="$cfg{themesurl}/standard/style.css" type="text/css">);
}
print "Content-type: text/html\n\n";
        print <<HTML;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>$cfg{pagetitle} - $msg{print_friendly}</title>
$css_code
</head>
<body>
$html_print
</body>
</html>
HTML

# DC SQL
#$back_ends{$cfg{Portal_backend}}->disconnect();
exit;
}

sub format_print {
my ($cat_id, $sub_cat_id, $thread_id, $poster, $subjectt, $messagee, $type_id, $datee, $jump_to) = @_;

#aubbc_mod();
$messagee = $AUBBC_mod->do_all_ubbc($messagee);
$subjectt = $AUBBC_mod->do_all_ubbc($subjectt);

# Format date.
$datee = $Flex_WPS->format_date($datee);

return <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="100%">
<tr>
<td><b><big>$subjectt</big></b><br><small>$datee - $poster</small></td>
</tr>
<tr>
<td>$messagee</td>
</tr>
<tr>
<td>
<small>Post URL: <a href="$cfg{pageurl}/index.$cfg{ext}?op=threads,Forum;cat=$cat_id;subcat=$sub_cat_id;thread=$thread_id;sticky=$type_id#$jump_to" target="_parent">$cfg{pageurl}/index.$cfg{ext}?op=threads,Forum;cat=$cat_id;subcat=$sub_cat_id;thread=$thread_id;sticky=$type_id#$jump_to</a></small></td>
</tr></table><hr>
HTML
}

sub rss_feed {
my $post_msg = '';
my $query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.sec_level = '$usr{anonuser}' ORDER BY forum_threads.date DESC LIMIT 50;";
my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute || return;

while(my @row = $sth->fetchrow)  {

     my $cat_type = $row[$#row] if $row[$#row];
     my $ddate = $row[5];
     # Format date.
     $ddate = $Flex_WPS->format_date($ddate, 1);
                $subject = $AUBBC_mod->script_escape($row[11]);
                if (length($subject) > 250) {
                    $subject = substr($subject, 0, 250);
                    $subject =~ s/(.*)\s.*/$1 \.\.\./;
                    }

                my $message = $AUBBC_mod->script_escape($row[12]);
                if (length($message) > 250) {
                    $message = substr($message, 0, 250);
                    $message =~ s/(.*)\s.*/$1 \.\.\./;
                    }

                $post_msg .= <<HTML;
                
<item>
<title>$subject</title>
<link>$cfg{pageurl}/index.$cfg{ext}?op=threads,Forum;cat=$row[1];subcat=$row[2];thread=$row[0];sticky=$cat_type</link>
<description>$message</description>
<pubDate>$ddate</pubDate>
</item>

HTML
}
$sth->finish;

use Fcntl ':flock';
        open(FH, '>', $cfg{non_cgi_dir} . '/newsfeed.xml');
        flock(FH, LOCK_EX);
my $new_date = $Flex_WPS->format_date('', 1);
print FH <<HTML;
<?xml version="1.0" encoding="$cfg{codepage}" ?>
<rss version="2.0">
<channel>
<title>$cfg{pagetitle}</title>
<link>$cfg{pageurl}/index.$cfg{ext}</link>
<description>
$cfg{pagetitle} Newest Topics.
</description>
<language>en-us</language>
<generator>Flex-WPS RSS Feeds</generator>
<copyright>Copyright @ $cfg{pagetitle}</copyright>
<pubDate>$new_date</pubDate>
<lastBuildDate></lastBuildDate>
<category>$cfg{pagetitle}</category>
<image>
<title>$cfg{pagetitle}</title>
<url>$cfg{non_cgi_url}/images/pb_flex.gif</url>
<link>$cfg{pageurl}/index.$cfg{ext}</link>
</image>
$post_msg
</channel>
</rss>
HTML

close(FH);

        chmod($cfg{non_cgi_dir} . '/newsfeed.xml', 0644);

}

1;


