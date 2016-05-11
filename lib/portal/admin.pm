package admin;
# see bottum of file for version

# Load necessary modules.
use strict;
# Assign global variables.
use vars qw(
    $query $Flex_WPS $AUBBC_mod %back_ends
    %user_data %err %cfg %usr %nav %user_action %msg
    );
use exporter;

%user_action = (
        admin => $usr{admin},
        awelcome => $usr{admin},
        awelcome2 => $usr{admin},
        main_menu => $usr{admin},
        main_menu2 => $usr{admin},
        subs_load  => $usr{admin},
        subs_load2 => $usr{admin},
        super_mods => $usr{admin},
        super_mods2 => $usr{admin},
        super_paths => $usr{admin},
        super_paths2 => $usr{admin},
        module_settings => $usr{admin},
        module_settings2 => $usr{admin},
        user_menu2 => $usr{admin},
        user_menu => $usr{admin},
        menu_block => $usr{admin},
        menu_block2 => $usr{admin},
        admin_config => $usr{admin},
        admin_config2 => $usr{admin},
        site_ban => $usr{admin},
        site_ban2 => $usr{admin},
        theme => $usr{admin},
        theme2 => $usr{admin},
        optimize => $usr{admin},
        optimize2 => $usr{admin},
        ajax => $usr{admin},
        ajax2 => $usr{admin},
        stats_log => $usr{admin},
        stats_log2 => $usr{admin},
        );
 
my $id = $query->param('id') || '';
my $title = $query->param('title') || '';
my $message = $query->param('message') || '';
my $html = $query->param('html') || 2;

my $image = $query->param('image') || '';
my $image2 = $query->param('image2') || '';
my $loc = $query->param('loc') || '';
my $inputer = $query->param('inputcrap') || '';

my $add = $query->param('add') || '';
my $f_mode = $query->param('mode') || '';
my $keywords = $query->param('keywords') || '';
my $disc = $query->param('disc') || '';

sub admin {

$Flex_WPS->print_header( cookie1 => '', cookie2 => '',);
$Flex_WPS->print_html(
        page_name    => $nav{view_profile},
        type         => '',
        ajax_name    => '',
        );
        print <<HTML;
<table width="95%" border="1" cellspacing="5" cellpadding="4" align="center" class="navtable">
  <tr align="center">
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=awelcome,admin"><img src="$cfg{imagesurl}/admin/welcome.png" border="0" alt="" /><br /><b>Welcome Message</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=main_menu,admin"><img src="$cfg{imagesurl}/admin/menu.png" border="0" alt="" /><br /><b>Main Menu</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=user_menu,admin"><img src="$cfg{imagesurl}/admin/menu.png" border="0" /><br /><b>User Menu</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=menu_block,admin"><img src="$cfg{imagesurl}/admin/blocks.png" border="0" alt="" /><br /><b>Menu Blocks</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=theme,admin"><img src="$cfg{imagesurl}/admin/theme.png" border="0" alt="" /><br /><b>Portal Themes</b></a></td>
  </tr>
  <tr align="center">
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=optimize,admin"><img src="$cfg{imagesurl}/admin/optimize.png" border="0" alt="" /><br /><b>Optimize Tables</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=subs_load,admin"><img src="$cfg{imagesurl}/admin/subs.png" border="0" alt="" /><br /><b>Sub(s) Load</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=admin_config,admin"><img src="$cfg{imagesurl}/admin/config.png" border="0" alt="" /><br /><b>Portal Config</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=site_ban,admin"><img src="$cfg{imagesurl}/admin/ban.png" border="0" alt="" /><br /><b>IP Ban</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=module_settings,admin"><img src="$cfg{imagesurl}/admin/mod.png" border="0" alt="" /><br /><b>Module Settings</b></a></td>
  </tr>
  <tr align="center">
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=super_mods,admin"><img src="$cfg{imagesurl}/admin/group.png" border="0" alt="" /><br /><b>Super Groups</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=super_paths,admin"><img src="$cfg{imagesurl}/admin/action.png" border="0" alt="" /><br /><b>Super Paths</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=ajax,admin"><img src="$cfg{imagesurl}/admin/meta.png" border="0" alt="" /><br /><b>Ajax Edit</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=stats_log,admin"><img src="$cfg{imagesurl}/admin/mysql.gif" border="0" alt="" /><br /><b>Stats Log</b></a></td>
    <td> </td>
  </tr>
</table>
HTML

$Flex_WPS->print_html(
        page_name    => $nav{view_profile},
        type         => 1,
        ajax_name    => '',
        );
}

sub awelcome {
my $form = '';

my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM welcome WHERE id='1'");
$sth->execute;
while(my @row = $sth->fetchrow)  {
my $tlt = $row[2] || '';
my $msg = $row[3] || '';

$msg =~ s/<\/textarea>/&#60;\/textarea&#62;/g;
$msg =~ s/(<aubbc>(?s)(.*?)<\/aubbc>)/
        my $ret = $AUBBC_mod->html_to_text( $2 );
        $ret ? '<aubbc>'.$ret."<\/aubbc>" : $1;
        /eg;
$msg = $AUBBC_mod->script_escape( $msg, 1 );
$tlt = $AUBBC_mod->script_escape( $tlt, 1 );
 $form .= <<HTML;
<div align="left">
Leave the Title blank if you dont want to print the message.<br /><br />
<form name="form1" method="post" action="$cfg{pageurl}/index.$cfg{ext}">
<input type="hidden" name="op" value="awelcome2,admin" />
<b>Title:</b> <input type="text" name="title" size="45" value="$tlt"><br /><br />
<b>Message:</b> Text / HTML / UBBC Allowed<br />
<textarea wrap="off" name="message" rows="35" cols="75">$msg</textarea><br />
<input type="submit" name="Submit" value="Submit" />
</form></div>
HTML
 }
 $sth->finish();

$Flex_WPS->print_page(
        markup       => $form,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Administrator Welcome Message',
        );
}
sub awelcome2 {

$message =~ s/&#60;\/textarea&#62;/<\/textarea>/g;
$message =~ s/(<aubbc>(?s)(.*?)<\/aubbc>)/
        my $ret = $AUBBC_mod->script_escape( $2 );
        $ret ? '<aubbc>'.$ret."<\/aubbc>" : $1;
        /eg;
$message = $back_ends{$cfg{Portal_backend}}->quote($message);
$title = $back_ends{$cfg{Portal_backend}}->quote($title);

$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `welcome` SET `title` = $title, `text` = $message WHERE `id` ='1' LIMIT 1 ;");

# Redirect to the welcome page.
print $query->redirect(
 -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=awelcome,admin'
 );
}

