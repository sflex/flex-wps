package Captcha;
# Flex - WPS SQL
# Captch - GD::SecurityImage
# version 2.1
# By: N.K.A.
# 5/5/2016
# New 2.1: Supports IE# & other browsers to disable cache for AJAX
# Some phones have this issue now.
# 7-30-2016 = Fix defined warning ! defined $in_action

use strict;
# Assign global variables.
use vars qw(
    %user_action %cfg %user_data %usr
    $query @rand_key $sec_key
    $Flex_WPS
    );
use Flex_Porter;
use lib '/home2/autotec5/perl/usr/lib/perl5/site_perl/5.8.8';

# Define possible user actions.
%user_action = ( ajax_get => $usr{anonuser}, image => $usr{anonuser},);

$cfg{captchadbdir} = $cfg{portaldir} . "/Captcha";

sub image {
 my $image_number   = $query->param('i') || '';
 my $size   = $query->param('a') || '';
 my $security_check   = $query->param('s') || '';
$security_check = $Flex_WPS->untaint2(value => $security_check, pattern => '0-9a-z',);
$image_number = $Flex_WPS->untaint2(value => $image_number, pattern => '0-9\|',);

if (!$security_check || !$image_number) {
print "Content-type: text/html\n\n";
exit(0);
}
 elsif ($size && $size ne 'small') {
print "Content-type: text/html\n\n";
exit(0);
}
 else {
my $width = 375;
my $hight = 100;
my $font_size = 55;
my $lines = 30;
#my $particle = '350 * 50';
my $particle2 = 50;
my $font_size2 = 10;
my $text = ' Type The Black Letters You See. ';

    if ($size eq 'small') {
    $width = 165;
    $hight = 60;
    $font_size = 24;
    $font_size2 = 7;
    $text = ' Type The BLACK Letters Only ';
    $lines = 5;
    #$particle = '350 * 20';
    $particle2 = 2;
    }

$cfg{captchadbdir} = $cfg{portaldir} . "/Captcha";
require "$cfg{captchadbdir}/rand_key.pl";
my $secret_letter = '';
my $bad = '';

my @stuff = split /\|/, $image_number;
foreach my $let (@stuff) {
        $bad = 1 if !$rand_key[$let];
        last if $bad;
        $secret_letter .= $rand_key[$let];
        }
 $bad = 1 if $secret_letter !~ m/\A\w{6}\z/i;
 # check if key is ok
 $security_check =~ s/(\d{10})\z//;
 my $date = $1;
 $bad = 1 if !$date;
 my $current = time;
 $bad = 1 if $date+360 < $current;
 my $seckey = $secret_letter;
 $seckey .= $ENV{'REMOTE_ADDR'} . $date;
 $seckey = $Flex_WPS->sha1_code(code1 => $seckey, code2 => $sec_key,);
 $bad = 1 if $security_check ne $seckey;

 if ($bad) {
      print "Content-type: text/html\n\n";
      exit(0);
 }
  else {
   use GD::SecurityImage;
   #my $font  = "$cfg{captchadbdir}/LASVEGSN.TTF";
   my $font = "$cfg{captchadbdir}/arialbd.ttf";
   #my $font  = "$cfg{captchadbdir}/PROGBOT.TTF";
   #my $font  = "$cfg{captchadbdir}/Vivaldii.TTF";

   my $image = GD::SecurityImage->new(
      width  =>   $width,
      height =>    $hight,
      ptsize =>    $font_size,
      lines => $lines,
      rndmax =>     0, # keeping this low helps to display short strings
      frame  =>     0, # disable borders
      font   => $font,
      scramble => 0,
      angle => 0,
      bgcolor    => '#eff5fa',
      gd_font => 'Larg',
   );

      $image->random($secret_letter);
      $image->create('ttf', 'ec', '#000000', '#000000');
      die "Error loading ttf font for GD: $@" if $image->gdbox_empty;
      #$image->particle($particle, $particle2);

   $image->info_text(
      text   => $text,
      ptsize => $font_size2,
      strip  =>  1,
      color  => '#0094CC',
   );
   $image->info_text(
      text   => ' (c) 2007 Flex-WPS ',
      ptsize => $font_size2,
      strip  =>  1,
      color  => '#0094CC',
      'y'      => 'down',
      );

   my($image_data, $mime, $random_number) = $image->out;

   binmode STDOUT;
   print <<"IMAGE";
Content-Type: image/$mime

$image_data
IMAGE
   exit(0);
   }
 }
}

