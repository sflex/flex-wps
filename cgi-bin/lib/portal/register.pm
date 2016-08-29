package register;


#  register.pm
#  v2.0 11/08/2007 By:  N.K.A.
#  added ajax for user name register
#  This file is part of Flex WPS.
#  v1.0 - 85% complete 10/25/2007

# Load necessary modules.
use strict;
# Assign global variables.
use vars qw(
    $query $Flex_WPS %back_ends $AUBBC_mod
    $username $email
    %user_data
    %user_action %err %usr %cfg %nav %msg %btn
    %inf
    );
use Flex_Porter;

%user_action = (
        register => $usr{anonuser},
        register2 => $usr{anonuser},
        user_names => $usr{anonuser},
        );

# Get the input.
$username = $query->param('username');
$email    = $query->param('email');
#$id       = $query->param('id');

my $date_captcha = $query->param('date_captcha');
my $security_key = $query->param('security_key');

$security_key = $Flex_WPS->untaint2(value => $security_key) if $security_key;
$date_captcha = $Flex_WPS->untaint2(value => $date_captcha) if $date_captcha;
# ---------------------------------------------------------------------
# Display formula to register users.
# ---------------------------------------------------------------------
sub register {
        # Check if user is already logged in.
        if ($user_data{uid} ne $usr{anonuser}) {
        $Flex_WPS->user_error(
                error => $err{bad_input},
                );
        }

        my $html_page = <<"HTML";
<table width="100%" border="0" cellspacing="5" cellpadding="5">
<tr>
<td width="50%">
<table border="0" cellpadding="5" cellspacing="1" align="center" class="navtable2">
<tr>
<td><div id="CheckOK"> </div>
<p>Not a Member yet? You can be one for free. As a registered user you have some advantages like post listings with your account and more.
</p>
<form method="post" action="$cfg{pageurl}/index.$cfg{ext}" name="regform">
<table border="0" cellspacing="1">
<tr>
<td><b>$msg{usernameC}</b></td>
<td><input type="text" name="username" size="20" /> <a href="javascript:checkName(document.regform.username.value,'');">Check UserName</a></td>
</tr>
<tr>
<td><b>$msg{emailC}</b></td>
<td><input type="text" name="email" size="20" maxlength="100" /></td>
</tr>
<tr>
<td><a href="$cfg{pageurl}/index.$cfg{ext}?op=page,page;id=4" target="_blank"><b>Terms of use</b></a></td>
<td>Check this <input type="checkbox" name="id" value="a" /> to Agree to the <a href="$cfg{pageurl}/index.$cfg{ext}?op=page,page;id=4" target="_blank">Terms of use</a>.</td>
</tr>
<tr>
<td colspan="2"><br /><input type="hidden" name="op" value="register2,register" /><div id="captimer"> </div><div id="captcha"> </div><input type="submit" value="$btn{register}" />
<script type="text/javascript" language="JavaScript">
//<![CDATA[
 var milisec=0
 var seconds=300
 var seconds2=seconds
function display(){
if (countNow == 1) {
if (seconds == seconds2) {
       document.getElementById('captimer').innerHTML="<b>Captcha Expires</b> "+seconds;
}
 if (milisec == 0){
    milisec=10
    seconds-=1
 }
    milisec-=1
        document.getElementById('captimer').innerHTML="<b>Captcha Expires</b> "+seconds+"."+milisec
    if (seconds == 0 && milisec == 0) {
    url  =
      '$cfg{pageurl}/index.$cfg{ext}?op=ajax_get,Captcha';
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
</td>
</tr>
</table>
</form>
</td>
</tr>
</table></td>
<td width="50%">
<table width="150" border="0" cellspacing="0" cellpadding="0" align="center" class="navtable2">
<tr>
<td align="center" height="99" class="tbl_row_dark"><b>Member $nav{login}.</b><br>
<a href="$cfg{pageurl}/index.$cfg{ext}?op=login,Login">$nav{login}</a></td>
</tr>
</table>
</td>
</tr>
</table>
HTML

$Flex_WPS->print_page(
        markup       => $html_page,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => 'register_name',
        navigation   => $nav{login},
        );

}

# ---------------------------------------------------------------------
# Register a new user.
# ---------------------------------------------------------------------
sub register2 {
my $bad_msg = '';
my $terms_ok = '';
foreach (grep { /\w/ } $query->param('id')) {
$terms_ok = 1 if $_ eq 'a';
}
# Check if user is already logged in.
if ($user_data{uid} ne $usr{anonuser}) {
$Flex_WPS->user_error(
        error => $err{bad_input},
        );
}
 elsif (! $terms_ok) {
$Flex_WPS->user_error(error => 'To become a member you must agree to the Terms of use.',);
}
 elsif (!$username) { # Check input
$Flex_WPS->user_error(
        error => $err{enter_name},
        );
}
 elsif ($username !~ m/\A\w+\z/i
                || length($username) < 2
                || length($username) > 14
                || $username eq $usr{admin}
                || $username eq $usr{sadmin}
                || $username eq $usr{sfadmin}
                || $username eq $usr{mod}
                || $username eq $usr{user}
                || $username eq $usr{anonuser}
                || $username =~ m!\A\d+!i) {
$Flex_WPS->user_error(
        error => $err{enter_name},
        );
}
 elsif (!$email || $email !~ m/\A[a-z\d\.\-\_\&]+\@[a-zA-Z\d\.\-\_]+\z/i) {
$Flex_WPS->user_error(
        error => $err{enter_email},
        );
}
 else {
# Check if user name exists
my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM members WHERE uid='$username'");
$sth->execute;
my $name = '';
while(my @user_data = $sth->fetchrow)  {
if($user_data[2] eq $username) { $name = $user_data[2]; }
}
$sth->finish();
#Captcha
require "$cfg{portaldir}/Captcha.pm";
my $secret_images = Captcha::get_image(1, $security_key, $date_captcha);

if ($name) {
$Flex_WPS->user_error(
        error => $err{username_exists},
        );
}
 elsif (!$secret_images) {
$Flex_WPS->user_error(
        error => $err{auth_failure},
        );
}
 else {

        # Get censored words.
       # my $censored = file2array("$cfg{datadir}/censor.txt", 1);

        # Check for bad words.
#         foreach (@{$censored})
#         {
#                 my ($bad_word, $censored) = split (/\=/, $_);
#                 user_error($err{bad_username}, $user_data{theme})
#                     if ($username eq $bad_word);
#         }

        # Generate a password.
        my $password = '';
        rand(time ^ $$);
        my @seed = ('a' .. 'k', 'm' .. 'n', 'p' .. 'z', '2' .. '9');
        for (my $i = 0; $i < 8; $i++) {
                $password .= $seed[int(rand($#seed + 1))];
        }
        my $enc_password = $Flex_WPS->sha1_code(code1 => $password, code2 => $username,);

        # Get date.
        my $date = $Flex_WPS->get_date();


        # Generate info email.
        my $subject = $msg{welcome_to} . ' ' . $cfg{pagetitle};
        my $message = <<EOT;
$inf{account_created}
$msg{usernameC} $username
$msg{passwordC} $password

This Email was sent from: $cfg{cgi_bin_url}/index.$cfg{ext}.
EOT
        # Admin info
        my $Adsubject = 'New User at ' . $cfg{pagetitle};
        my $Admessage = <<EOT;
New user has registerd.
$msg{emailC} $email
$msg{usernameC} $username
$msg{passwordC} $password
Date: $date
IP: $ENV{'REMOTE_ADDR'}

This Email was sent from: $cfg{cgi_bin_url}/index.$cfg{ext}.
EOT

        # Send the email to recipient.
        # $Flex_WPS->send_email($cfg{webmaster_email}, $email, $subject, $message);
        my $mailtt = $Flex_WPS->send_email(
                from => $cfg{webmaster_email},
                to => $email,
                subject => $subject,
                message => $message,
        ) || '';
        # Send info mail to site admin.
        #$mailtt = $Flex_WPS->send_email($email, $cfg{webmaster_email}, $subject, $message);
        $mailtt = $Flex_WPS->send_email(
                from => $email,
                to => $cfg{webmaster_email},
                subject => $Adsubject,
                message => $Admessage,
        ) || '';

                my $html_page = <<HTML;
<table align="center" border="0" cellspacing="1">
<tr>
<td>
The user information has been sent from $cfg{webmaster_email} to the following e-mail address: <b>$email</b><br />
Please check your email to retrieve your password.
<br /><br />
$inf{change_pass}<br /><br />
</td>
</tr>
</table>
HTML

# $Flex_WPS->SQL_Edit($reg_set{backend_name}, "UPDATE `whosonline` SET `membercount` =membercount + 1,`lastregistered` = '$username' WHERE `id` ='1' LIMIT 1 ;");

$enc_password = $back_ends{$cfg{Portal_backend}}->quote($enc_password);
$username = $back_ends{$cfg{Portal_backend}}->quote($username);
$email = $back_ends{$cfg{Portal_backend}}->quote($email);
$usr{user} = $back_ends{$cfg{Portal_backend}}->quote($usr{user});
$date = $back_ends{$cfg{Portal_backend}}->quote($date);

# Add New Member
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO `members` VALUES (NULL,$enc_password,$username,$username,$email,$usr{user},$date,'standard','$cfg{enable_approvals}','')");


$Flex_WPS->print_page(
        markup       => $html_page,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{login},
        );
       }
    }
}

sub user_names {
        if (!$username) {
        $username = $err{enter_name};
        }
        elsif ($username !~ m!\A[\d\w]+\z!i
                || length($username) < 2
                || length($username) > 14
                || $username eq $usr{admin}
                || $username eq $usr{sadmin}
                || $username eq $usr{sfadmin}
                || $username eq $usr{mod}
                || $username eq $usr{user}
                || $username eq $usr{anonuser}
                || $username =~ m!\A\d+!i) {
                $username = $err{bad_username};
        }
         else {
my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT `uid` FROM `members` WHERE `uid` = '$username'");
$sth->execute;
my $name = '';
my @user_data = $sth->fetchrow;
$sth->finish();
if($user_data[0] eq $username) { $name = $user_data[0]; }


if ($name) {
     $username = $err{username_exists};
     }
      else {
         $username .= ' Name is Available';
      }
}
print "Content-type: text/xml\n\n";
    print qq(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<response>
  <method>checkName</method>
  <result>$username</result>
</response>);

 exit;
}
1;
