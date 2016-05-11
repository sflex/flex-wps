package PM;
# =====================================================================
# Flex - WPS Evolution 3
# Private Messaging version 1 beta 6 with Ajax
#
# By N. K. A. (shakaflex [at] gmail.com)
#
# To do: Golf, preformance, security
#
#
# Date: 09/13/2011, PM.pm
# Fix - Added some no cache Headers to stop IE from cacheing AJAX, no special
# setting changes are required for IE browsers now.
# =====================================================================
# Load necessary modules.
use strict;
# Assign global variables.
use vars qw(
    $query
    %user_data %back_ends
    %nav %msg %cfg %usr %err %btn
    $Flex_WPS $AUBBC_mod %user_action
    );
use exporter;

%user_action = (
        view_pm => $usr{user},
        send_pm => $usr{user},
        save_pm => $usr{user},
        delete_pm => $usr{user},
        delete_pm2 => $usr{user},
        buddys => $usr{user},
        message2 => $usr{user},
        in_out_boxs => $usr{user},
        menu_out_in => $usr{user},
);

# Need to check filters! FOR ALL inputs!
my $subject = $query->param('subject') || '';
my $message = $query->param('message') || '';
my $quote = $query->param('quote') || '';
my $to = $query->param('to') || '';
my $id = $query->param('id') || '';

# need config for this and add code to check it
# put count in profile for speed
my $max_messages = 50;
my $max_stmessages = 51;

sub view_pm {

# Get private messages for user
my $boxlinks = <<HTML;
<table width="100%" border="0" cellspacing="0" cellpadding="2">
  <tr>
    <td width="50%"><div id="inoutMenu"> </div></td>
    <td width="25%"><table class="tablebox" width="100%">
<tr><td><a href="#veiw" onclick="changemessage('$cfg{pageurl}/index.$cfg{ext}?op=send_pm,PM');"><img src="$cfg{imagesurl}/PM/send.png" border="0" alt="send" /></a></td>
<td>&nbsp;<a href="#veiw" onclick="changemessage('$cfg{pageurl}/index.$cfg{ext}?op=send_pm,PM');"><b>Send PM</b></a>
</td></tr>
</table></td>
    <td width="25%"><table class="tablebox" width="100%">
<tr><td><a href="#veiw" onclick="getbuddysBox();"><img src="$cfg{imagesurl}/PM/buddys.png" border="0" alt="buddy" /></a></td>
<td><a href="#veiw" onclick="getbuddysBox();"><b>Help Desk</b></a>
</td></tr>
</table></td>
  </tr>
</table>
HTML

#my $print_html = box_script();
                my $print_html = <<HTML;
<a name="veiw"></a>
<table align="center" class="navtable" width="100%" border="0" cellspacing="0" cellpadding="3">
<tr valign="top">
<td>$boxlinks
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr valign="top">
<td width="100%">
<div id="messageview">
HTML

if ($message eq 'send'){
 $print_html .= send_pm();
}
elsif ($message eq 'buddys') {
 $print_html .= buddys();
}

                $print_html .= <<HTML;
 </div>
<div id="inoutBox"> </div></td>
</tr>
</table>
</td>
</tr>
</table>
HTML

# New: Supports IE# cache disabling for AJAX
 print $query->header(
        -expires => 'now',
        -charset => $cfg{codepage},
        -cache_con => 'no-store, no-cache, must-revalidate', # HTTP/1.1
        -cache => 1, # HTTP/1.0
 );
 $Flex_WPS->print_html(
        page_name    => $nav{im_index},
        type         => '',
        ajax_name    => 'PM_box',
        word_density => '',
        );
 print $print_html;
 $Flex_WPS->print_html(
        page_name    => $nav{im_index},
        type         => 1,
        ajax_name    => '',
        );
# old
#$Flex_WPS->print_page(
#        markup       => $print_html,
#        cookie1      => '',
#        cookie2      => '',
#        location     => '',
#        ajax_name    => 'PM_box',
#        navigation   => $nav{im_index},
#        );
}
sub get_percentpix {
my ($total_size, $max_messages) = @_;
my ($percent, $pixel, $a, $b);
   if ($total_size != 0)
   {
   $pixel = int((($total_size / $max_messages) * 100) / 2);
   $percent = ($total_size / $max_messages) * 100;
   my $c = int(10 * ($percent * 10 - int($percent * 10)));
   $b = int(10 * ($percent - int($percent)));
   $a = int($percent);
   if ($c >= 5) { $b++; }
   }
   else { $a = 0; $b = 0; }
   $percent = $a . "." . $b;
   if (!$pixel) { $pixel = 0; }
   return ($pixel, $percent);
}
sub row_color {
my $row_color = shift;
$row_color = ($row_color eq ' class="tbl_row_dark"')
? ' class="tbl_row_light"'
: ' class="tbl_row_dark"';
return $row_color;
}
sub in_out_boxs {
my $messages = '';
my $boxsubj = '';
my $row_color = ' class="tbl_row_dark"';
# Get private messages for user
if(!$quote) {
$boxsubj = 1;
my (@pmin);
my $sth = "SELECT * FROM pmin WHERE memberid='$user_data{id}' ORDER BY date DESC";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
# build message
if ($row[0]) {

        push (
                @pmin,
                join (
                        "|",   $row[0], $row[3], $row[4], $row[5], $row[2], $row[6]
                )
            );
 }
}
$sth->finish();

for (my $i = 0; $i <= $#pmin; $i++) {
 my @row = split(/\|/, $pmin[$i]);
 if (!$row[5]) { $row[5] = ''; }
 $messages .= message_build($row_color, $row[0], $row[1], $row[2], $row[3], $row[4], $row[5]);
 # Alternate the row colors.
 $row_color = row_color($row_color);
 }
}
# Get Sent private messages for user
if($quote) {
$boxsubj = 2;
my (@pmout);
my $sth = "SELECT * FROM pmout WHERE memberid='$user_data{id}' ORDER BY date DESC";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
      if($row[0]) {
# build message
if ($row[0]) {
        push (
                @pmout,
                join (
                        "|",   $row[0], $row[3], $row[4], $row[5], $row[2]
                )
            );
            }
      }
}
$sth->finish();

