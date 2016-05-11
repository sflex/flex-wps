package Gallery;
=head1 Flex-WPS, Gallery.pm

by N. K. A.

 shakaflex@gmail.com
 http://search.cpan.org/~sflex/

 Version: 1.0 beta 1
Date: 06/26/2011
Converted to Evo 3

=cut

use strict;
# Assign global variables.
use vars qw(
    %err $query %cfg $Flex_WPS %user_action
    %usr %user_data $AUBBC_mod %back_ends
    );
use exporter;

# Define possible user actions.
%user_action = (
 cat_view => $usr{anonuser},
 sub_cat => $usr{anonuser},
 view => $usr{anonuser},
 add_cat => $usr{admin},
 add_cat2 => $usr{admin},
 add_subcat => $usr{admin},
 add_subcat2 => $usr{admin},
 add_pic => $usr{admin},
 add_pic2 => $usr{admin},
 edit_catsub => $usr{admin},
 edit_catsub2 => $usr{admin},
 delete_pic => $usr{admin},
 delete_subcat => $usr{admin},
 );

# inputs
my $name = $query->param('name');
my $cat = $query->param('cat'); # allow numbers
my $subcat = $query->param('subcat'); # allow numbers
my $id = $query->param('id'); # allow numbers
my $html = $query->param('html');

my $title = $query->param('title');
my $message = $query->param('message');

$cfg{gallerydir} = "$cfg{imagesdir}/uploads/Gallery";

sub admin_menu {
my $admin_html = '';
    if($user_data{sec_level} eq $usr{admin}) {
     $admin_html .= <<HTML;
<table width="100%" border="1" cellspacing="0" cellpadding="0">
<tr align="center" valign="top">
<td><b>New Gallery</b></td>
<td><b>Current Gallery</b></td>
</tr>
<tr valign="top">
<td><a href="$cfg{pageurl}/index.$cfg{ext}?op=add_cat;module=Gallery">Add Category</a><br>
<a href="$cfg{pageurl}/index.$cfg{ext}?op=add_subcat;module=Gallery">Add Subcategory</a><br>
<a href="$cfg{pageurl}/index.$cfg{ext}?op=add_pic;module=Gallery">Add Pictures</a></td>
<td>
HTML

if ($cat) {
 $admin_html .= <<HTML;
<script language="javascript" type="text/javascript">
<!--
function OOption() {
var MyWindow;
var MyUrl;
MyUrl = '$cfg{pageurl}/upload.$cfg{ext}?op=page;cat=$cat;call_type=Gallery;name=$cat;up_count=1';
MyWindow = window.open(MyUrl, 'Add_Pictures', 'width=400,height=350,status=no,toolbar=no,menubar=no,location=no');
}
// -->
</script>
<a href="javascript:OOption();">Change Category Image</a><br>
<a href="$cfg{pageurl}/index.$cfg{ext}?op=add_subcat;module=Gallery;cat=$cat">Add Subcategory to Current Category</a><br>
HTML
}
if ($cat && $subcat) {
$admin_html .= <<HTML;
<script language="javascript" type="text/javascript">
<!--
function OOOptions() {
var MyWindow;
var MyUrl;
MyUrl = '$cfg{pageurl}/upload.$cfg{ext}?op=page;cat=$cat;subcat=$subcat;call_type=Gallery';
MyWindow = window.open(MyUrl, 'Add_Pictures', 'width=400,height=350,status=no,toolbar=no,menubar=no,location=no');
}
// -->
</script>
<a href="javascript:OOOptions();">Add Pictures to Current Subcategory</a><br>
HTML
}
    $admin_html .= <<HTML;
</td>
</tr>
</table><br>
HTML
    }
    return $admin_html;
}