sub main_menu {
my $html = '';  #

my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM mainmenu');
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
my $select = ' selected';
my $select2 = ' selected';
$select2 = '' if $row[5];
$select = '' if !$row[5];
$html .= <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="main_menu2,admin" />
<input type="hidden" name="id" value="$row[0]" />
  <tr>
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="return confirm('Are you sure you want to Edit this item?')" />
    </td>
    <td width="26%">
        <select name="html">
          <option value="1"$select>Yes</option>
          <option value=""$select2>No</option>
        </select> <input type="text" name="title" value="$row[1]" />
      </td>
    <td width="26%">
        <input type="text" name="message" value="$row[2]" />
      </td>
    <td width="17%">
        <input type="text" name="image" value="$row[3]" size="14" /> <input type="text" name="image2" value="$row[4]" size="14" />
      </td>
      <td width="19%" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=main_menu2,admin;id=$row[0]" onclick="return confirm('Are you sure you want to Delete this item?')">Delete</a></td>
  </tr>
 </form>
</table>
HTML

}
$sth->finish();

                my $html_print = <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Main Menu Edit</p>
These are the Link(s) in the Main Menu and any user group can view an active link.<br />
The Theme Tag converter is used, so you can easly point to the main page like this.<br />
%homepage% = $cfg{pageurl}/index.$cfg{ext}</td>
</tr></table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="main_menu2,admin" />
    <tr>
      <td width="12%">
        <input type="submit" name="Submit" value="Add New" />
      </td>
      <td width="32%">
          <select name="html">
          <option value="1" selected>Yes</option>
          <option value="">No</option>
        </select> <input type="text" name="title" />
      </td>
      <td width="33%">
        <input type="text" name="message" />
      </td>
      <td width="20%">
         <input type="text" name="image" value="" size="14" /> <input type="text" name="image2" value="" size="14" />
      </td>
    </tr>
    </form>
  </table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>Active/Title</b></td>
    <td width="26%"><b>Link</b></td>
    <td width="17%"><b>Image(s)</b></td>
    <td width="19%"><b>Delete</b></td>
  </tr>
</table>
$html
<hr />
HTML

$Flex_WPS->print_page(
        markup       => $html_print,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{view_profile},
        );

}

sub main_menu2 {
$html = '' if $html eq 2;

if ($id && !$title && !$message) { # delete
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM `mainmenu` WHERE `id` = $id");
}
 elsif ($id && $message) { # Edit
 $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $message = $back_ends{$cfg{Portal_backend}}->quote($message);
 $image = $back_ends{$cfg{Portal_backend}}->quote($image);
 $image2 = $back_ends{$cfg{Portal_backend}}->quote($image2);
 $html = $back_ends{$cfg{Portal_backend}}->quote($html);
 $id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `mainmenu` SET `title` = $title, `link` = $message,
 `image` = $image,
 `image2` = $image2,
 `active` = $html WHERE `id` = $id LIMIT 1 ;");
 }
  elsif (!$id && $message) { # Add
 $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $message = $back_ends{$cfg{Portal_backend}}->quote($message);
 $image = $back_ends{$cfg{Portal_backend}}->quote($image);
 $image2 = $back_ends{$cfg{Portal_backend}}->quote($image2);
 $html = $back_ends{$cfg{Portal_backend}}->quote($html);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO `mainmenu` VALUES (NULL,$title,$message,$image,$image2,$html);");
  }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=main_menu,admin'
                    );
}

sub user_menu {
$html = '';  #

my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM usermenu');
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
 my $seclvl = '';
    foreach (sort keys %usr) {
            my $bs = '';
            $bs = ' selected' if $row[5] && $usr{$_} eq $row[5];
            #$bs = ' selected' if !$id && $usr{$_} eq $usr{anonuser};
            $seclvl .= "<option value=\"$usr{$_}\"$bs>$usr{$_}</option>\n";
            }
$html .= <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="user_menu2,admin" />
<input type="hidden" name="id" value="$row[0]" />
  <tr>
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')" />
    </td>
    <td width="26%">
        <select name="html">
          $seclvl
        </select> <input type="text" name="title" value="$row[1]" />
      </td>
    <td width="26%">
        <input type="text" name="message" value="$row[2]" />
      </td>
    <td width="17%">
        <input type="text" name="image" value="$row[3]" size="14" /> <input type="text" name="image2" value="$row[4]" size="14" />
      </td>
      <td width="19%" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=user_menu2,admin;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a></td>
  </tr>
 </form>
</table>
HTML

}
$sth->finish();

 my $seclvl2 = '';
    foreach (sort keys %usr) {
            my $bs = '';
            #$bs = ' selected' if $row[5] && $usr{$_} eq $row[5];
            $bs = ' selected' if $usr{$_} eq $usr{anonuser};
            $seclvl2 .= "<option value=\"$usr{$_}\"$bs>$usr{$_}</option>\n";
            }

                my $html_print = <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">User Menu Edit</p>
These are the Link(s) in the User Menu, you can controle what user groups can see the links.<br />
$usr{admin} = See's all, $usr{mod} = See's all but $usr{admin} links, $usr{user} = See's $usr{user} links<br />
with the exception that $usr{anonuser} can only see $usr{anonuser} links in this menu.<br />
The Theme Tag converter is used, so you can easly point to the main page like this.<br />
%homepage% = $cfg{pageurl}/index.$cfg{ext}</td>
</tr></table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="user_menu2,admin" />
    <tr>
      <td width="12%">
        <input type="submit" name="Submit" value="Add New" />
      </td>
      <td width="32%">
          <select name="html">
          $seclvl2
        </select> <input type="text" name="title" />
      </td>
      <td width="33%">
        <input type="text" name="message" />
      </td>
      <td width="20%">
         <input type="text" name="image" value="" size="14" /> <input type="text" name="image2" value="" size="14" />
      </td>
    </tr>
    </form>
  </table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>Security Level/Title</b></td>
    <td width="26%"><b>Link</b></td>
    <td width="17%"><b>Image(s)</b></td>
    <td width="19%"><b>Delete</b></td>
  </tr>
</table>
$html
<hr />
HTML

$Flex_WPS->print_page(
        markup       => $html_print,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{view_profile},
        );

}

