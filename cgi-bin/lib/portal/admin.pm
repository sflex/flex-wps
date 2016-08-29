package admin;
# see bottum of file for version

# Load necessary modules.
use strict;
# Assign global variables.
use vars qw(
    $query $Flex_WPS $AUBBC %back_ends
    %user_data %err %cfg %usr %nav %user_action %msg
    );
use Flex_Porter;

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
        my $html_out = <<"HTML";
<small>
<div class="pure-g">
    <div class="pure-u-1-8 all-c"><a href="$cfg{pageurl}/index.$cfg{ext}?op=awelcome,admin"><img class="pure-img-responsive" src="$cfg{imagesurl}/admin/welcome.png" alt="" /></a></div>
    <div class="pure-u-1-8 all-c"><a href="$cfg{pageurl}/index.$cfg{ext}?op=main_menu,admin"><img class="pure-img-responsive" src="$cfg{imagesurl}/admin/menu.png" alt="" /></a></div>
    <div class="pure-u-1-8 all-c"><a href="$cfg{pageurl}/index.$cfg{ext}?op=user_menu,admin"><img class="pure-img-responsive" src="$cfg{imagesurl}/admin/menu.png" alt="" /></a></div>
    <div class="pure-u-1-8 all-c"><a href="$cfg{pageurl}/index.$cfg{ext}?op=menu_block,admin"><img class="pure-img-responsive" src="$cfg{imagesurl}/admin/blocks.png" alt="" /></a></div>
    <div class="pure-u-1-8 all-c"><a href="$cfg{pageurl}/index.$cfg{ext}?op=theme,admin"><img class="pure-img-responsive" src="$cfg{imagesurl}/admin/theme.png" alt="" /></a></div>
</div>
<div class="pure-g small">
    <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=awelcome,admin"><b>Home</b></a></div>
    <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=main_menu,admin"><b>Main Menu</b></a></div>
    <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=user_menu,admin"><b>User Menu</b></a></div>
    <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=menu_block,admin"><b>Blocks</b></a></div>
    <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=theme,admin"><b>Themes</b></a></div>
</div>
<hr />
<div class="pure-g">
    <div class="pure-u-1-8 all-c"><a href="$cfg{pageurl}/index.$cfg{ext}?op=optimize,admin"><img class="pure-img-responsive" src="$cfg{imagesurl}/admin/optimize.png" alt="" /></a></div>
    <div class="pure-u-1-8 all-c"><a href="$cfg{pageurl}/index.$cfg{ext}?op=subs_load,admin"><img class="pure-img-responsive" src="$cfg{imagesurl}/admin/subs.png" alt="" /></a></div>
    <div class="pure-u-1-8 all-c"><a href="$cfg{pageurl}/index.$cfg{ext}?op=admin_config,admin"><img class="pure-img-responsive" src="$cfg{imagesurl}/admin/config.png" alt="" /></a></div>
    <div class="pure-u-1-8 all-c"><a href="$cfg{pageurl}/index.$cfg{ext}?op=site_ban,admin"><img class="pure-img-responsive" src="$cfg{imagesurl}/admin/ban.png" alt="" /></a></div>
    <div class="pure-u-1-8 all-c"><a href="$cfg{pageurl}/index.$cfg{ext}?op=module_settings,admin"><img class="pure-img-responsive" src="$cfg{imagesurl}/admin/mod.png" alt="" /></a></div>
</div>
<div class="pure-g small">
    <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=optimize,admin"><b>Optimize</b></a></div>
    <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=subs_load,admin"><b>Sub(s) Load</b></a></div>
    <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=admin_config,admin"><b>Config</b></a></div>
    <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=site_ban,admin"><b>IP Ban</b></a></div>
    <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=module_settings,admin"><b>Module Settings</b></a></div>
</div>
<hr />
<div class="pure-g">
    <div class="pure-u-1-8 all-c"><a href="$cfg{pageurl}/index.$cfg{ext}?op=super_mods,admin"><img class="pure-img-responsive" src="$cfg{imagesurl}/admin/group.png" alt="group" /></a></div>
    <div class="pure-u-1-8 all-c"><a href="$cfg{pageurl}/index.$cfg{ext}?op=super_paths,admin"><img class="pure-img-responsive" src="$cfg{imagesurl}/admin/action.png" alt="action" /></a></div>
    <div class="pure-u-1-8 all-c"><a href="$cfg{pageurl}/index.$cfg{ext}?op=ajax,admin"><img class="pure-img-responsive" src="$cfg{imagesurl}/admin/meta.png" alt="ajax" /></a></div>
    <div class="pure-u-1-8 all-c"><a href="$cfg{pageurl}/index.$cfg{ext}?op=stats_log,admin"><img class="pure-img-responsive" src="$cfg{imagesurl}/admin/mysql.gif" alt="log" /></a></div>
</div>
<div class="pure-g small">
    <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=super_mods,admin"><b>Super Groups</b></a></div>
    <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=super_paths,admin"><b>Super Paths</b></a></div>
    <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=ajax,admin"><b>Ajax Edit</b></a></div>
    <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=stats_log,admin"><b>Stats Log</b></a></div>
