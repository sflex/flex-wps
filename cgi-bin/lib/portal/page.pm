package page;
=head1 Flex-WPS, page.pm

by N. K. A.

 shakaflex@gmail.com
 http://search.cpan.org/~sflex/
 
 Version: 1.0 beta 9
Date: 01/21/2011
Fixed </textarea> bug
Set <textarea wrap="off" for better view
AJAX name installed and name formated as "page::$id"
SubLoad location installed and name formated as "page::$id"

11/05/2010 v1.0 beta 8
Fixed authorized not working for double length numbers "\d+"

1.0 beta 7 - 07/03/2010 - Added module help

v1.0 beta 6 05/30/2009- Now has an option to print without the theme layout, in plain text/html.
?op=page,page;id=#;plain=text
?op=page,page;id=#;plain=html

v1.0 beta 1 - 09/14/2008
=cut

use strict;
use vars qw(
    %err $query %cfg $Flex_WPS %user_action
    %usr %user_data $AUBBC %back_ends
    );
use Flex_Porter;

%user_action = (
      delete_page => $usr{admin},
      page        => $usr{anonuser},
      page_admin  => $usr{admin},
      page_edit   => $usr{admin},
      page_edit2  => $usr{admin},
);

my $id  = $query->param('id') || '';

$id = $Flex_WPS->untaint2(value => $id, pattern => '\d',) if $id =~ m/\A\d+\z/;

# Main Page View
sub page {
my ($text, $title, $string) = ('', '', "`pageid` = '$id' AND `active` = '1'");

if ($id !~ m/\A\d+\z/) {
$id = $Flex_WPS->untaint2(value => $id, pattern => '\w\:',);
$string = "`active` = '1' AND `title` = '$id'" if $id;
$string = "`title` = '$id'" if $user_data{sec_level} eq $usr{admin};
}

if ($id) {
my $sth = "SELECT `pageid`, `title`, `pagetext` FROM pages WHERE $string AND `sec_level` = '$usr{anonuser}' LIMIT 1 ;";
if ($user_data{sec_level} eq $usr{admin}) {
$string = "`pageid` = '$id'" if $id =~ m/\A\d+\z/;
        $sth = "SELECT `pageid`, `title`, `pagetext` FROM pages WHERE $string LIMIT 1 ;";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
        $sth = "SELECT `pageid`, `title`, `pagetext` FROM pages WHERE $string AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 1 ;";
}
 elsif ($user_data{sec_level} eq $usr{user}) {
        $sth = "SELECT `pageid`, `title`, `pagetext` FROM pages WHERE $string AND `sec_level` REGEXP '($usr{anonuser}|$usr{user})' LIMIT 1 ;";
}
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
 while(my @row = $sth->fetchrow)  {
 $id = $row[0];
 $title = $Flex_WPS->eval_theme_tags($row[1]);
 $text = $Flex_WPS->eval_theme_tags($row[2]);
 }
$sth->finish;
}

my $plain  = $query->param('text')  || 0;
if (! $id || ! $text && $plain ne 'text') {
$Flex_WPS->user_error();
}
 elsif (! $text && $plain eq 'text') {
 print "Content-type: text/html\n\n";
 print "No help message for this section. <a href=\"#top\" onclick=\"javascript:closeMessage(\'help\');\">Close <img src=\"$cfg{imagesurl}/button_cance.png\" alt=\"Close\" border=\"0\" /></a>";
}
 elsif ($id && $text) {
$AUBBC->add_a_settings('href_target', ' target="_blank"') if $plain;

#if (! $plain) {
#$cfg{theme_description} = $text;
#$cfg{theme_description} =~ s{<\/?(?s).*?\/?>}{ }g;
#$cfg{theme_description} =~ s{\[\/?.+?\]}{ }g;
#$cfg{theme_description} =~ s{(?:\r?\n|\s?\s)}{ }g;
# if (length($cfg{theme_description}) > 150) {
#  $cfg{theme_description} = substr($cfg{theme_description}, 0, 150);
#  $cfg{theme_description} =~ s/(.*)\s.*/$1/;
# }
#$cfg{theme_keywords} = $cfg{pagetitle}.' - '.$title;
#}

$text = $AUBBC->parse_bbcode($text);
$text =~ s{\<\/?aubbc\>}{}g;

my $admin_link = '';
$admin_link = <<"HTML" if ($user_data{sec_level} eq $usr{admin});
<a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=page_edit,page;id=$id">Admin Page Edit</a><hr />
HTML

        $admin_link = <<"HTML";
$admin_link
$text
HTML

        if (! $plain) {
        $Flex_WPS->print_page(
                markup       => $admin_link,
                cookie1      => '',
                cookie2      => '',
                location     => 'page::'.$id,
                ajax_name    => 'page::'.$id,
                navigation   => $title,
                );
        }
         elsif ($plain eq 'text') {
          print "Content-type: text/html\n\n";
          print $admin_link;
        }
         elsif ($plain eq 'html') {
        print <<"HTML";
Content-type: text/html

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$cfg{pagetitle} - $title</title>
<meta http-equiv="Content-Type" content="text/html; charset=$cfg{codepage}" />
<link rel="stylesheet" href="$cfg{themesurl}/$cfg{default_theme}/style.css" type="text/css" />
</head>
<body>
<div class="pagetable">
$admin_link
</div>
</body>
</html>
HTML
        }
 }
}