sub user_menu2 {
if ($id && !$title && !$message) { # Delete
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM usermenu WHERE `id` = $id");
}
 elsif ($id && $message) { # Edit
  $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $message = $back_ends{$cfg{Portal_backend}}->quote($message);
 $image = $back_ends{$cfg{Portal_backend}}->quote($image);
 $image2 = $back_ends{$cfg{Portal_backend}}->quote($image2);
 $html = $back_ends{$cfg{Portal_backend}}->quote($html);
 $id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `usermenu` SET `title` = $title, `link` = $message,
`image` = $image, `image2` = $image2, `seclevel` = $html WHERE `id` = $id LIMIT 1 ;");
 }
  elsif (!$id && $message) { # Add
   $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $message = $back_ends{$cfg{Portal_backend}}->quote($message);
 $image = $back_ends{$cfg{Portal_backend}}->quote($image);
 $image2 = $back_ends{$cfg{Portal_backend}}->quote($image2);
 $html = $back_ends{$cfg{Portal_backend}}->quote($html);

$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO usermenu VALUES (NULL,$title,$message,$image,$image2,$html,'');");
  }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=user_menu,admin'
                    );
}

sub menu_block {

my $form = <<HTML;
<div align="left">
<b>Add New Block</b><br />
<form method="post" action="$cfg{pageurl}/index.$cfg{ext}">
<input type="hidden" name="op" value="menu_block2,admin"><br />
<b>Title:</b> <input type="text" name="title" size="45" value="" />
<br /><b>HTML/Text:</b><br />
<textarea wrap="off"  name="message" rows="8" cols="55"></textarea><br />
<input type="text" name="mode" value="" />
<b>Active = 1/0</b><br />
<input type="text" name="loc" value="" />
<b>Location = left/right</b><br />
<input type="submit" name="Submit" value="Submit" />
</form><hr /></div>
HTML

my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM blocks");
$sth->execute;
while(my @row = $sth->fetchrow)  {
if ($row[0]) {
 $form .= <<HTML;
 <div align="left"><form method="post" action="$cfg{pageurl}/index.$cfg{ext}">
<input type="hidden" name="id" value="$row[0]" />
<input type="hidden" name="op" value="menu_block2,admin" /><br />
<b>Title:</b> <input type="text" name="title" size="45" value="$row[2]" /> <a href="$cfg{pageurl}/index.$cfg{ext}?op=menu_block2,admin;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a>
<br /><b>HTML/Text:</b><br />
<textarea wrap="off"  name="message" rows="8" cols="55">$row[3]</textarea><br />
<input type="text" name="mode" value="$row[1]" />
<b>Active = 1/0</b><br />
<input type="text" name="loc" value="$row[4]" />
<b>Location = left/right</b><br />
<input type="submit" name="Submit" value="Edit" />
</form><hr /></div>
HTML
}
 }
 $sth->finish();

$Flex_WPS->print_page(
        markup       => $form,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{view_profile},
        );
}

sub menu_block2 {
 
if ($id && !$title && !$message) { # Delete
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM blocks WHERE `id` = $id");
}
 elsif ($id && $message) { # Edit
  $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $message = $back_ends{$cfg{Portal_backend}}->quote($message);
 $loc = $back_ends{$cfg{Portal_backend}}->quote($loc);
 $f_mode = $back_ends{$cfg{Portal_backend}}->quote($f_mode);
 $id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `blocks`
SET `active` = $f_mode, `title` = $title,
`boxtext` = $message, `type` = $loc WHERE `id` = $id LIMIT 1 ;");
 }
  elsif (!$id && $message) { # Add
   $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $message = $back_ends{$cfg{Portal_backend}}->quote($message);
 $loc = $back_ends{$cfg{Portal_backend}}->quote($loc);
 $f_mode = $back_ends{$cfg{Portal_backend}}->quote($f_mode);

$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO blocks VALUES (NULL,$f_mode,$title,$message,$loc);");
  }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=menu_block,admin'
                    );
}

sub admin_config {
my %cp = ();

my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM `portalconfigs` WHERE `configid` = \'1\'');
$sth->execute || die("Couldn't exec sth! at Get Portal Config b2");

while(my @row = $sth->fetchrow)  {
# Have to clean and setup the config with better stuff!!!
# little cleaner
# not using ip_time, enable_approvals, date_format?,
#
%cp = (
 'a.configid' => $row[0],
 'ab.pagename' => $row[1],
 'ac.pagetitle' => $row[2],
 'ad.cgi_bin_dir' => $row[3],
 'ae.non_cgi_dir' => $row[4],
 'af.cgi_bin_url' => $row[5],
 'ag.non_cgi_url' => $row[6],
 'ah.lang' => $row[7],
 'ai.codepage' => $row[8],
 'aj.ip_time' => $row[9],
 'ak.enable_approvals' => $row[10],
 'al.webmaster_email' => $row[11],
 'am.mail_type' => $row[12],
 'an.mail_program' => $row[13],
 'ao.smtp_server' => $row[14],
 'ap.time_offset' => $row[15],
 'aq.date_format' => $row[16],
 'ar.cookie_expire' => $row[17],
 'as.default_theme' => $row[18],
 'at.max_upload_size' => $row[19],
 'au.picture_height' => $row[20],
 'av.picture_width' => $row[21],
 'aw.ext' => $row[22]
 );
 }
 $sth->finish();

my $stuff = '';
foreach (sort keys %cp) {
        my $key_n = $_;
        $key_n =~ s/\A\w+\.//g;
        $stuff .= "<tr>\n<td>$key_n =></td><td> <input type=\"text\" name=\"ic\" value=\"$cp{$_}\" /></td>\n</tr>\n";
        }

        $stuff = <<HTML;
These are the settings and paths of the server and portal.<br />
<form action="$cfg{pageurl}/index.$cfg{ext}" method="post">
<input type="submit" value="Edit Config" onclick="javascript:return confirm('This Will Update the Settings to the Site.')" />
<table>
$stuff
</table>
<input type="hidden" name="op" value="admin_config2,admin" />
<input type="submit" value="Edit Config" onclick="javascript:return confirm('This Will Update the Settings to the Site.')" />
</form>
HTML

