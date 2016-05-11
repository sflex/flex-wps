package recommend;
# recommend.pm v1.21 - see bottum for more.

# Load necessary modules.
use strict;
# Assign global variables.
use vars qw(
    $query $Flex_WPS %back_ends $AUBBC_mod
    %user_data
    %user_action %err %usr %cfg %nav %msg %btn
    %inf
    );
use exporter;

%user_action = (
        email => $usr{anonuser},
        email2 => $usr{anonuser},
        admin => $usr{admin},
        empty => $usr{admin},
        );

# Get the input.
my $yourname = $query->param('yourname');
my $youremail    = $query->param('youremail');
my $frname = $query->param('frname');
my $fremail    = $query->param('fremail');
#$id       = $query->param('id');

my $date_captcha = $query->param('date_captcha');
my $security_key = $query->param('security_key');

$security_key = $Flex_WPS->untaint2(value => $security_key) if $security_key;
$date_captcha = $Flex_WPS->untaint2(value => $date_captcha) if $date_captcha;

sub email {

         require "$cfg{portaldir}/Captcha.pm";
         my $Imagehtml = Captcha::get_image();
            # class="bg6" tbl_row_light
        my $html_page = <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><big><strong>Recommend This Site to a Friend</strong></big><br /><br />
<strong>Please fill in the correct information so you don't get an error.
All form fields below are required.</strong>
</td>
</tr></table>
<hr />
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td>
<form method="post" action="$cfg{pageurl}/index.$cfg{ext}">
<table border="0" cellspacing="2" cellpadding="3" width="60%">
  <tr>
    <td class="tbl_row_dark"><b>Your Name:</b></td>
    <td class="tbl_row_light"><input type="text" name="yourname" size="30" maxlength="55" /></td>
   </tr>
  <tr>
    <td class="tbl_row_dark"><b>Your Email:</b></td>
    <td class="tbl_row_light"><input type="text" name="youremail" size="30" maxlength="55" /></td>
   </tr>
  <tr>
    <td class="tbl_row_dark"><b>Friends Name:</b></td>
    <td class="tbl_row_light"><input type="text" name="frname" size="30" maxlength="55" /></td>
   </tr>
  <tr>
    <td class="tbl_row_dark"><b>Friends Email:</b></td>
    <td class="tbl_row_light"><input type="text" name="fremail" size="30" maxlength="55" /></td>
   </tr>
  <tr>
</table>
<table border="0" cellspacing="2" cellpadding="3" width="70%">
  <tr>
    <td>$Imagehtml<input type="hidden" name="op" value="email2,recommend" /><input type="submit" value="Send Recommend" /></td>
  </tr>
</table>
</form>
</td>
</tr></table>
HTML

$Flex_WPS->print_page(
        markup       => $html_page,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Recommend This Site',
        );

}

sub email2 {
my $bad_msg = '';

require "$cfg{portaldir}/Captcha.pm";
my $secret_images = '';
$secret_images = Captcha::get_image(1, $security_key, $date_captcha) if ($security_key && $date_captcha);

$bad_msg = 1 if (! $secret_images || ! $security_key || ! $date_captcha);

if (!$youremail || $youremail !~ m/\A[a-z\d\.\-\_\&]+\@[a-zA-Z\d\.\-\_]+\z/i) {
$Flex_WPS->user_error(
        error => $err{bad_input},
        );
        $bad_msg = 1;
}
if (!$fremail || $fremail !~ m/\A[a-z\d\.\-\_\&]+\@[a-zA-Z\d\.\-\_]+\z/i) {
$Flex_WPS->user_error(
        error => $err{bad_input},
        );
        $bad_msg = 1;
}
$yourname = $Flex_WPS->untaint2(value => $yourname) if $yourname;
$frname = $Flex_WPS->untaint2(value => $frname) if $frname;
if (!$yourname && !$bad_msg) {
$Flex_WPS->user_error(
        error => $err{bad_input},
        );
        $bad_msg = 1;
}
if (!$frname && !$bad_msg) {
$Flex_WPS->user_error(
        error => $err{bad_input},
        );
        $bad_msg = 1;
}

if ($bad_msg) {
$Flex_WPS->user_error(
        error => $err{not_writable},
        );
}
 else {
        # Generate info email.
        my $subject = "$yourname, is recommending a web site to $frname.";
        my $message = <<EOT;
        Dear $frname,

        $yourname is recommending web site $cfg{cgi_bin_url}/index.$cfg{ext} to you.
Please visit the web site if you are interested.


E-mail was sent from: $cfg{cgi_bin_url}/index.$cfg{ext}
If you have received this email in error or spam, please contact the above sites administrator.
We will resolve the issues you are having with this message.
EOT

my $date = $Flex_WPS->format_date($Flex_WPS->get_date(), 3);
my $string = <<HTML;
Date: $date
Guest $ENV{'REMOTE_ADDR'}
$yourname $youremail
$frname $fremail
HTML
$string = $back_ends{$cfg{Portal_backend}}->quote($string);

$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO `recommend_log` VALUES (NULL,$string);");
# Send the email to recipient.
 my $email_ok = $Flex_WPS->send_email(
        from => $youremail,
        to => $fremail,
        subject => $subject,
        message => $message,
        ) || '';
        
if ($email_ok) {
 $message = $AUBBC_mod->script_escape($message);
 $message = $AUBBC_mod->do_all_ubbc($message);
}
my $html_page = <<HTML;
<b>Your recommend request was sent successfully!</b><br />
The message sent to your friend was:<br />
<blockquote><b>Subject:</b> $subject<br />
<b>Message:</b> $message</blockquote>
HTML

$html_page = 'Your request could not be sent, please try again later.' if ! $email_ok;
$Flex_WPS->print_page(
        markup       => $html_page,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Recommend This Site',
        );
 }
}

sub admin {
my $html_page = '<hr />';
my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM `recommend_log`");
$sth->execute;
while(my @row = $sth->fetchrow)  {
$html_page .= "$row[0], $row[1]<hr />";
}
$sth->finish;

$html_page = <<HTML;
<p><b>Recommend Admin</b> <a href="$cfg{pageurl}/index.$cfg{ext}?op=empty,recommend">Empty</a>
$html_page</p>
HTML

$Flex_WPS->print_page(
        markup       => $html_page,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Recommend Admin',
        );
}

sub empty {
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, 'TRUNCATE `recommend_log`');

# Redirect to user_actions page.
print $query->redirect(
 -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=admin,recommend'
 );
}

1;

__END__

=pod

=head1 COPYLEFT

recommend.pm, v1.21 with Captcha 01/10/2011 N.K.A.
Works with Flex-WPS Evolution 3 v1.0 series

CREATE TABLE `recommend_log` (
  `id` smallint(5) unsigned NOT NULL auto_increment,
  `text1` text collate latin1_general_ci,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci AUTO_INCREMENT=1 ;



Flex Web Portal System Evolution 3

Main Developer:
 N.K.A.
 shakaflex [at] gmail.com
 http://search.cpan.org/~sflex/

=cut