for (my $i = 0; $i <= $#pmout; $i++) {
 my @row = split(/\|/, $pmout[$i]);
 $messages .= message_build($row_color, $row[0], $row[1], $row[2], $row[3], $row[4], '');
 # Alternate the row colors.
 $row_color = row_color($row_color);
 }
}

# New: Supports IE# cache disabling for AJAX
 print $query->header(
        -expires => 'now',
        -charset => $cfg{codepage},
        -cache_con => 'no-store, no-cache, must-revalidate', # HTTP/1.1
        -cache => 1, # HTTP/1.0
 );
if ($messages) {
$boxsubj = $nav{im_index} if $boxsubj == 1;
$boxsubj = $nav{im_sent} if $boxsubj == 2;
                print <<HTML;
<br />
<form name="item_list" method="post" action="$cfg{pageurl}/index.$cfg{ext}">
<input type="submit" value="Delete Checked" onclick="return confirm('Are you sure you want to Delete Checked item?');" />&nbsp;&nbsp;<small><a href="javascript:checkAll(1)">Check All</a> - <a href="javascript:checkAll(0)">Clear All</a></small>
<table width="100%" border="0" cellspacing="1" cellpadding="2">
<tr class="tbl_header">
<td><b>$msg{authorC}</b></td>
<td><b>$boxsubj - $msg{subjectC}</b></td>
</tr>
$messages
</table>
<input type="hidden" name="op" value="delete_pm,PM" />
<input type="hidden" name="quote" value="$quote" />
<input type="submit" value="Delete Checked" onclick="return confirm('Are you sure you want to Delete Checked item?');" />&nbsp;&nbsp;
<small><a href="javascript:checkAll(1)">Check All</a> - <a href="javascript:checkAll(0)">Clear All</a></small>
</form>
HTML
} else { print 'No Messages'; }

 exit;
}
sub menu_out_in {
# Get private messages for user
my $total_size = 0;
my $menu_box = '';

    my $sth = "SELECT `date` FROM `pmin` WHERE `memberid` = '$user_data{id}' ORDER BY `date` DESC";
    $sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
    $sth->execute || die("Couldn't exec sth!");
    while(my @row = $sth->fetchrow) {
    # build message
    $total_size++ if $row[0];
    }
    $sth->finish();
    my ($pixel1, $percent1) = get_percentpix($total_size, $max_messages);
    my $barhtml = <<HTML;
<img src="$cfg{imagesurl}/leftbar.gif" width="7" height="14" alt="" /><img src="$cfg{imagesurl}/mainbar.gif" width="$pixel1" height="14" alt="" /><img src="$cfg{imagesurl}/rightbar.gif" width="7" height="14" alt="" />
HTML
    $menu_box = <<HTML;
<table class="tablebox" align="left" width="50%">
<tr><td><a href="#veiw" onclick="getinoutBox('','');"><img src="$cfg{imagesurl}/PM/inbox.png" border="0" alt="inbox" /></a></td>
<td>
&nbsp;<a href="#veiw" onclick="getinoutBox('','');"><b>$nav{im_index}:</b></a>&nbsp;$total_size/$max_messages<br>&nbsp;$barhtml $percent1
</td></tr>
</table>
HTML
         $total_size = 0;
         $sth = "SELECT `date` FROM `pmout` WHERE `memberid` ='$user_data{id}' ORDER BY `date` DESC"; #SELECT * FROM pmout WHERE memberid='$user_data{id}'";
         $sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
         $sth->execute || die("Couldn't exec sth!");
         while(my @row = $sth->fetchrow) {
               $total_size++ if ($row[0]);
         }
         $sth->finish();
         my ($pixel2, $percent2) = get_percentpix($total_size, $max_stmessages);
         $barhtml = <<HTML;
<img src="$cfg{imagesurl}/leftbar.gif" width="7" height="14" alt="" /><img src="$cfg{imagesurl}/mainbar.gif" width="$pixel2" height="14" alt="" /><img src="$cfg{imagesurl}/rightbar.gif" width="7" height="14" alt="" />
HTML
    $menu_box .= <<HTML;
<table class="tablebox" align="left" width="50%">
<tr><td><a href="#veiw" onclick="getinoutBox(1,'');"><img src="$cfg{imagesurl}/PM/outbox.png" border="0" alt="outbox" /></a></td>
<td>&nbsp;<a href="#veiw" onclick="getinoutBox(1,'');"><b>$nav{im_sent}:</b></a>&nbsp;$total_size/$max_stmessages<br>&nbsp;$barhtml $percent2
</td></tr>
</table>
HTML
       #  }

# New: Supports IE# cache disabling for AJAX
 print $query->header(
        -expires => 'now',
        -charset => $cfg{codepage},
        -cache_con => 'no-store, no-cache, must-revalidate', # HTTP/1.1
        -cache => 1, # HTTP/1.0
 );
print $menu_box;
 exit;
}
sub message_build {
# Need to add user info
my ($row_color, $iid, $date, $subject, $message, $user, $unread) = @_;
 # Text and word Wrap, default Perl Module!
 use Text::Wrap;
 $Text::Wrap::columns = 60; # Wrap at 60 characters
    $subject = wrap('', '', $subject);
    $message = wrap('', '', $message);

my $edit_link;
if ($unread) {
$unread = <<HTML;
<img src="$cfg{imagesurl}/forum/new.gif" alt="New Message" border="0" />
HTML
}
else {
$unread = <<HTML;
<img src="$cfg{imagesurl}/forum/xx.gif" alt="Read Message" border="0" />
HTML
}

if ($user !~ m!^([0-9]+)$!i) {
$edit_link = <<HTML;
<a href="#veiw" onclick="getdeleteBox($iid, '');"><img src="$cfg{imagesurl}/button_cance.png" alt="$msg{delete}" border="0" /></a>&nbsp;&nbsp;
HTML
}
elsif ($quote) {
$edit_link = <<HTML;
<a href="#veiw" onclick="changemessage('$cfg{pageurl}/index.$cfg{ext}?op=send_pm,PM;id=$iid;quote=1;to=$user;subject=sent');"><img src="$cfg{imagesurl}/forum/quote.gif" alt="$msg{quote}" border="0" /></a>
&nbsp;&nbsp;<a href="#veiw" onclick="getdeleteBox($iid, 1);"><img src="$cfg{imagesurl}/button_cance.png" alt="$msg{delete}" border="0" /></a>&nbsp;&nbsp;
HTML
 }
 else {
$edit_link = <<HTML;
<a href="#veiw" onclick="changemessage('$cfg{pageurl}/index.$cfg{ext}?op=send_pm,PM;id=$iid;quote=1;to=$user');"><img src="$cfg{imagesurl}/forum/quote.gif" alt="$msg{quote}" border="0" /></a>
&nbsp;&nbsp;<a href="#veiw" onclick="getdeleteBox($iid, '');"><img src="$cfg{imagesurl}/button_cance.png" alt="$msg{delete}" border="0" /></a>&nbsp;&nbsp;
HTML
}

$date = $Flex_WPS->format_date($date, 5);
my $buddyhtml = '';

#my $lid = $user_data{buddys};

if($user =~ m!^[0-9]+$!i) {
#my $crap = $user;
$buddyhtml .= '<td align="left">';
#$buddyhtml .= mouse_boxtop();
my $filx = profile($user) || '';
my $name = '';

if ($filx) {
$name = $filx;
#$stuff = $filx;
#$stuff = mouse_box("$stuff");
}
$buddyhtml .= <<HTML;
<img src="$cfg{imagesurl}/PM/buddys_s.png" style="border: none;" alt="$name" />
</td>
<td width="100%"><b>$name</b></td>
HTML

}
else {
my $name = profile($user) || '';
    if (!$name && $user) {
    $buddyhtml = <<HTML;
<td><img src="$cfg{imagesurl}/icon/sticky.gif" style="border: none;" alt="none" /></td>
<td width="100%">System-Alert</td>
HTML
    }
    else {
    $buddyhtml = <<HTML;
<td><img src="$cfg{imagesurl}/icon/sticky.gif" style="border: none;" alt="none" /></td>
<td width="100%"><a href="$cfg{pageurl}/index.$cfg{ext}?op=view_profile;username=$user">$name</a></td>
HTML
    }
}

$AUBBC_mod->settings( for_links => 1 );
$subject = $AUBBC_mod->do_all_ubbc($subject);
$AUBBC_mod->settings( for_links => 0 );
my $table = <<HTML;
<tr$row_color>
<td width="140" valign="top" rowspan="1">
<table border="0" width="100%" cellpadding="0" cellspacing="1">
<tr>
<td width="30"><input type="checkbox" name="id" value="$iid" /></td>
$buddyhtml
</tr>
</table>
</td>
<td valign="top" width="100%">
<table border="0" width="100%" cellpadding="0" cellspacing="1">
<tr>
<td width="100%">&nbsp;$unread<a href="#veiw" onclick="changemessage('$cfg{pageurl}/index.$cfg{ext}?op=message2,PM;id=$iid;quote=$quote');"><b>$subject</b></a></td>
<td align="right" nowrap><small>$date</small>&nbsp;&nbsp;$edit_link</td>
</tr>
</table></td>
</tr>
HTML

return $table;
}
sub message2 {
my $readcheck = 0;
my $message = '';
my $subject = '';
my $buddyin = '';
my $query1;

 # Text and word Wrap, default Perl Module!
 use Text::Wrap;
 $Text::Wrap::columns = 60; # Wrap at 60 characters

if (!$quote) {
# Get private messages for user
$query1 = "SELECT * FROM pmin WHERE id='$id' AND memberid='$user_data{id}'";
} else {
# Get private messages for user
$query1 = "SELECT * FROM pmout WHERE id='$id' AND memberid='$user_data{id}'";
}
my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
# build message
if ($row[6]) { $readcheck = 1; }
$buddyin = $row[2];
$subject = $row[4];
$message = $row[5];
}
$sth->finish();