sub cat_view {
my (@cats, $board_index);
# Get all cats
my $sth = "SELECT * FROM gallery_cat";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
        push (
                @cats,
                join (
                        "|",     $row[0],
                        $row[1], $row[2],
                        $row[3]
                )
            );
}
$sth->finish;
      # Error if no info
      if (!@cats && $user_data{sec_level} ne $usr{admin}) {

          $Flex_WPS->user_error($err{bad_input});
      }

      my $row_color = qq( class="tbl_row_dark");

    # Cycle through all cats and get all subcats for ramdom pic
    foreach (@cats) {
                my (
                        $lid,  $cat_name, $disc, $view_ct
                    )
                    = split (/\|/, $_);
            my @some_sub = ();
            my $subcatnum = 0;
               $sth = "SELECT * FROM gallery_subcat WHERE cat_id='$lid'";
               $sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
               $sth->execute;
               while(my @row = $sth->fetchrow)  {
                    $subcatnum++;
                    push (
                          @some_sub,
                          join (
                                "|", $row[0], $row[1],
                                     $row[2], $row[3],
                                     $row[4]
                                )
                         );
               }
               $sth->finish;
               my @some_pic = ();
               my $num = -1;
               my $admin_edit = '';
               my ($liid, $cat_id, $subcat_name, $discp, $viewct);
    foreach (@some_sub) {
                ($liid, $cat_id, $subcat_name, $discp, $viewct) = split (/\|/, $_);

               $sth = "SELECT * FROM gallery_x WHERE cat_id='$lid' AND subcat_id='$liid'";
               $sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
               $sth->execute;
               while(my @row = $sth->fetchrow)  {
                    $num++;
                    push (
                          @some_pic,
                          join (
                                "|", $row[0], $row[1],
                                     $row[2], $row[3],
                                     $row[4], $row[5]
                                )
                         );
               }
               $sth->finish;
    }
        my $specialhtml = '';
        my $subnum;
        #if (@specials) {
        rand(time ^ $$);
        my @seed = (0 .. $num);
        for (my $i = 0; $i < 1; $i++)
        {
                $subnum .= $seed[int(rand($#seed + 1))];
        }
        for (@some_pic[$subnum]) {
              my ($laid, $cat_id, $subcat_id, $pic_disc, $pic, $count)
                    = split (/\|/, $_);
                 $specialhtml =  qq(<center><a href="$cfg{pageurl}/index.$cfg{ext}?op=view;module=Gallery;cat=$cat_id;subcat=$subcat_id"><img src="$cfg{imagesurl}/uploads/Gallery/$pic" alt="$pic_disc" border="0" width="95" height="95"><br>
<small>$subcat_name</small></a></center>);
                    }

my $admin_catpic = '';
if($user_data{sec_level} eq $usr{admin}) {
$admin_catpic = qq(<script language="javascript" type="text/javascript">
<!--
function Option$lid() {
var MyWindow;
var MyUrl;
MyUrl = '$cfg{pageurl}/upload.$cfg{ext}?op=page;cat=$lid;call_type=Gallery;name=$lid;up_count=1';
MyWindow = window.open(MyUrl, 'Add_Pictures', 'width=400,height=350,status=no,toolbar=no,menubar=no,location=no');
}
// -->
</script>
<a href="javascript:Option$lid();">Change Category Image</a><br>);
$admin_edit = <<HTML;
<br><a href="$cfg{pageurl}/index.$cfg{ext}?op=edit_catsub;module=Gallery;cat=$lid"><img src="$cfg{imagesurl}/forum/modify.gif" alt="modify" border="0"></a>
HTML

}

# Cat pic!
my $new = qq(<img src="$cfg{imagesurl}/uploads/Gallery/$lid/$lid.gif" alt="$cat_name" border="0">);
if (-r ("$cfg{imagesdir}/uploads/Gallery/$lid/$lid.jpg")) {
$new = qq(<img src="$cfg{imagesurl}/uploads/Gallery/$lid/$lid.jpg" alt="$cat_name" border="0">);
}
# add 1 back for true pic count
$num += 1;
$board_index .= <<HTML;
<tr$row_color>
<td width=10>$admin_catpic<a href="$cfg{pageurl}/index.$cfg{ext}?op=sub_cat;module=Gallery;cat=$lid">$new</a></td>
<td>
<b><a href="$cfg{pageurl}/index.$cfg{ext}?op=sub_cat;module=Gallery;cat=$lid">$cat_name</a></b><br>
$disc$admin_edit</td>
<td width="10%" align="center">$subcatnum</td>
<td width="10%" align="center">$num</td>
<td width="20%">$specialhtml</td>
</tr>
HTML

# Alternate the row colors.
$row_color =
  ($row_color eq qq( class="tbl_row_dark"))
  ? qq( class="tbl_row_light")
  : qq( class="tbl_row_dark");
    }


    my $ad_html = admin_menu();
        $board_index = <<HTML;
$ad_html
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<td><img src="$cfg{imagesurl}/forum/open.gif" width="17" height="15" border="0" alt="">&nbsp;&nbsp;
Flex - Gallery Module</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<td>
<table width="100%" border="0" cellspacing="2" cellpadding="4">
<tr class="tbl_header">
<td width="10">&nbsp;</td>
<td><b>Category</b></td>
<td nowrap align="center"><b>Subcat(s).</b></td>
<td nowrap align="center"><b>Pic(s).</b></td>
<td nowrap align="center"><b>Random Picture</b></td>
</tr>
$board_index
</table>
</td>
</tr>
</table>
HTML
        $Flex_WPS->print_page(
                markup       => $board_index,
                cookie1      => '',
                cookie2      => '',
                location     => 'Gallery::cat_view',
                ajax_name    => 'Gallery::cat_view',
                navigation   => 'Gallery',
                );
}

sub  sub_cat {
my ($cat_name, $board_index);
# Get all cats
my $sth = "SELECT * FROM gallery_cat WHERE id='$cat'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
      $cat_name = $row[1];
}
$sth->finish;
      # Error if no info
      if (!$cat_name) {

          $Flex_WPS->user_error($err{bad_input});
      }

      my $row_color = qq( class="tbl_row_dark");

    # Cycle through all cats and get all subcats for ramdom pic

            my @some_sub = ();
            my $subcatnum = 0;
               $sth = "SELECT * FROM gallery_subcat WHERE cat_id='$cat'";
               $sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
               $sth->execute;
               while(my @row = $sth->fetchrow)  {
                    $subcatnum++;
                    push (
                          @some_sub,
                          join (
                                "|", $row[0], $row[1],
                                     $row[2], $row[3],
                                     $row[4]
                                )
                         );
               }
               $sth->finish;


               my ($liid, $cat_id, $subcat_name, $discp, $viewct);
               my $admin_edit = '';
    foreach (@some_sub) {
                ($liid, $cat_id, $subcat_name, $discp, $viewct) = split (/\|/, $_);
              my @some_pic = ();
               my $num = -1;
               $sth = "SELECT * FROM gallery_x WHERE cat_id='$cat' AND subcat_id='$liid'";
               $sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
               $sth->execute;
               while(my @row = $sth->fetchrow)  {
                    $num++ if $row[0];
                    push (
                          @some_pic,
                          join (
                                "|", $row[0], $row[1],
                                     $row[2], $row[3],
                                     $row[4], $row[5]
                                )
                         );
               }
               $sth->finish;
        my $specialhtml = '';
        my $subnum;
        if ($num >= 1) {
        rand(time ^ $$);
        my @seed = (0 .. $num);
        for (my $i = 0; $i < 1; $i++)
        {
                $subnum .= $seed[int(rand($#seed + 1))];
        }
        for (@some_pic[$subnum]) {
              my ($laid, $cat_id, $subcat_id, $pic_disc, $pic, $count) = split (/\|/, $_);
                 $specialhtml =  qq(<center><a href="$cfg{pageurl}/index.$cfg{ext}?op=view;module=Gallery;cat=$cat;subcat=$liid"><img src="$cfg{imagesurl}/uploads/Gallery/$pic" alt="$pic_disc" border="0" width="95" height="95"><br>
<small>$subcat_name</small></a></center>);
                    }
       }
if($user_data{sec_level} eq $usr{admin}) {
$admin_edit = <<HTML;
<br><a href="$cfg{pageurl}/index.$cfg{ext}?op=edit_catsub;module=Gallery;cat=$cat;subcat=$liid"><img src="$cfg{imagesurl}/forum/modify.gif" alt="modify" border="0"></a>
HTML
    if ($num == -1) {
    $admin_edit .= <<HTML;
&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=delete_subcat;module=Gallery;cat=$cat;subcat=$liid" onclick="javascript:return confirm('Are you sure you want to Delete This Subcat?')"><img src="$cfg{imagesurl}/forum/delete.gif" alt="delete" border="0"></a>
HTML
 }
}
# Cat pic!
#my $new = qq(<img src="$cfg{imagesurl}/uploads/Gallery_Cat/$cat.gif" alt="$cat_name" border="0">);
# add 1 back for true pic count
$num += 1;
$board_index .= <<HTML;
<tr$row_color>
<td>
<b><a href="$cfg{pageurl}/index.$cfg{ext}?op=view;module=Gallery;cat=$cat;subcat=$liid">$subcat_name</a></b><br>
$discp$admin_edit</td>
<td width="15%" align="center">$num</td>
<td width="20%">$specialhtml</td>
</tr>
HTML

# Alternate the row colors.
$row_color =
  ($row_color eq qq( class="tbl_row_dark"))
  ? qq( class="tbl_row_light")
  : qq( class="tbl_row_dark");
    }

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "Gallery");
        admin_menu();
        print <<HTML;
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<td><img src="$cfg{imagesurl}/forum/open.gif" width="17" height="15" border="0" alt="">&nbsp;&nbsp;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=cat_view;module=Gallery">Flex - Gallery Module</a>
<br>
<img src="$cfg{imagesurl}/forum/tline.gif" width="12" height="12" border="0" alt=""><img src="$cfg{imagesurl}/forum/open.gif" width="17" height="15" border="0" alt="">&nbsp;&nbsp;$cat_name</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<td>
<table width="100%" border="0" cellspacing="2" cellpadding="4">
<tr class="tbl_header">
<td><b>Subcategory</b></td>
<td nowrap align="center"><b>Pictures</b></td>
<td nowrap align="center"><b>Random Picture</b></td>
</tr>
$board_index
</table>
</td>
</tr>
</table>
HTML

theme::print_html($user_data{theme}, "Gallery", 1);
}

sub view {
my ($cat_name, $sub_cat_name, $sub_cat_disc, $board_index);
# Get all cats
my $sth = "SELECT * FROM gallery_cat WHERE id='$cat'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
      $cat_name = $row[1];
}
$sth->finish;
      # Error if no info
      if (!$cat_name) {

          $Flex_WPS->user_error($err{bad_input});
      }

      #my $row_color = qq( class="tbl_row_dark");

    # Cycle through all cats and get all subcats for ramdom pic

           # my @some_sub = ();
          #  my $subcatnum = 0;
               $sth = "SELECT * FROM gallery_subcat WHERE id='$subcat'";
               $sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
               $sth->execute;
               while(my @row = $sth->fetchrow)  {
                    $sub_cat_name = $row[2];
                    $sub_cat_disc = $row[3];
               }
               $sth->finish;


              # my ($liid, $cat_id, $subcat_name, $discp, $viewct);
   # foreach (@some_sub) {
              #  ($liid, $cat_id, $subcat_name, $discp, $viewct) = split (/\|/, $_);
            #  my @some_pic = ();
            #   my $num = -1;
            my $row_count = 0;
            my $first_pic = 0;
            my $script = qq(<SCRIPT language=JavaScript>
<!--
);
            $board_index = <<HTML;
<table width="100%" border="1" cellspacing="0" cellpadding="0">
HTML
               my $admin_del = '';
               $sth = "SELECT * FROM gallery_x WHERE cat_id='$cat' AND subcat_id='$subcat'";
               $sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
               $sth->execute;
               while(my @row = $sth->fetchrow)  {
               if($user_data{sec_level} eq $usr{admin}) {
                   $admin_del = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=delete_pic;module=Gallery;id=$row[0];html=$row[4];cat=$cat;subcat=$subcat" onclick="javascript:return confirm('Are you sure you want to Delete This Picture?')">Delete:<img src="$cfg{imagesurl}/forum/delete.gif" alt="Delete" border="0"></a>);
               }
               if (!$first_pic) {
                   $first_pic = qq(<img src="$cfg{imagesurl}/uploads/Gallery/$row[4]" alt="$row[3]">);
               }
               $row_count++;
               if ($row_count == 1) {
               $script .= qq(function gallery$row[0]() {
picture.innerHTML='<img src="$cfg{imagesurl}/uploads/Gallery/$row[4]" alt="$row[3]">';
}
);
               $board_index .= <<HTML;
<tr align="center" valign="top">
<td>$admin_del<br><a href="#top" Onclick="javascript: gallery$row[0]();"><img src="$cfg{imagesurl}/uploads/Gallery/$row[4]" alt="$row[3]" border="0" width="95" height="95"></a></td>
HTML
               }
                elsif ($row_count == 2) {
               $script .= qq(function gallery$row[0]() {
picture.innerHTML='<img src="$cfg{imagesurl}/uploads/Gallery/$row[4]" alt="$row[3]">';
}
);
               $board_index .= <<HTML;
<td>$admin_del<br><a href="#top" Onclick="javascript: gallery$row[0]();"><img src="$cfg{imagesurl}/uploads/Gallery/$row[4]" alt="$row[3]" border="0" width="95" height="95"></a></td>
HTML
                }
                 elsif ($row_count == 3) {
               $script .= qq(function gallery$row[0]() {
picture.innerHTML='<img src="$cfg{imagesurl}/uploads/Gallery/$row[4]" alt="$row[3]">';
}
);
               $board_index .= <<HTML;
<td>$admin_del<br><a href="#top" Onclick="javascript: gallery$row[0]();"><img src="$cfg{imagesurl}/uploads/Gallery/$row[4]" alt="$row[3]" border="0" width="95" height="95"></a></td>
</tr>
HTML
                  $row_count = 0;
                 }

               }
               $sth->finish;
               $script .= qq(
// -->
</SCRIPT>);
          if ($row_count == 1) {
               $board_index .= <<HTML;
<td>&nbsp;</td>
<td>&nbsp;</td>
</tr>
</table>
HTML
          }
           elsif ($row_count == 2) {
               $board_index .= <<HTML;
<td>&nbsp;</td>
</tr>
</table>
HTML
           }
            else {
               $board_index .= <<HTML;
</table>
HTML
            }


        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "Gallery");
        admin_menu();
print <<HTML;
<NOSCRIPT>
The Gallery Work Best With a Jave Enabled Browser.

Thank You,
Admin
</NOSCRIPT>
<script type="text/javascript" language="JavaScript1.2">
<!--
window.onload=function(m,u,l)
{
        picture.innerHTML='$first_pic';
}
//-->
</script>
$script
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<td><img src="$cfg{imagesurl}/forum/open.gif" width="17" height="15" border="0" alt="">&nbsp;&nbsp;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=cat_view;module=Gallery">Flex - Gallery Module</a>
<br>
<img src="$cfg{imagesurl}/forum/tline.gif" width="12" height="12" border="0" alt=""><img src="$cfg{imagesurl}/forum/open.gif" width="17" height="15" border="0" alt="">&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=sub_cat;module=Gallery;cat=$cat">$cat_name</a>
<br>
<img src="$cfg{imagesurl}/forum/tline.gif" width="12" height="12" border="0" alt=""><img src="$cfg{imagesurl}/forum/open.gif" width="17" height="15" border="0" alt="">&nbsp;&nbsp;$sub_cat_name</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="2" cellpadding="4" class="navtable">
<tr>
<td align="center">
<blockquote>
<p align="left">$sub_cat_disc</p>
</blockquote>
<table width="100%" border="0" cellspacing="2" cellpadding="4">
<tr>
<td align="center" valign="top" width="45%">$board_index</td>
<td align="center"><div id="picture"> </div></td>
</tr>
</table>
</td>
</tr>
</table>
HTML

theme::print_html($user_data{theme}, "Gallery", 1);

}

sub add_cat {
# Check admin's
if($user_data{sec_level} ne $usr{admin}) {

$Flex_WPS->user_error($err{auth_failure});
}
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "Gallery");
        admin_menu();
        print <<HTML;
<div align="left"><form name="form1" method="post" action="$cfg{pageurl}/index.$cfg{ext}">
<input type="hidden" name="op" value="add_cat2">
<input type="hidden" name="module" value="Gallery"><br>
<b>Title:</b> <input type="text" name="title" size="45" value="">
<br><br><b>Message:</b><br>
<textarea name="message" rows="8" cols="45"></textarea><br>
<input type="radio" name="html" value="1" checked>
<b>Allow \HTML</b><br>
<input type="radio" name="html" value="2">
<b>Use UBBC</b><br>
<input type="radio" name="html" value="3">
<b>Use Text Only</b><br><input type="submit" name="Submit" value="Submit">
</form></div>
HTML

theme::print_html($user_data{theme}, "Gallery", 1);

}
sub add_cat2 {
# Check admin's
if($user_data{sec_level} ne $usr{admin}) {

$Flex_WPS->user_error($err{auth_failure});
}
if ($html eq '1') {
# should check how safe it realy is, but this is an admin area anyway.
$title =~ s{'}{&#39;}gso; # SQL Safer
$title =~ s{\\}{&#92;}gso; # need this!
$message =~ s{'}{&#39;}gso; # SQL Safer
$message =~ s{\\}{&#92;}gso; # need this!
}
elsif($html eq '3') {
require HTML_TEXT;
$title = HTML_TEXT::html_escape($title);
$message = HTML_TEXT::html_escape($message);
}
else {
require HTML_TEXT;
$title = HTML_TEXT::html_escape($title);
$message = HTML_TEXT::html_escape($message);
require UBBC;
$title = UBBC::do_ubbc($title);
$message = UBBC::do_ubbc($message);
}
my $sql = qq(INSERT INTO `gallery_cat` ( `id` , `cat_name` , `disc` , `view_ct` )
VALUES (
NULL , '$title', '$message', 'NULL'
););

$Flex_WPS->SQL_Edit($sql);

my $options = '';
my $sth = "SELECT * FROM gallery_cat WHERE view_ct='NULL'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
       $options = $row[0];
}
$sth->finish;

$sql = qq(UPDATE `gallery_cat` SET `view_ct` = NULL
WHERE `id` ='$options' LIMIT 1 ;);

$Flex_WPS->SQL_Edit($sql);


    mkdir("$cfg{gallerydir}/$options", 0777) or $Flex_WPS->user_error("Cant Make Folder $options. ($!)");
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "Gallery");
        admin_menu();

        print <<HTML;
<center><b>Category Added</b>
<br>
<script language="javascript" type="text/javascript">

function Options22() {
var MyWindow;
MyWindow = window.open('$cfg{pageurl}/upload.$cfg{ext}?op=page;cat=$options;call_type=Gallery;name=$options;up_count=1', 'Add_Pictures', 'width=400,height=350,status=no,toolbar=no,menubar=no,location=no')
}
</script>
<a href="javascript:Options22()">Add Picture of Category Now!</a>
<br>
<a href="$cfg{pageurl}/index.$cfg{ext}?op=add_subcat;module=Gallery;cat=$options">Add Subcategory?</a></center>
HTML
        theme::print_html($user_data{theme}, "Gallery", 1);
# INSERT INTO `gallery_cat` ( `id` , `cat_name` , `disc` , `view_ct` )
# VALUES (
# NULL , 'Residential', 'New Construction, Remodeling and other past projects.', NULL
# );

}
sub add_subcat {
# Check admin's
if($user_data{sec_level} ne $usr{admin}) {

$Flex_WPS->user_error($err{auth_failure});
}
if (!$cat) {
my $options = '';
my $sth = "SELECT * FROM gallery_cat";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
       $options .= qq(<option value="$row[0]">$row[1]</option>);
}
$sth->finish;

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "Gallery");
        admin_menu();
print <<HTML;
<b>Pick a Gallery Category</b>
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="add_subcat">
<input type="hidden" name="module" value="Gallery">
<select name="cat">
$options
</select>
<input type="submit" name="Submit" value="Submit">
</form>
HTML

theme::print_html($user_data{theme}, "Gallery", 1);
}
 else {
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "Gallery");
        admin_menu();
        print <<HTML;
<div align="left"><form name="form1" method="post" action="$cfg{pageurl}/index.$cfg{ext}">
<input type="hidden" name="op" value="add_subcat2">
<input type="hidden" name="module" value="Gallery">
<input type="hidden" name="cat" value="$cat"><br>
<b>Title:</b> <input type="text" name="title" size="45" value="">
<br><br><b>Message:</b><br>
<textarea name="message" rows="8" cols="45"></textarea><br>
<input type="radio" name="html" value="1" checked>
<b>Allow \HTML</b><br>
<input type="radio" name="html" value="2">
<b>Use UBBC</b><br>
<input type="radio" name="html" value="3">
<b>Use Text Only</b><br><input type="submit" name="Submit" value="Submit">
</form></div>
HTML

theme::print_html($user_data{theme}, "Gallery", 1);
 }
