package testimonials;

use strict;

# Assign global variables.
use vars qw(
    %nav %cfg $query %user_action %err
    $Flex_WPS $AUBBC_mod %usr %back_ends
    );

use exporter;

%user_action = (
view => $usr{anonuser},
send_it => $usr{anonuser},
good => $usr{anonuser},
bad => $usr{anonuser},
agood => $usr{admin},
abad => $usr{admin},
);

sub view {
         require "$cfg{portaldir}/Captcha.pm";
         my $Imagehtml = Captcha::get_image();

#### Start Form HTML
my $form_html = <<HTML;
<style>
a.button5 {
    -webkit-appearance: button;
    -moz-appearance: button;
    appearance: button;

    text-decoration: none;
    color: initial;
}
</style>
<blockquote>
<b><a class="button5" id="displayText" href="javascript:toggleDiv('toggleText','displayText');">&nbsp;&nbsp;Submit your review&nbsp;&nbsp;</a></b>
<hr />
</blockquote>
<div id="toggleText" style="display: none">
<form name="form" method="post" action="">
<table width="100%" border="0" cellpadding="2" cellspacing="2">
<tr valign="top">
<td width="168">&nbsp;</td>
<td width="362"><b><big>Submit your review:</big></b> <small><i>(<font color="white">*</font> Required fields)</i><br />
Your email will remain private and will not be posted for the public to see!</small></td>
</tr>
<tr valign="top">
<td width="168" align="right">Name:</td>
<td width="362"><input name="name" /> <small><i><font color="white">*</font></i></small></td>
</tr>
<tr valign="top">
<td width="168" align="right">Email:</td>
<td width="362"><input name="email" /> <small><i><font color="white">*</font></i></small></td>
</tr>
<tr valign="top">
<td width="168" align="right">Website:</td>
<td width="362"><input name="site" /></td>
</tr>
<tr valign="top">
<td width="168" align="right">Review Title:</td>
<td width="362"><input name="title" /></td>
</tr>
<tr valign="top">
<td width="168" align="right">Rating:</td>
<td width="362">
<span class="rating">
        <input type="radio" class="rating-input"
    id="rating-input-1-5" name="rating-input-1" value="5" />
        <label for="rating-input-1-5" class="rating-star"></label>
        <input type="radio" class="rating-input"
                id="rating-input-1-4" name="rating-input-1" value="4" />
        <label for="rating-input-1-4" class="rating-star"></label>
        <input type="radio" class="rating-input"
                id="rating-input-1-3" name="rating-input-1" value="3" />
        <label for="rating-input-1-3" class="rating-star"></label>
        <input type="radio" class="rating-input"
                id="rating-input-1-2" name="rating-input-1" value="2" />
        <label for="rating-input-1-2" class="rating-star"></label>
        <input type="radio" class="rating-input"
                id="rating-input-1-1" name="rating-input-1" value="1" />
        <label for="rating-input-1-1" class="rating-star"></label>
</span>
</td>
</tr>
<tr valign="top">
<td width="168" align="right">Review:
</td>
<td width="362"><textarea wrap="off" name="review" rows="10" cols="57"></textarea>
</td>
</tr>
</table>
<center>
<div id="captimer"> </div><div id="captcha"> </div>
<input type="submit" name="Send" value="Submit your review" />
        <input type="hidden" value="send_it,testimonials" name="op" /></center>
</form>
<hr />
</div>

<script type="text/javascript">
//<![CDATA[
var milisec=0
var seconds=300
var seconds2=seconds
function coupon() {
 document.form.Coupon.value='checkbox';
}
function display(){
 if (countNow == 1) {
  if (seconds == seconds2) { document.getElementById('captimer').innerHTML="<b>Captcha Reload</b> "+seconds; }
  if (milisec == 0){
   milisec=10
   seconds-=1
  }
  milisec-=1
  document.getElementById('captimer').innerHTML="<b>Captcha Reload</b> "+seconds+"."+milisec
  if (seconds == 0 && milisec == 0) {
   url = '$cfg{pageurl}/index.$cfg{ext}?op=ajax_get,Captcha';
   seconds=seconds2
   countNow = '';
   doAjaxRequest(url, processReqChangeMany, '', 'captcha', countdownStart);
    }
 } else {
  document.getElementById('captimer').innerHTML="<b>Loading Captcha....</b>";
 }
 setTimeout("display()",100)
}
display();
//]]>
</script>
<blockquote>
HTML
#(`id`, `name`, `title`, `website`, `review`, `email`, `rating`, `date`, `approved`)

my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM `testimonials` WHERE `approved` = '2' ORDER BY `date` DESC ;");
$sth->execute;
my @row = ('','','','','','','','','');
while(@row = $sth->fetchrow) {
$row[6] = 3*16 if $row[6] eq 0;
$row[6] = 1*16 if $row[6] eq 1;
$row[6] = 2*16 if $row[6] eq 2;
$row[6] = 3*16 if $row[6] eq 3;
$row[6] = 4*16 if $row[6] eq 4;
$row[6] = 5*16 if $row[6] eq 5;
my $format_date = $Flex_WPS->format_date($row[7], 3); # date
$row[2] = "<b>$row[2]</b>" if $row[2];

$form_html .= <<HTML;
$row[2]<br />
<div style="width:80px;" class="rating-star-empty" >
<div style="width:$row[6]px;" class="rating-star-full" ></div>
</div> <small>&nbsp;&nbsp;$format_date <small><i>by ($row[1]) $row[3]</i></small></small><br />
$row[4]<br />
<hr />
HTML
@row = ('','','','','','','','','');
}
$sth->finish();
#### End Form HTML
$form_html .= '</blockquote>';
$Flex_WPS->print_page(
        markup       => $form_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => 'testimonials',
        navigation   => 'Testimonials',
        );
}