#$AUBBC_mod->settings( protect_email => 1 );
$message = $AUBBC_mod->do_all_ubbc($message);
$AUBBC_mod->settings( for_links => 1 );
$subject = $AUBBC_mod->do_all_ubbc($subject);
$AUBBC_mod->settings( for_links => 0 );
    $subject = wrap('', '', $subject);
my $filx = profile("$buddyin") || '';
my $name = '';
my $stuff = '';
$filx =~ s/(.+?)\]\[\]\[//;
$name = $1;
my $buddyhtml = <<HTML;
<td><img src="$cfg{imagesurl}/icon/sticky.gif" style="border: none;" alt="none" /></td>
<td><a href="$cfg{pageurl}/index.$cfg{ext}?op=view_profile;username=$buddyin" target="_parent">$name</a></td>
HTML
if ($readcheck){
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE pmin SET new='0' WHERE id='$id' LIMIT 1 ;");
}
print "Content-type: text/html\n\n";

print <<HTML;
<table width="100%" border="0" cellspacing="0" cellpadding="3" bgcolor="#FFFFFF" valign="top">
<tr>
$buddyhtml
<td width="100%"><b>$subject</b></td>
</tr>
<tr>
<td colspan="3">$message</td>
</tr>
</table>
HTML

exit;
}
sub buddys {
my $buddyhtml = <<HTML;
<tr class="tbl_row_light">
<td colspan="2">
<a href="#veiw" onclick="changemessage('$cfg{pageurl}/index.$cfg{ext}?op=send_pm,PM;to=3');">Report a Problem</a>
</td>
</tr>
<tr class="tbl_row_light">
<td colspan="2">
<a href="#veiw" onclick="changemessage('$cfg{pageurl}/index.$cfg{ext}?op=send_pm,PM;to=3');">Make a Suggestion</a>
</td>
</tr>
<tr class="tbl_row_light">
<td colspan="2">
<a href="#veiw" onclick="changemessage('$cfg{pageurl}/index.$cfg{ext}?op=send_pm,PM;to=3');">Ask a question</a>
</td>
</tr>
<tr class="tbl_row_light">
<td colspan="2">
<a href="#veiw" onclick="changemessage('$cfg{pageurl}/index.$cfg{ext}?op=send_pm,PM;to=3');">Contact us</a>
</td>
</tr>
HTML

print "Content-type: text/html\n\n";
#print box_script();
print <<HTML;
<br />
<table border="0" cellspacing="2" width="65%" cellpadding="3">
<tr class="bg2">
<td colspan="2"><b>Help Desk Contacts</b></td>
</tr>
$buddyhtml
</table>
<br />
HTML

 exit;

}
#sub add_buddy {
#if (!$to) {
#                $Flex_WPS->user_error(
#                        error => $err{user_no_exist},
#                        );
#                }
##require get_user;
#my $check_user = check_user($to, '1');
#if (!$check_user) {
#                $Flex_WPS->user_error(
#                        error => $err{user_no_exist},
#                        );
#        }
## Check if current member has buddy in profile.
#if ($user_data{buddys} =~ s/$to\,//
#|| $user_data{buddys} =~ s/\,$to//
#|| $user_data{buddys} =~ s/$to//) {
#$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE members SET rib='$user_data{buddys}' WHERE memberid='$user_data{id}' LIMIT 1 ;");
#} else {
## add it
#if ($user_data{buddys}) { $user_data{buddys} .= ',' . $check_user; }
#else { $user_data{buddys} = $check_user; }
#$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE members SET rib='$user_data{buddys}' WHERE memberid='$user_data{id}' LIMIT 1 ;");
#}
#print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=view_pm,PM');
#}
# Send PM
sub send_pm {
my ($temp_subject, $temp_message) = ('', '');

if ($quote) {
my $query1;
if (!$subject) { $query1= "SELECT * FROM pmin WHERE id='$id' AND (memberid='$user_data{id}' OR posterid ='$user_data{id}')"; }
else { $query1= "SELECT * FROM pmout WHERE id='$id' AND (memberid='$user_data{id}' OR posterid ='$user_data{id}')"; }
my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute;

while(my @row = $sth->fetchrow) {
$temp_subject = 'Re: ' . $row[4];
$temp_message = $row[5];
$temp_message = "[quote=*to\]" . $temp_message . "\[/quote\]";
$temp_message = $AUBBC_mod->html_to_text($temp_message);
}
$sth->finish();
}
# Print list of available users.
my ($selected,$members) = ('', '<select name="to">');

if (!$to) {
   $members = '<input type="text" name="to" value="" size="40" maxlength="50" />';
 }
  elsif ($to) {
  my $user_id = check_user($to, '');
  $user_id =~ s/\A([^<]+)\<.*?\z/$1/g;
  $temp_message =~ s/\*to/$user_id/;
  $members .= "<option value=\"$user_id\"$selected>$user_id</option>\n" if $user_id;
  $members .= "</select>";
  }

        # Generate the UBBC panel.
        require UBBC;
        my $ubbc_panel = UBBC::print_ubbc_panel();

# New: Supports IE# cache disabling for AJAX
 print $query->header(
        -expires => 'now',
        -charset => $cfg{codepage},
        -cache_con => 'no-store, no-cache, must-revalidate', # HTTP/1.1
        -cache => 1, # HTTP/1.0
 );
print <<HTML;
<div id="sdmsg"> </div><br />
<a href="javascript:void(0)" onclick="closeMessage('messageview');"><img align="right" src="$cfg{imagesurl}/button_cance.png" alt="Close_Send" border="0" /></a>
<table width="100%" border="0" cellspacing="0" cellpadding="1">
<tr>
<td><form action="javascript:void(0)" method="post" name="creator" onsubmit="SubmitMyForm(this); return false;">
<table border="0" align="center">
<tr>
<td><font size="2"><b>$msg{to_userC}</b></font></td>
<td>
$members
</td>
</tr>
<tr>
<td><font size="2"><b>$msg{subjectC}</b></font></td>
<td><input type="text" name="subject" value="$temp_subject" size="40" maxlength="50" /></td>
</tr>
<tr>
<td valign="top"><font size="2"><b>$msg{textC}</b></font></td>
<td>
<textarea wrap="off" id="edit" name="message" style="width: 450px; height: 200px;">$temp_message</textarea></td>
</tr>
<tr>
<td valign="top"><font size="2"><b>$msg{ubbc_tagsC}</b></font></td>
<td valign="top"><font size="2">$ubbc_panel</font></td>
</tr>
<tr>
<td colspan="2" align="center"><input type="hidden" name="op" value="save_pm,PM" />
<input type="submit" value="$btn{send_message}" />
<input type="reset" value="$btn{reset}" /></td>
</tr>
</table></form>
</td>
</tr>
</table>
HTML

}