</div>
</small>
HTML

$Flex_WPS->print_page(
        markup       => $html_out,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Main Administrator Area',
        );
}

sub awelcome {
my $form = '';

my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM welcome WHERE id=\'1\'');
$sth->execute;
while(my @row = $sth->fetchrow)  {
my $tlt = $row[2] || '';
my $msg = $row[3] || '';

$msg =~ s/<\/textarea>/&#60;\/textarea&#62;/g;
$msg =~ s/(<aubbc>(?s)(.*?)<\/aubbc>)/
        my $ret = $AUBBC->html_to_text($2);
        $ret ? '<aubbc>'.$ret."<\/aubbc>" : $1;
        /eg;

$msg = $AUBBC->script_escape($msg);
$tlt = $AUBBC->script_escape($tlt);

 $form = <<"HTML";
<b>Leave the Title blank if you dont want to print the message.</b>
<form class="pure-form" method="post" action="$cfg{pageurl}/index.$cfg{ext}">
 <input type="hidden" name="op" value="awelcome2,admin" />
  <fieldset class="pure-group">
   <input type="text" name="title" class="pure-input-1" placeholder="Title..." value="$tlt" />
  </fieldset>
<b>Message: Text / HTML / UBBC Allowed</b>
<fieldset class="pure-group">
<textarea class="pure-input-1 oflow" name="message" rows="25" placeholder="Message...">$msg</textarea>
<button class="pure-input-1 pure-button pure-button-active" type="submit">Submit</button>
</fieldset>
</form>
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
        my $ret = $AUBBC->script_escape($2);
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
$sth->execute or die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
my $select = ' selected';
my $select2 = ' selected';
$select2 = '' if $row[5];
$select = '' if !$row[5];
$html .= <<"HTML";
<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="main_menu2,admin" />
<input type="hidden" name="id" value="$row[0]" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button type="submit" onclick="return ConfirmThis();" class="pure-button pure-button-primary">Edit</button>
     </div>
     <div class="pure-u-1-12 all-c">
        <select name="html">
          <option value="1"$select>Yes</option>
          <option value="0"$select2>No</option>
        </select>
        </div>
        <div class="pure-u-1-4 all-c">
        <input class="pure-input-1" type="text" name="title" placeholder="Title" value="$row[1]" />
        </div>
        <div class="pure-u-1-4 all-c">
        <input class="pure-input-1" type="text" name="message" placeholder="Link" value="$row[2]" />
        </div>
        <div class="pure-u-1-6 all-c">
    <input type="text" name="image" class="pure-input-1" placeholder="Title Image" value="$row[3]" />
    <input type="text" name="image2" class="pure-input-1" placeholder="Icon Image" value="$row[4]" />
    </div>
     <div class="pure-u-1-12 all-c">
     <a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=main_menu2,admin;id=$row[0]" onclick="return ConfirmThis();">Delete</a>
     </div>
    </div>
    </fieldset>
    </form>
</small>
<hr />
HTML

}
$sth->finish();

                my $html_print = <<"HTML";
<b>Main Menu Edit</b><br />
These are the Link(s) in the Main Menu and any user group can view an active link.<br />
The Theme Tag converter is used, so you can easly point to the main page like this.<br />
%homepage% = $cfg{pageurl}/index.$cfg{ext}
<br />
<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="main_menu2,admin" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button type="submit" class="pure-button pure-button-primary">Add</button>
     </div>
     <div class="pure-u-1-12 all-c">
        <select name="html">
          <option value="1" selected>Yes</option>
          <option value="0">No</option>
        </select>
        </div>
        <div class="pure-u-1-4 all-c">
        <input class="pure-input-1" type="text" name="title" placeholder="Title" />
        </div>
        <div class="pure-u-1-4 all-c">
        <input class="pure-input-1" type="text" name="message" placeholder="Link" />
        </div>
        <div class="pure-u-1-6 all-c">
    <input class="pure-input-1" type="text" name="image" size="10" placeholder="Title Image" />
    <input class="pure-input-1" type="text" name="image2" size="10" placeholder="Icon Image" />
    </div>
     <div class="pure-u-1-12 all-c"> &nbsp;</div>
    </div>
    </fieldset>
    </form>
</small>
<div class="pure-g">
    <div class="pure-u-1-12 pure-table all-c"><b>Edit</b></div>
    <div class="pure-u-1-12 pure-table all-c"><b>Active</b></div>
    <div class="pure-u-1-4 pure-table all-c"><b>Title</b></div>
    <div class="pure-u-1-4 pure-table all-c"><b>Link</b></div>
    <div class="pure-u-1-6 pure-table all-c"><b>Image(s)</b></div>
    <div class="pure-u-1-12 pure-table all-c"><b>Delete</b></div>
</div>
$html
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
$sth->execute or die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
 my $seclvl = '';
    foreach (sort keys %usr) {
            my $bs = '';
            $bs = ' selected' if $row[5] && $usr{$_} eq $row[5];
            #$bs = ' selected' if !$id && $usr{$_} eq $usr{anonuser};
            $seclvl .= "<option value=\"$usr{$_}\"$bs>$usr{$_}</option>\n";
            }