#  INSERT INTO `gallery_subcat` ( `id` , `cat_id` , `subcat_name` , `disc` , `view_ct` )
# VALUES (
# NULL , '1', 'Vaulted Ceiling Arch', '1,200 square inch Grand Vaulted Ceiling Arch', NULL
# );
}
sub add_subcat2 {
# Check admin's
if($user_data{sec_level} ne $usr{admin}) {

$Flex_WPS->user_error($err{auth_failure});
}
if ($html eq '1') {
# should check how safe it realy is, but this is an admin area anyway.
$title =~ s{'}{&#39;}gso; # SQL Safer
$title =~ s{\\}{&#92;}gso; # need this!
$message =~ s{'}{&#39;}gso; # SQL Safer
$message =~ s{\\}{&#92;}gso; # need this!
}
elsif($html eq '3') {
require HTML_TEXT;
$title = HTML_TEXT::html_escape($title);
$message = HTML_TEXT::html_escape($message);
}
else {
require HTML_TEXT;
$title = HTML_TEXT::html_escape($title);
$message = HTML_TEXT::html_escape($message);
require UBBC;
$title = UBBC::do_ubbc($title);
$message = UBBC::do_ubbc($message);
}
my $sql = qq(INSERT INTO `gallery_subcat` ( `id` , `cat_id` , `subcat_name` , `disc` , `view_ct` )
VALUES (
NULL , '$cat', '$title', '$message', 'NULL'
););

$Flex_WPS->SQL_Edit($sql);

my $options = '';
my $sth = "SELECT * FROM gallery_subcat WHERE view_ct='NULL'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
       $options = $row[0];
}
$sth->finish;

$sql = qq(UPDATE `gallery_subcat` SET `view_ct` = NULL
WHERE `id` ='$options' LIMIT 1 ;);

$Flex_WPS->SQL_Edit($sql);

    mkdir("$cfg{gallerydir}/$cat/$options", 0777) or $Flex_WPS->user_error("Cant Make Folder 1. ($!)");
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "Gallery");
        admin_menu();
        print <<HTML;
<script language="javascript" type="text/javascript">
<!--
function Options() {
var MyWindow;
var MyUrl;
MyUrl = '$cfg{pageurl}/upload.$cfg{ext}?op=page;cat=$cat;subcat=$options;call_type=Gallery';
MyWindow = window.open(MyUrl, 'Add_Puctures', 'width=400,height=350,status=no,toolbar=no,menubar=no,location=no');
}
// -->
</script>
<center><b>Subcategory Added</b>
<br>
<br>
<a href="javascript:Options();">Add Pictures To Subcategory?</a></center>
HTML
        theme::print_html($user_data{theme}, "Gallery", 1);
}
sub add_pic {
# Check admin's
if($user_data{sec_level} ne $usr{admin}) {

$Flex_WPS->user_error($err{auth_failure});
}
if (!$cat) {
my $options = '';
my $sth = "SELECT * FROM gallery_cat";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
       $options .= qq(<option value="$row[0]">$row[1]</option>);
}
$sth->finish;

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "Gallery");
        admin_menu();
print <<HTML;
<b>Pick a Gallery Category</b>
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="add_pic">
<input type="hidden" name="module" value="Gallery">
<select name="cat">
$options
</select>
<input type="submit" name="Submit" value="Submit">
</form>
HTML

theme::print_html($user_data{theme}, "Gallery", 1);
}
 elsif (!$subcat) {
my $options = '';
my $sth = "SELECT * FROM gallery_subcat WHERE cat_id='$cat'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
       $options .= qq(<option value="$row[0]">$row[2]</option>);
}
$sth->finish;

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "Gallery");
        admin_menu();