# Print New PM Alert
#sub pm_alert {
#my $pmlist = '';
#my $printlist = '';
#my $incount = 0;

#if ($user_data{uid} ne $usr{anonuser}) {
##require theme;
# # Text and word Wrap, default Perl Module!
# use Text::Wrap;
# $Text::Wrap::columns = 25; # Wrap at 25 characters for menu

#my $query1 = "SELECT * FROM pmin WHERE memberid='$user_data{id}'";
#my $sth = $dbh->prepare($query1);
#$sth->execute || die("Couldn't exec sth!");
#while(my @row = $sth->fetchrow) {
## build message
#if ($row[6]) { $incount++;
#my $subject = wrap('', '', $row[4]);
#$pmlist .= $Flex_WPS->menu_item("$cfg{pageurl}/index.$cfg{ext}?op=view_pm", $subject, '', "forum/exclamation.gif");
# }
#}
#$sth->finish(); #}
#if ($incount) {
#$printlist = $Flex_WPS->box_header("$incount Private Message Alert");
#$printlist .= $pmlist;
#$printlist .= $Flex_WPS->box_footer();
#print $printlist;
# }
#}
#}
#
# Check Max messages
#
sub check_messages {
my ($from, $other, $backend, $theme) = @_;
my $outcount = 0;
my $incount = 0;
# Get private messages for user
my $query1 = "SELECT * FROM pmout WHERE memberid='$from'";
my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
# build message
if ($row[0]) { $outcount++; }
}
$sth->finish();
if ($outcount >= $max_stmessages) {
                $Flex_WPS->user_error(
                        error => 'You Need to Delete Messages From Your Sent PM\'s',
                        );
               }
