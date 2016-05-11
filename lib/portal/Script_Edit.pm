package Script_Edit;

# Load necessary modules.
use strict;
use vars qw(
    $query %cfg %user_action %nav
    %user_data %usr %err $Flex_WPS
    );
use exporter;

# Portal directorys
# $cfg{cgi_bin_dir}
#$cfg{libdir}
#$cfg{subloaddir}
#$cfg{portaldir}

# Define possible user actions.
%user_action = (
    main => $usr{admin},
    scripted => $usr{admin},
    scripted2 => $usr{admin},
);

my $id = $query->param('id') || '';
my $this_path = $query->param('path') || '';
my $edited = $query->param('ed') || '';

$id = $Flex_WPS->untaint2(value => $id, pattern => '\w\.\s');
$this_path = $Flex_WPS->untaint2(value => $this_path, pattern => '\w\/\s');

sub warn_msg {
return <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Script Editor</p>
<big><b>Warning!!</b></big><br />This editor can allow changes in ways that allow programs to work or
 not work.<br />
 Edites to some files can change their version or even reduce security.<br />
 Only People that know what they are doing should use this!</td>
</tr></table>
HTML
}

sub main {
my $options = '';
my $dir_path = $cfg{cgi_bin_dir};

# Settup the paths
if ($this_path && $id) {
 $this_path = $this_path.'/'.$id;
 $dir_path .= '/'.$this_path;
} elsif ($id && ! $this_path) {
 $this_path = $id;
 $dir_path .= '/'.$id;
}
 elsif ($this_path && ! $id) {
 $dir_path .= '/'.$this_path;
}


my $list = $Flex_WPS->dir2array($dir_path);
 foreach(@{$list}) {
  $options .= "<img src=\"$cfg{imagesurl}/forum/tline2.gif\" alt\"\" /><img src=\"$cfg{imagesurl}/icon/folder_yellow.png\" alt\"\" />
<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=main,Script_Edit;id=$_;path=$this_path\">$_</a><br />\n"
   if ($_ && $_ !~ m/\./i);
 }
 my $file_info = '';
 foreach(@{$list}) {
 $file_info = (stat($dir_path.'/'.$_))[7];
  $options .= "<img src=\"$cfg{imagesurl}/forum/tline.gif\" alt\"\" /><img src=\"$cfg{imagesurl}/icon/files.png\" alt\"\" />
<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=scripted,Script_Edit;id=$_;path=$this_path\">$_</a> - $file_info bytes<br />\n"
   if ($_ && $_ =~ m/\A[\w\s]+\.\w{2,3}\z/i);
 }

my $go_back = '';
if ($this_path) {

$go_back = "<img src=\"$cfg{imagesurl}/icon/folder_yellow.png\" alt\"\" /> $this_path<br />";
 if ($this_path =~ /\//) {
  $this_path =~ s/\/[\w\s]+\z//;
 }
  elsif ($this_path !~ /\//) {
  $this_path =~ s/\A[\w\s]+\z//;
 }
$go_back = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=main,Script_Edit;path=$this_path\">Back Directory</a><br />".$go_back;
}
 else {
 my $last_path = '';
 if ($cfg{cgi_bin_dir} =~ /\/([^\/]+)\z/) {
    $last_path = $1;
 }
$go_back = "<img src=\"$cfg{imagesurl}/icon/folder_yellow.png\" alt\"\" /> $last_path<br />";
 }

my $topmenu = &warn_msg.$go_back;

$Flex_WPS->print_page(
        markup       => $topmenu. $options,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Script Edit Administrator',
        );
}


sub scripted {
my $dir_path = $cfg{cgi_bin_dir};
$dir_path .= '/'. $this_path if $this_path;

my @file_info = stat($dir_path.'/'.$id);
$file_info[8] = $Flex_WPS->format_date($file_info[8],3);
$file_info[9] = $Flex_WPS->format_date($file_info[9],3);
$file_info[10] = $Flex_WPS->format_date($file_info[10],3);

my $file_content = $Flex_WPS->file2scalar($dir_path.'/'.$id);
$file_content =~ s/<\/textarea>/&#60;\/textarea&#62;/g;

my $mode = $file_info[2] & 07777;
#printf "Permissions are %04o\n", $mode & 07777;

my $html = &warn_msg;
$html .= <<HTML;
<hr />
<b>Directory:</b> <a href=\"$cfg{pageurl}/index.$cfg{ext}?op=main,Script_Edit;path=$this_path\">$dir_path</a><hr />
<b>File:</b> $id - $file_info[7] bytes<br />
<b>Last Access Time:</b> $file_info[8]<br />
<b>Last Modify Time:</b> $file_info[9]<br />
<b>File Created Time:</b> $file_info[10]<br />
<b>File Permissions:</b> $file_info[2] , $mode<hr />
<form name="form1" method="post" action="">
<input type="hidden" name="id" value="$id" />
<input type="hidden" name="path" value="$this_path" />
<input type="hidden" name="op" value="scripted2,Script_Edit" />
<br><b>File Content:</b><br>
<textarea wrap="off" name="content" rows="35" cols="75">$file_content</textarea><br>
<input type="submit" name="Submit" value="Submit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')" />
</form>
HTML

$Flex_WPS->print_page(
        markup       => $html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Script Editor',
        );
        
}

sub scripted2 {
my $file_content = $query->param('content') || '';
my $dir_path = $cfg{cgi_bin_dir}.'/'. $this_path.'/'.$id;

$file_content =~ s/&#60;\/textarea&#62;/<\/textarea>/g;
$Flex_WPS->array2file(file => $dir_path, string => $file_content);

# Redirect to user_actions page.
print $query->redirect(
 -location => "$cfg{pageurl}/index.$cfg{ext}?op=scripted,Script_Edit;id=$id;path=$this_path"
 );
}

1;

__END__

=pod

=head1 COPYLEFT

Script_Edit.pm, v1.00 01/19/2011 N.K.A.
Works with Flex-WPS Evolution 3 v1.0 series

Brows throught directorys and edit files.

TODO: Needs testing!!!!

Flex Web Portal System Evolution 3

Main Developer:
 N.K.A.
 shakaflex [at] gmail.com
 http://search.cpan.org/~sflex/

=cut
