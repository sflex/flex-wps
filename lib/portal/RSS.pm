package RSS;
use strict;
# Flex-WPS mySQL RSS Module
# Version: 0.99
# Date: 10.08.2007 06:02:12
#
# This script may not have any bugs Parsing the XML after the
# Fixes have been added, more testing is needed
# This code also seems faster then the RSS Module 2
#
#
# module_settings table
# ID, module_name, settings
#
# feed_expire, feed_limit, default_feed, request, feed_mod
#
# rss_info table
# ID, Name, Link, DATA, Date, sec_lvl
#
# rss_members table
# ID, UID, rss_id, options
#
# Assign global variables.
use vars qw(
  $query $Flex_WPS $AUBBC_mod
  %user_action
  %user_data %back_ends
  %sub_action %cfg %usr %err
  );
use exporter;

my $RSS_VERSION = '0.99';

# Define possible user actions.
%user_action = (
                feeds => $usr{anonuser},
                settings => $usr{user},
                save_set => $usr{user},
                admin => $usr{admin},
                admin_set => $usr{admin},
                admin_add => $usr{admin},
                );

# Define possible subload actions.
#%sub_action = ( menu => 1 );

my $logo = $query->param('logo') || 0;
my $rsslimit = $query->param('rsslimit') || '';
my $select = $query->param('select') || '';
my $id = $query->param('id') || '';
if ($logo && $logo !~ m!^([0-1]+)$!i) { $logo = 1; }
if ($rsslimit && $rsslimit !~ m!^([0-9]+)$!i) { $rsslimit = 225; }
if ($select && $select !~ m!^([0-9]+)$!i) { $select = 1; }

my $name = $query->param('name') || '';
my $fdate = $query->param('fdate') || '';
my $link = $query->param('link') || '';
my $seclvl = $query->param('seclvl') || '';
my $text = $query->param('text') || '';

my $set_id = '';
my ($feed_expire, $feed_limit, $default_feed, $request_feed, $feed_mod) = ('+20m','225','1','1','1');
# Get RSS Module Settings
my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM module_settings WHERE module_name='RSS_Module'");
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow)  {
$set_id = $row[0];
($feed_expire, $feed_limit, $default_feed, $request_feed, $feed_mod) = split(/\|/, $row[2]);
}
$sth->finish();
my $feed_expire1 = $feed_expire;
my $feed_limit1 = $feed_limit;
my $default_feed1 = $default_feed;
my $request_feed1 = $request_feed;
my $feed_mod1 = $feed_mod;

my ($rssid, $show_logo, $member_limit, $member_feed) = ('','','','');
# Get Member Settings
if ($user_data{uid} ne $usr{anonuser}) {
$sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM rss_members WHERE uid='$user_data{uid}'");
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow)  {
$rssid = $row[0];
$member_feed = $row[2];
($show_logo, $member_limit) = split(/\|/, $row[3]);
}
$sth->finish();
$feed_limit = $member_limit if $member_limit <= $feed_limit;
$default_feed = $member_feed if $member_feed;
}

# Get and Print RSS feed to HTML
sub feeds {

my ($rss_link, $rss_data, $rss_date, $other_stuff) = ('','',0,'');
$sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM rss_info WHERE id='$default_feed'");
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow)  {
$rss_link = $row[2];
$rss_data = $row[3];
$rss_date = $row[4];
}
$sth->finish();
if (!$rss_link || !$rss_date) {
        $Flex_WPS->user_error(
                error => $err{bad_input},
                theme => $cfg{default_theme},
                backend_name => $cfg{Portal_backend},
                );
    }

my $current_date = '';
$current_date = CGI::Util::expire_calc('now','');
# Get Remote xml file  http://www.perlmonks.com/?node_id=30175&xmlstyle=rss
# http://www.washingtonpost.com/wp-dyn/rss/index.html
if ($rss_date <= $current_date) {
use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
$ua->timeout( 20 );
$ua->agent("Flex-WPS_mySQL; RSS_Module/$RSS_VERSION");
my $req = HTTP::Request->new(GET => $rss_link);
my $res = $ua->request($req);

if ($res->is_success) {
$rss_data = $res->content;
$rss_date = CGI::Util::expire_calc($feed_expire,'');
    # All of these fix many problems
    $rss_data =~ s/<!\[CDATA\[//gso;
    $rss_data =~ s/]]>//gso;
    #$rss_data =~ s/'/&#39;/gso;
    #$rss_data =~ s/\\/&#92;/gso;
    $rss_data =~ s/\G<(.*?)>(?s)(.*?)<\/\1>\G/
    my $ret = "<$1>" . $AUBBC_mod->script_escape($2) . "<\/$1>";
    $ret ? $ret : $2;
    /exisg;
    #$rss_data =~ s{<(.*?)(\s.*?)>(?s)(.*?)</\1>}{<$1$2>HTML_TEXT::html_escape($3, 1)</$1>}gso;

           if (length($rss_data) > 160000) {
               $rss_data = substr($rss_data, 0, 160000);
               $rss_data =~ s/(.*)\s.*/$1/;
               }
               $rss_data = $back_ends{$cfg{Portal_backend}}->quote($rss_data);
     $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `rss_info` SET `data`=$rss_data, `date`='$rss_date' WHERE `id` ='$default_feed' LIMIT 1 ;");
       }
     }