$html .= <<"HTML";
<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="user_menu2,admin" />
<input type="hidden" name="id" value="$row[0]" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button type="submit" onclick="return ConfirmThis();" class="pure-button pure-button-primary">Edit</button>
     </div>
     <div class="pure-u-6-24 all-c">
        <select name="html">
          $seclvl
        </select>
        <input class="pure-input-1" type="text" name="title" placeholder="Title" value="$row[1]"/>
        </div>
        <div class="pure-u-6-24 all-c">
        <input class="pure-input-1" type="text" name="message" placeholder="Link" value="$row[2]" />
        </div>
        <div class="pure-u-1-6 all-c">
    <input type="text" name="image" class="pure-input-1" placeholder="Title Image" value="$row[3]" />
    <input type="text" name="image2" class="pure-input-1" placeholder="Icon Image" value="$row[4]" />
    </div>
     <div class="pure-u-1-6 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=user_menu2,admin;id=$row[0]" onclick="return ConfirmThis();">Delete</a></div>
    </div>
    </fieldset>
    </form>
</small><hr />
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

                my $html_print = <<"HTML";
<b>User Menu Edit</b><br />
These are the Link(s) in the User Menu, you can controle what user groups can see the links.<br />
$usr{admin} = See's all, $usr{mod} = See's all but $usr{admin} links, $usr{user} = See's $usr{user} links<br />
with the exception that $usr{anonuser} can only see $usr{anonuser} links in this menu.<br />
The Theme Tag converter is used, so you can easly point to the main page like this.<br />
%homepage% = $cfg{pageurl}/index.$cfg{ext}
<br />
<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="user_menu2,admin" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button type="submit" class="pure-button pure-button-primary">Add</button>
     </div>
     <div class="pure-u-6-24 all-c">
        <select name="html">
          $seclvl2
        </select>
        <input class="pure-input-1" type="text" name="title" placeholder="Title" />
        </div>
        <div class="pure-u-6-24 all-c">
        <input class="pure-input-1" type="text" name="message" placeholder="Link" />
        </div>
        <div class="pure-u-1-6 all-c">
    <input type="text" name="image" class="pure-input-1" placeholder="Title Image" />
    <input type="text" name="image2" class="pure-input-1" placeholder="Icon Image" />
    </div>
     <div class="pure-u-1-6 all-c"> &nbsp;</div>
    </div>
    </fieldset>
    </form>
</small>
<div class="pure-g">
    <div class="pure-u-1-12 pure-table all-c"><b>Edit</b></div>
    <div class="pure-u-6-24 pure-table all-c"><b>Security Level/Title</b></div>
    <div class="pure-u-6-24 pure-table all-c"><b>Link</b></div>
    <div class="pure-u-1-6 pure-table all-c"><b>Image(s)</b></div>
    <div class="pure-u-1-6 pure-table all-c"><b>Delete</b></div>
</div>
$html
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

my $form = <<'HTML';
<b>Add New Block</b>
<form class="pure-form" method="post">
<input type="hidden" name="op" value="menu_block2,admin">
<fieldset class="pure-group">
<input class="pure-input-1" type="text" name="title" placeholder="Title" />
<textarea class="pure-input-1 oflow" rows="8" placeholder="HTML/Text" name="message"></textarea>
</fieldset>
<select name="mode">
        <option value="1"selected>Yes</option>
        <option value="0">No</option>
</select> <b>Active = Yes or No</b><br />
<input type="text" name="loc" placeholder="Location" />
<b>Location = left or right</b><br />
<button type="submit" class="pure-button pure-button-primary">Submit</button>
</form>
<hr />
HTML

my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM blocks');
$sth->execute;
while(my @row = $sth->fetchrow)  {
my $select_it = '<option value="1" selected>Yes</option>
<option value="0">No</option>';
$select_it = '<option value="1">Yes</option>
<option value="0" selected>No</option>'
 if (! $row[1]);
 $form .= <<"HTML" if ($row[0]);
<form class="pure-form" method="post">
<input type="hidden" name="id" value="$row[0]" />
<input type="hidden" name="op" value="menu_block2,admin" />
<fieldset class="pure-group">
<input class="pure-input-1" type="text" name="title" placeholder="Title" value="$row[2]" />
<textarea class="pure-input-1 oflow" rows="8" placeholder="HTML/Text" wrap="soft" name="message">$row[3]</textarea>
</fieldset>
<select name="mode">
        $select_it
</select> <b>Active = Yes or No</b><br />
<input type="text" name="loc" placeholder="Location" value="$row[4]" />
<b>Location = left or right</b><br />
<div class="pure-g">
 <div class="pure-u-1-5">
 <button onclick="return ConfirmThis();" type="submit" class="pure-button pure-button-primary">Edit</button>
 </div>
 <div class="pure-u-1-3">
 <a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=menu_block2,admin;id=$row[0]" onclick="return ConfirmThis();">Delete</a>
 </div>
</div>
</form>
<hr />
HTML
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
$sth->execute or die("Couldn't exec sth! at Get Portal Config b2");

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
 'aj.page_expire' => $row[9],
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
        $stuff .= <<"HTML";
<div class="pure-control-group">
 <label for="$key_n">$key_n =&#62;</label>
 <input size="30" id="$key_n" type="text" placeholder="$key_n" name="ic" value="$cp{$_}">
</div>
HTML
        }

        $stuff = <<"HTML";
