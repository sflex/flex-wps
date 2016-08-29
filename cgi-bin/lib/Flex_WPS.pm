package Flex_WPS;

use warnings;
use strict;

BEGIN {
# Clean up the environment.
delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};
use vars qw(
    $VERSION $AUBBC_mod $AUBBC $query
    %cfg %user_data %user_action
    %usr %err %msg %btn %nav %inf %hlp %months %week_days
    %back_ends
    );

$VERSION = 1.0;

use Flex_Porter;

# File lock and goodies
use Fcntl qw(:DEFAULT :flock);
use Digest::SHA1 qw(sha1_hex);

# figure out if mod_perl is on
use constant IS_MODPERL => $ENV{MOD_PERL};
use subs qw(exit);
# Select the correct exit function, may or may not need "Apache::Constants::DONE"
*exit = IS_MODPERL ? \&Apache::exit(Apache::Constants::DONE) : sub { CORE::exit };

# Catch fatal errors.
$SIG{__DIE__} = \&fatal_error;

} # BEGIN end

# my vars only
my @Theme_data = ();
my %subload    = ();
$cfg{theme_printed} = 0;
$cfg{fatal_printed} = 0;
my $fatal_html  = '';
my $fatal_error = '';

# make the path to the db
unless (defined $cfg{main_path}) {
 my $Mpath = $ENV{'SCRIPT_FILENAME'} || ''; # this is just to syntex check it
 $cfg{main_path} = ($Mpath =~ m'\A([^\.]+)\/[^\/]+\z') ? $1 : '';
 $cfg{path_made} = 1; # indicate if the path was made
 }

# path used in Error_Log.pm
$cfg{errorlog} = $cfg{main_path}.'/db/error.log';
# check log size
$cfg{error_size} = -s $cfg{errorlog};
# clear oversized log
$Flex_WPS->array2file(
        file => $cfg{errorlog},
        ) if ($cfg{error_size} >= 524288);
        
# Log Perl Warnings and Errors - Improved
use CGI::Carp qw(carpout);
sysopen(LOG_WARN, $cfg{errorlog}, O_WRONLY | O_APPEND)
 or die 'Unable to append to error-log: at '.$!."\n";
carpout(\*LOG_WARN);

sub new {
 return bless {};
}

sub DESTROY {
&dc_all_backends if keys %back_ends;
}

sub dc_backend {
my $self = shift;
my $backend = shift;
if (defined $back_ends{$backend} && $back_ends{$backend}) {
        $back_ends{$backend}->disconnect();
        delete $back_ends{$backend};
        }
}
sub dc_all_backends {
 foreach my $key (keys %back_ends) {
  if ($back_ends{$key}) {
   $back_ends{$key}->disconnect();
   delete $back_ends{$key};
  }
 }
}

# Loads Flex_CGI.pm
sub Load_CGI {
my ($self, %set) = @_;
use Flex_CGI;
$Flex_CGI::POST_MAX        = $set{POST_MAX} * 1024;
$Flex_CGI::HEADERS_ONCE    = $set{HEADERS_ONCE};
$query = Flex_CGI->new();

$cfg{op} = $query->param('op') || '';
$cfg{core_error} = ($query->cgi_error())
 ? $query->cgi_error() : '';

 # if there are no errors
 if ( ! $cfg{core_error} && $cfg{op} ) {
  # Copy to a temp variable
  my $op_temp = $cfg{op};
  # This is the exact pattern
  ($cfg{op}, $cfg{module}) = ($op_temp !~ m'\A[a-z\_\-\d]+\,[a-z\_\-\d]+\z'i)
   ? ('', '') : split('\,', $op_temp);
  # if op has no content then the pattern was wrong, log it.
  write_error('Param OP did not have the correct pattern.')
   if ! $cfg{op};
 }

return $query;
}

# New BBcode
sub AUBBC {
my ($self, %setting) = @_;
use AUBBC2;
 $AUBBC2::MEMOIZE    = $setting{MEMOIZE};# Module Speed good on some 5.8
 $AUBBC2::CONFIG     = $setting{CONFIG};# Path to configuration file
 $AUBBC2::ESCAPE     = $setting{ESCAPE};# script_escape
 $AUBBC2::ACCESS_LOG = $setting{ACCESS_LOG};# Default off
 $AUBBC = AUBBC2->new();
 return $AUBBC;
}