$Flex_WPS->print_page(
        markup       => $stuff,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Config',
        );
}
sub admin_config2 {
my @row = split(/\000\000/, $query->param_more('ic'));
my @new_row = ();
my $fix = 0;
 foreach (@row) {
 if ($fix == 0){
  $fix++;
  next;
 }
  push ( @new_row, $back_ends{$cfg{Portal_backend}}->quote($_) );
 }

my $stuff = <<SQL;
UPDATE `portalconfigs` SET `pagename` = $new_row[1],
`pagetitle` = $new_row[2],
`cgi_bin_dir` = $new_row[3],
`non_cgi_dir` = $new_row[4],
`cgi_bin_url` = $new_row[5],
`non_cgi_url` = $new_row[6],
`lang` = $new_row[7],
`codepage` = $new_row[8],
`ip_time` = $new_row[9],
`enable_approvals` = $new_row[10],
`webmaster_email` = $new_row[11],
`mail_type` = $new_row[12],
`mail_program` = $new_row[13],
`smtp_server` = $new_row[14],
`time_offset` = $new_row[15],
`date_format` = $new_row[16],
`cookie_expire` = $new_row[17],
`default_theme` = $new_row[18],
`max_upload_size` = $new_row[19],
`picture_height` = $new_row[20],
`picture_width` = $new_row[21],
`ext` = $new_row[22] WHERE `portalconfigs`.`configid` =$new_row[0];
SQL
        
#$Flex_WPS->print_page(
#        markup       => $stuff,
#        cookie1      => '',
#        cookie2      => '',
#        location     => '',
#        ajax_name    => '',
#        navigation   => 'Config',
#        );
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, $stuff);

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=admin_config,admin'
                    );
}

sub subs_load {
my $html = '';

my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM subload');
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
$html .= <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="subs_load2,admin" />
<input type="hidden" name="id" value="$row[0]" />
  <tr>
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')" />
    </td>
    <td width="26%">
    <input type="text" name="title" value="$row[1]" size="5" />
      </td>
    <td width="26%">
        <input type="text" name="image" value="$row[2]" size="14" /> <input type="text" name="image2" value="$row[3]" size="14" />
      </td>
    <td width="17%">
        <input type="text" name="loc" value="$row[4]" size="5" />
      </td>
      <td width="19%" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=subs_load2,admin;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a></td>
  </tr>
 </form>
</table>
HTML

}
$sth->finish();

                my $html_print = <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Sub(s) Load Edit</p>
These are the Perl Subroutines that can be loaded.<br />
<b>Active:</b> 1 = On & 0 = Off<br />
<b>Locations:</b> 1 is for subs that do background tasks befor the theme, 2-6 can be used to print html/text in the theme,<br />
'home' can be used to print html/text under the welcome message of the Home Page.<br />
Two new locations they are 3b and 5b, those locations will print under 3 or 5 and its expected block for that side.</td>
</tr></table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="subs_load2,admin" />
    <tr>
      <td width="12%">
        <input type="submit" name="Submit" value="Add New" />
      </td>
      <td width="32%">
      <input type="text" name="title" value="" size="5" />
      </td>
      <td width="33%">
        <input type="text" name="image" value="" size="14" /> <input type="text" name="image2" value="" size="14" />
      </td>
      <td width="20%">
         <input type="text" name="loc" value="" size="5" />
      </td>
    </tr>
    </form>
  </table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>Active</b></td>
    <td width="26%"><b>PM/Sub Name</b></td>
    <td width="17%"><b>Location</b></td>
    <td width="19%"><b>Delete</b></td>
  </tr>
</table>
$html
<hr />
HTML

$Flex_WPS->print_page(
        markup       => $html_print,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{view_profile},
        );

}

sub check_subload {
my ($Fpm,$Lsub) = @_;
my $check = '';
my $load = '';

  unless ($Fpm && -r "$cfg{subloaddir}/$Fpm.pm") {
        warn "Module ( $cfg{subloaddir}/$Fpm.pm ) does not exist";
   }
    else {
 require "$cfg{subloaddir}/$Fpm.pm" unless exists $INC{"$cfg{subloaddir}/$Fpm.pm"};
my %sub_action2 = ();
 if (exists &{$Fpm . '::sub_action'}
        && (ref $Fpm . '::sub_action' eq 'CODE' || ref $Fpm . '::sub_action' eq '')) {
        $load = \&{$Fpm . '::sub_action'};
        %sub_action2 = $load->();
    }
     else {
        warn "Module ( $cfg{subloaddir}/$Fpm.pm ) Does not support SubLoad ( sub_action )";

     }

   unless ($Lsub && exists $sub_action2{$Lsub} && $sub_action2{$Lsub}) {
        warn "Module ( $cfg{subloaddir}/$Fpm.pm ) Does not support SubLoad ( $Lsub )";
   }
    else {
      $check = 1;
    }
 }
return $check;
}

sub subs_load2 {
if ($id && !$image && !$image2) { # delete
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM subload WHERE `id` = $id");
}
 elsif ($id && $image && $image2 && check_subload($image, $image2) ) { # Edit
 $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $image = $back_ends{$cfg{Portal_backend}}->quote($image);
 $image2 = $back_ends{$cfg{Portal_backend}}->quote($image2);
 $loc = $back_ends{$cfg{Portal_backend}}->quote($loc);
 $id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE subload SET `active` = $title,
`pmname` = $image, `subname` = $image2, `location` = $loc WHERE `id` = $id LIMIT 1 ;");
}
  elsif (!$id && $image && $image2 && check_subload($image, $image2)) { # Add
 $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $image = $back_ends{$cfg{Portal_backend}}->quote($image);
 $image2 = $back_ends{$cfg{Portal_backend}}->quote($image2);
 $loc = $back_ends{$cfg{Portal_backend}}->quote($loc);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO subload VALUES (NULL,$title,$image,$image2,$loc);");
  }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=subs_load,admin'
                    );
}

sub super_mods {
my $html = '';  #

my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM super_mods');
$sth->execute;
while(my @row = $sth->fetchrow) {
$html .= <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form method="post" action="">
<input type="hidden" name="op" value="super_mods2,admin" />
<input type="hidden" name="id" value="$row[0]" />
  <tr>
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')" />
    </td>
    <td width="26%">
    <input type="text" name="title" value="$row[2]" size="5" />
      </td>
    <td width="26%">
        <input type="text" name="image" value="$row[1]" size="14" />
      </td>
      <td width="36%" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=super_mods2,admin;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a></td>
  </tr>
 </form>
</table>
HTML

}
$sth->finish();

                my $html_print = <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Super Groups</p>
Security Levels from high to low would be:<br />
$usr{admin}, $usr{user}(user can be super_mod), $usr{anonuser}(Guest can be super_mod).<br /><br />
These are the other User Groups that can be used.<br />
<b>Active:</b> 1 = On & 0 = Off<br />
</td>
</tr></table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="super_mods2,admin" />
    <tr>
      <td width="8%">
        <input type="submit" name="Submit" value="Add New" />
      </td>
      <td width="33%">
      <input type="text" name="title" value="1" size="5" />
      </td>
      <td>
        <input type="text" name="image" value="" size="14" />
      </td>
    </tr>
    </form>
  </table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>Active</b></td>
    <td width="26%"><b>Group Name</b></td>
    <td width="36%"><b>Delete</b></td>
  </tr>
</table>
$html
<hr />
HTML

$Flex_WPS->print_page(
        markup       => $html_print,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{view_profile},
        );

}

