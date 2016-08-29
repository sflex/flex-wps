package Login;

=head1 COPYLEFT

  Login.pm,v 1.0 beta 3 07/31/2016 N.K.A.

 This file is part of Flex WPS - Flex Web Portal System.
 Login, Log-out, Remember Password code.

 Need a Clear IP code

 7-31-2016 cleaned up HTML and CSS

=cut

use strict;
use vars qw(
    $query %user_action $Flex_WPS %back_ends
    %err %user_data %usr %nav %cfg %msg %btn
    %inf $failed
    );
# Load Portal Core
use Flex_Porter;

%user_action = (
        login => $usr{anonuser},
        login2 => $usr{anonuser},
        logout => $usr{user},
        reminder => $usr{anonuser},
        reminder2 => $usr{anonuser},
        reminder3 => $usr{anonuser},
        admin => $usr{admin},
        empty => $usr{admin},
        );

my $username = $query->param('username') || '';
my $password = $query->param('password') || '';
my $email = $query->param('email') || '';
my $remember = $query->param('remember') || 0;
my $confirm  = $query->param('confirm') || '';

# For - Captcha Module
my $security_key  = $query->param('security_key');
my $date_captcha  = $query->param('date_captcha');

# ---------------------------------------------------------------------
# Display the login page.
# ---------------------------------------------------------------------
sub login {

 my $retry_msg = $failed
        ? $failed.'<br>'
        : '';
                
# Check if user is already logged in.
$Flex_WPS->user_error( error => $err{bad_input})
 if ($user_data{uid} ne $usr{anonuser});

# Captcha
# Page Expire now or they may see a cached version in error
#$cfg{'page_expire'} = 'now';
#require "$cfg{portaldir}/Captcha.pm";
#my $Imagehtml = Captcha::get_image('small');
# the current ajax capcha has the cache header fix also

my $register = '';
$register = <<"HTML" if -r "$cfg{portaldir}/register.pm";
<p>Not a Member Yet? <a href="$cfg{pageurl}/index.$cfg{ext}?op=register,register">$nav{new_user}</a></p>
HTML

         my $html_page = <<"HTML";
$retry_msg
<form class="pure-form" method="post">
<input type="hidden" name="op" value="login2,Login">
    <fieldset class="pure-group">
            <input class="pure-input-1" id="username" name="username" type="text" placeholder="$msg{usernameC}">
            <input class="pure-input-1" id="password" name="password" type="password" placeholder="$msg{passwordC}">
        </fieldset>
        <div class="pure-controls">
            <label for="remember" class="pure-checkbox">
                <input id="remember" name="remember" type="checkbox" checked>&nbsp;$msg{remember_me}
            </label>
            <div id="captimer"> </div><div id="captcha"> </div>
            <button type="submit" class="pure-button pure-button-active">$btn{login}</button>
        </div>
</form>
<p>
<a href="$cfg{pageurl}/index.$cfg{ext}?op=reminder,Login">$nav{forgot_pass}</a>
</p>
$register
<script type="text/javascript">
//<![CDATA[
var milisec=0;
var seconds=300;
var seconds2=seconds;
function display(){
var html_print="<b>Loading Captcha....</b>";

  if (seconds == seconds2) { html_print="<b>Captcha Reload</b> "+seconds; }
  else { html_print="<b>Captcha Reload</b> "+seconds+"."+milisec; }

  if (seconds == 0 && milisec == 0 || seconds == 300 && milisec == 0) {
   url = '$cfg{pageurl}/index.$cfg{ext}?op=ajax_get,Captcha&amp;a=small';
   seconds=seconds2;
   doAjaxRequest(url, processReqChangeMany, '', 'captcha', '');
   }
    
  if (milisec == 0){ milisec=10; seconds-=1; }
  milisec-=1;
  
 document.getElementById('captimer').innerHTML=html_print;
 setTimeout("display()",100);
}
display();
//]]>
</script>
HTML

$Flex_WPS->print_page(
        markup       => $html_page,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => 'Login::login',
        navigation   => $nav{login},
        );
}

=head2 login2()

 Return a LOGIN Function.
 LOGIN::login2();

=cut

