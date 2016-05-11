package Flex_CGI;

use strict;
use warnings;
                           
our $VERSION = '0.09';
#our $MOD_PERL            = 0;          # no mod_perl by default

# global settings
our $POST_MAX            = 1024 * 100;  # limit total parsing size to 100kb
our $GET_MAX             = 1024 * 100;  # limit total parsing size to 100kb
our $COOKIE_MAX          = 1024 * 100;  # limit total parsing size to 100kb
our $NO_UNDEF_PARAMS     = 0;           # parameters exist with blank values
our $HEADERS_ONCE        = 1;           # print the Header once
our $NPH                 = 0;           # not realy used in header
our $SET_CRLF            = '';          # auto defined or define your CRLF or '' for $/
our $NO_NULL             = 1;           # filter out null bytes in name & value pairs


my $flex_error   = '';
my %QUERY        = ();
my %QUERY_more   = ();
my @QUERY_names  = ();
my %COOKIES      = ();
my @COOKIE_names = ();
my $header_ct    = 0;

#my $OS = $^O || do { require Config; $Config::Config{'osname'} };
my $CRLF = $SET_CRLF || $/;
#unless ($SET_CRLF) {
# $CRLF = ( $OS =~ m/VMS/i ) ? "\n"
#  : ( "\t" ne "\011" ) ? "\r\n"
#  :                      "\015\012";
#}
    
sub new {

if (@QUERY_names || @COOKIE_names) {
%QUERY        = ();
%QUERY_more   = ();
@QUERY_names  = ();
%COOKIES      = ();
@COOKIE_names = ();
}

# avoid large parsing
my $query_string = $ENV{'QUERY_STRING'} || $ENV{'REDIRECT_QUERY_STRING'} || '';
my $raw_cookie   = $ENV{'HTTP_COOKIE'}  || $ENV{'COOKIE'} || '';

my $COOKIE_LENGTH = length($raw_cookie)    || 0;
my $POST_LENGTH   = $ENV{'CONTENT_LENGTH'} || 0;
my $GET_LENGTH    = length($query_string)  || 0;

 if ($POST_LENGTH && $POST_MAX > 0 && $POST_LENGTH > $POST_MAX
  || $GET_LENGTH && $GET_MAX > 0 && $GET_LENGTH > $GET_MAX
  || $COOKIE_LENGTH && $COOKIE_MAX > 0 && $COOKIE_LENGTH > $COOKIE_MAX) {
  $flex_error .=
   "413 Request entity too large: $POST_LENGTH bytes $GET_LENGTH bytes $COOKIE_LENGTH bytes. Limit is: $POST_MAX! IP:$ENV{'REMOTE_ADDR'}\n";
 }
  else {
# POST or GET
  my $meth = $ENV{'REQUEST_METHOD'} || '';
  if ($meth) {
  my @params = ();
  if ($POST_LENGTH && ($meth eq 'POST' || $meth eq 'PUT')) {
   my $input = '';
   read(\*STDIN, $input, $POST_LENGTH); # post
   @params = split(/[&;]/, $input);
  }
   elsif ($GET_LENGTH && ($meth eq 'GET' || $meth eq 'HEAD')) {
   @params = split(/[&;]/, $query_string) if $query_string; # get
  }
  
   foreach (@params) {
    my ($name, $value) = split('=', $_, 2);
    next if ! defined $name || $NO_UNDEF_PARAMS && ! defined $value;
    $value = '' unless defined $value;
    $name = url_decode($name);
    push(@QUERY_names,$name) unless exists($QUERY{$name});
    $QUERY{$name} ||= url_decode($value);

    # need more v0.07
    $QUERY_more{$name} .= (exists($QUERY_more{$name}))
     ? "\000\000".url_decode($value)
     : url_decode($value);
   }
  }
  
# Cookies
  if ($COOKIE_LENGTH) {
   my @pairs = split('[;,] ?',$raw_cookie);
   my @values = ();
   foreach (@pairs) {
    s/\A\s+|\s+\z//g;
    my ($key,$value) = split('=', $_, 2);
    next if ! defined $key || ! defined $value;
    $key = url_decode($key);
    if ($value ne '') {
     @values = map url_decode($_),split(/[&;]/,$value.'&dmy');
     pop @values;
    }
    push(@COOKIE_names,$key);
    $COOKIES{$key} ||= ($key && @values) ? "@values" : '';
    @values = ();
   }
  }
  
 }
 
 return bless {};
}

