package user;

# Load necessary modules.
use strict;
# Assign global variables.
use vars qw(
    $query $Flex_WPS %back_ends %user_action
    %user_data %err $dbh %usr %cfg %msg %nav %btn $AUBBC_mod
    );
use exporter;

my $delete_user = 0; # members can be deleted

%user_action = (
        edit_profile => $usr{user},
        edit_profile2 => $usr{user},
        );

# inputs
my $username                  = $query->param('username');
my $password1                 = $query->param('password1');
my $password2                 = $query->param('password2');
my $nick                      = $query->param('nick');
my $email                     = $query->param('email');
my $sec_level                 = $query->param('sec_level');
my $joined                    = $query->param('joined') || '';
my $theme                     = $query->param('theme');
my $rib2                      = $query->param('rib2');
my $rib3                      = $query->param('rib3');
my $modify                    = $query->param('modify');
my $delete                    = $query->param('delete');

$password2 = $Flex_WPS->untaint2(value => $password2) if $password2;
$password1 = $Flex_WPS->untaint2(value => $password1) if $password1;
$username = $Flex_WPS->untaint2(value => $username) if $username;

sub edit_profile {
if (!$username) {
$username = $user_data{id};
}
# Check if user has permissions to edit other user's profile.
if ($user_data{id} ne $username && $user_data{sec_level} ne $usr{admin}) {
        $Flex_WPS->user_error(error => $err{auth_failure},);
}

# Get current user profile.
my @user_profile = ();

        my $query1 = '';
        $query1 = "SELECT * FROM members WHERE memberid='$username' AND approved='1' LIMIT 1 ;" if $username =~ /\A\d+\z/;
        $query1 = "SELECT * FROM members WHERE memberid='$username' LIMIT 1 ;" if ($user_data{sec_level} eq $usr{admin} && $username =~ /\A\d+\z/);
        $query1 = "SELECT * FROM members WHERE uid = '$username' AND approved='1' LIMIT 1 ;" if $username !~ /\A\d+\z/;
        $query1 = "SELECT * FROM members WHERE uid = '$username' LIMIT 1 ;" if ($user_data{sec_level} eq $usr{admin} && $username !~ /\A\d+\z/);

my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute() || die("Couldn't exec sth!");
@user_profile = $sth->fetchrow;
$sth->finish();

 $delete_user = $delete_user
  ? "<input type=\"submit\" name=\"delete\" value=\"$btn{delete_profile}\" onclick=\"javascript:return confirm('Are you sure you want to Delete This Member?')\">"
  : '';

$Flex_WPS->print_header( cookie1 => '', cookie2 => '',);
$Flex_WPS->print_html(
        page_name    => $nav{edit_profile},
        type         => '',
        ajax_name    => '',
        );
        
$modify = $modify
 ? '<center><h3>Settings were saved.</h3></center>'
 : '';
        print <<HTML;
$modify
<table border="0" cellspacing="1">
<tr>
<td><form action="$cfg{pageurl}/index.$cfg{ext}" method="post" name="creator">
<table border="0">
<tr>
<td><b>$msg{usernameC}</b></td>
<td><input type="hidden" name="username" value="$user_profile[2]"><b>$user_profile[2]</b></td>
</tr>
<tr>
<td><b>$msg{passwordC}</b></td>
<td><input type="password" name="password1" size="20" value="$user_profile[1]">*</td>
</tr>
<tr>
<td><b>$msg{passwordC}</b></td>
<td><input type="password" name="password2" size="20" value="$user_profile[1]">*</td>
</tr>
<tr>
<td><b>Nick Name</b></td>
<td><input type="text" name="nick" size="40" value="$user_profile[3]">*
</td>
</tr>
<tr>
<td><b>$msg{emailC}</b></td>
<td><input type="text" name="email" size="40" value="$user_profile[4]">*</td>
</tr>
HTML

# Print actions for admins.
if ($user_data{sec_level} eq $usr{admin}) {
my $pos       = '';
my @userlevel = ($usr{admin}, $usr{mod}, $usr{user});
my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT `group_name`
FROM `super_mods`
WHERE `active` = '1'");
$sth->execute();
while (my @super_lvls = $sth->fetchrow) {
 push (@userlevel, @super_lvls);
}
$sth->finish();

foreach (@userlevel) {
        $pos = ($user_profile[5] eq $_)
                ? qq($pos<option value="$_" selected>$_</option>\n)
                : qq($pos<option value="$_">$_</option>\n);
 }

        print <<HTML;
<tr>
<td><br /></td>
<td><br /></td>
</tr>
<tr>
<td><b>Admin</b></td>
<td> Stuff</td>
</tr>
<tr>
<td><b>Active User</b></td>
<td><input type="text" name="rib2" size="4" value="$user_profile[8]"></td>
</tr>
<tr>
<td><b>IP Security</b></td>
<td><input type="text" name="rib3" size="4" value="$user_profile[9]"></td>
</tr>
<tr>
<td><b>Status</b></td>
<td><select name="sec_level">
$pos</select></td>
</tr>
<tr>
<td colspan="2">* $msg{required_fields}</td>
</tr>
<tr>
<td colspan="2"><input type="hidden" name="joined" value="$user_profile[6]">
HTML
        }
        else {
                print <<HTML;
<tr>
<td colspan="2">* $msg{required_fields}</td>
</tr>
<tr>
<td colspan="2">
HTML
        }

        print <<HTML;
<input type="hidden" name="op" value="edit_profile2,user">
<input type="submit" name="modify" value="$btn{edit_profile}" onclick="javascript:return confirm('Are you sure you want to Edit This Member?')">
$delete_user
</td>
</tr>
</table>
</form>
</td>
</tr>
</table>
HTML

$Flex_WPS->print_html(
        page_name    => $nav{edit_profile},
        type         => 1,
        ajax_name    => '',
        );
}