print <<HTML;
<b>Pick a Gallery Subcategory</b>
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="add_pic">
<input type="hidden" name="module" value="Gallery">
<input type="hidden" name="cat" value="$cat">
<select name="subcat">
$options
</select>
<input type="submit" name="Submit" value="Submit">
</form>
HTML

theme::print_html($user_data{theme}, "Gallery", 1);
 }
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "Gallery");
        admin_menu();
        print <<HTML;
<script language="javascript" type="text/javascript">
<!--
function Options() {
var MyWindow;
var MyUrl;
MyUrl = '$cfg{pageurl}/upload.$cfg{ext}?op=page;cat=$cat;subcat=$subcat;call_type=Gallery';
MyWindow = window.open(MyUrl, 'Add_Pictures', 'width=400,height=350,status=no,toolbar=no,menubar=no,location=no');
}
// -->
</script>
<center><b>Add Pictures</b>
<br>
<br>
<a href="javascript:Options();">Add Pictures To Subcategory?</a></center>
HTML

theme::print_html($user_data{theme}, "Gallery", 1);

# INSERT INTO `gallery_x` ( `id` , `cat_id` , `subcat_id` , `pic_disc` , `pic` , `view_ct` )
# VALUES (
# NULL , '1', '1', 'The vaulted ceiling 1', '/1/1/The vaulted ceiling again_thumb.jpg', NULL
# );
}