sub send_it {
my @ratings = ();

# inputs
my $name = $query->param('name') || '';
my $email = $query->param('email') || '';
my $site = $query->param('site') || '';
my $title = $query->param('title') || '';
my $review = $query->param('review') || '';
my $rating = $query->param('rating-input-1') || 0;


# For - Captcha Module
my $security_key  = $query->param('security_key');
my $date_captcha  = $query->param('date_captcha');

my $redirect_ok = '';
$redirect_ok = 1 if ! $name;
#$redirect_ok = 1 if $name !~ m/\A\w+\z/;
$redirect_ok = 1 if ! $review;
#$redirect_ok = 1 if $review !~ m/\A\w+\z/;

$redirect_ok = 1 if $rating && $rating !~ m/\A\d\z/;

$redirect_ok = 1 if $email && $email !~ m/\A[\w\.\-\&]+\@[\w\.\-]+\z/i;
$redirect_ok = 1 if ! $email;

         require "$cfg{portaldir}/Captcha.pm";
         my $secret_images = Captcha::get_image(1, $security_key, $date_captcha);
         if (!$secret_images) {
          $redirect_ok = 1;
         }

if ($email) {
my @row = ('','','','','','','','','');
my $id = $back_ends{$cfg{Portal_backend}}->quote($email);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM testimonials WHERE `email` = $id LIMIT 1 ;");
$sth->execute;
@row = $sth->fetchrow;
$sth->finish();
$redirect_ok = 1 if $row[0];
}

# no or bad input redirect
if($redirect_ok) {
  print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=view,testimonials');
}
 else {

    # Generate info email.
        my $date = $Flex_WPS->get_date();
        my $format_date = $Flex_WPS->format_date($date, 3); # date
        #my $catch_time = Flex_CGI::expires('now','');
        my $title2 = "Review Authorization Required";

        my $message2 = <<EOT;
This email was used to post a review at $cfg{homeurl}/
You can authorize the posting of this review or decline it to start new.
Your email is only used to authorize your review and will not be posted for the public to see.
On Date: $format_date
With IP: $ENV{REMOTE_ADDR}

Review Information:
Name: $name
Website: $site
Review Title: $title
Rating: $rating star
Review: $review

To authorize and post this review, use the link below.
$cfg{cgi_bin_url}/index.$cfg{ext}?op=good,testimonials;email=$email

To decline and delete this review, use the link below.
$cfg{cgi_bin_url}/index.$cfg{ext}?op=bad,testimonials;email=$email

For help or support: $cfg{webmaster_email}
E-mail was sent from: $cfg{homeurl}/
EOT

        # Send the email to recipient.
       # my $email_ok = 1;
        my $email_ok = $Flex_WPS->send_email(
                from => $cfg{webmaster_email},
                to => $email,
                subject => $title2,
                message => $message2,
        ) || '';
my $string = <<HTML;
Date: $format_date
IP: $ENV{REMOTE_ADDR}
Name: $name
Website: $site
Review Title: $title
Rating: $rating
Review: $review
HTML

$name = $back_ends{$cfg{Portal_backend}}->quote($AUBBC_mod->script_escape($name));
$title = $back_ends{$cfg{Portal_backend}}->quote($AUBBC_mod->script_escape($title));
$site = $back_ends{$cfg{Portal_backend}}->quote($AUBBC_mod->script_escape($site));
$review = $back_ends{$cfg{Portal_backend}}->quote($AUBBC_mod->script_escape($review));
$email = $back_ends{$cfg{Portal_backend}}->quote($email);
$rating = $back_ends{$cfg{Portal_backend}}->quote($rating);
$date = $back_ends{$cfg{Portal_backend}}->quote($date);
#(`id`, `name`, `title`, `website`, `review`, `email`, `rating`, `date`, `approved`)
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO `testimonials` VALUES (NULL, $name, $title, $site, $review, $email, $rating, $date, '0');");
# log review
$string = $back_ends{$cfg{Portal_backend}}->quote($string);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO `recommend_log` VALUES (NULL,$string);");

      my $form_html = <<HTML;
<blockquote><big><b>Please check your email and authorize the review you have submited.<br />
You can decline the review in the email and start over. </b>
<br /><br /></big>
<center><big><big>Your email is only used to authorize your review.</big></big></center>
<br /><br />
Thank You,<br />
$cfg{homeurl}
</blockquote>
HTML

$email_ok
 ? $Flex_WPS->print_page(
        markup       => $form_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Review Submit Thank You',
        )
 : $Flex_WPS->user_error(
        error => 'Message was not sent. Please contact the webmaster.',
        );
      }
}

