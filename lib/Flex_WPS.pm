package Flex_WPS;
use warnings;
use strict;
use vars qw(
    $VERSION $AUBBC_mod $query
    %cfg %sub_action %user_data %user_action
    %usr %err %msg %btn %nav %inf %hlp %months %week_days
    %back_ends
    @subload @Theme_data
    );

use core;
use exporter;
$VERSION = 'Flex-WPS Evo3 v1.0 beta 31';

sub new {
use Flex_CGI;
use Digest::SHA1 qw(sha1_hex);
use DBI;
use AUBBC;
 return bless {};
}

sub DESTROY {
&dc_all_backends if keys %back_ends;
}

sub dc_backend {
my ($self, $backend) = @_;
if (exists $back_ends{$backend} && $back_ends{$backend}) {
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

# Loads CGI.pm
sub Load_CGI {
my ($self, %load_type) = @_;
$Flex_CGI::POST_MAX        = 1024 * $load_type{max_upload_size};
#$Flex_CGI::DISABLE_UPLOADS = $load_type{cgi} if exists $load_type{cgi};
$Flex_CGI::HEADERS_ONCE    = $load_type{cgi}
 if exists $load_type{cgi} && $load_type{cgi};
 
$query = Flex_CGI->new();
$cfg{op} = $query->param('op') || '';

$cfg{core_error} = ($query->cgi_error())
 ? $query->cgi_error()
 :'';

if (! $cfg{core_error} && $cfg{op}) {
my $op_temp = $cfg{op};
$cfg{op} = '';
$cfg{module} = '';
 ($cfg{op}, $cfg{module}) = ($op_temp !~ m/\w+\,{1}\w+/)
  ? ('', '')
  : split (/\,{1}/, $op_temp);

 if ($cfg{op} || $cfg{module}) {
  $cfg{op} = $self->untaint2(value => $cfg{op});
  $cfg{module} = $self->untaint2(value => $cfg{module});
  $cfg{mod_ok} = \&{$self->user_error(error => $err{bad_input},)}
   if !$cfg{op} || !$cfg{module};
 }
}

return $query;
}
sub Load_AUBBC {
my ($self, %load_type) = @_;
$AUBBC::DEBUG_AUBBC = $load_type{Debug} if exists $load_type{Debug};
$AUBBC::MEMOIZE = $load_type{Memoize} if exists $load_type{Memoize};
$AUBBC_mod = AUBBC->new();
return $AUBBC_mod;
}
# Can connect to many DB's
sub SQL_Connect {
my ($self, %mysql) = @_;

# settup connection options
my ($backend, $connect_options) = ($mysql{backend_name}.'_'.$mysql{host}, 'DBI:mysql:database=' .  $mysql{backend_name}. ';host='.$mysql{host});
if (exists $mysql{port} && $mysql{port}) {
        $connect_options .= ';port='.$mysql{port};
        $backend .= "_$mysql{port}";
        }
$backend = sha1_hex($backend, $mysql{username}.$mysql{password});
# Connect
$back_ends{$backend} = DBI->connect(
$connect_options, $mysql{username}, $mysql{password},
\%{$mysql{DBI_Settings}})
 or die($DBI::errstr);

return $backend;
}
# SQL Edit
sub SQL_Edit {
my ($self, $backend, $string) = @_;
$back_ends{$backend}->do($string) unless (!$backend && !$string);
}
# Get Portal config and lang
sub Portal_Config {
my ($self, %flex_set) = @_;

$flex_set{portal_config} = 1 unless exists $flex_set{portal_config} && $flex_set{portal_config};

my $sth = $back_ends{$flex_set{backend_name}}->prepare("SELECT * FROM portalconfigs WHERE `configid` = '$flex_set{portal_config}' LIMIT 1 ;")
         or die($DBI::errstr);
$sth->execute or die($DBI::errstr);
while(my @row = $sth->fetchrow)  {
# Have to clean and setup the config with better stuff!!!
# little cleaner
# not using ip_time, max_upload_size, picture_height, picture_width
# need max_download_size?
%cfg = (
 configid => $row[0],
 pagename => $row[1],
 pagetitle => $row[2],
 cgi_bin_dir => $row[3],
 non_cgi_dir => $row[4],
 cgi_bin_url => $row[5],
 non_cgi_url => $row[6],
 lang => $row[7],
 codepage => $row[8],
 ip_time => $row[9],
 enable_approvals => $row[10],
 webmaster_email => $row[11],
 mail_type => $row[12],
 mail_program => $row[13],
 smtp_server => $row[14],
 time_offset => $row[15],
 date_format => $row[16],
 cookie_expire => $row[17],
 default_theme => $row[18],
 max_upload_size => $row[19],
 picture_height => $row[20],
 picture_width => $row[21],
 ext => $row[22],
 );
}
 $sth->finish();

# Build some paths
#$cfg{scriptdir}     = $cfg{cgi_bin_dir};
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
require "$cfg{langdir}/$cfg{lang}.pl";

# Authentication default backend change
 $cfg{Auth_backend} = exists $flex_set{Auth_DB} && $flex_set{Auth_DB}
        ? $flex_set{Auth_DB}
        : $flex_set{backend_name};
# Theme default backend change
 $cfg{Theme_backend} = exists $flex_set{Theme_DB} && $flex_set{Theme_DB}
        ? $flex_set{Theme_DB}
        : $flex_set{backend_name};
# SubLoad default backend change
 $cfg{SubLoad_backend} = exists $flex_set{SubLoad_DB} && $flex_set{SubLoad_DB}
        ? $flex_set{SubLoad_DB}
        : $flex_set{backend_name};
# Portal default backend change
 $cfg{Portal_backend} = exists $flex_set{Portal_DB} && $flex_set{Portal_DB}
        ? $flex_set{Portal_DB}
        : $flex_set{backend_name};
}

sub Auth_Loggin {
my ($self, %auth) = @_;
my ($user_id, $encrypted_password) = ('', '');
# Data integrity check.
$auth{username} = $self->untaint2(value => $auth{username});
$auth{password} = $self->untaint2(value => $auth{password});

if(!$auth{username} || length($auth{username}) < 1 || length($auth{username}) > 14
        || !$auth{password} || length($auth{password}) < 4 || length($auth{password}) > 28) {
$user_id = 'a';
}

if (! $user_id ) {
$encrypted_password = sha1_hex($auth{password}, $auth{username});
# Check the request
my $sth = $back_ends{$cfg{Auth_backend}}->prepare(
"SELECT memberid
FROM `members`
WHERE `password` = '$encrypted_password'
AND `uid` = '$auth{username}' AND `approved` = '1'
LIMIT 1 ;");
$sth->execute;
while(my @user_data = $sth->fetchrow)  {
$user_id = $user_data[0];
}
$sth->finish();
}

if (! $user_id || $user_id eq 'a') {
        return 1;
}
 else {
$self->SQL_Edit($cfg{Auth_backend}, "DELETE FROM auth_session WHERE user_id='$user_id' LIMIT 1 ;");

my $date = Flex_CGI::expire_calc('now','');
my $expire = $auth{remember} ? '+10y' : $cfg{cookie_expire};
my $session_exp = Flex_CGI::expire_calc($expire,'');
my $host = $ENV{'REMOTE_ADDR'} || $ENV{'REMOTE_HOST'} || '';
$auth{password} = sha1_hex($encrypted_password . $auth{username} . $session_exp, $host);

# Add new session
$self->SQL_Edit($cfg{Auth_backend}, "INSERT INTO `auth_session` VALUES (NULL , '$user_id', '$auth{password}', '$session_exp', '$date');");

# Return the cookie.
return $query->make_cookie(
        -name     => 'ID',
        -value    => $auth{password},
        -expires  => $expire,
        -httponly => 1,
        );
 }
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
my ($self, %flex_set) = @_;
# Get cookie.
my $pwd   = $query->cookie('ID') || '';
$pwd = $self->untaint2(value => $pwd, pattern => 'a-f0-9',) if $pwd;
 
%user_data  = ();
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
# Get user's data from approved user.
my $sth = $back_ends{$cfg{Auth_backend}}->prepare("SELECT members . * , auth_session.`id`, auth_session.`expire_date`, auth_session.`date`
FROM auth_session, members
WHERE auth_session.`session_id` = '$pwd'
AND members.`memberid` = auth_session.`user_id`
AND members.`approved` = '1'
LIMIT 1 ;
") or die($DBI::errstr);
$sth->execute or die($DBI::errstr);
while(my @user_data = $sth->fetchrow) {

# Session Expired
if ($user_data[11] < $date) {
$expire_flag = $user_data[10];
last;
}

# Format Session Key
my $host = $ENV{REMOTE_ADDR} || $ENV{REMOTE_HOST} || '';
$host = sha1_hex($user_data[1] . $user_data[2] . $user_data[11], $host);

# Check Valid Session
if ($pwd eq $host) {
# Format User Profile
my $sec_level = $user_data[5];
my $stat_level = $user_data[5];

if ($user_data[5] ne $usr{user}
 && $user_data[5] ne $usr{admin}
 && $user_data[5] ne $usr{mod}) {
 $sec_level = $usr{user};
 $stat_level = $user_data[5];
}

%user_data = (
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
$sth->finish();
}

if ($expire_flag) {
 $self->SQL_Edit($cfg{Auth_backend}, "DELETE FROM auth_session WHERE `id` = '$expire_flag'");
 return %guest_data;
}
 elsif ($user_data{admin_ip} && $user_data{admin_ip} ne $ENV{REMOTE_ADDR}
     && $user_data{sec_level} eq $usr{admin}) {
 return %guest_data;
}
 elsif (exists $user_data{uid} && $user_data{uid}) {
 # Update the session date
 $self->SQL_Edit($cfg{Auth_backend}, "UPDATE `auth_session` SET `date` = '$date' WHERE `id` = '$user_data{session_id}' LIMIT 1 ;");
 return %user_data; # Finaly ur logged
}
 else {
 return %guest_data;
 }
 
}
# has no known bugs, but needs more testing.
# Security Levels from high to low would be:
# $usr{admin}, $usr{mod}, $usr{user}, $usr{anonuser}.
sub check_access {
my ($self, %ch_access) = @_;
my ($check_ok, @group_path) = ( '', () );

my $sth = $back_ends{$cfg{Auth_backend}}->prepare("SELECT `id`
FROM `super_mod_places`
WHERE `group_name` = '$user_data{sec_group}'
AND `class_sub` = '$ch_access{class_sub}'
AND `active` = '1'
LIMIT 1 ;
") or die($DBI::errstr);
$sth->execute or die($DBI::errstr);
@group_path = $sth->fetchrow;
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
my ($self, $in_date1, $in_date2, $type) = @_;
my $result = $in_date1 - $in_date2;

$result = ! $type
 ? int($result / 3600) # Calculate difference in hours.
 : int($result / (24 * 3600)); # Calculate difference in days.

return $result;
}

# Format date output.
sub format_date {
my ($self, $date, $type) = @_;
$date = $self->get_date if ! $date || $date !~ m/\A\d+\z/;
$type = $cfg{date_format} if !$type;

# Get selected date format.
my $sel_date_format = (exists $user_data{date_format})
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
return "$cmon/$cday/$syear, $hour:$min:$sec" if (!$sel_date_format || $sel_date_format == 11);

# Format: 15.01.00, 15:15:30
return "$cday.$cmon.$syear, $hour:$min:$sec" if $sel_date_format == 1;

# Format: 15.01.2000, 15:15:30
return "$cday.$cmon.$year, $hour:$min:$sec" if $sel_date_format == 2;

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

return "$months{$mon} $mday$cday, $year, $hour:$min$ampm";
}

# Format: 15. Jan 2000, 15:15
return "$wday. $months{$mon} $year, $hour:$min" if $sel_date_format == 4;

# Format: 01/15/00, 3:15pm
if ($sel_date_format == 5) {
my $ampm = 'am';
if ($hour > 11) { $ampm = 'pm'; }
if ($hour > 12) { $hour = $hour - 12; }
if ($hour == 0) { $hour = 12; }

return "$cmon/$cday/$syear, $hour:$min$ampm";
}

# Format: Sunday, 15 January, 2000
return "$week_days{$wday}, $mday $months{$mon} $year" if $sel_date_format == 6;

# Format: 15/01/2000 - 03:15:30
return "$cday/$cmon/$year - $hour:$min:$sec" if $sel_date_format == -1;

# Format: Sunday, 15 January, 2000 3:15pm
if ($sel_date_format == 7) {
 my $ampm = 'am';
 if ($hour > 11) { $ampm = 'pm'; }
 if ($hour > 12) { $hour = $hour - 12; }
 if ($hour == 0) { $hour = 12; }
 return "$week_days{$wday}, $mday $months{$mon} $year $hour:$min$ampm";
}

}

sub sha1_code {
my ($self, %sha1code) = @_;
$sha1code{code1} = '' unless exists $sha1code{code1} && defined $sha1code{code1};
$sha1code{code2} = '' unless exists $sha1code{code2} && defined $sha1code{code2};
return sha1_hex($sha1code{code1}, $sha1code{code2});
}

#  Untaint
sub untaint {
my ($self, %untaint) = @_;
return '' unless exists $untaint{value} && $untaint{value};
$untaint{pattern} = '\w' unless exists $untaint{pattern} && $untaint{pattern};
$untaint{value} =~ m!\A([$untaint{pattern}]+)\z!i
 ? return $1
 : return '';
}

#  Untaint2
sub untaint2 {
my ($self, %untaint) = @_;
return '' unless exists $untaint{value} && $untaint{value};
$untaint{pattern} = '\w' unless exists $untaint{pattern} && $untaint{pattern};
$untaint{value} !~ m!\A([$untaint{pattern}]+)\z!i
 ? return ''
 : return $1;
}

# Initialize a core error
sub core_error {
my ($self, $error) = @_;
$error
 ? core::fatal_error($error)
 : core::fatal_error('Default core error at core_error');
}

# Loads extra sub's where you want
# Known Bug:
# Starting to name sub's as Class_SubName, to prevent a bug in %sub_action hash.
sub SubLoad {
my ($self, %load_set) = @_;
# Get all active Sub's to load
 if (!@subload) {
  my $sth = $back_ends{$cfg{SubLoad_backend}}->prepare(
"SELECT `pmname`, `subname`, `location` FROM `subload` WHERE `active` = '1'")
  or die($DBI::errstr);
  $sth->execute or die($DBI::errstr);
  while(my @row = $sth->fetchrow) {
   push(@subload, join("|", $row[0], $row[1], $row[2])) if $row[0];
  }
  $sth->finish();
 }

 if (@subload && ! $cfg{core_error}) {
  my $load = '';
  foreach my $sb_data (@subload) {
   last if exists $cfg{core_error} && $cfg{core_error};
   my @row = split (/\|/, $sb_data);
   next if $row[2] ne $load_set{location};
   require "$cfg{subloaddir}/$row[0].pm"
    unless exists $INC{"$cfg{subloaddir}/$row[0].pm"};
   unless ($row[1] && exists $sub_action{$row[1]}) {
    $load = \&{$row[0] . '::sub_action'};
    %sub_action = (%sub_action, $load->());
   }
   if ($row[1] && exists $sub_action{$row[1]} && $sub_action{$row[1]}) {
    $load = \&{$row[0] . '::' . $row[1]};
    $load->();
   }
  }
 }
}

sub print_portal {
my $self = shift;
my $mod_ok = '';
 
$mod_ok = \&core::fatal_error($cfg{core_error})
 if $cfg{core_error};
$mod_ok = \&core::fatal_error($AUBBC_mod->aubbc_error())
  if $AUBBC_mod->aubbc_error() && ! $mod_ok;

# was made to run a sub from subload
$mod_ok = \&{$cfg{mod_ok}}
 if ! $mod_ok && exists $cfg{mod_ok} && $cfg{mod_ok};
 
if (! $mod_ok && $cfg{op} && $cfg{module} && -r "$cfg{portaldir}/$cfg{module}.pm") {
 require "$cfg{portaldir}/$cfg{module}.pm";
 if (exists $user_action{$cfg{op}} && $user_action{$cfg{op}}
  && $self->check_access(
   class_sub => $cfg{module} . '::' . $cfg{op},
   sec_lvl   => $user_action{$cfg{op}},)
   ) {
    $mod_ok = \&{$cfg{module} . '::' . $cfg{op}};
   }
 core::write_error("Portal Module ( $cfg{module}\:\:$cfg{op} ) does not support page view or user has no access")
  if ! $mod_ok;
}
 elsif (! $mod_ok && $cfg{module}) {
  core::write_error("Portal Module ( $cfg{module} ) does not exist");
 }
        
 $mod_ok
  ? $mod_ok->()
  : $self->main_page();
}

sub user_error {
my ($self, %load_set) = @_;
$load_set{error} = $err{auth_failure} unless exists $load_set{error} && $load_set{error};
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
if (exists $load_set{cookie2} && exists $load_set{cookie1}
        && $load_set{cookie2} && $load_set{cookie1}) {
        print $query->redirect(
                -location => $load_set{location},
                -cookie   => [$load_set{cookie1}, $load_set{cookie2}]
            );
}
 elsif (exists $load_set{cookie1} && $load_set{cookie1}) {
        print $query->redirect(
                -location => $load_set{location},
                -cookie   => $load_set{cookie1},
            );
 }
  else {
        print $query->redirect( -location => $load_set{location}, );
  }
}
sub print_page {
my ($self, %load_set) = @_;
$self->print_header( cookie1 => $load_set{cookie1}, cookie2 => $load_set{cookie2},);
$self->print_html(
        page_name    => $load_set{navigation},
        type         => '',
        ajax_name    => $load_set{ajax_name},
        word_density => '',     #$load_set{markup},
        );
print $load_set{markup};
$self->SubLoad(location => $load_set{location},) if $load_set{location};
$self->print_html(
        page_name    => $load_set{navigation},
        type         => 1,
        ajax_name    => '',
        );
}

#not in use!
sub word_density {
my ($self, %load_set) = @_;
my ($give_back, %Words) = ('', () );
my %ignore_words = (
'a' => 1,'of' => 1,'in' => 1,'an' => 1,'and' => 1,'it' => 1,
'is' => 1,'the' => 1,'with' => 1,'for' => 1,'to' => 1,'be' => 1,
'on' => 1,'that' => 1,'are' => 1,'www' => 1,'com' => 1,'if' => 1,
);

# cleaner(s)
$load_set{page_data} =~ s/<(?s)[^>]+alt="(.*?)"(?s)[^>]+>/$1/gism;
$load_set{page_data} =~ s/\<\s*SCRIPT.*?\>.*?\<\s*\/SCRIPT\s*\>//gism; # javascript
$load_set{page_data} =~ s/\<\s*STYLE.*?\>.*?\<\s*\/STYLE\s*\>//gism; # style
$load_set{page_data} =~ s/\<\s*OPTION.*?\>.*?\<\s*\/OPTION\s*\>//gism; # form/option
$load_set{page_data} =~ s/<(?s).*?>/ /g; # strips most HTML
$load_set{page_data} =~ s/\&[\#\w]+;/ /gi; # code names
$load_set{page_data} =~ s/[\.\!\?\,\:\;\=\"\'\/\)\(\]\[]+/ /g; # punctuation(s)

# counts words
foreach (split(/\s/,$load_set{page_data})) {
if ($_ =~ m/\A(:?\w{2}\-|\w{3}\-?)/i) {
        $Words{lc($_)}++ unless exists $ignore_words{lc($_)} && $ignore_words{lc($_)};
	}
}

my $top_count = 0;      # || $a cmp $b
 foreach (sort { $Words{$b} <=> $Words{$a} } keys %Words) {
  if ($Words{$_} >= 2 && $top_count <= 24 || $top_count <= 24) {
        $top_count++;
        $give_back .= $top_count eq 1
                ? $_
                : ',' . $_;
        }
 }
return $give_back;
}

sub main_page {
my $self = shift;
my $return_html = '';

# Home Page Welome Message
my $sth = $back_ends{$cfg{Theme_backend}}->prepare("SELECT * FROM welcome WHERE `active` = '1' LIMIT 1 ;");
$sth->execute || $self->core_error("Couldn't connect to Welome Message!");
while(my @row = $sth->fetchrow)  {
 if ($row[2]) {
$row[3] = $AUBBC_mod->do_all_ubbc($self->eval_theme_tags($row[3]));
$row[2] = $AUBBC_mod->do_all_ubbc($self->eval_theme_tags($row[2]));
        $return_html = <<HTML;
<div class="welcometable">
$row[2]
$row[3]
</div>
HTML
#        $return_html = <<HTML;
#<table border="0" cellpadding="7" cellspacing="0" width="100%" class="welcometable" align="center">
#<tr>
#<td>$row[2]<br />
#$row[3]
#</td>
#</tr>
#</table>
#HTML
 }
}
$sth->finish();

#foreach my $key (keys %user_data) {
#    $return_html .= "$key = $user_data{$key}<br>";
#}
#foreach my $key (keys %main::) {
#    $return_html .= "$key = $main::{$key}<br>";
#}
#foreach my $key (keys %ENV) {
#    $return_html .= "$key = $ENV{$key}<br>";
#}
#my $stuff = $self->word_density(page_data => $return_html);
#$return_html .= $stuff;
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
if (exists $cookies{cookie2} && exists $cookies{cookie1}
        && $cookies{cookie2} && $cookies{cookie1}) {
        print $query->header(
                -cookie  => [$cookies{cookie1}, $cookies{cookie2}],
                -expires => 'now',
                -charset => $cfg{codepage},
        );
}
 elsif (exists $cookies{cookie1} && $cookies{cookie1}) {
        print $query->header(
                -cookie  => $cookies{cookie1},
                -expires => 'now',
                -charset => $cfg{codepage},
        );
}
 else {
        print $query->header(
                -expires => 'now',
                -charset => $cfg{codepage},
        );
 }
}

# Evaluate tags for a theme
sub eval_theme_tags {
my ($self, $string) = @_;
unless ($string) {
 return '';
 } else {
 $string =~ s|%cgi_bin_url%|$cfg{cgi_bin_url}|g;
 $string =~ s|%non_cgi_url%|$cfg{non_cgi_url}|g;
 $string =~ s|%pageurl%|$cfg{pageurl}|g;
 $string =~ s|%default_theme%|$cfg{default_theme}|g;
 $string =~ s|%themesurl%|$cfg{themesurl}|g;
 $string =~ s|%ext%|$cfg{ext}|g;
 $string =~ s|%pagename%|$cfg{pagename}|g;
 $string =~ s|%pagetitle%|$cfg{pagetitle}|g;
 $string =~ s|%language%|$cfg{lang}|g;
 $string =~ s|%codepage%|$cfg{codepage}|g;
 $string =~ s|%imagesurl%|$cfg{imagesurl}|g;
 $string =~ s|%homepage%|$cfg{pageurl}/index.$cfg{ext}|g;
 $string =~ s|%homeurl%|$cfg{homeurl}|g;
 $string =~ s|%flex_ver%|$VERSION|g;
 return $string;
 }
}

sub box_header {
my ($self, $title) = @_;
$title = $title
 ? '<div class="bg5"><b>'.$title.'</b></div>'
 : '';
        return <<HTML;
$title
<div class="menuback">
HTML

}

# Print the footer of a menu box.
sub box_footer {
my $self = shift;
        return <<HTML;
</div><br />
HTML

}
# Print the XHTML template.
sub print_html {
my ($self, %theme_set) = @_;
my $meta_tags = '';

# Load requested theme if active
if (! $cfg{theme_printed}) {
my $sth = $back_ends{$cfg{Theme_backend}}->prepare("SELECT `themename`, `description`, `keywords`, `theme_top`, `theme_1`, `theme_2`, `theme_3`, `theme_4`
FROM themes
WHERE `active` = '1'
AND `themename` = '$cfg{default_theme}'
LIMIT 1 ;");
 $sth->execute;
 while(my @row = $sth->fetchrow) {
       # $cfg{default_theme} = $row[0];
        
        $row[2] = $self->word_density(page_data => $theme_set{word_density}.' '.$row[1].' '.$row[3].' '.$row[4].' '.$row[5].' '.$row[6].' '.$row[7])
        if exists $theme_set{word_density} && $theme_set{word_density} && $user_data{uid} eq $usr{anonuser};
        
        $meta_tags .= $self->eval_theme_tags($row[1]);
        $meta_tags = "<meta name=\"keywords\" content=\"$row[2]\" />\n".$meta_tags;
        @Theme_data = (
                $AUBBC_mod->do_all_ubbc($self->eval_theme_tags($row[3])),
                $AUBBC_mod->do_all_ubbc($self->eval_theme_tags($row[4])),
                $AUBBC_mod->do_all_ubbc($self->eval_theme_tags($row[5])),
                $AUBBC_mod->do_all_ubbc($self->eval_theme_tags($row[6])),
                $AUBBC_mod->do_all_ubbc($self->eval_theme_tags($row[7])),
                );
 }
 $sth->finish();

 if (exists $cfg{theme_description} && $cfg{theme_description}) {
 $meta_tags =~ s/<meta name="description" content="(?s).+?" \/>/<meta name="description" content="$cfg{theme_description}" \/>/;
 }
 if (exists $cfg{theme_keywords} && $cfg{theme_keywords}) {
 $meta_tags =~ s/<meta name="keywords" content="(?s).+?" \/>/<meta name="keywords" content="$cfg{theme_keywords}" \/>/;
 }
 
# Ajax scripts
if ($theme_set{ajax_name}) {
my $sth = $back_ends{$cfg{Theme_backend}}->prepare("SELECT `script` FROM `ajax_scripts` WHERE `name` = '$theme_set{ajax_name}' LIMIT 1 ;");
$sth->execute;
my @row = $sth->fetchrow;
$sth->finish();
$theme_set{ajax_name} = $row[0]
 ? $self->eval_theme_tags($row[0])
 : '';

 }
}

# Print the header.
if (!$theme_set{type}) {
# Top of Theme was printed
$cfg{theme_printed} = 1;
$theme_set{page_name} = " - $theme_set{page_name}" if $theme_set{page_name} ne '';
# may want to rename the lang files to example en insted of english,
# To have a name for the XHTML lang="en"
        print <<HTML;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$cfg{pagetitle}$theme_set{page_name}</title>
<meta http-equiv="Content-Type" content="text/html; charset=$cfg{codepage}" />
<meta name="Generator" content="$VERSION" />
$meta_tags
<link rel="stylesheet" href="$cfg{themesurl}/$cfg{default_theme}/style.css" type="text/css" />
<script type="text/javascript">
//<![CDATA[
function closeMessage (ToClose) {
 if (document.getElementById(ToClose)) { document.getElementById(ToClose).innerHTML=''; }
}

function gethelpBox(input1) {
 closeMessage('help');
 var url ='$cfg{pageurl}/index.$cfg{ext}?op=page,page;text=text;id=' + input1;
 doAjaxRequest(url, processReqChangeMany, '', 'help', '');
}
$theme_set{ajax_name}
//]]>
</script>
</head>
<body>
$Theme_data[0]
HTML
# Subs Load - Location 2
$self->SubLoad(location => 2,);
# Theme html theme_1
print $Theme_data[1];
# Subs Load - Location 3
$self->SubLoad(location => 3,);
# Left Block
$self->SubLoad(location => 'block_left',);
# Subs Load - Location 3b bottum
$self->SubLoad(location => '3b',);
# Theme html theme_2
print $Theme_data[2];
# Subs Load - Location 4
$self->SubLoad(location => 4,);
}
# Print the footer.
if ($theme_set{type}) {
# Theme html theme_3
print $Theme_data[3];
# Subs Load - Location 5
$self->SubLoad(location => 5,);
# Right Block
$self->SubLoad(location => 'block_right',);
# Subs Load - Location 5b bottum
$self->SubLoad(location => '5b',);
# Theme html theme_4
print $Theme_data[4];
# Subs Load - Location 6
$self->SubLoad(location => 6,);
# End of HTML
print <<'HTML';
</body>
</html>
HTML

exit;
 }
}
# Send emails. $from, $to, $subject, $message
sub send_email {
 my ($self, %email_set) = @_;
 my ($x, $here, $there, $null) = ('', '', '', '');
 
 use Carp;
 # Format input.
 $email_set{to}      =~ s/[ \t]+/, /g;
 $email_set{from}    =~ s/.*<([^\s]*?)>/$1/;
 $email_set{message} =~ s/^\./\.\./gm;
 #$email_set{message} =~ s/\r\n/\n/g;
 #$email_set{message} =~ s/\n/\r\n/g;
 $cfg{smtp_server} =~ s/\A\s+|\s+\z//g;

 # Send email via SMTP.
 if ($cfg{mail_type} == 1) {
  ($x, $x, $x, $x, $here)  = gethostbyname($null);
  ($x, $x, $x, $x, $there) = gethostbyname($cfg{smtp_server});

  my $thisserver   = pack('S n a4 x8', 2, 0,  $here);
  my $remoteserver = pack('S n a4 x8', 2, 25, $there);

  croak "Socket failure. $!" if (!(socket(S, 2, 1, 6)));
  croak "Bind failure. $!" if (!(bind(S, $thisserver)));
  croak "Connection to $cfg{smtp_server} has failed. $!"
   if (!(connect(S, $remoteserver)));

  my $oldfh = select(S);
  $| = 1;
  select($oldfh);
  $_ = <S>;
  croak "Sending Email: data in Connect error - 220. $!"
   if ($_ !~ /^220/);
  print S "HELO $cfg{smtp_server}\r\n";
  $_ = <S>;
  croak "Sending Email: data in Connect error - 250. $!"
   if ($_ !~ /^250/);
  print S "MAIL FROM:<$email_set{from}>\n";
  $_ = <S>;
  croak "Sending Email: Sender address '$email_set{from}' not valid. $!"
   if ($_ !~ /^250/);
  print S "RCPT TO:<$email_set{to}>\n";
  $_ = <S>;
  croak "Sending Email: Recipient address '$email_set{to}' not valid. $!"
   if ($_ !~ /^250/);
  print S "DATA\n";
  $_ = <S>;
  croak "Sending Email: Message send failed - 354. $!"
   if ($_ !~ /^354/);
 }

 # Send email via NET::SMTP.
 if ($cfg{mail_type} == 2) {
  eval q^
use Net::SMTP;
my $smtp = Net::SMTP->new($cfg{smtp_server}, Debug => 0)
 or croak "Unable to connect to '$cfg{smtp_server}'. $!";

$smtp->mail($email_set{from});
$smtp->to($email_set{to});
$smtp->data();
$smtp->datasend("From: $email_set{from}\n");
$smtp->datasend("Subject: $email_set{subject}\n");
$smtp->datasend("\n");
$smtp->datasend($email_set{message});
$smtp->dataend();
$smtp->quit();
^;
  croak "Net::SMTP fatal error: $@" if $@;
  return 1;
 }

 # Send email via sendmail.
 $ENV{PATH} = '';
 if ($cfg{mail_type} == 0) {
  open S, "| $cfg{mail_program} -t" or croak "Mailprogram error. at $!";
  print S <<THE_EMAIL;
From: $email_set{from}
Subject: $email_set{subject}
To: $email_set{to}
X-Mailer: Flex-WPS Mail_Module v1.0
Content-type: text/plain

$email_set{message}


THE_EMAIL
}

 # Send email via SMTP.
 if ($cfg{mail_type} == 1) {
  $_ = <S>;
  croak "Sending Email: Message send failed - try again - 250. $!"
   if ($_ !~ /^250/);
  print S "QUIT\n";
 }

 close(S);
 return 1;
}
sub dir2array {
        my ($self, $file) = @_;
        my @content = ();

        return '' if ! $file || ! -d $file;
        opendir(DIR, $file);
        @content = readdir(DIR);
        closedir DIR;

        return \@content;
}

sub file2array {
my ($self, $file, $chomp) = @_;
        return core::file2array($file, $chomp);
}

sub file2scalar {
my ($self, $file, $chomp) = @_;
        return core::file2scalar($file, $chomp);
}
sub array2file {
my ($self, %file_set) = @_;
        return core::array2file(%file_set);
}

1;

__END__

=pod

=head1 COPYLEFT

Flex_WPS.pm, v1.0 beta 31 11/09/2014 N.K.A.

Flex Web Portal System Evolution 3

This object is a compilation of methods I normaly use
for web page programing.

 shakaflex [at] gmail.com
 
 http://search.cpan.org/~sflex/

See POD file.

=cut