sub super_mods2 {
if ($id && !$image) { # delete
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM super_mods WHERE `id` = $id");
}
 elsif ($id && $image) { # Edit
 $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $image = $back_ends{$cfg{Portal_backend}}->quote($image);
 $id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE super_mods SET `group_name` = $image,
`active` = $title WHERE `id` = $id LIMIT 1 ;");
}
  elsif (!$id && $image) { # Add
 $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $image = $back_ends{$cfg{Portal_backend}}->quote($image);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO super_mods VALUES (NULL,$image,$title);");
  }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=super_mods,admin'
                    );
}

sub super_paths {
my $html = '';  #

my $pos       = '';
my @userlevel = ($usr{mod}, $usr{user}, $usr{anonuser});
my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT `group_name`
FROM `super_mods`
WHERE `active` = '1'");
$sth->execute();
while (my @super_lvls = $sth->fetchrow) {
push (@userlevel, @super_lvls);
}
$sth->finish();

$sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM `super_mod_places`');
$sth->execute;
while(my @row = $sth->fetchrow) {
foreach (@userlevel) {
        $pos .= ($row[1] eq $_)
                ? "<option value=\"$_\" selected>$_</option>\n"
                : "<option value=\"$_\">$_</option>\n";
 }
$html .= <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form method="post" action="">
<input type="hidden" name="op" value="super_paths2,admin" />
<input type="hidden" name="id" value="$row[0]" />
  <tr>
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')" />
    </td>
    <td width="26%">
    <select name="title">
        $pos
        </select>
      </td>
    <td width="26%">
        <input type="text" name="image" value="$row[2]" size="14" />
      </td>
    <td width="17%">
        <input type="text" name="image2" value="$row[3]" size="5" />
      </td>
      <td width="19%" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=super_paths2,admin;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a></td>
  </tr>
 </form>
</table>
HTML
  $pos = '';
}
$sth->finish();

foreach (@userlevel) {
        $pos .= "<option value=\"$_\">$_</option>\n";
 }
                my $html_print = <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><div class="texttitle">Super Paths</div><br />
Be carefull! You can allow groups to places that my harm the site.<br />
These Security levels can be used also:<br />
$usr{user}(user can be super_mod), $usr{anonuser}(Guest can be super_mod).<br /><br />
These are the Paths and User Groups that are allowed to them.<br />
<b>Active:</b> 1 = On & 0 = Off<br />
</td>
</tr></table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="super_paths2,admin" />
    <tr>
      <td width="8%">
        <input type="submit" name="Submit" value="Add New" />
      </td>
      <td width="33%">
    <select name="title">
        $pos
        </select>
      </td>
      <td>
        <input type="text" name="image" value="" size="14" />
      </td>
      <td>
        <input type="text" name="image2" value="1" size="5" />
      </td>
    </tr>
    </form>
  </table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>Group Name</b></td>
    <td width="26%"><b>Class::Sub</b></td>
    <td width="17%"><b>Active</b></td>
    <td width="19%"><b>Delete</b></td>
  </tr>
</table>
$html
<hr />
HTML

$Flex_WPS->print_page(
        markup       => $html_print,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{view_profile},
        );

}

sub super_paths2 {
if ($id && !$image && !$title) { # delete
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM super_mod_places WHERE `id` = $id");
}
 elsif ($id && $image && $title) { # Edit
 $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $image = $back_ends{$cfg{Portal_backend}}->quote($image);
 $image2 = $back_ends{$cfg{Portal_backend}}->quote($image2);
 $id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE super_mod_places SET `group_name` = $title,
`class_sub` = $image, `active` = $image2 WHERE `id` = $id LIMIT 1 ;");
}
  elsif (!$id && $image) { # Add
 $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $image = $back_ends{$cfg{Portal_backend}}->quote($image);
 $image2 = $back_ends{$cfg{Portal_backend}}->quote($image2);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO super_mod_places VALUES (NULL,$title,$image,$image2);");
  }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=super_paths,admin'
                    );
}

sub ajax {
my $html = '';  #

my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM ajax_scripts');
$sth->execute;
while(my @row = $sth->fetchrow) {
$row[1] =~ s/<\/textarea>/&#60;\/textarea&#62;/g;
$html .= <<HTML;
<form method="post" action="">
<input type="hidden" name="op" value="ajax2,admin" />
<input type="hidden" name="id" value="$row[0]" />
  <tr>
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')" />
    </td>
    <td width="26%">
    <b>$row[0]</b>
      </td>
    <td width="26%">
        <textarea wrap="off"  name="image" rows="8" cols="45">$row[1]</textarea>
      </td>
      <td width="36%" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=ajax2,admin;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a></td>
  </tr>
 </form>
HTML

}
$sth->finish();

                my $html_print = <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Ajax Script(s) Edit</p>

</td>
</tr></table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="ajax2,admin" />
    <tr>
      <td width="8%">
        <input type="submit" name="Submit" value="Add New" />
      </td>
      <td width="33%">
      <input type="text" name="title" value="" size="14" />
      </td>
      <td>
        <textarea wrap="off"  name="image" rows="8" cols="45"></textarea>
      </td>
      <td> </td>
    </tr>
    </form>
  <tr align="center" bgcolor="#CCFF00">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>Name</b></td>
    <td width="26%"><b>Script</b></td>
    <td width="36%"><b>Delete</b></td>
  </tr>
$html
</table>
<hr />
HTML

$Flex_WPS->print_page(
        markup       => $html_print,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{view_profile},
        );

}

sub ajax2 {
$image =~ s/&#60;\/textarea&#62;/<\/textarea>/g if $image;
if ($id && !$image) { # delete
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM ajax_scripts WHERE `name` = $id");
}
 elsif ($id && $image) { # Edit
 #$title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $image = $back_ends{$cfg{Portal_backend}}->quote($image);
 $id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE ajax_scripts SET `script` = $image WHERE `name` = $id LIMIT 1 ;");
}
  elsif (!$id && $image) { # Add
 $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $image = $back_ends{$cfg{Portal_backend}}->quote($image);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO ajax_scripts VALUES ($title,$image);");
  }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=ajax,admin'
                    );
}