# Can connect to many DB's
sub SQL_Connect {
my ($self, %mysql) = @_;
# settup connection options
my ($backend, $connect_options) =
($mysql{backend_name}.'_'.$mysql{host},
'DBI:mysql:database='.$mysql{backend_name}.';host='.$mysql{host});

# Add port option
 if (defined $mysql{port} && $mysql{port}) {
        $connect_options .= ';port='.$mysql{port};
        $backend .= '_'.$mysql{port};
        }
        
# make an exclusive name for this backend
$backend = sha1_hex($backend, $mysql{username}.$mysql{password});

# connect
use Apache::DBI;
$back_ends{$backend} = DBI->connect_cached($connect_options,
 $mysql{username}, $mysql{password},
 \%{$mysql{DBI_Settings}})
 or die($DBI::errstr);

return $backend;
}
# SQL Edit
sub SQL_Edit {
my $self = shift;
my $backend = shift;
my $string = shift;
$back_ends{$backend}->do($string) unless (!$backend && !$string);
}
# Get Portal config and lang
sub Portal_Config {
my ($self, %flex_set) = @_;
my @cfg = qw(configid pagename pagetitle cgi_bin_dir non_cgi_dir cgi_bin_url non_cgi_url lang codepage page_expire enable_approvals webmaster_email mail_type mail_program smtp_server time_offset date_format cookie_expire default_theme max_upload_size picture_height picture_width ext);
$flex_set{portal_config} = 1 unless defined $flex_set{portal_config};
$flex_set{portal_config} = $back_ends{$flex_set{backend_name}}->quote($flex_set{portal_config});
my $sth = $back_ends{$flex_set{backend_name}}->prepare(
'SELECT * FROM portalconfigs WHERE `configid` = '.$flex_set{portal_config}.' LIMIT 1 ;')
 or die($DBI::errstr);
$sth->execute or die($DBI::errstr);
my @row = $sth->fetchrow();
$sth->finish();
# Fixes an issue with clearing the hash after config, faster also
my $count = 0;
 map {
  $cfg{$_} = $row[$count];
  $count++;
 } @cfg;

# Build some paths
$cfg{datadir}       = $cfg{cgi_bin_dir} . '/db';
$cfg{libdir}        = $cfg{cgi_bin_dir} . '/lib';
$cfg{langdir}       = $cfg{cgi_bin_dir} . '/lang';
$cfg{portaldir}     = $cfg{cgi_bin_dir} . '/lib/portal';
$cfg{subloaddir}    = $cfg{cgi_bin_dir} . '/lib/subload';
$cfg{themesdir}     = $cfg{non_cgi_dir} . '/themes';
$cfg{imagesdir}     = $cfg{non_cgi_dir} . '/images';
$cfg{pageurl}       = $cfg{cgi_bin_url};
$cfg{themesurl}     = $cfg{non_cgi_url} . '/themes';
$cfg{imagesurl}     = $cfg{non_cgi_url} . '/images';
$cfg{homeurl}       = 'http://'.$ENV{'SERVER_NAME'};

# Load the language library.
# maybe turn taint on...
require $cfg{langdir}.'/'.$cfg{lang}.'.pl';

# Authentication default backend change
 $cfg{Auth_backend} = defined $flex_set{Auth_DB} && $flex_set{Auth_DB}
        ? $flex_set{Auth_DB}
        : $flex_set{backend_name};
# Theme default backend change
 $cfg{Theme_backend} = defined $flex_set{Theme_DB} && $flex_set{Theme_DB}
        ? $flex_set{Theme_DB}
        : $flex_set{backend_name};
# SubLoad default backend change
 $cfg{SubLoad_backend} = defined $flex_set{SubLoad_DB} && $flex_set{SubLoad_DB}
        ? $flex_set{SubLoad_DB}
        : $flex_set{backend_name};
# Portal default backend change
 $cfg{Portal_backend} = defined $flex_set{Portal_DB} && $flex_set{Portal_DB}
        ? $flex_set{Portal_DB}
        : $flex_set{backend_name};
}