sub edit_catsub {
 my $form_tab = '';
if ($cat && !$subcat) {
my $sth = "SELECT * FROM gallery_cat WHERE id='$cat'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
       $form_tab = <<HTML;
<div align="left"><form name="form1" method="post" action="$cfg{pageurl}/index.$cfg{ext}">
<input type="hidden" name="op" value="edit_catsub2">
<input type="hidden" name="module" value="Gallery">
<input type="hidden" name="id" value="$row[0]">
<input type="hidden" name="cat" value="$cat"><br>
<b>Title:</b> <input type="text" name="title" size="45" value="$row[1]">
<br><br><b>Message:</b><br>
<textarea name="message" rows="8" cols="45">$row[2]</textarea><br>
<input type="radio" name="html" value="1" checked>
<b>Allow \HTML</b><br>
<input type="radio" name="html" value="2">
<b>Use UBBC</b><br>
<input type="radio" name="html" value="3">
<b>Use Text Only</b><br><input type="submit" name="Submit" value="Submit">
</form></div>
HTML
}
$sth->finish;
}
 elsif ($cat && $subcat) {
my $sth = "SELECT * FROM gallery_subcat WHERE id='$subcat'";
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
       $form_tab = <<HTML;
<div align="left"><form name="form1" method="post" action="$cfg{pageurl}/index.$cfg{ext}">
<input type="hidden" name="op" value="edit_catsub2">
<input type="hidden" name="module" value="Gallery">
<input type="hidden" name="id" value="$row[0]">
<input type="hidden" name="cat" value="$cat">
<input type="hidden" name="subcat" value="$subcat"><br>
<b>Title:</b> <input type="text" name="title" size="45" value="$row[2]">
<br><br><b>Message:</b><br>
<textarea name="message" rows="8" cols="45">$row[3]</textarea><br>
<input type="radio" name="html" value="1" checked>
<b>Allow \HTML</b><br>
<input type="radio" name="html" value="2">
<b>Use UBBC</b><br>
<input type="radio" name="html" value="3">
<b>Use Text Only</b><br><input type="submit" name="Submit" value="Submit">
</form></div>
HTML
}
$sth->finish;
 }
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "Gallery");
        admin_menu();
        print $form_tab;
        theme::print_html($user_data{theme}, "Gallery", 1);
}