sub module_settings {
my $html = '';  #

my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM module_settings');
$sth->execute;
while(my @row = $sth->fetchrow) {
$row[2] =~ s/<\/textarea>/&#60;\/textarea&#62;/g;
$html .= <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form method="post" action="">
<input type="hidden" name="op" value="module_settings2,admin" />
<input type="hidden" name="id" value="$row[0]" />
  <tr>
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')" />
    </td>
    <td width="26%">
    <input type="text" name="title" value="$row[1]" size="14" />
      </td>
    <td width="26%">
        <textarea wrap="off"  name="message" rows="5" cols="25">$row[2]</textarea>
      </td>
      <td width="36%" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=module_settings2,admin;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a></td>
  </tr>
 </form>
</table>
HTML

}
$sth->finish();

                my $html_print = <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Module Settings</p>
This is a table that modules can use to hold there settings.<br />
Most modules should use this table and provide there own setting editer.<br />
</td>
</tr></table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="module_settings2,admin" />
    <tr>
      <td width="8%">
        <input type="submit" name="Submit" value="Add New" />
      </td>
      <td width="33%">
      <input type="text" name="title" value="" size="14" />
      </td>
      <td>
        <textarea wrap="off"  name="message" rows="5" cols="25"></textarea>
      </td>
    </tr>
    </form>
  </table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>Module</b></td>
    <td width="26%"><b>Settings</b></td>
    <td width="36%"><b>Delete</b></td>
  </tr>
</table>
$html
<hr />
HTML

$Flex_WPS->print_page(
        markup       => $html_print,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{view_profile},
        );

}

sub module_settings2 {
$message =~ s/&#60;\/textarea&#62;/<\/textarea>/g if $message;
if ($id && !$message && !$title) { # delete
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM module_settings WHERE `id` = $id");
}
 elsif ($id && $message && $title) { # Edit
 $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $message = $back_ends{$cfg{Portal_backend}}->quote($message);
 $id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE module_settings SET `module_name` = $title,
`settings` = $message WHERE `id` = $id LIMIT 1 ;");
}
  elsif (!$id && $message) { # Add
 $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $message = $back_ends{$cfg{Portal_backend}}->quote($message);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO module_settings VALUES (NULL,$title,$message);");
  }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=module_settings,admin'
                    );
}

sub site_ban {
my $html = '';

my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM ban');
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
$row[1] = $Flex_WPS->format_date($row[1], 11);
my $link = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=site_ban2,admin;loc=$row[0]\" onclick=\"javascript:return confirm('Are you sure you want to Disable this item?')\">Disable</a>";
if ($row[3] ne '1') {
$row[3] = $row[3] =~ m/\A\d+\z/
 ? $Flex_WPS->format_date($row[3], 11)
 : $row[3];
}
 else {
 $row[3] = 'Disabled!';
 $link = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=site_ban2,admin;mode=$row[0]\" onclick=\"javascript:return confirm('Are you sure you want to Activate this item?')\">Activate</a>";
 }
$html .= <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
  <tr>
    <td width="12%">$link</td>
    <td width="26%">
        $row[0]<br />
        <a href="http://network-tools.com/default.asp?prog=network&host=$row[0]" target="_blank" alt="Whois Search">Whois</a> |
        <a href="http://network-tools.com/default.asp?prog=dnsrec&host=$row[0]" target="_blank" alt="DNS Lookup">DNS Lookup</a><hr />
        <a href="http://www.mxtoolbox.com/SuperTool.aspx?action=blacklist%3a$row[0]" target="_blank" alt="Black List">Black List</a>
      </td>
    <td width="26%">
        $row[2]
      </td>
    <td width="17%">
        $row[1]<br />$row[3]
      </td>
      <td width="19%" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=site_ban2,admin;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a></td>
  </tr>
</table>
HTML

}
$sth->finish();

         my $ip_ban = '<font color=DarkRed><b>Site Ban Did Not Load</b></font><br />';
         $ip_ban = '<font color=Green><b>Site Ban is Working</b></font><br />' if $cfg{check_ban};

        my $html_print = <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Site Ban Edit</p>
$ip_ban
Here you can manage what IP's or Domain names you would like to Block from your site.<br />
The <b>"Whois"</b>, <b>"DNS Lookup"</b> links under the IP or Domain will use a free service from www.network-tools.com to
 reveal more information about that location.<b>"Black List"</b> is to check if its a known spam location, you may want to check this
 first.<br /><br />
Some <b>Crawlers/Bots</b> do not follow internet standards witch will get them band from this site,
 to allow those locations after they have been ban click "Disable" so they are not blocked and the last date will change
 to "Disabled!". You can reactivate by clicking "Activate".
</td>
</tr></table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form method="post" action="">
<input type="hidden" name="op" value="site_ban2,admin" />
    <tr>
      <td width="12%">
        <input type="submit" name="Submit" value="Add New" />
      </td>
      <td width="32%">
        <input type="text" name="message" />
      </td>
      <td width="33%">
      </td>
      <td width="20%">
      </td>
    </tr>
    </form>
  </table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%">&nbsp;</td>
    <td width="26%"><b>IP</b></td>
    <td width="26%"><b>Ban Count</b></td>
    <td width="17%"><b>First & Last Date</b></td>
    <td width="19%"><b>Delete</b></td>
  </tr>
</table>
$html
<hr />
HTML

$Flex_WPS->print_page(
        markup       => $html_print,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{view_profile},
        );
}

sub site_ban2 {
if ($id) { # Delete
 $id = $back_ends{$cfg{Portal_backend}}->quote($id);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM ban WHERE `banid` = $id LIMIT 1 ;");
}
 elsif ($message) { # Add

my $add = 1;
 $message = $back_ends{$cfg{Portal_backend}}->quote($message);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT banid FROM ban WHERE `banid` = $message");
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
      if ($row[0]) {
       $add = 0;
       last;
      }

}
$sth->finish();
      if ($add) {
           my $DATE = time || 'DATE';
           $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO `ban` VALUES ( $message , '$DATE' , '0', '$DATE' );");
           }
  }
   elsif ($loc) {
   $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `ban` SET `last_date` = '1' WHERE `banid` ='$loc' LIMIT 1 ;");
   }
   elsif ($f_mode) {
   $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `ban` SET `last_date` = 'Active!' WHERE `banid` ='$f_mode' LIMIT 1 ;");
   }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=site_ban,admin'
                    );
}
sub theme {
$id = $back_ends{$cfg{Portal_backend}}->quote($id) if $id;
$add = '' if $add ne 'add';
my $sth = '';
my @row = ();

if (!$add) {
$sth = "SELECT * FROM themes WHERE themeid =$id LIMIT 1;";
$sth = "SELECT * FROM themes WHERE active ='1' LIMIT 1;" if !$id;
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @theme_info = $sth->fetchrow) {
 push (@row, @theme_info);
}
$sth->finish();
 }
 
$sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM themes');
$sth->execute || die('Couldn\'t exec sth!');
my $theme_form = <<HTML;
<form method="post" action="">
<input type="hidden" name="op" value="theme,admin" />
<b>Select a Theme:</b> <select name="id">
HTML
while(my @theme_info = $sth->fetchrow) {
 $theme_form .= "<option value=\"$theme_info[0]\">$theme_info[2] - $theme_info[1]</option>\n";
}
$sth->finish();
$theme_form .= <<HTML;
</select>
<input type="image" src="$cfg{imagesurl}/icon/move.png" Border="0" name="submit" />
</form> <a href="$cfg{pageurl}/index.$cfg{ext}?op=theme,admin;add=add">Add New Theme</a>
<br /><br />
HTML

for (my $count = 9; $count >= 1; $count--) {
 last if $count == 4;
 $row[$count] =~ s/<\/textarea>/&#60;\/textarea&#62;/g;
 }

        $theme_form = <<HTML;
 $theme_form
<form method="post" action="">
  <input type="hidden" name="id" value="$row[0]" />
  <input type="hidden" name="add" value="$add" />
  <input type="hidden" name="op" value="theme2,admin" />
  <table width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;<b>Active:</b> 1 = Default Theme / 0 = Off<br />
<input type="text" name="title" value="$row[1]" />
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;<b>Theme Name:</b><br />
<input type="text" name="html" value="$row[2]" /> <a href="$cfg{pageurl}/index.$cfg{ext}?op=theme2,admin;add=1;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this Theme?')">Delete This Theme</a>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;<b>Meta Tags:</b><br />
<textarea wrap="off"  name="disc" cols="75" rows="10">$row[3]</textarea>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;<b>Key Words:</b><br />
<textarea wrap="off"  name="keywords" cols="75" rows="10">$row[4]</textarea>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;<b>Theme Top:</b><br />
<textarea wrap="off"  name="image" cols="75" rows="10">$row[5]</textarea>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;<b>Theme 1:</b><br />
<textarea wrap="off"  name="image2" cols="75" rows="10">$row[6]</textarea>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;<b>Theme 2:</b><br />
<textarea wrap="off"  name="loc" cols="75" rows="10">$row[7]</textarea>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;<b>Theme 3:</b><br />
<textarea wrap="off"  name="message" cols="75" rows="10">$row[8]</textarea>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;<b>Theme Bottom:</b><br />
<textarea wrap="off"  name="inputcrap" cols="75" rows="10">$row[9]</textarea>
      </td>
    </tr>
  </table>
  <input type="submit" name="Submit" value="Submit" />&nbsp;&nbsp;&nbsp;<input type="submit" name="mode" value="Duplicate" />
</form>
HTML

$Flex_WPS->print_page(
        markup       => $theme_form,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{view_profile},
        );

}

sub theme2 {
 my $url_link = $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=theme,admin;id=' . $id;
 
 $image =~ s/&#60;\/textarea&#62;/<\/textarea>/g;
 $image2 =~ s/&#60;\/textarea&#62;/<\/textarea>/g;
 $loc =~ s/&#60;\/textarea&#62;/<\/textarea>/g;
 $message =~ s/&#60;\/textarea&#62;/<\/textarea>/g;
 $inputer =~ s/&#60;\/textarea&#62;/<\/textarea>/g;
 
 $title = $back_ends{$cfg{Portal_backend}}->quote($title);
 $message = $back_ends{$cfg{Portal_backend}}->quote($message);
 $image = $back_ends{$cfg{Portal_backend}}->quote($image);
 $image2 = $back_ends{$cfg{Portal_backend}}->quote($image2);
 $loc = $back_ends{$cfg{Portal_backend}}->quote($loc);
 $html = $back_ends{$cfg{Portal_backend}}->quote($html);
 $id = $back_ends{$cfg{Portal_backend}}->quote($id);
 $inputer = $back_ends{$cfg{Portal_backend}}->quote($inputer);
 $keywords = $back_ends{$cfg{Portal_backend}}->quote($keywords);
 $disc = $back_ends{$cfg{Portal_backend}}->quote($disc);
 #$add = '' if $add ne 'add';
        my $string = '';
        if ($html && ($f_mode eq 'Duplicate' || $add eq 'add')) {
                $string = "INSERT INTO `themes` VALUES (NULL,$title,$html,$disc,$keywords,$image,$image2,$loc,$message,$inputer);";
          }
            elsif (!$add && $id && $html) {
                $string = "UPDATE `themes` SET `active` = $title,
`themename` = $html, `description` = $disc, `keywords` = $keywords, `theme_top` = $image, `theme_1` = $image2,
`theme_2` = $loc, `theme_3` = $message, `theme_4` = $inputer WHERE `themeid` = $id LIMIT 1 ;";
            }
             elsif ($add eq '1' &&  $id) {
                $string = "DELETE FROM `themes` WHERE `themeid` = $id LIMIT 1 ;";
             }
             # elsif ($add eq 'add' && $html) {
             #   $string = "INSERT INTO `themes` VALUES (NULL,$title,$html,$image,$image2,$loc,$message,$inputer);";
             # }
             
            $Flex_WPS->SQL_Edit($cfg{Portal_backend}, $string);
                # Redirect to user_actions page.
                print $query->redirect( -location => $url_link );
}