# Wrap Text
use Text::Wrap
$Text::Wrap::columns = 25;
my @title = ('');
my @link = ('');
my @description = ('');
my @language = ('');
my @generator = ('');
my $image_html = '';
# Top Info
if (!$show_logo) {
@title = ($rss_data =~ m{<title>(.*?)</title>}i);
@link = ($rss_data =~ m{<link>([http|https].*?)</link>}i);
# This description regex had many problems =P
# Problems may have been caused by "missmatched tags" error
# A fix has been issued and seemd to be working very well
#my @description = ($rss_data =~ m{(?<![<item.*?>.*?])(?:<channel>(?s).*?)<description>(?s)(.*?)</description>(?:.*?<item)}i);
@description = ($rss_data =~ m{(?<![<item.*?>.*?])(?:<channel>(?s).*?)<description>(?s)(.*?)</description>}i);
@language = ($rss_data =~ m{<language>(.*?)</language>}i);
@generator = ($rss_data =~ m{<generator>(.*?)</generator>}i);
           # Cap the length
           if ($description[0] && length($description[0]) > 150) {
               $description[0] = substr($description[0], 0, 150);
               $description[0] =~ s/(.*?)\s.*\z/$1 \.\.\./;
               }
           $description[0] = wrap('', '', $description[0]) if $description[0];
           $title[0] = wrap('', '', $title[0]) if $title[0];
# Make it safe
#$description[0] = HTML_TEXT::html_escape($description[0], 1) if $description[0];
#$title[0] = HTML_TEXT::html_escape($title[0], 1) if $title[0];
#$link[0] = HTML_TEXT::html_escape($link[0], 1) if $link[0];
#$language[0] = HTML_TEXT::html_escape($language[0], 1) if $language[0];
#$generator[0] = HTML_TEXT::html_escape($generator[0], 1) if $generator[0];
        # The Image
        while ($rss_data =~ s{<image>(.*?)</image>} {
                       my $tmp = $1;
                       # Image Info
                       my @width = ($tmp =~ m{<width>(\d+)</width>}i);
                       my @height = ($tmp =~ m{<height>(\d+)</height>}i);
                       my @link1 = ($tmp =~ m{<link>([http|https].*?)</link>}i);
                       my @image1 = ($tmp =~ m{<url>([http|https].*?)</url>}i);
                       my @title1 = ($tmp =~ m{<title>(.*?)</title>}i);

                       #$title1[0] = HTML_TEXT::html_escape($title1[0], 1);
                       #$link[0] = HTML_TEXT::html_escape($link[0], 1);
                       #$image1[0] = HTML_TEXT::html_escape($image1[0], 1);
                       $width[0] = " width=\"$width[0]\"" if $width[0];
                       $height[0] = " height=\"$height[0]\"" if $height[0];
                       $image_html .= "<a href=\"$link1[0]\" target=\"_blank\"><img src=\"$image1[0]\"$height[0]$width[0] border=\"0\"><br />$title1[0]</a><br />\n";
                       }exisog) {}
 } # End Show Logo
        # The News
        my $br_tag = '';
        my $feed_ct = 0;
        while ($rss_data =~ s{<item.*?>(.*?)</item>} {
                       my $tmp = $1;
                       $feed_ct++;
                       my @description1 = ($tmp =~ m{<description>(?s)(.*?)</description>}i);
                       my @title1 = ($tmp =~ m{<title>(.*?)</title>}i);
                       my @link1 = ($tmp =~ m{<link>([http|https].*?)</link>}i);
                       my @pubDate1 = ($tmp =~ m{<pubDate>(.*?)</pubDate>}i);

                       if ($description1[0] && length($description1[0]) > 200) {
                           $description1[0] = substr($description1[0], 0, 200);
                          # $description1[0] =~ s/\A(.*?)\s.*\z/$1/g;

                           }
                           $description1[0] .= ' ...';
                           $description1[0] = wrap('', '', $description1[0]) if $description1[0];
                           $title1[0] = wrap('', '', $title1[0]) if $title1[0];

                       #$description1[0] = HTML_TEXT::html_escape($description1[0], 1)  if $description1[0];
                       #$title1[0] = HTML_TEXT::html_escape($title1[0], 1) if $title1[0];
                       #$link1[0] = HTML_TEXT::html_escape($link1[0], 1) if $link1[0];
                       #$pubDate1[0] = HTML_TEXT::html_escape($pubDate1[0], 1) if $pubDate1[0];
                       $pubDate1[0] = "<small><font color=DarkRed><i>$pubDate1[0]</i></font></small><br />\n" if $pubDate1[0];
                       $other_stuff .= "$br_tag\n<font size=\"2\">$feed_ct)<a href=\"$link1[0]\" target=\"_blank\">$title1[0]</a></font><br />\n<font size=\"1\">"
                                . $description1[0]
                                . "<br />\n$pubDate1[0]</font>\n";
                        last if $feed_ct == $feed_limit; # Limit how many to show
                        $br_tag = '<br />' if !$br_tag;
                }exisog) {}

       $rss_date = $Flex_WPS->format_date($rss_date, 5);
       $description[0] = "<b>Description:</b> $description[0]<br />" if $description[0] && !$show_logo;
       print "Content-type: text/html\n\n";
       print <<HTML;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>RSS Feed</title>
