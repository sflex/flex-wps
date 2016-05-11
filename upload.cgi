#!perl

=head1 COPYLEFT

 upload.cgi, v1.0 08/06/2010 N.K.A

 This file is part of Flex-WPS Evo3.
 Image upload.
 
Notes: Because of the Header security we have to use this file upload.cgi
for uploading files.

=cut

$| = 1;

use strict;
use warnings;
use vars qw(%mysql $Flex_WPS $AUBBC_mod %user_data %cfg %usr %user_action);

use lib 'lib';
use exporter;
use Flex_WPS;

$Flex_WPS = Flex_WPS->new();
use CGI qw(:standard);
$CGI::POST_MAX        = 1024 * 1024;
$CGI::DISABLE_UPLOADS = 0;
my $cgi_pt = new CGI;
# get database info
require "$cfg{log_path}/db/config.pl";
# Connect to a database and return a special name
my $DB_Name = $Flex_WPS->SQL_Connect(
        backend_name => $mysql{backendname},
        username => $mysql{username},
        password => $mysql{password},
        host => $mysql{host},
        port => $mysql{port},
        DBI_Settings => { 'RaiseError' => 1, 'AutoCommit' => 1, },
        );

# Load portal settings
$Flex_WPS->Portal_Config(
        backend_name  => $DB_Name,
        portal_config => 1,
        Auth_DB      => '',
        Theme_DB     => '',
        SubLoad_DB   => '',
        Portal_DB    => '',
        );

# Load CGI.pm and return the object
my $query = $Flex_WPS->Load_CGI(
        max_upload_size => 1024,
        cgi             => 0,
        );

# Authenticate user
%user_data = $Flex_WPS->Auth_Session();

# Load AUBBC mod
$AUBBC_mod = $Flex_WPS->Load_AUBBC( Debug => 0 );
$AUBBC_mod->settings(
        images_url => $cfg{imagesurl},
        html_type => 'xhtml',
        code_class => ' class="codepost"',
        code_extra => '<div style="clear: left"> </div>',
        quote_class => ' class="border"',
        quote_extra => '<div style="clear: left"> </div>',
        script_escape => 0,
        protect_email => 4,
        highlight_class1 => ' class="highlightclass1"',
        highlight_class2 => ' class="highlightclass2"',
        highlight_class3 => ' class="highlightclass1"',
        highlight_class4 => ' class="highlightclass1"',
        highlight_class5 => ' class="highlightclass5"',
        highlight_class6 => ' class="highlightclass6"',
        highlight_class7 => ' class="highlightclass7"',
        );

# Load Subload
$Flex_WPS->SubLoad(location => 1,);

my $op = $cgi_pt->param('op') || '';
my $pic = $cgi_pt->param('pic') || '';

my $name = '';
my $up_count = 1;

$cfg{gallerydir} = "$cfg{imagesdir}/uploads/profile/$user_data{id}";
my $allowEightbit = 1;

# Define possible user actions
if ($cfg{core_error}) {
$Flex_WPS->core_error('Image was to big, keep it under 512kb at upload image');
}
 elsif ($user_data{sec_level} eq $usr{anonuser}) {
 $Flex_WPS->core_error('You can not post any more listings at post limit');
} else {

if (! -d $cfg{gallerydir}) {
mkdir($cfg{gallerydir}, 0755) or $Flex_WPS->core_error($!);
}

%user_action = (
 upload => \&upertt,
 final => \&final,
 page => \&page
 );

if ($user_action{$op}) {
$user_action{$op}->();
}
else {
 page();
 }
}