These are the settings and paths of the server and portal.<br />
<form class="pure-form pure-form-aligned" method="post">
<fieldset>
<button type="submit" class="pure-button pure-button-primary" onclick="return ConfirmThis();">Edit Config</button>
$stuff
<input type="hidden" name="op" value="admin_config2,admin" />
<button type="submit" class="pure-button pure-button-primary" onclick="return ConfirmThis();">Edit Config</button>
</fieldset>
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
my @row = $query->multi_param('ic');
my @new_row = ();

 foreach (@row) {
  push ( @new_row, $back_ends{$cfg{Portal_backend}}->quote($_) );
 }

my $stuff = <<"SQL";
UPDATE `portalconfigs` SET `pagename` = $new_row[1],
`pagetitle` = $new_row[2],
`cgi_bin_dir` = $new_row[3],
`non_cgi_dir` = $new_row[4],
`cgi_bin_url` = $new_row[5],
`non_cgi_url` = $new_row[6],
`lang` = $new_row[7],
`codepage` = $new_row[8],
`page_expire` = $new_row[9],
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
        
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, $stuff);

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=admin_config,admin'
                    );
}

sub subs_load {
my $html = '';

my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM subload');
$sth->execute or die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {

my $select_it = '<option value="1" selected>Yes</option>
<option value="0">No</option>';
$select_it = '<option value="1">Yes</option>
<option value="0" selected>No</option>'
 if (! $row[1]);

$html .= <<"HTML";
<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="subs_load2,admin" />
<input type="hidden" name="id" value="$row[0]" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button onclick="return ConfirmThis();" type="submit" class="pure-button pure-button-primary">Edit</button>
     </div>
     <div class="pure-u-1-12 all-c">
        <select class="pure-input-1" name="title">
          $select_it
        </select>
        </div>
        <div class="pure-u-1-6 all-c">
        <input class="pure-input-1" type="text" name="image" placeholder="Class" value="$row[2]" />
        </div>
        <div class="pure-u-1-6 all-c">
        <input class="pure-input-1" type="text" name="image2" placeholder="Sub" value="$row[3]" />
        </div>
        <div class="pure-u-1-8 all-c">
    <input class="pure-input-1" type="text" name="loc" placeholder="Loc.." value="$row[4]" />
    </div>
     <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=subs_load2,admin;id=$row[0]" onclick="return ConfirmThis();">Delete</a></div>
    </div>
    </fieldset>
    </form>
</small><hr />
HTML

}
$sth->finish();

                my $html_print = <<"HTML";
<b>Sub(s) Load Edit</b><br />
These are the Perl Subroutines that can be loaded.<br />
<b>Active:</b> Yes = On & No = Off<br />
<b>Locations:</b> START is for subs that do background tasks befor the theme, they do not print or return.<br />
Other locations are called in the theme and they are tags [%SubLoad-location%] you can make up locations for them.<br />
'home' can be used to return html/text under the welcome message of the Home Page.<br />

<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="subs_load2,admin" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button type="submit" class="pure-button pure-button-primary">Add</button>
     </div>
     <div class="pure-u-1-12 all-c">
        <select class="pure-input-1" name="title">
          <option value="1" selected>Yes</option>
          <option value="0">No</option>
        </select>
        </div>
        <div class="pure-u-1-6 all-c">
        <input class="pure-input-1" type="text" name="image" placeholder="Class" />
        </div>
        <div class="pure-u-1-6 all-c">
        <input class="pure-input-1" type="text" name="image2" placeholder="Sub" />
        </div>
        <div class="pure-u-1-8 all-c">
    <input class="pure-input-1" type="text" name="loc" placeholder="Loc.." />
    </div>
     <div class="pure-u-1-8 all-c"> &nbsp;</div>
    </div>
    </fieldset>
    </form>
</small>
<div class="pure-g">
    <div class="pure-u-1-12 pure-table all-c"><b>Edit</b></div>
    <div class="pure-u-1-12 pure-table all-c"><b>Active</b></div>
    <div class="pure-u-1-6 pure-table all-c"><b>Class</b></div>
    <div class="pure-u-1-6 pure-table all-c"><b>Sub</b></div>
    <div class="pure-u-1-8 pure-table all-c"><b>Location</b></div>
    <div class="pure-u-1-8 pure-table all-c"><b>Delete</b></div>
</div>
$html
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
    my $untaint_path = $Flex_WPS->untaint(
        value => $cfg{subloaddir}.'/'.$Fpm.'.pm',
        pattern => '\w\-\ \/\.\:'
        ) || 0;
   die('Dead Subload path') if ! $untaint_path;
   
  unless ($Fpm && -r $untaint_path) {
        warn "Module ( $untaint_path ) does not exist";
   }
    else {
 require $untaint_path unless exists $INC{$untaint_path};
my %sub_action2 = ();
 if (exists &{$Fpm . '::sub_action'}
        && (ref $Fpm . '::sub_action' eq 'CODE' || ref $Fpm . '::sub_action' eq '')) {
        $load = \&{$Fpm . '::sub_action'};
        %sub_action2 = $load->();
    }
     else {
        warn "Module ( $untaint_path ) Does not support SubLoad ( sub_action )";

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
my $select_it = '<option value="1" selected>Yes</option>
<option value="0">No</option>';
$select_it = '<option value="1">Yes</option>
<option value="0" selected>No</option>'
 if (! $row[2]);
 
$html .= <<"HTML";
<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="super_mods2,admin" />
<input type="hidden" name="id" value="$row[0]" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button onclick="return ConfirmThis();" type="submit" class="pure-button pure-button-primary">Edit</button>
     </div>
     <div class="pure-u-1-12 all-c">
        <select name="title">
          $select_it
        </select>
        </div>
        <div class="pure-u-6-24 all-c">
        <input class="pure-input-1" type="text" name="image" placeholder="Group" value="$row[1]" />
        </div>
     <div class="pure-u-1-6 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=super_mods2,admin;id=$row[0]" onclick="return ConfirmThis();">Delete</a></div>
    </div>
    </fieldset>
    </form>
</small><hr />
HTML

}
$sth->finish();

                my $html_print = <<"HTML";
<b>Super Groups</b><br />
Security Levels from high to low would be:<br />
$usr{admin}, $usr{mod} (user can be super_mod),<br />
$usr{user}(user can be super_mod), $usr{anonuser}(Guest can be super_mod).<br />
These are a secondary user group that defaults the base user level to $usr{user} and requiers<br />
all authorized areas above $usr{user} security to be specified for that group in Super Paths.<br />
<b>Active:</b> Yes = On & No = Off<br />
<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="super_mods2,admin" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button type="submit" class="pure-button pure-button-primary">Add</button>
     </div>
     <div class="pure-u-1-12 all-c">
        <select name="title">
          <option value="1" selected>Yes</option>
          <option value="0">No</option>
        </select>
        </div>
        <div class="pure-u-6-24 all-c">
        <input class="pure-input-1" type="text" name="image" placeholder="Group" />
        </div>
     <div class="pure-u-1-6 all-c"> &nbsp;</div>
    </div>
    </fieldset>
    </form>
</small>
<div class="pure-g">
    <div class="pure-u-1-12 pure-table all-c"><b>Edit</b></div>
    <div class="pure-u-1-12 pure-table all-c"><b>Active</b></div>
    <div class="pure-u-6-24 pure-table all-c"><b>Group Name</b></div>
    <div class="pure-u-1-6 pure-table all-c"><b>Delete</b></div>
</div>
$html
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

my $select_it = '<option value="1" selected>Yes</option>
<option value="0">No</option>';
$select_it = '<option value="1">Yes</option>
<option value="0" selected>No</option>'
 if (! $row[3]);
 
$html .= <<"HTML";
<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="super_paths2,admin" />
<input type="hidden" name="id" value="$row[0]" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button type="submit" class="pure-button pure-button-primary">Edit</button>
     </div>
     <div class="pure-u-6-24 all-c">
        <select name="title">
          $pos
        </select>
        </div>
        <div class="pure-u-6-24 all-c">
        <input class="pure-input-1" type="text" name="image" placeholder="Path" value="$row[2]" />
        </div>
        <div class="pure-u-1-12 all-c">
        <select name="image2">
          $select_it
        </select>
        </div>
     <div class="pure-u-1-6 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=super_paths2,admin;id=$row[0]" onclick="return ConfirmThis();">Delete</a></div>
    </div>
    </fieldset>
    </form>
</small><hr />
HTML
  $pos = '';
}
$sth->finish();

foreach (@userlevel) {
        $pos .= "<option value=\"$_\">$_</option>\n";
 }
                my $html_print = <<"HTML";
<b>Super Paths</b><br />
Be carefull! You can allow groups to places that my harm the site.<br />
These Security levels can be used also:<br />
$usr{user}(user can be super_mod), $usr{anonuser}(Guest can be super_mod).<br /><br />
These are the Paths and User Groups that are allowed to them.<br />
<b>Active:</b> Yes = On & No = Off<br />
<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="super_paths2,admin" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button type="submit" class="pure-button pure-button-primary">Add</button>
     </div>
     <div class="pure-u-6-24 all-c">
        <select name="title">
          $pos
        </select>
        </div>
        <div class="pure-u-6-24 all-c">
        <input class="pure-input-1" type="text" name="image" placeholder="Path" />
        </div>
        <div class="pure-u-1-12 all-c">
        <select name="image2">
          <option value="1" selected>Yes</option>
          <option value="0">No</option>
        </select>
        </div>
     <div class="pure-u-1-6 all-c"> &nbsp;</div>
    </div>
    </fieldset>
    </form>
</small>
<div class="pure-g">
    <div class="pure-u-1-12 pure-table all-c"><b>Edit</b></div>
    <div class="pure-u-6-24 pure-table all-c"><b>Group Name</b></div>
    <div class="pure-u-6-24 pure-table all-c"><b>Class::Sub</b></div>
    <div class="pure-u-1-12 pure-table all-c"><b>Active</b></div>
    <div class="pure-u-1-6 pure-table all-c"><b>Delete</b></div>
</div>
$html
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
$html .= <<"HTML";
<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="ajax2,admin" />
<input type="hidden" name="id" value="$row[0]" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button onclick="return ConfirmThis();" type="submit" class="pure-button pure-button-primary">Edit</button>
     </div>
     <div class="pure-u-1-6 all-c">
        <b>$row[0]</b>
        </div>
        <div class="pure-u-1-2 all-c">
        <textarea name="image" rows="8" class="pure-input-1 oflow" placeholder="Script">$row[1]</textarea>
        </div>
     <div class="pure-u-1-6 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=ajax2,admin;id=$row[0]" onclick="return ConfirmThis();">Delete</a></div>
    </div>
    </fieldset>
    </form>
</small><hr />
HTML

}
$sth->finish();

                my $html_print = <<"HTML";