</head>
<body bgcolor="#ebebeb" text="#000000">
HTML
if (!$show_logo) {
print <<HTML;
<hr>
<font size="1" color=DarkRed>Next Update: $rss_date</font><br />
<font size="2"><a href="$link[0]" target=\"_blank\"><b>$title[0]</b></a></font><br />
<font size="1"><small><u>$language[0] - $generator[0]</u></small><br />
$description[0]
$image_html
Total: $feed_ct</font>
<hr>
HTML
}
print <<HTML;
$other_stuff
</body>
</html>
HTML
}

# In the Site Admin area >> Sub's Load
# Add New lib/module = 0 & 1, PM = RSS,
# Sub = menu, Location = 3
sub menu {
my $user_html = '';
my $admin_html = '';
if($user_data{sec_level} eq $usr{admin} || $user_data{uid} eq $feed_mod) {
    $admin_html = qq(<center><a href="$cfg{pageurl}/index.$cfg{ext}?op=admin;module=RSS"><font color=red>RSS Admin</font></a></center>);
}
    if ($user_data{uid} ne $usr{anonuser}) {
         $user_html = qq(<center><a href="$cfg{pageurl}/index.$cfg{ext}?op=settings;module=RSS"><font color=red>RSS Settings</font></a>);
         $user_html .= qq( | <a href="$cfg{pageurl}/index.$cfg{ext}?op=view_pm;message=send;to=$feed_mod"><font color=red>Request Feed</font></a>) if $request_feed;
         $user_html .= qq(</center>);
    }
        # We want to do it in an iframe incase the xml provider lags
        my $user_status = $Flex_WPS->box_header('RSS Feed');
        $user_status .= <<HTML;
<tr>
<td valign="top">
$admin_html
<IFRAME width="173" height="250" SRC="$cfg{pageurl}/index.$cfg{ext}?op=feeds,RSS;id=$default_feed" marginwidth="1" marginheight="1" border="1" frameborder="1"></IFRAME><br />
$user_html
</td>
</tr>
HTML
        $user_status .= $Flex_WPS->box_footer();

        print $user_status;

}
# Member Settings
sub settings {
if($user_data{sec_level} eq $usr{anonuser}) {
        $Flex_WPS->user_error(
                error => $err{auth_failure},
                theme => $cfg{default_theme},
                backend_name => $cfg{Portal_backend},
                );
}
my $select = '';
$sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM rss_info");
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow)  {
            my $bs = '';
            $bs = ' selected' if $row[0] && $member_feed eq $row[0];
            #$bs = ' selected' if !$id && $usr{$_} eq $usr{anonuser};
            $select .= "<option value=\"$row[0]\"$bs>$row[1]</option>\n";
}
$sth->finish();
my $select1 = ' selected';
my $select2 = ' selected';
$select2 = '' if $show_logo;
$select1 = '' if !$show_logo;
      $request_feed = "You can Request a RSS Feed Here <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=view_pm;message=send;to=$feed_mod\">Request Feed</a><br />" if $request_feed;
$Flex_WPS->print_header( cookie1 => '', cookie2 => '',);
$Flex_WPS->print_html(
        theme        => $cfg{default_theme},
        page_name    => 'RSS Settings',
        type         => '',
        ajax_name    => '',
        backend_name => $cfg{Portal_backend},
        );