sub DESTROY {

}

sub url_decode {
 my $decode = shift;
 if ($decode) {
  $decode =~ tr/+/ /;
  $decode =~ s/%([0-9a-fA-F]{2})/ pack "C", hex $1 /eg;
  $decode =~ tr/\000//d if $NO_NULL;
  $decode =~ s/\r//g; # windows and *nix fix
 }
 return $decode;
}

sub url_encode {
 my $encode = shift;
 if ($encode) {
  $encode =~ s/([^A-Za-z0-9\-_.!~*'() ])/ uc sprintf "%%%02x",ord $1 /eg;
  $encode =~ tr/ /+/;
 }
 return $encode;
}

# get/set last cgi_error
sub cgi_error {
 my ($self, $error) = @_;
 defined $error && $error
 ? $flex_error .= $error
 : return $flex_error;
}

sub params {
my $self = shift;
return \%QUERY;
}

sub param {
 my ($self, $name) = @_;
 if (defined $name && $name) {
  exists $QUERY{$name}
   ? return $QUERY{$name}
   : return '';
 } else { return @QUERY_names; }
}

sub param_more{
 my ($self, $name) = @_;
 if (defined $name && $name) {
  exists $QUERY_more{$name}
   ? return $QUERY_more{$name}
   : return '';
 } else { return @QUERY_names; }
}

sub cookies {
my $self = shift;
return \%COOKIES;
}

sub cookie {
 my ($self, $name) = @_;
 if (defined $name && $name) {
  exists $COOKIES{$name}
   ? return $COOKIES{$name}
   : return '';
 } else {
  return @COOKIE_names;
 }
}

sub redirect {
my ($self, %red) = @_;
 if (exists $red{'-location'} && $red{'-location'} =~ m/\A\w+:\/\/|\//i) {
  return $self->header(
        -status => $red{'-status'} || '302 Found',
        -location => $red{'-location'},
        -nph => $NPH,
        -target => $red{'-target'} || '',
        -type => '',
        -cookie => [$red{'-cookie'}] || '',
        );
 }
}

sub header {
 my ($self, %header) = @_;
 if (! $header_ct) {
  my @header = ();
  my $type = 'text/html';
  $type = $header{'-type'} if exists $header{'-type'} && $header{'-type'};
  my $charset = 'ISO-8859-1';
  if (exists $header{'-charset'} && $header{'-charset'}) {
      $charset = $header{'-charset'};
    } else {
      $charset = 'ISO-8859-1' if $type =~ /^text\//;
    }
 $type .= '; charset='.$charset
  if $type !~ /\bcharset\b/ and $charset;
  
  my $protocol = $ENV{'SERVER_PROTOCOL'} || 'HTTP/1.0';
  push(@header,$protocol . ' ' . ($header{'-status'} || '200 OK')) if $NPH;
  push(@header,'Server: ' . $ENV{'SERVER_SOFTWARE'}) if $NPH;
  push(@header,'Status: '.$header{'-status'}) if exists $header{'-status'} && $header{'-status'};
  push(@header,'Window-Target: '.$header{'-target'}) if exists $header{'-target'} && $header{'-target'};
# push all the cookies -- there may be several
  if ($header{'-cookie'}) {
   my @cookie = ref($header{'-cookie'}) && ref($header{'-cookie'}) eq 'ARRAY' ? @{$header{'-cookie'}} : $header{'-cookie'};
   for (@cookie) {
    push(@header,'Set-Cookie: '."$_") if $_;
   }
  }
# if the user indicates an expiration time, then we need
# both an Expires and a Date header (so that the browser is
# uses OUR clock)
  push(@header,'Expires: '. expires($header{'-expires'},'http')) if exists $header{'-expires'} && $header{'-expires'};
  push(@header,'Date: ' . expires(0,'http'))
   if exists $header{'-expires'} && $header{'-expires'} || exists $header{'-cookie'} && $header{'-cookie'} || $NPH;
  # v0.08 : Cache-Control: xx; HTTP/1.1
  push(@header,'Cache-Control: '.$header{'-cache_con'}) if exists $header{'-cache_con'} && $header{'-cache_con'};
  #
  # v0.09 Access-Control-Allow-Origin
  push(@header,'Access-Control-Allow-Origin: '.$header{'-origin'}) if exists $header{'-origin'} && $header{'-origin'};
  #
  push(@header,'Pragma: no-cache') if exists $header{'-cache'} && $header{'-cache'};
  push(@header,'Content-Disposition: attachment; filename="'.$header{'-attachment'}.'"')
   if exists $header{'-attachment'} && $header{'-attachment'};

  if (exists $header{'-location'}) {
   push(@header,'Location: ' . $header{'-location'});
   $type = '';
  }
  push(@header,'Content-Type: '.$type) if $type ne '';
  my $header = join($CRLF,@header).$CRLF.$CRLF;
  $header_ct = 1 if $HEADERS_ONCE;
  return $header;
 }
  else {
  $self->cgi_error(
  'One set of header\'s was printed: this action is default by the $HEADERS_ONCE variable.'."\n"
  );
 }
}

# This internal routine creates date strings suitable for use in
# cookies and HTTP headers.  (They differ, unfortunately.)
# Thanks to Mark Fisher for this.
sub expires {
    my($time,$format) = @_;
    $format ||= 'http';

    my(@MON)=qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/;
    my(@WDAY) = qw/Sun Mon Tue Wed Thu Fri Sat/;

    # pass through preformatted dates for the sake of expire_calc()
    $time = expire_calc($time);
    return $time unless $time =~ /^\d+$/;

    # make HTTP/cookie date string from GMT'ed time
    # (cookies use '-' as date separator, HTTP uses ' ')
    my($sc) = ' ';
    $sc = '-' if $format eq 'cookie';
    my($sec,$min,$hour,$mday,$mon,$year,$wday) = gmtime($time);
    $year += 1900;
    return sprintf("%s, %02d$sc%s$sc%04d %02d:%02d:%02d GMT",
                   $WDAY[$wday],$mday,$MON[$mon],$year,$hour,$min,$sec);
}

# This internal routine creates an expires time exactly some number of
# hours from the current time.  It incorporates modifications from
# Mark Fisher.
sub expire_calc {
    my($time) = @_;
    my(%mult) = ('s'=>1,
                 'm'=>60,
                 'h'=>60*60,
                 'd'=>60*60*24,
                 'M'=>60*60*24*30,
                 'y'=>60*60*24*365);
    # format for time can be in any of the forms...
    # "now" -- expire immediately
    # "+180s" -- in 180 seconds
    # "+2m" -- in 2 minutes
    # "+12h" -- in 12 hours
    # "+1d"  -- in 1 day
    # "+3M"  -- in 3 months
    # "+2y"  -- in 2 years
    # "-3m"  -- 3 minutes ago(!)
    # If you don't supply one of these forms, we assume you are
    # specifying the date yourself
    my($offset);
    if (!$time || (lc($time) eq 'now')) {
      $offset = 0;
    } elsif ($time=~/^\d+/) {
      return $time;
    } elsif ($time=~/^([+-]?(?:\d+|\d*\.\d*))([smhdMy])/) {
      $offset = ($mult{$2} || 1)*$1;
    } else {
      return $time;
    }
    return (time+$offset);
}

sub make_cookie {
my ($self, %cookie) = @_;

if (exists $cookie{'-name'} && $cookie{'-name'}) {
 $cookie{'-path'} ||= '/';
 $cookie{'-name'} = escape($cookie{'-name'});
 $cookie{'-value'} = join "&", map { escape(defined $_ ? $_ : '') } $cookie{'-value'};
 my $spc = '; ';
 my $cookie = $cookie{'-name'}.'='.$cookie{'-value'};
 $cookie .= $spc.'domain='.$cookie{'-domain'}
  if exists $cookie{'-domain'} && $cookie{'-domain'};
 $cookie .= $spc.'path='.$cookie{'-path'}
  if $cookie{'-path'};
 $cookie .= $spc.'expires='.expires($cookie{'-expires'},'cookie')
  if exists $cookie{'-expires'} && $cookie{'-expires'};
 $cookie .= $spc.'max-age='.expire_calc($cookie{'-max_age'})-time()
  if exists $cookie{'-max_age'} && $cookie{'-max_age'};
 $cookie .= $spc.'secure'
  if exists $cookie{'-secure'} && $cookie{'-secure'};
 $cookie .= $spc.'HttpOnly'
  if exists $cookie{'-httponly'} && $cookie{'-httponly'};
 return $cookie;
}
 else { return ''; }
}

#sub make_cookie {
#my ($self, %cookie) = @_;

#if (exists $cookie{'-name'} && $cookie{'-name'}) {
# $cookie{'-path'} ||= '/';
# $cookie{'-name'} = escape($cookie{'-name'});
# $cookie{'-value'} = join "&", map { escape(defined $_ ? $_ : '') } $cookie{'-value'};
# my @cookie = ( $cookie{'-name'}.'='.$cookie{'-value'} );
# push @cookie,'domain='.$cookie{'-domain'}
#  if exists $cookie{'-domain'} && $cookie{'-domain'};
# push @cookie,'path='.$cookie{'-path'}
#  if $cookie{'-path'};
# push @cookie,'expires='.expires($cookie{'-expires'},'cookie')
#  if exists $cookie{'-expires'} && $cookie{'-expires'};
# push @cookie,'max-age='.expire_calc($cookie{'-max_age'})-time()
#  if exists $cookie{'-max_age'} && $cookie{'-max_age'};
# push @cookie,'secure'
#  if exists $cookie{'-secure'} && $cookie{'-secure'};
# push @cookie, 'HttpOnly'
#  if exists $cookie{'-httponly'} && $cookie{'-httponly'};
# return join '; ', @cookie;
#}
# else { return ''; }
#}

sub escape {
 my $text = shift;
 return undef unless defined $text;
 $text =~ s/([^a-zA-Z0-9_.~-])/ uc sprintf "%%%02x",ord $1 /eg;
 return $text;
}

1;

__END__

=pod
=head1 COPYLEFT

Flex_CGI.pm, v0.09 05/05/2016 N.K.A

This file is part of Flex-WPS Evo3.
Flex_CGI.pm is a highly optimized remake of some parts of CGI.pm.
After reviewing the way CGI.pm was made I found it to be unoptimized and
porly designed! For this portal there was no advantage in continuing to use CGI.pm,
since it's very heavy, slow, it's band-aid fixes where not re-factored for the rest of the code!
I think this has a lot to do with the module being originaly
desinged before the concept of re-factoring.
I liked CGI.pm for over 7 years and still do. But I wanted my stuff to run faster and
making this module was one way to get some speed.

history
v0.09 - 5/5/2016
Added Access-Control-Allow-Origin: to header -origin => '*'

v0.08 - 09/13/2011
added HTTP/1.1 Cache-Control: to the Header: header(-cache_con => 'no-cache, must-revalidate, est...')

v0.07 - 01/20/2011
added param_more

=cut