<b>Ajax Script(s) Edit</b>
<br />
<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="ajax2,admin" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button type="submit" class="pure-button pure-button-primary">Add</button>
     </div>
     <div class="pure-u-1-6 all-c">
        <input type="text" name="title" class="pure-input-1" placeholder="Place" />
        </div>
        <div class="pure-u-1-2 all-c">
        <textarea name="image" rows="8" class="pure-input-1 oflow" placeholder="Script..."></textarea>
        </div>
     <div class="pure-u-1-6 all-c"> &nbsp;</div>
    </div>
    </fieldset>
    </form>
</small>
<div class="pure-g">
    <div class="pure-u-1-12 pure-table all-c"><b>Edit</b></div>
    <div class="pure-u-1-6 pure-table all-c"><b>Place</b></div>
    <div class="pure-u-1-2 pure-table all-c"><b>Script</b></div>
    <div class="pure-u-1-6 pure-table all-c"><b>Delete</b></div>
</div>
$html
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
$html .= <<"HTML";
<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="module_settings2,admin" />
<input type="hidden" name="id" value="$row[0]" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button onclick="return ConfirmThis();" type="submit" class="pure-button pure-button-primary">Edit</button>
     </div>
     <div class="pure-u-1-6 all-c">
        <input type="text" name="title" class="pure-input-1" placeholder="Module" value="$row[1]" />
        </div>
        <div class="pure-u-1-2 all-c">
        <textarea name="message" rows="8" class="pure-input-1 oflow" placeholder="Settings...">$row[2]</textarea>
        </div>
     <div class="pure-u-1-6 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=module_settings2,admin;id=$row[0]" onclick="return ConfirmThis();">Delete</a></div>
    </div>
    </fieldset>
    </form>