print <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">User RSS Settings Edit</p>
Show the Top Logo of the RSS Feed.<br />
Limit RSS is 1 to $feed_limit topics to show.<br />
You can Select the News you want to see from the list.<br />
$request_feed
</td>
</tr></table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>Show Logo</b></td>
    <td width="26%"><b>Limit RSS</b></td>
    <td width="17%"><b>Feed Select</b></td>
    <td width="19%"></td>
  </tr>
</table>
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="save_set,RSS">
  <tr>
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')">
    </td>
    <td width="26%">
        <select name="logo">
          <option value="1"$select1>No</option>
          <option value="0"$select2>Yes</option>
        </select>
      </td>
    <td width="26%">
        <input type="text" name="rsslimit" value="$member_limit" size="5">
      </td>
    <td width="17%">
       <select name="select">
          $select
        </select>
      </td>
      <td>&nbsp;</td>
  </tr>
 </form>
</table>
HTML
$Flex_WPS->print_html(
        theme        => $cfg{default_theme},
        page_name    => 'RSS Settings',
        type         => 1,
        ajax_name    => '',
        backend_name => $cfg{Portal_backend},
        );

}
sub save_set {
if($user_data{sec_level} eq $usr{anonuser}) {
        $Flex_WPS->user_error(
                error => $err{auth_failure},
                theme => $cfg{default_theme},
                backend_name => $cfg{Portal_backend},
                );
}
my $options = '';
$rsslimit = 225 if $rsslimit > 225 || $rsslimit <= 0;
$options = $logo . '|' . $rsslimit;
if ($rssid) {
     $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `rss_members` SET `rss_id`='$select', `options`='$options' WHERE `uid` ='$user_data{uid}' LIMIT 1 ;");
}
 else {
     $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO rss_members VALUES (NULL,'$user_data{uid}','$select','$options');");
 }
                # Redirect to user_actions page.
                print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=settings,RSS');

}
sub admin {
if($user_data{sec_level} ne $usr{admin} && $user_data{uid} ne $feed_mod) {
        $Flex_WPS->user_error(
                error => $err{auth_failure},
                theme => $cfg{default_theme},
                backend_name => $cfg{Portal_backend},
                );
}
my $select = '';
$sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM rss_info");
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow)  {
 my $seclvl = '';
    foreach (sort keys %usr) {
            my $bs = '';
            $bs = ' selected' if $row[5] && $usr{$_} eq $row[5];
            #$bs = ' selected' if !$id && $usr{$_} eq $usr{anonuser};
            $seclvl .= "<option value=\"$usr{$_}\"$bs>$usr{$_}</option>\n";
            }
 $select .= <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="admin_add,RSS">
<input type="hidden" name="id" value="$row[0]">
  <tr>
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')"> ID $row[0]
    </td>
    <td width="26%">
        <input type="text" name="name" value="$row[1]" size="10">
        <input type="text" name="fdate" value="$row[4]" size="5">
      </td>
    <td width="26%">
        <input type="text" name="link" value="$row[2]">
      </td>
    <td width="17%">
       <select name="seclvl">
          $seclvl
        </select>
      </td>
      <td>&nbsp;</td>
  </tr>
 </form>
</table>
HTML

}
$sth->finish();
 my $seclvl = '';
    foreach (sort keys %usr) {
            my $bs = '';
            #$bs = ' selected' if $row[5] && $usr{$_} eq $row[5];
            $bs = ' selected' if $usr{$_} eq $usr{anonuser};
            $seclvl .= "<option value=\"$usr{$_}\">$usr{$_}</option>\n";
            }
$Flex_WPS->print_header( cookie1 => '', cookie2 => '',);
$Flex_WPS->print_html(
        theme        => $cfg{default_theme},
        page_name    => 'RSS Admin Settings',
        type         => '',
        ajax_name    => '',
        backend_name => $cfg{Portal_backend},
        );

print <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">RSS Admin Settings</p>
...
</td>
</tr></table>
<table width="100%" border="0" cellspacing="0" cellpadding="2" bgcolor="#CCFF00">
  <tr>
      <td>&nbsp;</td>
      <td>Expier</td>
      <td>Limit RSS</td>
      <td>Default RSS</td>
      <td>Request RSS</td>
      <td>RSS Mod</td>
  </tr>