sub edit_catsub2 {

if($user_data{sec_level} ne $usr{admin}) {

$Flex_WPS->user_error($err{auth_failure});
}
if ($html eq '1') {
# should check how safe it realy is, but this is an admin area anyway.
$title =~ s{'}{&#39;}gso; # SQL Safer
$title =~ s{\\}{&#92;}gso; # need this!
$message =~ s{'}{&#39;}gso; # SQL Safer
$message =~ s{\\}{&#92;}gso; # need this!
}
elsif($html eq '3') {
require HTML_TEXT;
$title = HTML_TEXT::html_escape($title);
$message = HTML_TEXT::html_escape($message);
}
else {
require HTML_TEXT;
$title = HTML_TEXT::html_escape($title);
$message = HTML_TEXT::html_escape($message);
require UBBC;
$title = UBBC::do_ubbc($title);
$message = UBBC::do_ubbc($message);
}

if ($cat && !$subcat) {
my $sql = qq(UPDATE `gallery_cat` SET `cat_name` = '$title',
`disc` = '$message'
WHERE `id` = '$cat' LIMIT 1 ;);

$Flex_WPS->SQL_Edit($sql);

print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=cat_view;module=Gallery');

}
 elsif ($cat && $subcat) {
my $sql = qq(UPDATE `gallery_subcat` SET `subcat_name` = '$title',
`disc` = '$message'
WHERE `id` = '$subcat' LIMIT 1 ;);

$Flex_WPS->SQL_Edit($sql);

print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=sub_cat;module=Gallery;cat=' . $cat);
 }
 else {

  $Flex_WPS->user_error("There was nothing to do.");
 }
}

sub delete_pic {
# Check admin's
if($user_data{sec_level} ne $usr{admin}) {

$Flex_WPS->user_error($err{auth_failure});
}

unlink("$cfg{gallerydir}/$html");
my $sql = qq(DELETE FROM gallery_x WHERE id='$id');

$Flex_WPS->SQL_Edit($sql);

print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=view;module=Gallery;cat=' . $cat . ';subcat=' . $subcat);
}

sub delete_subcat {
# Check admin's
if($user_data{sec_level} ne $usr{admin}) {

$Flex_WPS->user_error($err{auth_failure});
}

my $sql = qq(DELETE FROM gallery_subcat WHERE id='$subcat' AND cat_id='$cat');

$Flex_WPS->SQL_Edit($sql);

print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=sub_cat;module=Gallery;cat=' . $cat);
}
# sub delete_catpic {
# # Check admin's
# if($user_data{sec_level} ne $usr{admin}) {
#
# $Flex_WPS->user_error($err{auth_failure});
# }
#
# unlink("$cfg{gallerydir}/$html");
#
# }

1;