</small><hr />
HTML

}
$sth->finish();

                my $html_print = <<"HTML";
<b>Module Settings</b><br />
This is a table that modules can use to hold their settings.<br />
Most modules should use this table and provide their own setting editor.<br />
<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="module_settings2,admin" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-12 all-c">
    <button type="submit" class="pure-button pure-button-primary">Add</button>
     </div>
     <div class="pure-u-1-6 all-c">
        <input type="text" name="title" class="pure-input-1" placeholder="Module" />
        </div>
        <div class="pure-u-1-2 all-c">
        <textarea wrap="soft" name="message" rows="8" class="pure-input-1" placeholder="Settings..."></textarea>
        </div>
     <div class="pure-u-1-6 all-c"> &nbsp;</div>
    </div>
    </fieldset>
    </form>
</small>
<div class="pure-g">
    <div class="pure-u-1-12 pure-table all-c"><b>Edit</b></div>
    <div class="pure-u-1-6 pure-table all-c"><b>Module</b></div>
    <div class="pure-u-1-2 pure-table all-c"><b>Settings</b></div>
    <div class="pure-u-1-6 pure-table all-c"><b>Delete</b></div>
</div>
$html
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
$sth->execute or die('Couldn\'t exec sth!');
while(my @row = $sth->fetchrow) {
$row[1] = $Flex_WPS->format_date($row[1], 11);
my $link = "<a class=\"pure-button pure-button-active\" href=\"$cfg{pageurl}/index.$cfg{ext}?op=site_ban2,admin;loc=$row[0]\" onclick=\"return ConfirmThis();\">Disable</a>";
if ($row[3] ne '1') {
$row[3] = $row[3] =~ m/\A\d+\z/
 ? $Flex_WPS->format_date($row[3], 11)
 : $row[3];
}
 else {
 $row[3] = 'Disabled!';
 $link = "<a class=\"pure-button pure-button-active\" href=\"$cfg{pageurl}/index.$cfg{ext}?op=site_ban2,admin;mode=$row[0]\" onclick=\"return ConfirmThis();\">Activate</a>";
 }
$html .= <<"HTML";
<small>
<div class="pure-g">
   <div class="pure-u-1-8 all-c">
    $link
     </div>
     <div class="pure-u-1-4 all-c">
        <b>$row[0]</b><br />
        <a href="http://network-tools.com/default.asp?prog=network&host=$row[0]" target="_blank" alt="Whois Search">Whois</a> |
        <a href="http://network-tools.com/default.asp?prog=dnsrec&host=$row[0]" target="_blank" alt="DNS Lookup">DNS Lookup</a><hr />
        <a href="http://www.mxtoolbox.com/SuperTool.aspx?action=blacklist%3a$row[0]" target="_blank" alt="Black List">Black List Check</a>
        </div>
        <div class="pure-u-1-12 all-c"><b>$row[2]</b></div>
        <div class="pure-u-1-5 all-c"><b>$row[1]<br />$row[3]</b></div>
     <div class="pure-u-1-8 all-c"><a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=site_ban2,admin;id=$row[0]" onclick="return ConfirmThis();">Delete</a></div>
    </div>
    </small><hr />
HTML

}
$sth->finish();

         my $ip_ban = '<span style="color:DarkRed;"><b>Site Ban Did Not Load</b></span><br />';
         $ip_ban = '<span style="color:Green;"><b>Site Ban is Working</b></span><br />' if $cfg{check_ban};

        my $html_print = <<"HTML";
