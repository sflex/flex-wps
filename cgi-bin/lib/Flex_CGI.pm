package Flex_CGI;

use strict;
use warnings;
                           
our $VERSION = 0.10;

# global settings
our $POST_MAX            = 1024 * 100;  # limit total parsing size to 100kb
our $GET_MAX             = 1024 * 100;  # limit total parsing size to 100kb
our $COOKIE_MAX          = 1024 * 100;  # limit total parsing size to 100kb
our $NO_UNDEF_PARAMS     = 1;           # parameters exist with blank values
our $HEADERS_ONCE        = 1;           # print the Header once
our $NPH                 = 0;           # not used on apache
our $VIRTUAL_URL         = 1;           # Virtual URL
#our $SET_CRLF            = '';          # auto defined

my $flex_error   = '';
my %QUERY        = ();
my %QUERY_more   = ();
my %COOKIES      = ();
my $header_ct    =  0;
my @virtual_url  = ();

our $EBCDIC      = 0;

our $CRLF;
$EBCDIC = "\t" ne "\011";

if ($^O =~ /^VMS/i) {
  $CRLF = "\n";
} elsif ($EBCDIC) {
  $CRLF= "\r\n";
} else {
  $CRLF = "\015\012";
}

sub new {
# was thinking mod_perl may need this, test...
%QUERY        = ();
%QUERY_more   = ();
%COOKIES      = ();
@virtual_url  = ();

# avoid large parsing
my $query_string = $ENV{'QUERY_STRING'} || $ENV{'REDIRECT_QUERY_STRING'} || '';
my $raw_cookie   = $ENV{'HTTP_COOKIE'}  || $ENV{'COOKIE'} || '';
my $request_URI  = $ENV{'REQUEST_URI'}  || '';

my $COOKIE_LENGTH = length($raw_cookie)    || 0;
my $POST_LENGTH   = $ENV{'CONTENT_LENGTH'} || 0;
my $GET_LENGTH    = length($query_string)  || 0;

 if ($POST_LENGTH && $POST_MAX > 0 && $POST_LENGTH > $POST_MAX
  || $GET_LENGTH && $GET_MAX > 0 && $GET_LENGTH > $GET_MAX
  || $COOKIE_LENGTH && $COOKIE_MAX > 0 && $COOKIE_LENGTH > $COOKIE_MAX) {
  # 413 status code to header also?
  $flex_error .=
'413 Request entity too large: '.$POST_LENGTH.' bytes '.$GET_LENGTH.' bytes '
.$COOKIE_LENGTH.' bytes. Limit is: '.$POST_MAX.'! IP:'.$ENV{'REMOTE_ADDR'}."\n";
 }
  else {
  # Flex WPS doesnt use much so it doesnt do much.
  # POST, PUT, GET, HEAD....
  if ($POST_LENGTH || $GET_LENGTH) {
  # use post over get because get is default
  if ($ENV{'REQUEST_METHOD'} eq 'POST'
   || $ENV{'REQUEST_METHOD'} eq 'PUT') {
   $query_string = undef;
   read(\*STDIN, $query_string, $POST_LENGTH); # post
  }

   for (split '[&;]', $query_string) {
    my ($name, $value) = map { url_decode($_) } split('=', $_, 2);
    next if ! defined $name  || $name eq ''
     || $NO_UNDEF_PARAMS && ! defined $value;
    $value = '' unless defined $value;
    $QUERY{$name} ||= $value;
    # multi param array - new
    push(@{$QUERY_more{$name}},$value);
   }
  }
  
  # Cookies
  if ($COOKIE_LENGTH) {
   for (split '[;,] ?', $raw_cookie) {
    s/\A\s+|\s+\z//g; # Remove all whitespace at start and end
    my ($key,$value) = map { url_decode($_) } split('=', $_, 2);
    next if ! defined $key || $key eq '' || ! defined $value;
    my @values = ();
    if ($value ne '') {
     @values = split('[&;]', $value, -1);
    }
    $COOKIES{$key} ||= ( @values ) ? "@values" : '';
   }
  }
  # Virtual URL www.place.com/this/virtual/URL/is/found
  # instead of www.place.com?op=this;path=virtual;setting=URL;place=is;action=found
  # and/or writing a very involved apache RewriteRule just to get the virtual URL to work.
  # must use some apache mod_rewrite to get to the script and the rest is easy.
  # # this "First" one is for only www.place.com/test
  # RewriteRule ^test$ /cgi-bin/index.tgi?op=view,test
  # # the last one is for anything more than that www.place.com/test/est...
  # RewriteRule ^test/.*?$ /cgi-bin/index.tgi?op=view,test
  #            This^up^here is the URI     This^up^here is the query string
  # apache 2.4 enviroment the query sting will only have the content provided in
  # the apache RewriteRule.
  #
  # then have the script use this modules virtual_url method
  # to parse the REQUEST_URI, it returns an array in the order expected
  # in this path there are three blank spots that will get added to the array
  # www.place.com//place//or/here/
  #          here^  here^        ^There at the end! because of the slash /
  if ($VIRTUAL_URL && $request_URI) {
  # take out first slash and ? beyond
    $request_URI =~ s/\A\/|\?.*?\z//g;
    @virtual_url = map { url_decode($_) } split ('/', $request_URI, -1);
  }
  
 }
 
 return bless {};
}

