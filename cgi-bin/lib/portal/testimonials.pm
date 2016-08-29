package testimonials;

use strict;
use warnings;
# Assign global variables.
# This package only needs these variables, not all in Flex_Porter.pm
use vars qw(
    %nav %cfg $query %user_action %err
    $Flex_WPS $AUBBC %usr %back_ends
    %user_data
    );
# Keeps values of above variables in scope.
use Flex_Porter;

# sub's the portal will print and the commen security level of the area.
# ?op=subroutine,package
%user_action = (
view    => $usr{anonuser},
send_it => $usr{anonuser},
good    => $usr{anonuser},
bad     => $usr{anonuser},
agood   => $usr{admin},
abad    => $usr{admin},
comment => $usr{admin},
comment2 => $usr{admin},
import_demandforce_reviews => $usr{admin},
);

# Display the reviews and review form
sub view {
        # require "$cfg{portaldir}/Captcha.pm";
        # my $Imagehtml = Captcha::get_image();

#### Start Form HTML
my $form_html = <<"HTML";
<b><a class="pure-button pure-button-active" id="displayText" href="javascript:toggleDiv('toggleText','displayText');">Submit your review</a></b>
<hr />

<div id="toggleText" style="display: none">
<span class="big">Submit your review:</span> <small>( * Required fields )<br />
Your email will remain private and will not be posted for the public to see!</small>
<form class="pure-form" name="form" method="post">
    <fieldset class="pure-group">
       <input class="pure-input-1" type="text" name="name" placeholder="Name*">
       <input class="pure-input-1" type="email" name="email" placeholder="Email*">
       <input class="pure-input-1" type="text" name="site" placeholder="Website">
       </fieldset>

        <span class="rating">
        <input type="radio" class="rating-input" id="rating-input-1-5" name="rating-input-1" value="5" />
        <label for="rating-input-1-5" class="rating-star"></label>
        <input type="radio" class="rating-input" id="rating-input-1-4" name="rating-input-1" value="4" />
        <label for="rating-input-1-4" class="rating-star"></label>
        <input type="radio" class="rating-input" id="rating-input-1-3" name="rating-input-1" value="3" />
        <label for="rating-input-1-3" class="rating-star"></label>
        <input type="radio" class="rating-input" id="rating-input-1-2" name="rating-input-1" value="2" />
        <label for="rating-input-1-2" class="rating-star"></label>
        <input type="radio" class="rating-input" id="rating-input-1-1" name="rating-input-1" value="1" />
        <label for="rating-input-1-1" class="rating-star"></label>
        </span>

        <fieldset class="pure-group">
           <input class="pure-input-1" type="text" name="title" placeholder="Review Title" />
           <textarea class="pure-input-1" placeholder="Review..." name="review" rows="10"></textarea>
           </fieldset>
        <div class="all-c">
        <div id="captimer"> </div><div id="captcha"> </div>
        <fieldset>
        <input type="hidden" value="send_it,testimonials" name="op" />
        <button type="submit" name="Send" class="pure-button pure-button-primary">Submit your review</button>
        </fieldset>
        </div>
</form>
<hr />
</div>

<script type="text/javascript">
//<![CDATA[
var milisec=0;
var seconds=300;
var seconds2=seconds;
function display(){
 if (countNow == 1) {
  if (seconds == seconds2) { document.getElementById('captimer').innerHTML="<b>Captcha Reload</b> "+seconds; }
  if (milisec == 0){ milisec=10; seconds-=1; }
  milisec-=1
  document.getElementById('captimer').innerHTML="<b>Captcha Reload</b> "+seconds+"."+milisec;
  if (seconds == 0 && milisec == 0) {
   url = '$cfg{pageurl}/index.$cfg{ext}?op=ajax_get,Captcha';
   seconds=seconds2;
   countNow = '';
   doAjaxRequest(url, processReqChangeMany, '', 'captcha', countdownStart);
    }
 } else {
  document.getElementById('captimer').innerHTML="<b>Loading Captcha....</b>";
 }
 setTimeout("display()",100);
}
display();
//]]>
</script>
HTML
#(`id`, `name`, `title`, `website`, `review`, `email`, `rating`, `date`, `approved`)

# Get active reviews
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM `testimonials` WHERE `approved` = 'c' ORDER BY `date` DESC ;");
$sth->execute;
my @row = ('','','','','','','','','');
my @review_ids = ();
my $admin_link = '';
while(@row = $sth->fetchrow) {
$row[6] = 3*16 if !$row[6];
$row[6] = 1*16 if $row[6] eq 1;
$row[6] = 2*16 if $row[6] eq 2;
$row[6] = 3*16 if $row[6] eq 3;
$row[6] = 4*16 if $row[6] eq 4;
$row[6] = 5*16 if $row[6] eq 5;
my $format_date = $Flex_WPS->format_date($row[7], 6); # date
$format_date =~ s/\A(?:.*?) (\w+\s\d{4}\z)/$1/g;
$row[2] = "<b>$row[2]</b>" if $row[2];
push (@review_ids, $row[0]);

$admin_link = " <small><a class=\"pure-button pure-button-active\" href=\"$cfg{pageurl}/index.$cfg{ext}?op=abad,testimonials;email=$row[5]\" onclick=\"return ConfirmDelete();\">(Delete This Review)</a></small>"
 if $Flex_WPS->check_access(
 class_sub => 'testimonials::view-adminlink',
 sec_lvl   => $usr{admin},
 );
 
$form_html .= <<"HTML";
$row[2]$admin_link<br />
<div style="width:80px;" class="rating-star-empty" >
<div style="width:$row[6]px;" class="rating-star-full" ></div>
</div> <small>&nbsp;&nbsp;$format_date <i>by ($row[1]) $row[3]</i></small><br />
$row[4]<br />
<!--comment$row[0]-->
<hr />
HTML
@row = ('','','','','','','','','');
$admin_link = '';
}
$sth->finish();

# Get comments
if (@review_ids) {
foreach my $index (@review_ids) {
  $sth = $back_ends{$cfg{Portal_backend}}->prepare(
  "SELECT * FROM `testimonials` WHERE `approved` = '$index' LIMIT 1 ;");
  $sth->execute;
  while(@row = $sth->fetchrow) {
  if ($row[1] eq 'comment') {
   $row[4] = $AUBBC->parse_bbcode($row[4]);
   $form_html =~ s/<!--comment$index-->/<blockquote>
<small><b>Comment<\/b><\/small><br \/>
$row[4]<br \/>
<small>-- $cfg{pagename}<\/small>
<\/blockquote>/gs;
   }
  }
  $sth->finish();
  @row = ('','','','','','','','','');
 }
}
# Add comments link for admins
if($user_data{sec_level} eq $usr{admin}) {
   $form_html =~ s/<!--comment(\d+)-->/<blockquote>
<small><b><a class="pure-button pure-button-active" href="$cfg{pageurl}\/index.$cfg{ext}?op=comment,testimonials;id=$1">Add Comment<\/a><\/b><\/small><br \/>
<\/blockquote>/gs;
}

#### End Form HTML
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

        my $message2 = <<"EOT";
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
my $string = <<"HTML";
Date: $format_date
IP: $ENV{REMOTE_ADDR}
Name: $name
Website: $site
Review Title: $title
Rating: $rating
Review: $review
HTML

$name = $back_ends{$cfg{Portal_backend}}->quote($AUBBC->script_escape($name));
$title = $back_ends{$cfg{Portal_backend}}->quote($AUBBC->script_escape($title));
$site = $back_ends{$cfg{Portal_backend}}->quote($AUBBC->script_escape($site));
$review = $back_ends{$cfg{Portal_backend}}->quote($AUBBC->script_escape($review));
$email = $back_ends{$cfg{Portal_backend}}->quote($email);
$rating = $back_ends{$cfg{Portal_backend}}->quote($rating);
$date = $back_ends{$cfg{Portal_backend}}->quote($date);
#(`id`, `name`, `title`, `website`, `review`, `email`, `rating`, `date`, `approved`)
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO `testimonials` VALUES (NULL, $name, $title, $site, $review, $email, $rating, $date, 'a');");
# log review
$string = $back_ends{$cfg{Portal_backend}}->quote($string);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO `recommend_log` VALUES (NULL,$string);");

      my $form_html = <<"HTML";
<div class="big"><b>Please check your email and authorize the review you have submited.<br />
You can decline the review in the email and start over.</b>
</div>
<div class="big all-c">Your email is only used to authorize your review.</div>
Thank You,<br />
$cfg{homeurl}<br />
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
"SELECT * FROM testimonials WHERE `email` = $id AND `approved` = 'a' LIMIT 1 ;");
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

        my $message2 = <<"EOT";
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
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE testimonials SET `approved` = 'b' WHERE `email` = $email LIMIT 1 ;");

      my $form_html = <<"HTML";