# ---------------------------------------------------------------------
# Log on the user.
# ---------------------------------------------------------------------
sub login2 {

# Data integrity check.
$username = $Flex_WPS->untaint2(value => $username);
$password = $Flex_WPS->untaint2(value => $password);
# Captcha image check
require "$cfg{portaldir}/Captcha.pm";
my $secret_images = '';
$secret_images = Captcha::get_image(1, $security_key, $date_captcha)
 if ($security_key && $date_captcha);

 if (!$username) {
        $failed = $err{bad_username};
        log_login();
        login();
 }
 elsif (!$password) {
        $failed = $err{wrong_passwd};
        log_login();
        login();
 }
 elsif(length($username) < 1 || length($username) > 14) {
        $failed = $err{bad_username};
        log_login();
        login();
 }
 elsif(length($password) < 4 || length($password) > 28) {
        $failed = $err{wrong_passwd};
        log_login();
        login();
 }
 elsif (!$security_key || !$date_captcha) {
        $failed = $err{auth_failure};
        log_login();
        login();
 }
 elsif (!$secret_images) {
        $failed = 'Bad security code';
        log_login();
        login();
 }
 elsif ($username && $password) {
 my $cookie = $Flex_WPS->Auth_Loggin(
        username => $username,
        password => $password,
        remember => $remember,
        );
 $failed = "$err{bad_username} $msg{search_or} $err{wrong_passwd}";
        if ($cookie ne 1 && $cookie ne 0) {
         $failed = 'Logged in!';
         log_login();
         $Flex_WPS->page_redirect(
                location => "$cfg{pageurl}/index\.$cfg{ext}",
                cookie1 => $cookie,
                cookie2 => '',);
        }
        else {
         log_login();
         login();
        }
 }
}
# log all login trys
sub log_login {
my $date = $Flex_WPS->format_date($Flex_WPS->get_date(), 11);
my $string = <<HTML;
Date: $date
IP: $ENV{'REMOTE_ADDR'}
User: $username
Password: $password
Text: $failed
HTML
$string = $back_ends{$cfg{Portal_backend}}->quote($string);

$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO `login_log` VALUES (NULL,$string);");
}
# ---------------------------------------------------------------------
# Log off the user.
# ---------------------------------------------------------------------
sub logout {
        # Empty cookie
        my $cookie_username = $Flex_WPS->Auth_Loggout();
        # Redirect with new cookie.
        $Flex_WPS->page_redirect(
                location => "$cfg{pageurl}/index.$cfg{ext}",
                cookie1  => $cookie_username,
                cookie2  => '',
        );
}

# ---------------------------------------------------------------------
# Display a formular, where user can reset his password.
# ---------------------------------------------------------------------
sub reminder {
# Check if user is already logged in.
 if ($user_data{uid} ne $usr{anonuser}) {
        $Flex_WPS->user_error(error => $err{bad_input});
 }
  else {
        my $html_print = <<"HTML";
<blockquote>This will change the current Password of your Member and email it to the currect email.<br>
<form class="pure-form" method="post" action="$cfg{pageurl}/index.$cfg{ext}">
<input type="hidden" name="op" value="reminder2,Login">
    <fieldset class="pure-group">
            <input id="username" name="username" type="text" placeholder="$msg{usernameC}">
            <input id="email" name="email" type="email" placeholder="$msg{emailC}">
            <button type="submit" class="pure-button pure-button-active">$btn{send}</button>
    </fieldset>
</form>
</blockquote>
HTML

$Flex_WPS->print_page(
        markup       => $html_print,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{reset_pass},
        );
 }
}

# ---------------------------------------------------------------------
# Send user confirmation email for resetting password.
# ---------------------------------------------------------------------
sub reminder2 {
my $bad_msg = '';
my @user_profile = ();
if (!$email || $email !~ m/\A[a-z\d\.\-\_\&]+\@[a-zA-Z\d\.\-\_]+\z/i) {
$Flex_WPS->user_error(
        error => $err{bad_input},
        );
        $bad_msg = 1;
}
$username = $Flex_WPS->untaint2(value => $username) if $username;
if (!$username && !$bad_msg) {
$Flex_WPS->user_error(
        error => $err{bad_input},
        );
        $bad_msg = 1;
}
        # Read user profile.

        my $new_name = $username || '';
        if (! $bad_msg && $username) {

        $username = $back_ends{$cfg{Auth_backend}}->quote($username);
        $email = $back_ends{$cfg{Auth_backend}}->quote($email);

        my $sth = $back_ends{$cfg{Auth_backend}}->prepare(
        "SELECT `memberid`, `password`, `uid`, `nick`, `email` FROM `members` WHERE `uid` = $username AND `email` = $email AND `approved` = '1' LIMIT 1 ;");
        $sth->execute;
        #login("$err{bad_username} $msg{search_or} $err{wrong_passwd}");
        @user_profile = $sth->fetchrow;
        $sth->finish;
        }
if (! @user_profile && !$bad_msg) {
$Flex_WPS->user_error(
        error => '<br />Wrong username or email. Can not reset password.<br /><br />', #$err{not_writable}
        );

} elsif (!$bad_msg) {
$user_profile[1] = $Flex_WPS->sha1_code($user_profile[1], 'reminder2');
#$Flex_WPS->SQL_Edit($cfg{Auth_backend}, "UPDATE `members` SET `approved` = '0' WHERE `memberid` ='$user_profile[0]'");
        my $confirm_link =
            "$cfg{pageurl}/index.cgi?op=reminder3,Login&confirm=$user_profile[1]&username=$new_name";

        # Generate info email.
        my $subject =
            "$cfg{pagename} - $msg{confirm_pass_change} $user_profile[2]";
        my $message = <<"EOT";
$inf{hi_you_or} $ENV{REMOTE_ADDR} $inf{requested_that_user} $user_profile[2] $inf{receive_new_pass} $inf{to_confirm_visit}

$confirm_link

$inf{change_required_msg}

E-mail was sent from: $cfg{cgi_bin_url}/index.$cfg{ext}

EOT

        # Send the email to recipient.
        my $email_ok = $Flex_WPS->send_email(
                from => $cfg{webmaster_email},
                to => $user_profile[4],
                subject => $subject,
                message => $message,
        ) || '';

        my $html_print = "<br />$inf{confirmation_sent} <b>$user_profile[4]</b><br /><br />";
        $html_print = $err{not_writable} if !$email_ok;
        
        $Flex_WPS->print_page(
                markup       => $html_print,
                cookie1      => '',
                cookie2      => '',
                location     => '',
                ajax_name    => '',
                navigation   => $nav{forgot_pass},
                );
        }
}