<b>Site Ban Edit</b><br />
$ip_ban
Here you can manage what IP's or Domain names you would like to Block from your site.<br />
The <b>"Whois"</b>, <b>"DNS Lookup"</b> links under the IP or Domain will use a free service from www.network-tools.com to
 reveal more information about that location.<b>"Black List"</b> is to check if its a known spam location, you may want to check this
 first.<br /><br />
Some <b>Crawlers/Bots</b> do not follow internet standards witch will get them band from this site,
 to allow those locations after they have been ban click "Disable" so they are not blocked and the last date will change
 to "Disabled!". You can reactivate by clicking "Activate".<br />

<small>
<form class="pure-form pure-form-stacked" method="post">
<input type="hidden" name="op" value="site_ban2,admin" />
<fieldset>
<div class="pure-g">
   <div class="pure-u-1-8 all-c">
    <button type="submit" class="pure-button pure-button-primary">Add</button>
     </div>
     <div class="pure-u-1-4 all-c">
        <input class="pure-input-1" type="text" name="message" size="15" placeholder="IP" />
        </div>
        <div class="pure-u-1-12 all-c"> &nbsp;</div>
        <div class="pure-u-1-5 all-c"> &nbsp;</div>
     <div class="pure-u-1-8 all-c"> &nbsp;</div>
    </div>
    </fieldset>
    </form>
</small>
<div class="pure-g">
    <div class="pure-u-1-8 pure-table all-c"><b>Edit</b></div>
    <div class="pure-u-1-4 pure-table all-c"><b>IP</b></div>
    <div class="pure-u-1-12 pure-table all-c"><b>Count</b></div>
    <div class="pure-u-1-5 pure-table all-c"><b>First &amp; Last Date</b></div>
    <div class="pure-u-1-8 pure-table all-c"><b>Delete</b></div>
</div>
$html
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
$sth->execute or die("Couldn't exec sth!");
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
$sth = 'SELECT * FROM themes WHERE id ='.$id.' LIMIT 1;';
$sth = 'SELECT * FROM themes WHERE active =\'1\' LIMIT 1;' if !$id;
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute or die('Couldn\'t exec sth!');
while(my @theme_info = $sth->fetchrow) {
 push (@row, @theme_info);
}
$sth->finish();
 }
 
$sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM themes');
$sth->execute or die('Couldn\'t exec sth!');
my $theme_form = <<"HTML";


<form method="post" class="pure-form">
<div class="pure-g">
<input type="hidden" name="op" value="theme,admin" />
<div class="pure-u-1-12"><b>Select:</b></div>
<div class="pure-u-1-7">
<select name="id">
HTML
while(my @theme_info = $sth->fetchrow) {
 $theme_form .= "<option value=\"$theme_info[0]\">$theme_info[2] $theme_info[1]</option>\n";
}
$sth->finish();
$theme_form .= <<"HTML";
</select></div>
<div class="pure-u-1-8">
<input class="pure-img-responsive pure-button pure-button-active" type="image" src="$cfg{imagesurl}/icon/move.png" name="submit" />
</div>

</div>
</form>

<p>
<a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=theme,admin;add=add">Add New Theme</a>
</p>
HTML

# fix markup for form
$row[5] =~ s/<\/textarea>/&#60;\/textarea&#62;/g;

my $select_it = '<option value="1" selected>Yes</option>
<option value="0">No</option>';
$select_it = '<option value="1">Yes</option>
<option value="0" selected>No</option>'
 if (! $row[1]);
 
        $theme_form = <<"HTML";
 $theme_form