<form method="post" action="">
<input type="hidden" name="op" value="admin_set,RSS">
<input type="hidden" name="id" value="$set_id">
  <tr>
      <td>
        <input type="submit" name="Submit" value="Edit Settings">
      </td>
      <td>
        <input type="text" name="name" value="$feed_expire1" size="5">
      </td>
      <td>
        <input type="text" name="link" value="$feed_limit1" size="5">
      </td>
      <td>
        <input type="text" name="fdate" value="$default_feed1" size="5">
      </td>
      <td>
        <input type="text" name="seclvl" value="$request_feed1" size="5">
      </td>
    <td>
        <input type="text" name="text" value="$feed_mod1" size="5">
      </td>
  </tr>
  </form>
</table>
<hr>
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="admin_add,RSS">
<input type="hidden" name="id" value="">
  <tr>
    <td width="12%">
        <input type="submit" name="Add New" value="Add New" onclick="javascript:return confirm('Are you sure you want to Edit this item?')">
    </td>
    <td width="26%">
        <input type="text" name="name" value="" size="10">
        <input type="text" name="fdate" value="" size="5">
      </td>
    <td width="26%">
        <input type="text" name="link" value="">
      </td>
    <td width="17%">
       <select name="seclvl">
          $seclvl
        </select>
      </td>
      <td>&nbsp;</td>
  </tr>
 </form>
</table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>Name/ExpierDate</b></td>
    <td width="26%"><b>RSS Link</b></td>
    <td width="17%"><b>Security Level</b></td>
    <td width="19%">&nbsp;</td>
  </tr>
</table>
$select
HTML
$Flex_WPS->print_html(
        theme        => $cfg{default_theme},
        page_name    => 'RSS Settings',
        type         => 1,
        ajax_name    => '',
        backend_name => $cfg{Portal_backend},
        );
}
sub admin_set {
if($user_data{sec_level} ne $usr{admin} && $user_data{uid} ne $feed_mod) {
        $Flex_WPS->user_error(
                error => $err{auth_failure},
                theme => $cfg{default_theme},
                backend_name => $cfg{Portal_backend},
                );
}
   my $options = "$name\|$link\|$fdate\|$seclvl\|$text";
   $options = $back_ends{$cfg{Portal_backend}}->quote($options);
   $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `module_settings` SET `settings`=$options WHERE `module_name`='RSS_Module' LIMIT 1 ;");

                # Redirect to user_actions page.
                print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=admin,RSS');

}

sub admin_add {
if($user_data{sec_level} ne $usr{admin} && $user_data{uid} ne $feed_mod) {
        $Flex_WPS->user_error(
                error => $err{auth_failure},
                theme => $cfg{default_theme},
                backend_name => $cfg{Portal_backend},
                );
}

#if ($fdate <= $current_date) {
#my $fees_from = 'http://www.perlmonks.com/?node_id=30175&xmlstyle=rss';
use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
$ua->timeout( 20 );
$ua->agent("Flex-WPS_mySQL; RSS_Module/$RSS_VERSION");
my $req = HTTP::Request->new(GET => $link);
my $res = $ua->request($req);
my $rss_data = '';
my $rss_date = '';
if ($res->is_success) {
$rss_data = $res->content;

    # All of these fix many problems
    $rss_data =~ s/<!\[CDATA\[//gso;
    $rss_data =~ s/]]>//gso;
    $rss_data =~ s/'/&#39;/gso;
    $rss_data =~ s/\\/&#92;/gso;
    $rss_data =~ s{<(.*?)>(?s)(.*?)</\1>}{<$1>$AUBBC_mod->script_escape($2)</$1>}gso;
    $fdate = CGI::Util::expire_calc($feed_expire,'');
     }
if ($id) {
     $name = $back_ends{$cfg{Portal_backend}}->quote($name);
     $link = $back_ends{$cfg{Portal_backend}}->quote($link);
     $rss_data = $back_ends{$cfg{Portal_backend}}->quote($rss_data);
     $seclvl = $back_ends{$cfg{Portal_backend}}->quote($seclvl);
     $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `rss_info` SET `name`=$name, `link`=$link, `data`=$rss_data, `date`='$fdate', `sec_lvl`=$seclvl WHERE `id` ='$id' LIMIT 1 ;");
}
 else {
     $name = $back_ends{$cfg{Portal_backend}}->quote($name);
     $link = $back_ends{$cfg{Portal_backend}}->quote($link);
     $rss_data = $back_ends{$cfg{Portal_backend}}->quote($rss_data);
     $seclvl = $back_ends{$cfg{Portal_backend}}->quote($seclvl);
     $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO rss_info VALUES (NULL,$name,$link,$rss_data,'$fdate',$seclvl);");
 }
                # Redirect to user_actions page.
                print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=admin,RSS');

}
1;