# ---------------------------------------------------------------------
# Reset user password.
# ---------------------------------------------------------------------
sub reminder3 {
my @user_profile = ();
        $username = $Flex_WPS->untaint2(value => $username);
        $confirm = $Flex_WPS->untaint2(value => $confirm);
        
        if (!$username || !$confirm) {
                $Flex_WPS->user_error(
                        error => $err{enter_name},
                        );
        }
         else {
        # Read user profile.
        my $new_name = $username;
        $username = $back_ends{$cfg{Auth_backend}}->quote($username);
        #$confirm = $back_ends{$cfg{Auth_backend}}->quote($confirm);
        my $sth = "SELECT `memberid`, `password`, `uid`, `nick`, `email`, `seclevel` FROM `members` WHERE `uid` = $username LIMIT 1 ;";
        $sth = $back_ends{$cfg{Auth_backend}}->prepare($sth);
        $sth->execute;
        @user_profile = $sth->fetchrow;
        $sth->finish;
        if (!@user_profile || $Flex_WPS->sha1_code($user_profile[1], 'reminder2') ne $confirm) {
                $Flex_WPS->user_error(
                        error => $err{bad_confirm_code},
                        );
         }
          elsif ($Flex_WPS->sha1_code($user_profile[1], 'reminder2') eq $confirm) {

        #@user_profile = split(/\|/, @user_profile);
        # Generate a password.
        my $password = '';
        rand(time ^ $$);
        my @seed = ('a' .. 'k', 'm' .. 'n', 'p' .. 'z', '2' .. '9');

        for (my $i = 0; $i < 8; $i++)
        {
                $password .= $seed[int(rand($#seed + 1))];
        }

        my $enc_password = $Flex_WPS->sha1_code(code1 => $password, code2 => $new_name,);

        # Update user database.
        $Flex_WPS->SQL_Edit($cfg{Auth_backend}, "UPDATE `members` SET `password` = '$enc_password' WHERE `memberid` ='$user_profile[0]' LIMIT 1 ;");

        # Generate info email.
        my $subject =
            $cfg{pagename} . " - " . $msg{password_forC} . $user_profile[3];
        my $message = <<EOT;
$inf{hi_you_or} $ENV{REMOTE_ADDR} $inf{requested_that_user} $user_profile[4] $inf{receive_new_pass} $inf{user_pass_are}

$msg{usernameC} $user_profile[2]
$msg{passwordC} $password

$msg{statusC} $user_profile[5]

$inf{change_pass}

E-mail was sent from: $cfg{cgi_bin_url}/index.$cfg{ext}
EOT

        # Send the email to recipient.
        my $email_ok = $Flex_WPS->send_email(
                from => $cfg{webmaster_email},
                to => $user_profile[4],
                subject => $subject,
                message => $message,
        ) || '';
        
        my $html_print = "<br />$inf{info_sent} <b>$user_profile[4]</b><br /><br />";
        $html_print = $err{not_writable} if !$email_ok;
        
        $Flex_WPS->print_page(
                markup       => $html_print,
                cookie1      => '',
                cookie2      => '',
                location     => '',
                ajax_name    => '',
                navigation   => $nav{reset_pass},
                );
        }
 }
}

sub admin {
my $html_page = '<hr />';
my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM `login_log`");
$sth->execute;
while(my @row = $sth->fetchrow)  {
$html_page .= "$row[0], $row[1]<hr />";
}
$sth->finish;

$html_page = <<HTML;
<p><b>Login Admin</b> <a href="$cfg{pageurl}/index.$cfg{ext}?op=empty,Login">Empty</a>
$html_page</p>
HTML

$Flex_WPS->print_page(
        markup       => $html_page,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Login Admin',
        );
}

sub empty {
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, 'TRUNCATE `login_log`');

# Redirect to user_actions page.
print $query->redirect(
 -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=admin,Login'
 );
}
1;