$query1 = "SELECT * FROM pmin WHERE memberid='$other'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
# build message
if ($row[0]) { $incount++; }
}
$sth->finish();
if ($incount >= $max_messages) {
                $Flex_WPS->user_error(
                        error => 'Members Inbox is Full, Try Their Email.',
                        );
                }
}
#
# Save Pivate Message
#
sub save_pm {
# Check if user is logged in.
if (!$to) {
print "Content-type: text/html\n\n";
print "<big><b>$err{user_no_exist}</b></big>";
exit;
        }
if (!$subject) {
print "Content-type: text/html\n\n";
print "<big><b>$err{enter_subject}</b></big>";
exit;
                }
if (!$message) {
print "Content-type: text/html\n\n";
print "<big><b>$err{enter_text}</b></big>";
exit;
                }

#require get_user;
my $selected = check_user($to, 2) || '';
if(!$selected) {
print "Content-type: text/html\n\n";
print "<big><b>$err{user_no_exist}</b></big>";
exit;
                }
                use URI::Escape;
                $message  = uri_unescape($message);
# Check Max messages
check_messages($user_data{id}, $to);
# Format the input.
$subject = $AUBBC_mod->script_escape($subject);
$message = $AUBBC_mod->script_escape($message);
$subject = $back_ends{$cfg{Portal_backend}}->quote($subject);
$message = $back_ends{$cfg{Portal_backend}}->quote($message);
# Get the current date.
my $date = $Flex_WPS->get_date();
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO pmin VALUES (NULL,'$selected','$user_data{id}','$date',$subject,$message,'1');");
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO pmout VALUES (NULL,'$user_data{id}','$selected','$date',$subject,$message);");
print "Content-type: text/html\n\n";
print "<big><b>Message Was Sent</b></big>";
exit;
}
sub delete_pm {
# Get private messages for user
# Check if user is logged in.
my $query1;
my @checked = ();
my @params = split(/\000\000/, $query->param_more('id'));
if (!$quote) { $query1 = "SELECT * FROM pmin WHERE memberid='$user_data{id}'"; }
else {$query1 = "SELECT * FROM pmout WHERE memberid='$user_data{id}'"; }

my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
 foreach (@params) {
  if ($row[0] eq $_) {
   if (@checked) {
    @checked = (@checked, $row[0]);
   }
    else { @checked = ($row[0]); }
  }
 }
}
$sth->finish();