sub good {
#(`id`, `name`, `title`, `website`, `review`, `email`, `rating`, `date`, `approved`)
my @row = ('','','','','','','','','');
my $email = $query->param('email') || '';
my $redirect_ok = '';
$redirect_ok = 1 if $email && $email !~ m/\A[\w\.\-\&]+\@[\w\.\-]+\z/i;
$redirect_ok = 1 if ! $email;

if ($email) {
my $id = $back_ends{$cfg{Portal_backend}}->quote($email);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM testimonials WHERE `email` = $id AND `approved` = '0' LIMIT 1 ;");
$sth->execute;
@row = $sth->fetchrow;
$sth->finish();
$redirect_ok = 1 if !$row[0];
}

if($redirect_ok) {
  print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=view,testimonials');
}
 else {
        # Generate info email.

        my $format_date = $Flex_WPS->format_date($row[7], 3); # date
        #my $catch_time = Flex_CGI::expires('now','');
        my $title2 = "Review Authorization Required";

        my $message2 = <<EOT;
This email wants to post a review at $cfg{homeurl}/
You can authorize the posting of this review or decline it.
You must login in as an administrator to approve reviews on the web site.
On Date: $format_date
With IP: $ENV{REMOTE_ADDR}

Review Information:
Email: $row[5]
Name: $row[1]
Website: $row[3]
Review Title: $row[2]
Rating: $row[6]
Review: $row[4]

To authorize and post this review, use the link below.
$cfg{cgi_bin_url}/index.$cfg{ext}?op=agood,testimonials;email=$row[5]

To decline and delete this review, use the link below.
$cfg{cgi_bin_url}/index.$cfg{ext}?op=abad,testimonials;email=$row[5]

For help or support: $cfg{webmaster_email}
E-mail was sent from: $cfg{homeurl}/
EOT
        #my $email_ok = 1;
        # Send the email to recipient.
        my $email_ok = $Flex_WPS->send_email(
                from => $cfg{webmaster_email},
                to => $cfg{webmaster_email},
                subject => $title2,
                message => $message2,
        ) || '';
$email = $back_ends{$cfg{Portal_backend}}->quote($row[5]);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE testimonials SET `approved` = '1' WHERE `email` = $email LIMIT 1 ;");

      my $form_html = <<HTML;
<blockquote><big><b>You have authorize a review for $cfg{pagename}.<br />
An administrator will approve it and it will soon display on our site.</b>
<br /><br /></big>
<big>Thank you for submitting your review for $cfg{pagename} at $cfg{homeurl}.
<br /><br />
We hope to see you again.
</big>
</blockquote>
HTML

$email_ok
 ? $Flex_WPS->print_page(
        markup       => $form_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Review Submit Thank You',
        )
 : $Flex_WPS->user_error(
        error => 'Message was not sent. Please contact the webmaster.',
        );
      }
      
}