<div class"big">
<b>You have authorize a review for $cfg{pagename}.<br />
An administrator will approve it and it will soon display on our site.</b><br /><br />
Thank you for submitting your review for $cfg{pagename} at $cfg{homeurl}.<br /><br />
We hope to see you again.
</div>
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
"SELECT * FROM testimonials WHERE `email` = $id  AND `approved` = 'a' LIMIT 1 ;");
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


my $form_html = <<"HTML";
<div class"big"><b>You have declined a review for $cfg{pagename}.<br />
The review has been removed and you can make a new review if you want.</b><br /><br />
Thank you for submitting your review for $cfg{pagename} at $cfg{homeurl}.<br /><br />
We hope to see you again.<br />
</div>
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
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE testimonials SET `approved` = 'c' WHERE `email` = $email LIMIT 1 ;");
}

my $form_html = <<"HTML";
<div class"big">
<b>You have Approved a review for $email.<br />
It will now display on the website.</b><br /><br />
Thank you.
</div>
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
my @row = ();
if ($email) {

my $id = $back_ends{$cfg{Portal_backend}}->quote($email);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT `id` FROM testimonials WHERE `email` = $id LIMIT 1 ;");
$sth->execute;
@row = $sth->fetchrow;
$sth->finish();
 if ($row[0]) {
  $id = $back_ends{$cfg{Portal_backend}}->quote($row[0]);
  $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM testimonials WHERE `approved` = $id");
  $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM testimonials WHERE `id` = $id");
 }
}