sub ajax_get {
my $a   = $query->param('a') || '';
$a = '' unless ($a eq 'small');
require "$cfg{captchadbdir}/rand_key.pl";
my ($secret_word, $secret_images) = ('','');
  for my $i (1..6) {
     my $letter_index = int(rand 994);
     $secret_images .= "$letter_index|" if $i ne 6;
     $secret_images .= "$letter_index" if $i eq 6;
     my $secret_letter = $rand_key[$letter_index];
     $secret_word .= $secret_letter;
  }

  my $start_time = time;
  $secret_word .= $ENV{'REMOTE_ADDR'} . $start_time;
  my $security_key2 = $Flex_WPS->sha1_code(code1 => $secret_word, code2 => $sec_key,);
  my $set = <<"HTML";
<img class="brdr pure-img-responsive" src="$cfg{pageurl}/index.$cfg{ext}?op=image,Captcha;a=$a;i=$secret_images;s=$security_key2$start_time" alt="captcha" /><br />
<span class="bacdkr"><img class="pure-img-responsive" src="$cfg{imagesurl}/icon/lamp.gif" alt="hint" /> <small>Not Case Sensitive and<br />Do not use vowels (ie: A,E,I,O,U.)</small></span><br />
<input type="text" name="security_key" class="pure-input-rounded" placeholder="Captcha code..." value="" />
<input type="hidden" name="date_captcha" value="$security_key2$start_time" /><br />
HTML
#print "Content-type: text/html\n\n";
# New: Supports IE# & other browsers to disable cache for AJAX
# Some phones have this issue now.
#    '-Cache-Control' => $cache_val,
#    '-Access-Control-Allow-Origin' => $origin_val,
# maybe make a $cfg{origin}
 print $query->header(
        -expires => 'now',
        -charset => $cfg{codepage},
        '-Access-Control-Allow-Origin' => '*', # Wild card HTTP/1.1
        '-Cache-Control' => 'no-store, no-cache, must-revalidate', # HTTP/1.1
        -cache => 1, # HTTP/1.0
 );
print $set;
 exit(0);
}

sub get_image {
# Function: Captcha Auth & Get Images
# Usage: See Top of file!
# has a cache issue with the current image
# Code: Captcha 2-2
# Edit at your own Risk

my ($in_action, $seckey, $date_ch) = @_;

if (! defined $in_action || $in_action eq 'small') {
$in_action = '' unless $in_action;
require "$cfg{captchadbdir}/rand_key.pl";
my ($secret_word, $secret_images) = ('','');
  for my $i (1..6) {
     my $letter_index = int(rand 994);
     $secret_images .= "$letter_index|" if $i ne 6;
     $secret_images .= $letter_index if $i eq 6;
     my $secret_letter = $rand_key[$letter_index];
     $secret_word .= $secret_letter;
  }

  my $start_time = time;
  $secret_word .= $ENV{'REMOTE_ADDR'} . $start_time;
  my $security_key2 = $Flex_WPS->sha1_code(code1 => $secret_word, code2 => $sec_key,);
  my $set = <<"HTML";
<img class="brdr pure-img-responsive" src="$cfg{pageurl}/index.$cfg{ext}?op=image,Captcha;a=$in_action;i=$secret_images;s=$security_key2$start_time" alt="captcha" /><br />
<span class="bacdkr"><img class="pure-img-responsive" src="$cfg{imagesurl}/icon/lamp.gif" alt="hint" /> <small>Not Case Sensitive and<br />Do not use vowels (ie: A,E,I,O,U.)</small></span><br />
<input type="text" name="security_key" class="pure-input-rounded" placeholder="Captcha code..." value="" />
<input type="hidden" name="date_captcha" value="$security_key2$start_time" /><br />
HTML

  return $set;
}
 else { # new
# Captcha Auth
 if(!$seckey || !$date_ch) { return 0; }
 $seckey = uc($seckey);
 $date_ch =~ s/(\d{10})\z//;
 my $date = $1;
 return 0 if !$date;
 my $current = time;
 return 0 if $date+360 < $current;
 $seckey .= $ENV{'REMOTE_ADDR'} . $date;
 require "$cfg{captchadbdir}/rand_key.pl";
 $seckey = $Flex_WPS->sha1_code(code1 => $seckey, code2 => $sec_key,);
 if($date_ch eq $seckey) { return 1; }
 else { return 0; }
 }
}
1;