foreach (@checked) {
if (!$quote) {
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM pmin WHERE id='$_' AND memberid='$user_data{id}'");
}
else {
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM pmout WHERE id='$_' AND memberid='$user_data{id}'");
}

}
print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=view_pm,PM;quote=' . $quote);
}
# delete 2
sub delete_pm2 {
# Check if user is logged in.
if (!$id) {
                $Flex_WPS->user_error(
                        error => $err{bad_input},
                        );
                }

if (!$quote) {
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM pmin WHERE id='$id' AND memberid='$user_data{id}'");
}
else {
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM pmout WHERE id='$id' AND memberid='$user_data{id}'");
}

print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=in_out_boxs,PM;quote=' . $quote);
}

sub profile {
my $memid = shift;
return '' unless $memid;
return '' unless ($memid =~ m!^([0-9]+)$!i);
my $userhtml = '';
my @user_data = ('', '');
my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT `uid`, `nick` FROM `members` WHERE `memberid` = '$memid' LIMIT 1 ;");
$sth->execute;
@user_data = $sth->fetchrow;
$sth->finish();
$userhtml = $user_data[0] . '<small>/(' . $user_data[1] . ')</small>' if $user_data[0] && $user_data[1];

 return $userhtml;
}

# Qiuck check user & return the name
sub check_user {
my ($memid, $option) = @_;
return '' unless $memid;
my $check = 0;
my $query1 = "SELECT uid, nick FROM members WHERE memberid='$memid'";
$query1 = "SELECT memberid FROM members WHERE memberid='$memid'" if $option eq 1;
$query1 = "SELECT memberid FROM members WHERE uid='$memid'" if $option eq 2;
my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute || die("Couldn't exec sth!");
while(my @user_data = $sth->fetchrow)  {
$check = $user_data[0];
$check .= '<small>/(' . $user_data[1] . ')</small>' if $user_data[1];
 }
 $sth->finish();
return '' unless $check;
return $check;
}
1;