my $form_html = <<"HTML";
<div class"big">
<b>You have Deleted a review for $email.<br />
It will not display on the website and the email can make a new post.</b><br /><br />
Thank you.
</div>
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

sub comment {
my $id = $query->param('id') || '';
my @row = ();
$id = '' if $id && $id !~ m/\A[\d]+\z/;
if ($id) {
my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
"SELECT * FROM testimonials WHERE `id` = '$id'  AND `approved` = 'c' LIMIT 1 ;");
$sth->execute;
@row = $sth->fetchrow;
$sth->finish();
}
my $form_html = <<"HTML";
<div class"big"><b>Admin Comment</b></div>
Email: $row[5]<br />
Website: $row[3]<br />
Name: $row[1]<br />
Rating: $row[6] stars<br />
Title: $row[2]<br />
Review:<br />
$row[4]
<form name="form" method="post" action="" onclick="javascript:return confirm('Are you sure you want to add a Comment?')">
<table width="100%" border="0" cellpadding="2" cellspacing="2">
<tr valign="top">
<td width="168">&nbsp;</td>
<td width="362"><b><big>Submit your Comment:</big></b></td>
</tr>

<tr valign="top">
<td width="168" align="right">Comment:
</td>
<td width="362"><textarea wrap="off" name="comment" rows="10" cols="57"></textarea>
</td>
</tr>
</table>
<center>
<input type="submit" name="Send" value="Submit your comment" />
<input type="hidden" value="$id" name="id" />
        <input type="hidden" value="comment2,testimonials" name="op" /></center>
</form>
HTML

$Flex_WPS->print_page(
        markup       => $form_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Review Admin Comment',
        );
        
}

sub comment2 {
my $id = $query->param('id') || '';
$id = '' if $id && $id !~ m/\A\d\z/;
my $comment = $query->param('comment') || '';

$comment = $back_ends{$cfg{Portal_backend}}->quote($AUBBC->script_escape($comment));
$id = $back_ends{$cfg{Portal_backend}}->quote($id);
my $date = $Flex_WPS->get_date();
$date = $back_ends{$cfg{Portal_backend}}->quote($date);
#(`id`, `name`, `title`, `website`, `review`, `email`, `rating`, `date`, `approved`)
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO `testimonials` VALUES (NULL, 'comment', 'comment', 'comment', $comment, 'comment', 'comment', $date, $id);");

# Redirect to main view.
print $query->redirect(
 -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=view,testimonials'
 );
}