# Page Admin
sub page_admin {
my $page_html = <<"HTML";
<blockquote><small>
<a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=page_edit,page">Add New Page</a>
<div class="pure-g">
    <div class="pure-u-1-6 pure-table all-c"><b>Delete</b></div>
    <div class="pure-u-6-24 pure-table all-c"><b>Page Title / Edit</b></div>
    <div class="pure-u-6-24 pure-table all-c"><b>Security Level</b></div>
    <div class="pure-u-1-12 pure-table all-c"><b>Active</b></div>
</div>
HTML

my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM pages");
$sth->execute;

while(my @row = $sth->fetchrow)  {
      if ($row[0]) {
             my $active = 'Yes';
             my $title = $Flex_WPS->eval_theme_tags($row[2]);
             $title =~ s{&#39;}{'}gso;
             $active = 'No' if !$row[1];
             $page_html .= <<"HTML";
<div class="pure-g">
    <div class="pure-u-1-6 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=delete_page,page;id=$row[0]" onclick="return ConfirmThis();">Delete</a></div>
    <div class="pure-u-6-24"><a class="pure-button pure-button-primary" href="$cfg{pageurl}/index.$cfg{ext}?op=page_edit,page;id=$row[0]">$title</a></div>
    <div class="pure-u-6-24 all-c"><b>$row[4]</b></div>
    <div class="pure-u-1-12 all-c"><b>$active</b></div>
</div><hr />
HTML
      }

}
$sth->finish;

$Flex_WPS->print_page(
        markup       => $page_html.'</small></blockquote>',
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Page Admin',
        );

}

# Add/Edit Page
sub page_edit {
my ($text, $title, $act, $lvl) = ('', '', '', '');
my $page = '';
if ($id) {
   $page = $AUBBC->parse_bbcode("[page://$id]");
   $page = <<"HTML";
<blockquote><b>Page Edit</b><br />
The Theme Tag converter is used, so you can easly point to the main page like this.<br />
%homepage% = $cfg{pageurl}/index.$cfg{ext}<br /><br />
You can use these paths and UBBC tag to link to this page.<br />
 <a href="$cfg{pageurl}/index.$cfg{ext}?op=page,page;id=$id">Current Link</a> : %homepage%?op=page,page;id=$id
<br />
<b>OR</b><br />
<a href="$cfg{homeurl}/page/$id/">Current Link</a> : %homeurl%/page/$id/
<br />
<b>OR</b> - UBBC<br /> $page = [page://$id]
</blockquote>
HTML

my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM pages WHERE pageid='$id'");
$sth->execute;
while(my @row = $sth->fetchrow)  {
$title = $row[2];
$text = $row[3];
$act = $row[1];
$lvl = $row[4];
}
$sth->finish;

$text =~ s/<\/textarea>/&#60;\/textarea&#62;/g;
$text =~ s/(<aubbc>(?s)(.*?)<\/aubbc>)/
        my $ret = $AUBBC->html_to_text($2);
        $ret ? '<aubbc>'.$ret."<\/aubbc>" : $1;
        /eg;
#$AUBBC2::line_break = 1;
#$text = $AUBBC->script_escape($text);
#$text = $AUBBC_mod->script_escape( $text, 1 );
}
 my $seclvl = '';
    foreach (sort keys %usr) {
            my $bs = '';
            $bs = ' selected' if $lvl && $usr{$_} eq $lvl;
            $bs = ' selected' if !$id && $usr{$_} eq $usr{anonuser};
            $seclvl .= "<option value=\"$usr{$_}\"$bs>$usr{$_}</option>\n";
            }
    my $yes = ' selected';
    $yes = '' if !$act;
    my $no = ' selected';
    $no = '' if $act && $id || !$id;
# the UBBC image selector.
require UBBC;

# Print the UBBC panel.
my $ubbc_panel = UBBC::print_ubbc_panel();
        my $page_html = <<"HTML";
$page
<script language="javascript" type="text/javascript">
<!--
function addCode(anystr) {
insertAtCursor(document.form1.text, anystr);
}
function showColor(color) {
var colortag = "[color="+color+"][/color]";
insertAtCursor(document.form1.text, colortag);
}
// -->
</script>
<blockquote><small>
<form class="pure-form pure-form-stacked" method="post" id="form1" name="form1">
<input type="hidden" name="op" value="page_edit2,page" />
<input type="hidden" name="id" value="$id" />
    <fieldset>

        <label for="title"><b>Title:</b></label>
        <input id="title" class="pure-input-1" type="text" name="title" placeholder="Title.." value="$title" />

        <label for="text"><b>Text / HTML / UBBC</b></label>
        <textarea id="text" wrap="soft" placeholder="$msg{textC}.." name="text" rows="25" class="pure-input-1">$text</textarea>

        <label for="bbct"><b>$msg{ubbc_tagsC}</b></label>
        <div id="bbct">$ubbc_panel</div>
        
<div class="pure-g">
    <div class="pure-u-1-5">
        <label for="sec_lvl"><b>Security Level:</b></label>
        <div id="sec_lvl">
        <select name="sec_lvl">
        $seclvl
        </select>
        </div>
        </div>
    <div class="pure-u-1-12">
        <label for="active"><b>Active:</b></label>
        <div id="active">
        <select name="active">
        <option value="1"$yes>Yes</option>
        <option value="0"$no>No</option>
        </select>
        </div>
    </div>
</div>
        <input onclick="return ConfirmThis();" class="pure-button pure-button-primary" type="submit" value="$btn{submit}" />
    </fieldset>
</form>
</small>
</blockquote>
HTML
$Flex_WPS->print_page(
        markup       => $page_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Page Admin',
        );
}

sub page_edit2 {
# Param
# these 2 are secured
my $active  = $query->param('active')  || 0;
my $sec_lvl  = $query->param('sec_lvl')  || '';

# Test The special text converter for these 2
my $text  = $query->param('text')  || '';
my $title  = $query->param('title')  || '';

$text =~ s/&#60;\/textarea&#62;/<\/textarea>/g;
$text =~ s/(<aubbc>(?s)(.*?)<\/aubbc>)/
        my $ret = $AUBBC->script_escape($2);
        $ret ? '<aubbc>'.$ret."<\/aubbc>" : $1;
        /eg;
$text = $back_ends{$cfg{Portal_backend}}->quote($text);
$title = $back_ends{$cfg{Portal_backend}}->quote($title);

        $Flex_WPS->user_error(
                error => $err{bad_input},
                ) if ($active && $active !~ m/\A\d+\z/);
        $Flex_WPS->user_error(
                error => $err{bad_input},
                ) if ($sec_lvl && $sec_lvl !~ m/\A\w+\z/i);

if (!$id) {
    $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO pages VALUES (NULL,'$active',$title,$text,'$sec_lvl');");
    }
     elsif ($id) {
        $id = $back_ends{$cfg{Portal_backend}}->quote($id);
        $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `pages` SET `active` = '$active', `title` = $title, `pagetext` = $text, `sec_level` = '$sec_lvl' WHERE `pageid` =$id LIMIT 1 ;");
     }

# Redirect to page_admin.
  $Flex_WPS->page_redirect(
        location => "$cfg{pageurl}/index.$cfg{ext}?op=page_admin,page",
        cookie1 => '',
        cookie2 => '',
        );
}
# Delete pages
sub delete_page {
if ($id) {
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM pages WHERE pageid=$id");
}

 # Redirect to page_admin.
  $Flex_WPS->page_redirect(
        location => "$cfg{pageurl}/index.$cfg{ext}?op=page_admin,page",
        cookie1 => '',
        cookie2 => '',
        );
}
1;