sub Auth_Loggin {
my ($self, %auth) = @_;
my ($user_id, $encrypted_password) = (0, '');
# Data integrity check.
$auth{username} = $self->untaint2(value => $auth{username});
$auth{password} = $self->untaint2(value => $auth{password});

$user_id = 1
 if (!$auth{username} || length($auth{username}) < 1 || length($auth{username}) > 14
  || !$auth{password} || length($auth{password}) < 4 || length($auth{password}) > 28);

if (! $user_id ) {
$encrypted_password = sha1_hex($auth{password}, $auth{username});
my $encryp_pass = $back_ends{$cfg{Auth_backend}}->quote($encrypted_password);
my $auth_user = $back_ends{$cfg{Auth_backend}}->quote($auth{username});
# Check the request
my $sth = $back_ends{$cfg{Auth_backend}}->prepare(
'SELECT memberid
FROM `members`
WHERE `password` = '.$encryp_pass.'
AND `uid` = '.$auth_user.' AND `approved` = \'1\'
LIMIT 1 ;');
$sth->execute;
my @user_data = $sth->fetchrow();
$sth->finish();
$user_id = $user_data[0];
}

if ($user_id && $user_id ne 1){
$self->SQL_Edit($cfg{Auth_backend}, 'DELETE FROM auth_session WHERE user_id=\''.$user_id.'\' LIMIT 1 ;');

my $date = Flex_CGI::expire_calc('now','');
my $expire = $auth{remember} ? '+10y' : $cfg{cookie_expire};
my $session_exp = Flex_CGI::expire_calc($expire,'');
my $host = $ENV{'REMOTE_ADDR'} || $ENV{'REMOTE_HOST'} || '';
$auth{password} = sha1_hex($encrypted_password . $auth{username} . $session_exp, $host);

# Add new session
$self->SQL_Edit($cfg{Auth_backend},
'INSERT INTO `auth_session` VALUES (NULL , \''.$user_id.'\', \''.$auth{password}.'\', \''.$session_exp.'\', \''.$date.'\');');

# Return the cookie.
$user_id = $query->make_cookie(
        -name     => 'ID',
        -value    => $auth{password},
        -expires  => $expire,
        -httponly => 1,
        );
 }
 # can return 1 or 0 for content error or cookie
 return $user_id;
}

sub Auth_Loggout {
 my $self = shift;
# Empty cookie value.
 return $query->make_cookie(
        -name    => 'ID',
        -value   => '',
        -path    => '/',
        -expires => 'now'
        );
}

# Check Auth Session if user is logged in.
sub Auth_Session {
my $self = shift;
my %flex_set = @_;
# Get cookie.
my $pwd = $query->cookie('ID') || '';
$pwd = $self->untaint2(value => $pwd, pattern => 'a-f0-9',) if $pwd;

my %user_lock;
# Guest Account Settings
my %guest_data = (
   uid => $usr{anonuser},
   nick => $usr{anonuser},
   sec_level => $usr{anonuser},
   sec_group => $usr{anonuser},
   theme => $cfg{default_theme},
   );

# Session Expired flag
my $expire_flag = '';

# Get the current date.
my $date = Flex_CGI::expire_calc('now','');

if (! $cfg{core_error} && $pwd && length($pwd) == 40) {
my $auth_pwd = $back_ends{$cfg{Auth_backend}}->quote($pwd);
# Get user's data from approved user.
my $sth = $back_ends{$cfg{Auth_backend}}->prepare(
'SELECT members . * , auth_session.`id`, auth_session.`expire_date`, auth_session.`date`
FROM auth_session, members
WHERE auth_session.`session_id` = '.$auth_pwd.'
AND members.`memberid` = auth_session.`user_id`
AND members.`approved` = \'1\'
LIMIT 1 ;
') or die($DBI::errstr);
$sth->execute or die($DBI::errstr);
my @user_data = $sth->fetchrow();
$sth->finish();

# Session Expired
$expire_flag = $user_data[10]
 if ($user_data[11] < $date);

# Format Session Key
my $host = $ENV{REMOTE_ADDR} || '';
$host = sha1_hex($user_data[1].$user_data[2].$user_data[11], $host);

# Check Valid Session
if ($pwd eq $host) {
# Format User Profile
my $sec_level = $user_data[5];
my $stat_level = $user_data[5];
# Super groups default to user security level
if ($user_data[5] ne $usr{user}
 && $user_data[5] ne $usr{admin}
 && $user_data[5] ne $usr{mod}) {
 $sec_level = $usr{user};
 $stat_level = $user_data[5];
}

%user_lock = (
 id => $user_data[0],
 uid => $user_data[2],
 pwd => $host,
 nick => $user_data[3],
 email => $user_data[4],
 sec_level => $sec_level,
 joined => $user_data[6],
 sec_group => $stat_level,
 theme => $user_data[7],
 approved => $user_data[8],
 admin_ip => $user_data[9],
 session_id => $user_data[10],
 expire_date => $user_data[11],
 last_date => $user_data[12],
 );
 }
}
# Session Expired
if ($expire_flag) {
 # inditace to remove the cookie
 $cfg{Session_Expired} = $expire_flag;
 $expire_flag = $back_ends{$cfg{Auth_backend}}->quote($expire_flag);
 $self->SQL_Edit($cfg{Auth_backend}, 'DELETE FROM auth_session WHERE `id` = '.$expire_flag);
 %user_data = %guest_data;
} # Bad admin IP security setting
 elsif (defined $user_lock{uid} && $user_lock{admin_ip}
  && $user_lock{admin_ip} ne $ENV{REMOTE_ADDR}
  && $user_lock{sec_level} eq $usr{admin}) {
  %user_data = %guest_data;
}# login
 elsif (defined $user_lock{uid} && $user_lock{uid}) {
 # Update the session date
 $date = $back_ends{$cfg{Auth_backend}}->quote($date);
 my $session_id = $back_ends{$cfg{Auth_backend}}->quote($user_data{session_id});
 $self->SQL_Edit($cfg{Auth_backend},
'UPDATE `auth_session` SET `date` = '.$date.' WHERE `id` = '.$session_id.' LIMIT 1 ;');
 # Finaly ur logged
 %user_data = %user_lock;
} # guest
 else {
 %user_data = %guest_data;
 }
 
 return %user_data;
}
# has no known bugs, but needs more testing.
# Security Levels from high to low would be:
# $usr{admin}, $usr{mod}, $usr{user}, $usr{anonuser}.
sub check_access {
my ($self, %ch_access) = @_;
my ($check_ok, @group_path) = ( '', () );
$ch_access{class_sub} = $back_ends{$cfg{Auth_backend}}->quote($ch_access{class_sub});
my $sec_group = $back_ends{$cfg{Auth_backend}}->quote($user_data{sec_group});
my $sth = $back_ends{$cfg{Auth_backend}}->prepare(
'SELECT `id`
FROM `super_mod_places`
WHERE `group_name` = '.$sec_group.'
AND `class_sub` = '.$ch_access{class_sub}.'
AND `active` = \'1\'
LIMIT 1 ;
') or die($DBI::errstr);
$sth->execute or die($DBI::errstr);
@group_path = $sth->fetchrow();
$sth->finish();

$check_ok = 1 if $user_data{sec_level} eq $usr{admin};

$check_ok = 1 if ($user_data{sec_level} eq $usr{mod}
 && ($ch_access{sec_lvl} eq $usr{user} || $ch_access{sec_lvl} eq $usr{anonuser}));
 
$check_ok = 1 if ($user_data{sec_level} eq $usr{user}
 && $ch_access{sec_lvl} eq $usr{anonuser});

$check_ok = 1 if ! $check_ok && $user_data{sec_level} eq $ch_access{sec_lvl};
$check_ok = 1 if ! $check_ok && @group_path;

 return $check_ok;
}

sub get_date {
my $self = shift;
 return time + 3600 * $cfg{time_offset};
}

# Calculate difference between two dates.
sub calc_time_diff {
my $self = shift;
my $in_date1 = shift;
my $in_date2 = shift;
my $type = shift;
my $result = $in_date1 - $in_date2;

$result = ! $type
 ? int($result / 3600) # Calculate difference in hours.
 : int($result / (24 * 3600)); # Calculate difference in days.

return $result;
}

# Format date output.
sub format_date {
my $self = shift;
my $date = shift;
my $type = shift;
$date = $self->get_date if ! $date || $date !~ m'\A\d+\z';
$type = $cfg{date_format} if !$type;

# Get selected date format.
my $sel_date_format = (defined $user_data{date_format})
 ? $user_data{date_format}
 : $cfg{date_format};
$sel_date_format = ($type) ? $type : $cfg{date_format};
$date            = ($date) ? $date : $self->get_date;

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) =
 localtime($date + 3600 * $cfg{time_offset});
my ($cmon, $cday, $syear);

$year += 1900;

$cmon  = $mon + 1;
$syear = sprintf("%02d", $year % 100);

$hour = 0 . $hour if $hour < 10;
$min  = 0 . $min if $min < 10;
$sec  = 0 . $sec if $sec < 10;
$cmon = 0 . $cmon if $cmon < 10;
        
$cday = ($mday < 10) ? 0 . $mday : $mday;

# Format: 01/15/00, 15:15:30
return $cmon.'/'.$cday.'/'.$syear.', '.$hour.':'.$min.':'.$sec
 if (!$sel_date_format || $sel_date_format == 11);

# Format: 15.01.00, 15:15:30
return $cday.'.'.$cmon.'.'.$syear.', '.$hour.':'.$min.':'.$sec
 if $sel_date_format == 1;

# Format: 15.01.2000, 15:15:30
return $cday.'.'.$cmon.'.'.$year.', '.$hour.':'.$min.':'.$sec
 if $sel_date_format == 2;

# Format: Jan 15th, 2000, 3:15pm
if ($sel_date_format == 3) {
my $ampm = 'am';
if ($hour > 11) { $ampm = 'pm'; }
if ($hour > 12) { $hour = $hour - 12; }
if ($hour == 0) { $hour = 12; }

if ($mday > 10 && $mday < 20) { $cday = '<sup>th</sup>'; }
elsif ($mday % 10 == 1) { $cday = '<sup>st</sup>'; }
elsif ($mday % 10 == 2) { $cday = '<sup>nd</sup>'; }
elsif ($mday % 10 == 3) { $cday = '<sup>rd</sup>'; }
else { $cday = '<sup>th</sup>'; }

return $months{$mon}.' '.$mday.$cday.', '.$year.', '.$hour.':'.$min.$ampm;
}

# Format: 15. Jan 2000, 15:15
return $wday.'. '.$months{$mon}.' '.$year.', '.$hour.':'.$min
 if $sel_date_format == 4;

# Format: 01/15/00, 3:15pm
if ($sel_date_format == 5) {
my $ampm = 'am';
if ($hour > 11) { $ampm = 'pm'; }
if ($hour > 12) { $hour = $hour - 12; }
if ($hour == 0) { $hour = 12; }

return $cmon.'/'.$cday.'/'.$syear.', '.$hour.':'.$min.$ampm;
}

# Format: Sunday, 15 January, 2000
return $week_days{$wday}.', '.$mday.' '.$months{$mon}.', '.$year
 if $sel_date_format == 6;

# Format: 15/01/2000 - 03:15:30
return $cday.'/'.$cmon.'/'.$year.' - '.$hour.':'.$min.':'.$sec
 if $sel_date_format == -1;

# Format: Sunday, 15 January, 2000 3:15pm
if ($sel_date_format == 7) {
 my $ampm = 'am';
 if ($hour > 11) { $ampm = 'pm'; }
 if ($hour > 12) { $hour = $hour - 12; }
 if ($hour == 0) { $hour = 12; }
 return $week_days{$wday}.', '.$mday.' '.$months{$mon}.' '.$year.' '.$hour.':'.$min.$ampm;
}

}

sub sha1_code {
my ($self, %sha1code) = @_;
$sha1code{code1} = '' unless defined $sha1code{code1};
$sha1code{code2} = '' unless defined $sha1code{code2};
return sha1_hex($sha1code{code1}, $sha1code{code2});
}

#  Untaint
sub untaint {
my ($self, %untaint) = @_;
return '' unless defined $untaint{value} && $untaint{value};
$untaint{pattern} = '\w' unless defined $untaint{pattern} && $untaint{pattern};
$untaint{value} =~ m[\A([$untaint{pattern}]+)\z]i
 ? return $1
 : return '';
}

#  Untaint2
sub untaint2 {
my ($self, %untaint) = @_;
return '' unless defined $untaint{value} && $untaint{value};
$untaint{pattern} = '\w' unless defined $untaint{pattern} && $untaint{pattern};
$untaint{value} !~ m[\A([$untaint{pattern}]+)\z]i
 ? return ''
 : return $1;
}

# Initialize a core error
sub core_error {
my $self = shift;
my $error = shift;
$error
 ? Flex_Core::fatal_error($error)
 : Flex_Core::fatal_error('Default core error at Flex_WPS::core_error');
}
=head1 SubLoad

 Loads extra sub's where you want
 There are only two SubLoad location's that are hard coded 'START' and 'home'
 START is for starting subroutines that do tasks before the theme and do not
 return or print. home is for sub's to return text that will be printed under
 the welcome message of the home page. All other subload locations are called
 through the theme [%SubLoad-location%] and has to return the html to print or
 defined black return '';. Now you can add, remove, and make your own subload
 locations in the theme.

 No Bugs:
 This version programmed out the known bug
 It is a lot faster because it uses less to function.
 Has taint check incase taint was on.
 
=cut

sub SubLoad {
my $self = shift;
my %load_set = @_;
my $return_text = '';
# Get all active Sub's to load
unless (keys %subload) {
  my $sth = $back_ends{$cfg{SubLoad_backend}}->prepare(
'SELECT `pmname`, `subname`, `location` FROM `subload` WHERE `active` = \'1\'')
  or die($DBI::errstr);
  $sth->execute or die($DBI::errstr);
  while(my @row = $sth->fetchrow) {
  # string format is Class,Sub|Class,Sub
  $subload{$row[2]} .= ($row[0] && defined $subload{$row[2]})
   ? '|'.$row[0].','.$row[1] : $row[0].','.$row[1] if ($row[0]);
  }
  $sth->finish();
 }

 if (! $cfg{core_error} && defined $subload{$load_set{location}}) {
 # location is the hash key
  for ( split '\|', $subload{$load_set{location}} ) {
    my @row = split ('\,', $_);
    my $load = '';
    my $untaint_path = $self->untaint(
        value => $cfg{subloaddir}.'/'.$row[0].'.pm',
        pattern => '\w\-\ \/\.\:') || 0;
    if (! $untaint_path) {
     warn 'Tainted path was skipped at SubLoad '.$row[0].'.pm';
     next;
    }

    require $untaint_path unless defined $INC{$untaint_path};
    $load = \&{$row[0].'::sub_action'};
    my %current_action = $load->();
    
  if (defined $current_action{$row[1]} && $current_action{$row[1]}) {
   $load = \&{$row[0].'::'.$row[1]};
   if ($load_set{location} eq 'START') {
     $load->(); # just run it
   } else {
      # need to gather all for this location.
      $return_text .= $load->();
     }
   }
    
  } # for
 } # no core_error
 return $return_text
  if $load_set{location} ne 'START';
}

=head1 print_portal

The beginning of the never ending story.

=cut
sub print_portal {
my $self = shift;
my $mod_ok = '';
# Core error overrides all, except for a die()
# Subroutines from SubLoad 'START' can add an error if needed
$mod_ok = \&fatal_error($cfg{core_error})
 if $cfg{core_error};
# Second error override, AUBBC errors
$mod_ok = \&fatal_error($AUBBC->error_message())
  if $AUBBC->error_message() && ! $mod_ok;

# Can run a subroutine from SubLoad 'START'
$mod_ok = \&{$cfg{mod_ok}}
 if ! $mod_ok && defined $cfg{mod_ok} && $cfg{mod_ok};
 
 # Decide if module exists
 my $untaint_path = '';
 $untaint_path = $self->untaint(
  value => $cfg{portaldir}.'/'.$cfg{module}.'.pm',
  pattern => '\w\-\ \/\.\:')
   if ! $mod_ok && $cfg{module} && $cfg{portaldir};
   
 if (! $mod_ok && $cfg{op} && $cfg{module} && -r $untaint_path) {
  require $untaint_path;
  # Only add to mod_ok if subroutine supports page view and user has access
  $mod_ok = \&{$cfg{module}.'::'.$cfg{op}}
   if (defined $user_action{$cfg{op}} && $user_action{$cfg{op}}
    && $self->check_access(
       class_sub => $cfg{module}.'::'.$cfg{op},
       sec_lvl => $user_action{$cfg{op}},)
       );

  write_error('Portal Module ( '.$cfg{module}.'::'.$cfg{op}
  .' ) does not support page view or user has no access')
   if ! $mod_ok;
 }
  elsif (! $mod_ok && $cfg{module}) {
  write_error('Portal Module ( '.$cfg{module}.' ) does not exist');
 }
# Default's to welcome message
 $mod_ok
  ? $mod_ok->()
  : $self->main_page();
}
sub user_error {
my ($self, %load_set) = @_;
$load_set{error} = $err{auth_failure}
 unless defined $load_set{error} && $load_set{error};
$self->print_page(
        markup       => $load_set{error},
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{error},
        );
}

sub page_redirect {
my ($self, %load_set) = @_;
if (defined $load_set{cookie2} && defined $load_set{cookie1}
        && $load_set{cookie2} && $load_set{cookie1}) {
        print $query->redirect(
                -location => $load_set{location},
                -cookie   => [$load_set{cookie1}, $load_set{cookie2}]
            );
}
 elsif (defined $load_set{cookie1} && $load_set{cookie1}) {
        print $query->redirect(
                -location => $load_set{location},
                -cookie   => $load_set{cookie1},
            );
 }
  else {
        print $query->redirect( -location => $load_set{location}, );
  }
}
# count length and add to header!
sub print_page {
my ($self, %load_set) = @_;
my $print_html = $self->print_html(
        page_name    => $load_set{navigation},
        type         => $cfg{theme_printed}, # auto switched
        ajax_name    => $load_set{ajax_name},
        );
$print_html .= $load_set{markup};
$print_html .= $self->SubLoad(location => $load_set{location},) if $load_set{location};
$print_html .= $self->print_html(
        page_name    => $load_set{navigation},
        type         => $cfg{theme_printed},
        ajax_name    => '',
        );
# no utf-8
# use Encode qw{encode};
 binmode STDOUT, ":raw";
 #$print_html = encode(utf8 =>$print_html);
# set length in header and print
$self->print_header(
        'length' => length($print_html),
        cookie1 => $load_set{cookie1},
        cookie2 => $load_set{cookie2},);
print $print_html;
exit(0);
}

sub main_page {
my $self = shift;
my $return_html = '';

# Home Page Welome Message
my $sth = $back_ends{$cfg{Theme_backend}}->prepare(
'SELECT * FROM welcome WHERE `active` = \'1\' LIMIT 1 ;');

$sth->execute or $self->core_error('Could not connect to Welcome Message!');
my @row = $sth->fetchrow;
$sth->finish();
$return_html =
        $AUBBC->parse_bbcode($self->eval_theme_tags($row[2]))
        ."\n".
        $AUBBC->parse_bbcode($self->eval_theme_tags($row[3]))
        if ($row[2]);

$self->print_page(
        markup       => $return_html,
        cookie1      => '',
        cookie2      => '',
        location     => 'home',
        ajax_name    => '',
        navigation   => $nav{home},
        );
}
# Print the HTTP header.
sub print_header {
my ($self, %cookies) = @_;
my $head_check;
if (defined $cookies{cookie2} && defined $cookies{cookie1}
        && $cookies{cookie2} && $cookies{cookie1}) {
        $head_check = $query->header(
                '-length'  => $cookies{length},
                '-cookie'  => [$cookies{cookie1}, $cookies{cookie2}],
                '-expires' => $cfg{page_expire},
                '-charset' => $cfg{codepage},
        );
}
 elsif (defined $cookies{cookie1} && $cookies{cookie1}) {
        $head_check = $query->header(
                '-length'  => $cookies{length},
                '-cookie'  => $cookies{cookie1},
                '-expires' => $cfg{page_expire},
                '-charset' => $cfg{codepage},
        );
}
 else {
        $head_check = $query->header(
                '-length'  => $cookies{length},
                '-expires' => $cfg{page_expire},
                '-charset' => $cfg{codepage},
        );
 }
 # die on bad header
  (! $query->cgi_error())
  ? print $head_check
  : fatal_error($query->cgi_error());
}

# Evaluate tags for a theme
sub eval_theme_tags {
my $self = shift;
local $_ = shift || '';
if ($_) {
 s[%cgi_bin_url%][$cfg{cgi_bin_url}]g;
 s[%non_cgi_url%][$cfg{non_cgi_url}]g;
 s[%pageurl%][$cfg{pageurl}]g;
 s[%default_theme%][$cfg{default_theme}]g;
 s[%themesurl%][$cfg{themesurl}]g;
 s[%ext%][$cfg{ext}]g;
 s[%pagename%][$cfg{pagename}]g;
 s[%pagetitle%][$cfg{pagetitle}]g;
 s[%language%][$cfg{lang}]g;
 s[%codepage%][$cfg{codepage}]g;
 s[%imagesurl%][$cfg{imagesurl}]g;
 s[%homepage%][$cfg{pageurl}/index.$cfg{ext}]g;
 s[%homeurl%][$cfg{homeurl}]g;
 s[%flex_ver%][Flex WPS v$VERSION]g;
 }
 return $_;
}

=head1 print_html

 Supports future HTML types.
 This method uses these theme tags:
 %page_name% %charset% %language% [%SubLoad-locations%] [%ajax_script%]
 Also tags from eval_theme_tags and AUBBC.
 
=cut
sub print_html {
my ($self, %theme_set) = @_;

# Load requested theme if active
if (! $cfg{theme_printed}) {
my $default_theme = $back_ends{$cfg{Theme_backend}}->quote($cfg{default_theme});
my $sth = $back_ends{$cfg{Theme_backend}}->prepare(
'SELECT `name`, `charset`, `language`, `markup`
FROM themes
WHERE `active` = \'1\'
AND `name` = '.$default_theme.'
LIMIT 1 ;');
 $sth->execute;
 my @row = $sth->fetchrow;
 $sth->finish();
  # convert most theme tags and bbcode
  $row[3] = $AUBBC->parse_bbcode($self->eval_theme_tags($row[3]));
  # format page name, used in title
  $theme_set{page_name} = ' &ndash; '.$theme_set{page_name}
   if $theme_set{page_name} ne '';
  $row[3] =~ s[%page_name%][$theme_set{page_name}]g;
  $row[3] =~ s[%\bcharset\b%][$row[1]]g;
  $row[3] =~ s[%\blang\b%][$row[2]]g;
  # All the magic for Subload in the theme
  $row[3] =~
   s[\[%\bSubLoad\b\-([a-z\-\_\d]+)%\]][$self->SubLoad(location => $1,)]gie;
  # split at [%content%] to get the header and footer
  @Theme_data = split(m'\[%\bcontent\b%\]', $row[3]);

 # Ajax scripts add to header
 if ($theme_set{ajax_name}) {
  $theme_set{ajax_name} =
   $back_ends{$cfg{Theme_backend}}->quote($theme_set{ajax_name});
   
  my $sth = $back_ends{$cfg{Theme_backend}}->prepare(
'SELECT `script` FROM `ajax_scripts` WHERE `name` = '
 .$theme_set{ajax_name}.' LIMIT 1 ;');
 
  $sth->execute;
  @row = $sth->fetchrow;
  $sth->finish();
 
  $theme_set{ajax_name} = $row[0]
    ? $self->eval_theme_tags($row[0]) # script
    : ''; # theme had ajax_name but no script
    $Theme_data[0] =~ s[\[%ajax_script%\]][$theme_set{ajax_name}]g;
   }
    else {
     $Theme_data[0] =~ s[\[%ajax_script%\]][]g;
   } # ajax end

 } # End load theme
my $return_this = '';
# Print the header.
 if ($Theme_data[0] && !$cfg{theme_printed}) {
  # Top of Theme was printed
  $cfg{theme_printed} = 1;
  # HTML header
  $return_this = $Theme_data[0];
 }

# Print the footer.
 if (!$Theme_data[0] && $cfg{theme_printed}) {
  # HTML footer
  $return_this = $Theme_data[1];
 }
 # used as a switch
 $Theme_data[0] = '';
 return $return_this;
}

# Send emails. $from, $to, $subject, $message
sub send_email {
 my ($self, %email_set) = @_;

 # Format input.
 $email_set{to}      =~ s/[ \t]+/, /g;
 $email_set{from}    =~ s/.*<([^\s]*?)>/$1/;
 $email_set{message} =~ s/^\./\.\./gm;
 $email_set{message} =~ s/\r\n/\n/g;
 $email_set{message} =~ s/\n/\r\n/g;
 $cfg{smtp_server}   =~ s/\A\s+|\s+\z//g;

 # Send email via SMTP.
 # Tested on Windows only
 if ($cfg{mail_type} == 1) {
 use Carp;
 use Socket;

  my $proto = getprotobyname('tcp') || 6;
  my $port  = getservbyname('SMTP', 'tcp') || 25;
  my $remoteserver = inet_aton($cfg{smtp_server})
    or croak 'Unable to resolve hostname : '.$cfg{smtp_server};

  croak 'Socket failure. '.$! if (! socket(S, AF_INET, SOCK_STREAM, $proto));
  croak 'Bind failure. '.$! if (! bind(S, sockaddr_in(0, INADDR_ANY)));
  croak 'Connection to '.$cfg{smtp_server}.' has failed. '.$!
   if (! connect(S, sockaddr_in($port, $remoteserver)));

  my $oldfh = select(S);
  $| = 1;
  binmode $oldfh;
  select($oldfh);

  $_ = <S>;
  croak "Sending Email: data in Connect error - 220. $_ $!"
   if ($_ !~ /^220/);
   
  print S "HELO $cfg{smtp_server}\r\n";
  $_ = <S>;
  croak "Sending Email: data in Connect error - 250. $_ $!"
   if ($_ !~ /^250/);

  print S "MAIL FROM:<$email_set{from}>\r\n";
  $_ = <S>;
  croak "Sending Email: Sender address '$email_set{from}' not valid. $_ $!"
   if ($_ !~ /^250/);
   
  print S "RCPT TO:<$email_set{to}>\r\n";
  $_ = <S>;
  croak "Sending Email: Recipient address '$email_set{to}' not valid. $_ $!"
   if ($_ !~ /^250/);
   
  print S "DATA\r\n";
  $_ = <S>;
  croak "Sending Email: Message send failed - 354. $_ $!"
   if ($_ !~ /^354/);
 }

 # Send email via sendmail.
  # needs testing
 if ($cfg{mail_type} == 0) {
  $ENV{PATH} = ''; # this was done in BEGIN, but one more time just to make sure
  open S, '| '.$cfg{mail_program}.' -t' or croak 'Mailprogram error. at '.$!;
  }

  print S "To: $email_set{to}\r\n";
  print S "From: $email_set{from}\r\n";
  print S "Subject: $email_set{subject}\r\n";
  print S "\t$email_set{message}";
  print S "\r\n.\r\n";

 # Send email via SMTP.
 if ($cfg{mail_type} == 1) {
  $_ = <S>;
  croak "Sending Email: Message send failed - try again - 250. $_ $!"
   if ($_ !~ /^250/);
  print S "QUIT\r\n";
 }

 close(S);
 return 1;
}

# die interface
sub fatal_error {
 my $error = shift || '';
 $error =~ s/\|/&#124;/g if $error;
 $fatal_error .= $error;
 my ($msg, $path) = ('','');
 ($msg, $path) = split( ' at ', $error) if ($error && $error =~ m/ \bat\b /io);
 $path =~ s/\n.+?\z|\n//g if $path; # clean for HTML

# uses a lot less code then befor, is HTML5 valid and looks better.
        $fatal_html = <<'HTML' if !$cfg{fatal_printed};
<!DOCTYPE html>
<html lang="en">
<head>
<title>Fatal Error</title>
<style>
h1{color:#333366;font-size:30px;}h2{font-size:20px;}.p1{color:#0000A0;}</style>
</head>
<body>
HTML

# header prints first so if write_error does a fatal_error
# we know a good header is up and write_error probably set it.
$error =~ s/\n/\/n\\/g if $error;
write_error($error.' IP:'.$ENV{'REMOTE_ADDR'}, 1) if !$cfg{fatal_printed};
$error =~ s/\/n\\/ /g if $error;

        $fatal_html .= <<"HTML";
<div><h1>Flex (WPS) - Fatal Error</h1><hr>
<h2>Flex has exited with the following error:</h2>
<p style="color:red"><b>$msg</b></p>
<b>This error was reported at:</b><br>
<span class="p1">$path</span>
<pre><b>Original Error:</b>
$fatal_error
</pre><hr>
<span class="p1"><b>Please inform the webmaster if this error persists.</b></span>
<hr></div>
</body>
</html>
HTML

binmode STDOUT, ":raw";
my $flength = length($fatal_html);
        print <<"HTML";
Content-Length: $flength
Connection: close
Content-Type: text/html

HTML
print $fatal_html;
exit(1);
}

sub write_error {
 my $error_msg = shift;
 my $theme_prt = shift;
 # Set top of theme was printed.
 $cfg{fatal_printed} = 1 if defined $theme_prt;
 # Update log file. fatal_error just handles the problems better then die here
 sysopen(FH, $cfg{main_path}.'/db/fatal_error.log', O_WRONLY | O_APPEND)
  or fatal_error 'Unable to append to fatal_error-log: at '.$!."\n";
 flock(FH, LOCK_EX);
 print FH '['.scalar(localtime).']|'.$error_msg."\n";
 close(FH);
}

sub file2array {
my $self = shift;
my $file = shift;
my $chomp = shift;
 return '' if ! $file || ! -r $file;
 my @content = ();
 sysopen(FH, $file, O_RDONLY);
 flock(FH, LOCK_EX);
 @content = <FH>;
 close(FH);
 chomp(@content) unless ! $chomp;
 return \@content;
}

sub file2scalar {
my $self = shift;
my $file = shift;
my $chomp = shift;
 return '' if ! $file || ! -r $file;
 sysopen(FH, $file, O_RDONLY);
 flock(FH, LOCK_EX);
 local $/ = undef;
 my $content = <FH>;
 close(FH);
 chomp($content) unless ! $chomp;
 return $content;
}

sub array2file {
 my ($self, %file_set) = @_;
 return '' if ! $file_set{file} || ! -r $file_set{file};
 sysopen(FH, $file_set{file}, O_WRONLY | O_TRUNC)
  or die($err{not_writable}.' '.$file_set{file}.'. ('.$!.')');
 flock(FH, LOCK_EX);
 if (exists $file_set{array} && @{$file_set{array}}) {
 # this part was not tested
  print FH $_."\n" foreach (@{$file_set{array}});
 }
  elsif (exists $file_set{string} && $file_set{string}) {
  print FH $file_set{string};
 }
  else {
  print FH ''; # used to clear error logs
 }
 close(FH);
}

sub dir2array {
my $self = shift;
my $file = shift;
        my @content = ();

        return '' if ! $file || ! -d $file;
        opendir(DIR, $file);
        @content = readdir(DIR);
        closedir DIR;

        return \@content;
}

1;

__END__

=pod

=head1 COPYLEFT

Flex_WPS.pm, v1.0 05/26/2016 N.K.A.

Flex (Web Portal System)

This object is a compilation of methods I normally use
for web page programming. Supports Perl 5.8 and up,
tested on 5.8 and 5.22. Requires Apache and MySQL.

Perl Modules:
Apache::DBI, Digest::SHA1, Flex_CGI, CGI::Carp,
Carp, Fcntl, AUBBC2

 shakaflex [at] gmail.com
 
 http://search.cpan.org/~sflex/

See Flex_WPS.pod POD file.
index.cgi chmod 755
all other files in cgi-bin chmod 644 or 666,
some chmod that hides the files from HTTP browsing.

Workflow:


         /db/config.pl   /----Flex_Porter-\
                  |      ^       ^     ^  ^
                  |      |       |     |  |
                  V      V       V     |  |
 Server<->Perl<->index.cgi<->Flex_WPS  |  |
                    ^          ^    ^  |  |
                    |          |    |  |  |
                    V          V    V  V  |
                  /lib  /subload  /portal |
                                \------<--/


=cut