sub import_demandforce_reviews {
# you will have to copy to clipboard the reviews through your browser
# and paste the text in a text file.
# Then edit your file path
# First row should start with the number: # stars  Customer_Name Verified customer
use Time::Local qw( timelocal_nocheck );
my ($day, $month, $year);
my $review_file = 'C:/xampp/cgi-bin/Flex2/lib/reviews.txt';
my $file_data = $Flex_WPS->file2array($review_file, 1);
# look_for = stars&name, review&date, comment, import_review
my $look_for = 'stars';
my ($stars,$name,$review,$date,$comment) = ('','','','','');
my $built = '';
if(scalar @{$file_data} == 0) {
  $built = 'none';
} else {
foreach my $line (@{$file_data}) {
        next if ($line =~ m/\A\n\z/ || ! $line);
        if ($look_for eq 'stars'
        && $line =~ m/\A(\d) stars  (.*?) Verified customer/i) {
         $stars = $1;
         $name = $2;
         $look_for = 'review';
         next;
        }
        if ($look_for eq 'review'
        && $line !~ m/\A(?:\d+|a) (?:months|years|year)/i) {
          $review .= ' '.$line;
          next;
        }
        elsif ($look_for eq 'review'
        && $line =~ m/\A(\d+|a) (months|years|year)/i) {
         my $now = time;
         ($day, $month, $year) = (localtime($now))[3, 4, 5];
          if ($2 eq 'months') {
           $year -= 1 if $1 >= 5;
           $month -= $1;
          }
          elsif ($2 eq 'years' || $2 eq 'year') {
            $1 eq 'a'
            ? $year -= 1
            : $year -= $1;
          }

         $date = timelocal_nocheck(0, 0, 0, ,$day, $month, $year);
         #($day, $month, $year) = (localtime($new_time))[3, 4, 5];
        $look_for = 'comment';
        next;
        }
        next if ($look_for eq 'comment'
        && $line =~ m/\A\s(?:.*?) replied:/i);
        if ($look_for eq 'comment'
        && $line !~ m/\A(?:\d) stars  (?:.*?) Verified customer/i) {
         $comment .= ' '.$line;
         next;
        }
        elsif ($look_for eq 'comment'
        && $line =~ m/\A(\d) stars  (.*?) Verified customer/i) {
        my $format_date = $Flex_WPS->format_date($date, 6);
        $built .= <<HTML;
stars $stars <br />
name $name <br />
review $review<br />
date $date   <br />
format_Date $format_date <br />
comment $comment <br /><br />
HTML

my $id = '';
$date = $back_ends{$cfg{Portal_backend}}->quote($date);
if ($comment) {
my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SHOW TABLE STATUS LIKE 'testimonials'");
$sth->execute;
while(my @row = $sth->fetchrow)  {
$id = $row[10];
}
$sth->finish;
$comment = $back_ends{$cfg{Portal_backend}}->quote($AUBBC->script_escape($comment));
}

$review = $back_ends{$cfg{Portal_backend}}->quote($AUBBC->script_escape($review));
$name = $back_ends{$cfg{Portal_backend}}->quote($AUBBC->script_escape($name));
$stars = $back_ends{$cfg{Portal_backend}}->quote($stars);
# needs to go first for next auto index
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO `testimonials` VALUES (NULL, $name, '', '', $review, '', $stars, $date, 'c');");
# needs to be last
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO `testimonials` VALUES (NULL, 'comment', 'comment', 'comment', $comment, 'comment', 'comment', $date, '$id');")
 if $comment;

         $stars = $1;
         $name = $2;
         $review = '';
         $date = '';
         $comment = '';
         $look_for = 'review';
         next;
        }
 }

}
 $Flex_WPS->print_page(
        markup       => $built,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Review Admin Import',
        );
}

1;

__END__

=pod

=head1 COPYLEFT

testimonials.pm, v1.1 with Captcha 05/16/2016 N.K.A.
Works with Flex-WPS Evolution 3 v1.0 series

v1.1 - Added Comments to reviews
- Can delete review with comment
- has no edit comments and reviews

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

Main Developer:
 N.K.A.
 shakaflex [at] gmail.com
 https://github.com/sflex/flex-wps
 http://search.cpan.org/~sflex/

=cut