sub bad {
#(`id`, `name`, `title`, `website`, `review`, `email`, `rating`, `date`, `approved`)
my @row = ('','','','','','','','','');
my $email = $query->param('email') || '';
my $redirect_ok = '';
$redirect_ok = 1 if $email && $email !~ m/\A[\w\.\-\&]+\@[\w\.\-]+\z/i;
$redirect_ok = 1 if ! $email;

if ($email) {
my $id = $back_ends{$cfg{Portal_backend}}->quote($email);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM testimonials WHERE `email` = $id  AND `approved` = '0' LIMIT 1 ;");
$sth->execute;
@row = $sth->fetchrow;
$sth->finish();
$redirect_ok = 1 if !$row[0];
}

if($redirect_ok) {
  print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=view,testimonials');
}
 else {
 
 $email = $back_ends{$cfg{Portal_backend}}->quote($email);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM testimonials WHERE `email` = $email");


my $form_html = <<HTML;
<blockquote><big><b>You have declined a review for $cfg{pagename}.<br />
The review has been removed and you can make a new review if you want.</b>
<br /><br /></big>
<big>Thank you for submitting your review for $cfg{pagename} at $cfg{homeurl}.
<br /><br />
We hope to see you again.
</big>
</blockquote>
HTML

$Flex_WPS->print_page(
        markup       => $form_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Review Submit Thank You',
        );
 }
}

sub agood {
my $email = $query->param('email') || '';
if ($email) {
$email = $back_ends{$cfg{Portal_backend}}->quote($email);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE testimonials SET `approved` = '2' WHERE `email` = $email LIMIT 1 ;");
}

my $form_html = <<HTML;
<blockquote><big><b>You have Approved a review for $email.<br />
It will now display on the website.</b>
<br /><br /></big>
<big>Thank you.</big>
</blockquote>
HTML

$Flex_WPS->print_page(
        markup       => $form_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Review Admin Approve',
        );
        
}

sub abad {
my $email = $query->param('email') || '';
if ($email) {
$email = $back_ends{$cfg{Portal_backend}}->quote($email);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM testimonials WHERE `email` = $email");
}

my $form_html = <<HTML;
<blockquote><big><b>You have Deleted a review for $email.<br />
It will not display on the website and the email can make a new post.</b>
<br /><br /></big>
<big>Thank you.</big>
</blockquote>
HTML

$Flex_WPS->print_page(
        markup       => $form_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Review Admin Approve',
        );
}

1;

__END__

=pod

=head1 COPYLEFT

testimonials.pm, v1.0 with Captcha 04/29/2016 N.K.A.
Works with Flex-WPS Evolution 3 v1.0 series

CREATE TABLE `testimonials` (
`id` smallint(5) unsigned NOT NULL,
  `name` varchar(150) COLLATE latin1_general_ci DEFAULT NULL,
  `title` varchar(150) COLLATE latin1_general_ci DEFAULT NULL,
  `website` varchar(150) COLLATE latin1_general_ci DEFAULT NULL,
  `review` text COLLATE latin1_general_ci,
  `email` varchar(100) COLLATE latin1_general_ci DEFAULT NULL,
  `rating` varchar(100) COLLATE latin1_general_ci DEFAULT NULL,
  `date` varchar(25) COLLATE latin1_general_ci DEFAULT NULL,
  `approved` varchar(25) COLLATE latin1_general_ci DEFAULT NULL
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci AUTO_INCREMENT=1 ;

INSERT INTO `flex`.`testimonials` (`id`, `name`, `title`, `website`, `review`, `email`, `rating`, `date`, `approved`) VALUES (NULL, 'fff', 'fff', 'fff', 'fff', 'fff', 'ff', 'date', '0');

Flex Web Portal System Evolution 3

Main Developer:
 N.K.A.
 shakaflex [at] gmail.com
 http://search.cpan.org/~sflex/

=cut