sub DESTROY {

}

# pull the 2nt element of the array, nice and clean way.
# my $second_value = ($query->virtual_url())[1] || '';
sub virtual_url {
 my $self = shift;
  @virtual_url
   ? return @virtual_url : return ();
}

sub url_decode {
 my $decode = shift || '';
 if ($decode) {
  $decode =~ tr/+/ /;
  $decode =~ s/%([\da-fA-F]{2})/ pack "C", hex $1 /eg;
  $decode =~ s/\r//g; # windows and *nix fix
 }
 return $decode;
}

sub url_encode { # check case
 my $encode = shift || '';
 if ($encode) {
  $encode =~ s/([^a-z0-9\-_.!~*'() ])/ uc sprintf "%%%02x",ord $1 /egi;
  $encode =~ tr/ /+/;
 }
 return $encode;
}

# get/set last cgi_error
sub cgi_error {
 my $self = shift;
 my $error = shift;
 defined $error && $error
 ? $flex_error .= $error."\n" : return $flex_error;
}

sub params {
my $self = shift;
return %QUERY;
}

sub param {
 my $self = shift;
 my $name = shift;
 my $return_this = '';
 $return_this = undef if ! $NO_UNDEF_PARAMS;
  (defined $name && exists $QUERY{$name})
   ? return $QUERY{$name} : return $return_this;
}
# maybe do an array like the others
sub multi_param{
 my $self = shift;
 my $name = shift;
  defined $name && exists $QUERY_more{$name}
   ? return @{$QUERY_more{$name}} : return ();
}

sub cookies {
my $self = shift;
return %COOKIES;
}

sub cookie {
 my $self = shift;
 my $name = shift;
  defined $name && exists $COOKIES{$name}
   ? return $COOKIES{$name} : return '';
}

sub redirect {
my $self = shift;
my %red  = @_;
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

sub clear_head {
 local $_ = shift;
 return m/(?:\015\012[\040|\011]+|\015|\012|$CRLF)/g;
}
# Security headers, have to add an option for more inputed headers
# http://perltricks.com/article/81/2014/3/31/Perl-web-application-security---HTTP-headers/
# X-Content-Security-Policy: default-src 'self'
sub header {
my $self = shift;
my %header = @_;
my $header = '';
 # Flex (WPS) has no need to unfold anything.
 # To add security from injection or malformed header it works per RFC 7230.
 # Setting status to 400, clearing out the bad stuff because we want the good
 # default values and send an error to cgi_error. Thats the way it should work.
  foreach my $key (keys %header) {
   if ($key eq '-cookie') {
    for (ref($header{'-cookie'}) eq 'ARRAY' ? @{$header{'-cookie'}} : $header{'-cookie'}) {
     if (defined $_ && clear_head($_)) {
     $flex_error .= '400 (Bad Request) malformed header. at Flex_CGI.pm'."\n";
     $header{'-status'} = '400 Bad Request';
     $header{'-connection'} = 'close';
     $header{'-cookie'} = '';
     last;
     }
    }
   }
    else {
    if (defined $header{$key} && clear_head($header{$key}) ) {
     $header{$key} = '';
     $header{'-status'} = '400 Bad Request';
     $header{'-connection'} = 'close';
     $flex_error .= '400 (Bad Request) malformed header. at Flex_CGI.pm'."\n";
     }
    }
  }
  
 if ($HEADERS_ONCE && ! $header_ct || ! $HEADERS_ONCE) {
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
  

  $header{'-status'}     ||= '200 OK';
  #$header{'-connection'} ||= 'close' # Keep-Alive is faster, this wasnt right
  # if $header{'-status'} !~ /\A1/; # rfc7230#section-6.1,#section-6.6
   
  my $protocol = $ENV{'SERVER_PROTOCOL'} || 'HTTP/1.0';
  push(@header,$protocol . ' ' . $header{'-status'}) if $NPH;
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
  push(@header,'Expires: '. expires($header{'-expires'},'http'))
   if exists $header{'-expires'} && $header{'-expires'};
  push(@header,'Date: ' . expires(0,'http'))
   if exists $header{'-expires'} && $header{'-expires'}
   || exists $header{'-cookie'} && $header{'-cookie'} || $NPH;
  # v0.08 : Cache-Control: xx; HTTP/1.1
  push(@header,'Cache-Control: '.$header{'-cache_con'})
   if exists $header{'-cache_con'} && $header{'-cache_con'};
  #
  # v0.09 Access-Control-Allow-Origin
  push(@header,'Access-Control-Allow-Origin: '.$header{'-origin'})
   if exists $header{'-origin'} && $header{'-origin'};
  #
  push(@header,'Pragma: no-cache') if exists $header{'-cache'} && $header{'-cache'};
  push(@header,'Content-Disposition: attachment; filename="'.$header{'-attachment'}.'"')
   if exists $header{'-attachment'} && $header{'-attachment'};

  if (exists $header{'-location'}) {
   push(@header,'Location: ' . $header{'-location'});
   $type = '';
  }
  # Content-Length:
  push(@header,'Content-Length: '.$header{'-length'})
   if exists $header{'-length'} && $header{'-length'} =~ m/\A\d+\z/;
  # Connection: close
  push(@header,'Connection: '.$header{'-connection'})
   if exists $header{'-connection'};
   
  push(@header,'Content-Type: '.$type) if $type ne '';
  $header = join($CRLF,@header).$CRLF.$CRLF;
  $header_ct = 1 if $HEADERS_ONCE;
 }
  else {
  # set to string for speed
  $flex_error .=
  'One set of header\'s was printed: this action is default by the $HEADERS_ONCE variable.'."\n";
 }
 # return header or nothing ''
 return $header;
}

# This internal routine creates date strings suitable for use in
# cookies and HTTP headers.  (They differ, unfortunately.)
# Thanks to Mark Fisher for this.
sub expires {
    my $time = shift;
    my $format = shift || 'http';
    #$format ||= 'http';

    my @MON = qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/;
    my @WDAY = qw/Sun Mon Tue Wed Thu Fri Sat/;

    # pass through preformatted dates for the sake of expire_calc()
    $time = expire_calc($time);
    return $time unless $time =~ /^\d+$/;

    # make HTTP/cookie date string from GMT'ed time
    # (cookies use '-' as date separator, HTTP uses ' ')
    my $sc = ' ';
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
    my $time = shift;
    my %mult = ('s'=>1,
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
    my $offset;
    if (!$time || lc($time) eq 'now') {
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
my $self = shift;
my %cookie = @_;
my $cookie = '';

if (exists $cookie{'-name'} && $cookie{'-name'}) {
 $cookie{'-path'} ||= '/';
 $cookie{'-name'} = escape($cookie{'-name'});
 $cookie{'-value'} = join '&', map { escape(defined $_ ? $_ : '') } $cookie{'-value'};  # "&"
 my $spc = '; ';
 $cookie = $cookie{'-name'}.'='.$cookie{'-value'};
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
 }
  return $cookie;
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
 $text =~ s/([^\w.~-])/ uc sprintf "%%%02x",ord $1 /egi;
 return $text;
}

1;

__END__

=pod
=head1 COPYLEFT

Flex_CGI.pm, v0.11 08/16/2016 N.K.A

This file is part of Flex-WPS Evo3.
Flex_CGI.pm was a highly optimized remake of some parts of CGI.pm.
This does not have a lot of old support,
target support is *nix, windows, Apache Only
does param, header, cookies, virual url


History
Adding bits of rfc 7230 standars but I have not read the hole standard yet.
So I can not call the update to rfc 7230 100% done.

v0.11 - 8/20/2016
Added Virtual URL www.place.com/this/virtual/URL/is/found
 instead of www.place.com?op=this;path=virtual;setting=URL;place=is;action=found
Added Content-Length:
Added error if header values are folded or malformed.
returns a safe defualt header with protocal status set to 400 bad request.
to use the new security you can do this or come^^up^^with your own^^.
        my $header = $q->header(); # put the header in a string
        (! $q->cgi_error()) # Check error befor print
         ? print $header # print good header
         : die($q->cgi_error()); # or die with error

v0.10 - 8/9/2016
Fixed param and cookies adding of blank names.
made it even faster in the hole script every subroutine was tweaked a little to a lot.
changed param_more to multi_param and it returns an array.
tested multi_param, params, param, cookie and cookies and they all operate correctly.
cgi_error delimits all new errors with a new line \n

v0.09 - 5/5/2016
Added Access-Control-Allow-Origin: to header -origin => '*'

v0.08 - 09/13/2011
added HTTP/1.1 Cache-Control: to the Header: header(-cache_con => 'no-cache, must-revalidate, est...')

v0.07 - 01/20/2011
added param_more

=cut