sub upertt {

        # Image Error and Header module.
        use Image::ExifTool 'ImageInfo';
        my $exifTool = new Image::ExifTool;
        $exifTool->Options(Binary => 1, Composite => 1, DateFormat => '%Y:%m:%d %H:%M:%S', Unknown => 2, Verbose => 0);

        # Process image upload.
        my ($filename, $filename2, $upload_filehandle, $buffer, $err_msg) = ('','','','','');
        my $up_ct = 0;
        # Get the form input and assign the variables.
        foreach my $key (sort {$a cmp $b} $cgi_pt->param()) {
        last if $err_msg;
        last if $up_ct == $up_count;
                next if ($key =~ /\A\s*\z/);
                next if ($cgi_pt->param($key) =~ /\A\s*\z/);
                next if ($key !~ /\Apicture_[\d]+\z/);

                unless ($cgi_pt->param($key) =~ /([^\/\\]+)\z/) {
                        $err_msg = '1) File Not Writable! at upload param check';
                        last;
                }

                $up_ct++;
                $filename = $1;
                $filename =~ s/^\.+//;
                # Extension Check
                unless ($filename =~ m/\.(?:GIF|JPG|PNG)\z/i) {
                         $err_msg = '1) Only gif, jpg and png files allowed! at upload Extension';
                         last;
                }

                           my $pic_count = 1;
                           $filename =~ s/\A(.*?)\.([^\.]+)\z/$1/;
                           my $extens = '.' . $2;
                           $filename = $user_data{id}.$extens;
                      if (-r ("$cfg{gallerydir}/$filename")) {
                           while ($pic_count) {
                                   if (-r ("$cfg{gallerydir}/$pic_count$extens")) {
                                        $pic_count++;
                                        next;
                                   }
                                   else {
                                         $filename = $pic_count . $extens;
                                         last;
                                   }
                           }
                      }

                $filename2 = $filename;
                $filename = "$cfg{gallerydir}/$filename";
                # returns a filehandle
                $upload_filehandle = $cgi_pt->upload($key);

                # Save image.
                # Will Overwright files with '>'
                unless (open (FH, '>', $filename)) {
                        $err_msg = '2) File Not Writable! at upload open';
                        last;
                }

                binmode (FH);

                while (<$upload_filehandle>) {
                         # This is realy not needed.
                         # But its one way to find some text files.
                         if ($_ =~ m/(?:<(?:html|HTML|script|SCRIPT)>|<\?php|<!--(?:.|\n)\*-->)/i) {
                         $err_msg = '2) Only gif, jpg and png files allowed! at upload text/html';
                         last;
                         }
                         else {
                               print FH $_;
                         }
                }

                close FH;

                # Stop loop on error
                if ($err_msg) {
                     unlink($filename);
                     last;
                }

                # Hmmmmm.......
                chmod 0644, $filename;

                # Check File Size 1 mb.
                my $size = (stat($filename))[7];
                unless ($size && $size < (1024 * 1024)) {
                     unlink($filename);
                     $err_msg = '1) File was to Big. at upload Bytes: ' . $size;
                     last;
                }

                # Get file info
                my $info = $exifTool->ImageInfo($filename);

                # File Format Warning or Error
                if ($$info{Warning} || $$info{Error}) {
                      unlink($filename);
                      $err_msg = '2) File format error. at upload format';
                      last;
                }
                # File x, y and Type
                unless ($$info{FileType} && $$info{ImageWidth} && $$info{ImageHeight} && $$info{ImageWidth} < 2000 && $$info{ImageHeight} < 2000
                && ($$info{FileType} eq 'JPG' || $$info{FileType} eq 'GIF' || $$info{FileType} eq 'PNG'|| $$info{FileType} eq 'JPEG')) {
                        unlink($filename);
                        $err_msg = '2) Only gif, jpg and png files allowed! at upload ' . "$$info{FileType} && $$info{ImageWidth} && $$info{ImageHeight}";
                        last;
                }

                # Test all
              #  my $info = $exifTool->ImageInfo($upload_filehandle, \%options);
#                 my $stuff ='';
#                 if ($info || !$info) {
#                     unlink($filename);
#                    foreach (sort keys %$info) {
#                    $stuff .= "$_ => $$info{$_}<br>\n";
#                    }
#                      $err_msg = '8) Only gif, jpg and png files allowed! at upload ' . $stuff;
#                      last;
#                 }

        }


if ($err_msg) {
 $Flex_WPS->core_error($err_msg);
}
 else {
 print $query->redirect(-location=>"$cfg{pageurl}/upload.$cfg{ext}?op=final;pic=$filename2");
 }
}

sub final {
print "Content-type: text/html\n\n";
print <<HTML;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Upload Screen</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<script type="text/javascript">

window.onload = addCode;

function addCode() {
 if (opener.document.getElementById("form1")) {
  opener.document.form1.text.value+='[right_img]$cfg{imagesurl}/uploads/profile/$user_data{id}/$pic\[/img]';
 } else {
  opener.document.creator.message.value+='[right_img]$cfg{imagesurl}/uploads/profile/$user_data{id}/$pic\[/img]';
 }
}
</script>
</head>

<body bgcolor="#FFFFFF" text="#000000">
<center>Upload(s) Successful!<br />
<img src="$cfg{imagesurl}/uploads/profile/$user_data{id}/$pic" alt="" />
<br />
<a href="javascript:window.close();">Close Window</a></center>
</body>
</html>
HTML

}
sub page {
#        require UBBC;
#        my $ubbc_panel = UBBC::print_ubbc_panel();
#my $option_print = <<HTML;
#<select name="cat">
#<option value="">Select Category</option>
#HTML
#my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
#"SELECT `id` , `title`
#FROM `listing_cats`
#");
#$sth->execute;
#while(my @row = $sth->fetchrow)  {

#$option_print .= <<HTML;
#<option value="$row[0]">$row[1]</option>
#HTML

#}
#$sth->finish();

#$option_print .= <<HTML;
#</select>
#HTML
print "Content-type: text/html\n\n";
print <<HTML;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Upload Screen</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

</head>

<body bgcolor="#FFFFFF" text="#000000">

<form name="creator" action="$cfg{pageurl}/upload.$cfg{ext}" method="post" enctype="multipart/form-data">
<input name="op" type="hidden" value="upload">
<table border="0" cellpadding="1" cellspacing="0">
HTML

        foreach (1 .. $up_count) {
        my $picnum = '';
        $picnum = $_ if $up_count > 1;
                print <<HTML;
<tr>
<td><b>Picture:</b> Upload GIF, JPG, JPEG or PNG</td>
</tr>
<tr><td width="20">&nbsp;</td>
</tr>
<tr>
<td><input name="picture_$_" type="file" accept="image/gif,image/jpg"></td>
</tr>
HTML
        }

        print <<HTML;
<tr>
<td><input type="submit" value="Save Image"></td>
</tr>
<tr>
<td><center><a href="javascript:window.close();">Close Window</a></center></td>
</tr>
</table>
</form>
</body>
</html>
HTML
}

#sub check_listings {
#my ($user_in, $group_in) = @_;
#return '' if ! $user_in;

#my $listing_ct = '';
#$user_in = $back_ends{$cfg{Portal_backend}}->quote($user_in);
#my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM listing_user WHERE user_id = $user_in LIMIT 1 ;");
#$sth->execute;
#while(my @row = $sth->fetchrow)  {
#$listing_ct = $row[2] if $row[0];
# }
# $sth->finish();
#my $check_listing = '';
#$check_listing = 'a' if ! $listing_ct && $listing_ct ne 0;
#if (! $check_listing) {

#my @groups_settings = split(/\|/, $user_settings);
#foreach my $groupd (@groups_settings) {
# my ($agroup, $acount) = split(/\,/, $groupd);
#    if ($group_in eq $agroup) {
#       $check_listing = 1 if $listing_ct < $acount;
#    }
#}
#}
#return $check_listing;
#}
1;