# Needs testing
sub optimize {
# , 'stats_log'
my @info = ('optimize', 'ajax_scripts', 'auth_session', 'ban', 'blocks', 'mainmenu', 'members', 'module_settings', 'pages', 'pmin', 'pmout', 'portalconfigs', 'smilies', 'subload', 'super_mods', 'super_mod_places', 'themes', 'usermenu', 'welcome');
my (@stuff, @module_tables, @all_tables) = ( (), (), () );
my $modules_delete = '';

my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM `optimize`");
$sth->execute;
while(my @row = $sth->fetchrow)  {
        push ( @module_tables, $row[1] );

        $modules_delete .= " <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=optimize2,admin;id=$row[0];add=1\" onclick=\"javascript:return confirm('Are you sure you want to Delete this table?')\">$row[1]</a> |";
}
$sth->finish;

push ( @all_tables, @info );
push ( @all_tables, @module_tables ) if @module_tables;

foreach my $table (@all_tables) {
# SHOW TABLE STATUS LIKE $table
$sth = $back_ends{$cfg{Portal_backend}}->prepare("SHOW TABLE STATUS LIKE '$table'");
$sth->execute;
while(my @row = $sth->fetchrow)  {

# Note: I know the MyISAM name works for me, the php code i modeled this from used MYISAM in its code.
# So the BDB name has not been tested and could be wrong.
if ($row[9] && ($row[1] eq 'MyISAM' || $row[1] eq 'BDB')) {
                push ( @stuff, $row[0] );
#                 push (
#                 @stuff,
#                 join (
#                         "|",   'Name', $row[0], '<br />', 'Engine', $row[1], '<br />',
#                         'Version', $row[2], '<br />', 'Row_format', $row[3], '<br />',
#                         'Rows', $row[4], '<br />', 'Avg_row_length',$row[5], '<br />',
#                         'Data_length', $row[6], '<br />', 'Max_data_length', $row[7], '<br />',
#                         'Index_length', $row[8], '<br />',
#                         'Data_free',$row[9], '<br />', 'Auto_increment', $row[10], '<br />',
#                         'Create_time',$row[11], '<br />', 'Update_time', $row[12], '<br />',
#                         'Check_time',$row[13],'<br />',
#                         'Collation',$row[14], '<br />', 'Checksum',$row[15], '<br />',
#                         'Create_options',$row[16], '<br />', 'Comment',$row[17], '<hr />'
#                 )
#             );
      }
}
$sth->finish;
                  #$stuff .= "<br />";
                   }
                   my $optamize = '';
                   if (@stuff) {

                          foreach my $table (@stuff) {
                                  # OPTIMIZE TABLE $table
                                  $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "OPTIMIZE TABLE `$table`");
                                  $optamize .= 'OPTIMIZE TABLE ' . $table . '<br /><br />';
                          }
                          # only used when you have the privileges
                          # FLUSH TABLES WITH READ LOCK
                          #$Flex_WPS->SQL_Edit($cfg{Portal_backend}, 'FLUSH TABLES WITH READ LOCK');
                          #UNLOCK TABLES
                          #$Flex_WPS->SQL_Edit($cfg{Portal_backend}, 'UNLOCK TABLES');
                   }
                    else {
                          $optamize = 'Nothing to Optimize';
                    }


                        my $html_print = <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Optimize Portal Tables</p>
This will optimize Tables for the Main Portal and Added Tables for Modules.<br />
It is Recommended to Run this Page if there has been many Inserts or Edits.<br />
The Optimizer will also check if the Table need to be Optimized.<br />
<b>Main Portal tables:</b><br />
@info<br />
<b>Module tables:</b> Click to delete.<br />
$modules_delete
</td>
</tr></table>
<form method="post" action="">
  <input type="hidden" name="op" value="optimize2,admin" />
   <input type="hidden" name="add" value="add" />
  <input type="text" name="title" value="" />
  &nbsp;&nbsp;&nbsp;<input type="submit" name="Submit" value="Add Table Name" />
</form>
$optamize
<hr />
HTML

$Flex_WPS->print_page(
        markup       => $html_print,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{view_profile},
        );
}

sub optimize2 {
 $title = $back_ends{$cfg{Portal_backend}}->quote($title) if $title;
 $id = $back_ends{$cfg{Portal_backend}}->quote($id) if $id;

 #$add = '' if ($add ne 'add' || $add ne '1');
        my $string = '';
        if (!$add && $title && $id) {
                $string = "UPDATE `optimize` SET `table_name` = $title WHERE `id` = $id LIMIT 1 ;";
           }
            elsif ($add eq 'add' && $title) {
                $string = "INSERT INTO `optimize` VALUES (NULL,$title);";
            }
             elsif ($add eq '1' && $id) {
                $string = "DELETE FROM `optimize` WHERE `id` = $id";
             }

           $Flex_WPS->SQL_Edit($cfg{Portal_backend}, $string) if $string;
                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=optimize,admin'
                    );
}

sub stats_log {
                        my $html_print = <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Stats Log Admin</p>
The stats_log table can become big. This will empty the stats_log table.<br />
<form action="$cfg{pageurl}/index.$cfg{ext}" method="post" name="sbox" onSubmit="if (document.sbox.query.value=='') return false">
<input type="text" name="query" size="15" class="text" />
<input type="hidden" name="what" value="statlog" />
<input type="hidden" name="op" value="search,Search" />
&nbsp;&nbsp;<input type="submit" value="$msg{search} Stats Log" />
</form>
</td>
</tr></table><hr />
<form method="post" action="">
  <input type="hidden" name="op" value="stats_log2,admin" />
  &nbsp;&nbsp;&nbsp;<input type="submit" name="Submit" value="Empty Now" />
</form>
<hr />
HTML

$Flex_WPS->print_page(
        markup       => $html_print,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Stats Log Admin',
        );
}

sub stats_log2 {
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, 'TRUNCATE `stats_log`');

# Redirect to user_actions page.
print $query->redirect(
 -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=stats_log,admin'
 );
}

1;

__END__

=pod

=head1 COPYLEFT

admin.pm, v0.90 01/21/2011 N.K.A.
Works with Flex-WPS Evolution 3 v1.0 series

Administrator area security system - not made yet

02/17/2011
Site ban can now disable and activate blocked IP's and links to Whois them.

01/21/2011
 v0.90% Fixed HTML bug with </textarea> injection in all areas.
 set <textarea wrap="off" for all textarea
 Converted HTML to XHTML.
 
 07/02/2010 - 3:41pm
 v0.80% alpha - Added Stats log empty and search section
 - Added 2 new locations for sub's load 3b and 5b

 03/29/2009 - 20:20:12
 v0.75% alpha - testing $Flex_WPS->check_access()

 v0.70% alpha -01/01/2008 12:49:15- Theme and Optimize updates

 v0.65% alpha -10/18/2007 08:29:33- inputs secured, some admin areas not added

Flex Web Portal System Evolution 3

Main Developer:
 N.K.A.
 shakaflex [at] gmail.com
 http://search.cpan.org/~sflex/

=cut