=head2 edit_profile2()

 Update user's profile.

=cut

sub edit_profile2 {
my $bad_message = '';
        if (!$username) {
        $username = $user_data{uid};
        }

        if ($username ne $user_data{uid} && $user_data{sec_level} ne $usr{admin}) {
             $Flex_WPS->user_error(
                error => $err{auth_failure},
                );
                $bad_message = 1;
        }

        # Get current user profile.
        $username = $Flex_WPS->untaint2(value => $username);
        if (!$username) {
             $Flex_WPS->user_error(
                error => $err{bad_input},
                );
                $bad_message = 1;
        }
# Get current user profile.
my @user_profile = ();
#my $query1 = "SELECT * FROM members WHERE uid='$username'";

        my $query1 = "SELECT * FROM members WHERE uid='$username' AND approved='1'";
        $query1 = "SELECT * FROM members WHERE uid='$username'" if ($user_data{sec_level} eq $usr{admin});

my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute();
@user_profile = $sth->fetchrow;
$sth->finish();
# No data error
if (!@user_profile) {
$Flex_WPS->user_error(
        error => $err{bad_input},
        );
        $bad_message = 1;
}
        # Update user profile.
        if ($modify ne '') {

                # Password validation.
                if ($password1 ne $password2) {
                $Flex_WPS->user_error(
                        error => $err{verify_pass},
                        );
                        $bad_message = 1;
                }
                if (!$password1) {
                $Flex_WPS->user_error(
                        error => $err{enter_pass},
                        );
                        $bad_message = 1;
                }

                my $password;
                if ($password1 eq $user_profile[1]) {
                $password = $user_profile[1];
                }
                else {

                $password = $Flex_WPS->sha1_code(code1 => $password1, code2 => $username,); # Better SHA1
                }

                if (!$nick) {
                $Flex_WPS->user_error(
                        error => $err{enter_nick},
                        );
                        $bad_message = 1;
                }
                if ($user_data{sec_level} eq $usr{admin}) { # Administrator can Edit other user profiles.
                }
                elsif ($nick !~ m!^([0-9A-Za-z_\ ]+)$!i
                        || $nick =~ /^[\.+\/\\\*\?\~\^\$\@\%\`\"\'\&\;\|\<\>\x00-\x1F]$/
                        || length($nick) < 2
                        || length($nick) > 14
                        || $nick eq $usr{admin}
                        || $nick eq $usr{mod}
                        || $nick eq $usr{user}
                        || $nick eq $usr{anonuser}
                        || $nick eq $usr{sadmin}
                        || $nick eq $usr{sfadmin}) {
                $Flex_WPS->user_error(
                        error => $err{bad_input},
                        );
                        $bad_message = 1;
                }

                # Email validation.
                if (!$email) {
                $Flex_WPS->user_error(
                        error => $err{enter_email},
                        );
                        $bad_message = 1;
                }
                if ($email !~ m/\A[\w\.\-\&]+\@[\w\.\-]+\z/i) {
                $Flex_WPS->user_error(
                        error => $err{bad_input},
                        );
                        $bad_message = 1;
                }


                # Check if user has permissions to modify security level and post count.
                if ($user_data{sec_level} ne $usr{admin})
                {
                        $sec_level   = $user_profile[5];
                        $joined      = $user_profile[6];
                        $rib2        = $user_profile[8];
                        $theme       = $user_profile[7];
                        $rib3        = $user_profile[9];

                }

                if (!$theme)    { $theme    = 'standard'; }
$nick = $back_ends{$cfg{Portal_backend}}->quote($nick);
$email = $back_ends{$cfg{Portal_backend}}->quote($email);

# Write profile.
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `members` SET `password` = '$password',
`nick` = $nick,
`email` = $email,
`seclevel` = '$sec_level',
`joined` = '$joined',
`theme` = '$theme',
`approved` = '$rib2',
`admin_ip` = '$rib3' WHERE `uid` ='$username' LIMIT 1 ;
") if (! $bad_message);


                if ($user_data{uid} eq $username && ! $bad_message) {

                my $session_exp = CGI::Util::expire_calc($cfg{cookie_expire},'');
                my $date = CGI::Util::expire_calc('now','');
                $password = $password . $username . $session_exp;
                my $host = $ENV{REMOTE_ADDR} || $ENV{REMOTE_HOST} || '';
                $password = $Flex_WPS->sha1_code(code1 => $password, code2 => $host,);

                # Add new session
                $Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `auth_session` SET `session_id` = '$password', `expire_date` = '$session_exp' , `date` = '$date' WHERE user_id = '$user_data{id}'");

                # Set the cookie.
                use CGI::Cookie;
                my $cookie_password = new CGI::Cookie(
                        -name     => 'ID',
                        -value    => $password,
                        -expires  => $cfg{cookie_expire},
                        -httponly => 1,
                    );

                        # Redirect to the welcome page.
                        print $query->redirect(
                                -location => $cfg{pageurl} . '/index.' . $cfg{ext} .
                                '?op=edit_profile,user;modify=1',
                                -cookie => $cookie_password,
                            );
                }
                else {
                 $username = $user_profile[0];
                        print $query->redirect(
                                -location => $cfg{pageurl} . '/index.' . $cfg{ext} .
                                '?op=edit_profile,user;modify=1;username=' . $username);
                }
       }
        elsif ($delete ne '' && ! $bad_message && $delete_user) {  # Delete user.
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "DELETE FROM `members` WHERE `uid` = '$username' LIMIT 1;");

                if ($user_data{uid} eq $username) {

                        # Empty cookie values.
                        my $cookie_username = $Flex_WPS->Auth_Loggout();

                        # Redirect to the logout page.
                        print $query->redirect(
                                -location => $cfg{pageurl} . '/index.' . $cfg{ext} ,
                                -cookie => $cookie_username,
                            );

                }
                else {
                        print $query->redirect(
                                -location => $cfg{pageurl} . '/index.' . $cfg{ext});
                }
        }
        elsif (! $bad_message) {
                $Flex_WPS->user_error(
                        error => $err{bad_input},
                        );
        }
}
1;