<form class="pure-form pure-form-stacked" method="post">
  <input type="hidden" name="id" value="$row[0]" />
  <input type="hidden" name="add" value="$add" />
  <input type="hidden" name="op" value="theme2,admin" />
    <fieldset>
        <legend>Theme $row[2]  <a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=theme2,admin;add=1;id=$row[0]" onclick="return ConfirmThis();">Delete This Theme</a></legend>

        <label for="title"><b>Active</b> Yes = Default or No = Off</label>
        <select id="title" name="title">
          $select_it
        </select>

        <label for="loc"><b>Theme Name</b></label>
        <input id="loc" type="text" name="loc" placeholder="Name.." value="$row[2]" />

        <label for="disc"><b>Charset</b></label>
        <input id="disc" type="text" name="disc" placeholder="Charset.." value="$row[3]" />

        <label for="keywords"><b>Language</b></label>
        <input id="keywords" type="text" name="keywords" placeholder="Lang.." value="$row[4]" />
        <label for="html"><b>Markup</b></label>
        <textarea id="html" placeholder="Markup.." name="html" rows="30" class="pure-input-1 oflow">$row[5]</textarea>
        <input onclick="return ConfirmThis();" class="pure-button pure-button-primary" type="submit" name="Submit" value="Edit" />&nbsp;&nbsp;&nbsp;<input onclick="return ConfirmThis();" class="pure-button pure-button-active" type="submit" name="mode" value="Duplicate" />
    </fieldset>
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
 
 $html =~ s/&#60;\/textarea&#62;/<\/textarea>/g;
 $keywords = $back_ends{$cfg{Portal_backend}}->quote($keywords);
 $disc = $back_ends{$cfg{Portal_backend}}->quote($disc);
 $loc = $back_ends{$cfg{Portal_backend}}->quote($loc);
 $title = $back_ends{$cfg{Portal_backend}}->quote($title);

 #$add = '' if $add ne 'add';
        my $string = '';
        if ($html && ($f_mode eq 'Duplicate' || $add eq 'add')) {
             $html = $back_ends{$cfg{Portal_backend}}->quote($html);
             $string = "INSERT INTO `themes` VALUES (NULL,$title,$loc,$disc,$keywords,$html);";
          }
            elsif (!$add && $id && $html) {
              $id = $back_ends{$cfg{Portal_backend}}->quote($id);
              $html = $back_ends{$cfg{Portal_backend}}->quote($html);
              $string = "UPDATE `themes` SET `active` = $title,
`name` = $loc, `charset` = $disc, `language` = $keywords, `markup` = $html WHERE `id` = $id LIMIT 1 ;";
            }
             elsif ($add eq '1' &&  $id) {
              $id = $back_ends{$cfg{Portal_backend}}->quote($id);
              $string = "DELETE FROM `themes` WHERE `id` = $id LIMIT 1 ;";
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

my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM `optimize`');
$sth->execute;
while(my @row = $sth->fetchrow)  {
        push ( @module_tables, $row[1] );

        $modules_delete .= " <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=optimize2,admin;id=$row[0];add=1\" onclick=\"return ConfirmThis();\">$row[1]</a> |";
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
                                  $Flex_WPS->SQL_Edit($cfg{Portal_backend}, 'OPTIMIZE TABLE `'.$table.'`');
                                  $optamize .= 'OPTIMIZE TABLE ' . $table . '<br />';
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


                        my $html_print = <<"HTML";
<b>Optimize Portal Tables</b><br />
This will optimize Tables for the Main Portal and Added Tables for Modules.<br />
It is Recommended to Run this Page if there has been many Inserts or Edits.<br />
The Optimizer will also check if the Table needs to be Optimized.<br />
<p><b>Main Portal tables:</b><br />
@info<br /></p>
<p><b>Module tables:</b> Click to delete.<br />
$modules_delete</p>

<form method="post" class="pure-form">
  <input type="hidden" name="op" value="optimize2,admin" />
  <input type="hidden" name="add" value="add" />
<fieldset>
        <legend>Add tables to optimize</legend>
  <input type="text" name="title" placeholder="Table Name..." />
  <button type="submit" class="pure-button pure-button-primary">Add Table Name</button>
  </fieldset>
</form>
$optamize
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
                        my $html_print = <<"HTML";
<b>Stats Log Admin</b><br />
The stats_log table can become big. This will empty the stats_log table.<br />
<form class="pure-form" method="post" name="sbox" onSubmit="if (document.sbox.query.value=='') return false">
<fieldset>
        <legend>Search Stats Log</legend>
<input type="text" name="query" size="15" placeholder="Search..." />
<input type="hidden" name="what" value="statlog" />
<input type="hidden" name="op" value="search,Search" />
  <button type="submit" class="pure-button pure-button-primary">$msg{search} Stats Log</button>
  </fieldset>
</form>
<p>
<a class="pure-button pure-button-active" href="$cfg{pageurl}/index.$cfg{ext}?op=stats_log2,admin" onclick="return ConfirmThis();">Empty Stats Log</a>
</p>
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

admin.pm, v1.00 08/03/2016 N.K.A.
Works with Flex-WPS v1.0 series

todo:
do something with the stats_log, search_log and other logs so it clears the
table every month or so to keep things running fast.

08/03/2016
Major update to the theme and how sub load works in it.
Uses AUBBC2, CGI.pm but may go back to an updated version of Flex_CGI
Updated standardized the HTML, CSS and javascript confirms
Fixed some coding errors of || die() to or die()
Fixed some double quotes to single quotes
Added double quotes to some strings

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

Main Developer:
 N.K.A.
 shakaflex [at] gmail.com
 http://search.cpan.org/~sflex/

=cut
