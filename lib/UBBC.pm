package UBBC;

=head1 COPYLEFT

 UBBC.pm, v1.0 09/16/2008 N.K.A

 This file is part of Flex-WPS Evo3.
 Universal Bulletin Board Code Tags Panel's.

=cut

=head1 History

v1.0 09/16/2008 -
 HTML Panel's for

=head1 TODO

 Testing

=cut

use strict;
use vars qw( %cfg %msg $Flex_WPS);
use exporter;

sub print_ubbc_panel {
my $option = shift;
if ($option) {
  $option = ';js=1';
}
 else {
   $option = '';
 }
 # onClick="window.open('$cfg{pageurl}/index.$cfg{ext}?op=print_smilies$option','_blank','scrollbars=yes,toolbar=no,height=270,width=270')"
        return <<HTML;
<a href="javascript:addCode('[b][/b]')"><img src="$cfg{imagesurl}/forum/bold.gif" align="bottom" width="23" height="22" alt="$msg{bold}" border="0" /></a>
<a href="javascript:addCode('[i][/i]')"><img src="$cfg{imagesurl}/forum/italicize.gif" align="bottom" width="23" height="22" alt="$msg{italic}" border="0" /></a>
<a href="javascript:addCode('[u][/u]')"><img src="$cfg{imagesurl}/forum/underline.gif" align="bottom" width="23" height="22" alt="$msg{underline}" border="0" /></a>
<a href="javascript:addCode('[strike][/strike]')"><img src="$cfg{imagesurl}/forum/strike.gif" align="bottom" width="23" height="22" alt="Strike" border="0" /></a>
<a href="javascript:addCode('[left][/left]')"><img src="$cfg{imagesurl}/forum/left.gif" align="bottom" width="23" height="22" alt="Left" border="0" /></a>
<a href="javascript:addCode('[center][/center]')"><img src="$cfg{imagesurl}/forum/center.gif" align="bottom" width="23" height="22" alt="$msg{center}" border="0" /></a>
<a href="javascript:addCode('[right][/right]')"><img src="$cfg{imagesurl}/forum/right.gif" align="bottom" width="23" height="22" alt="Right" border="0" /></a>
<a href="javascript:addCode('[sup][/sup]')"><img src="$cfg{imagesurl}/forum/sup.gif" align="bottom" width="23" height="22" alt="sup" border="0" /></a>
<a href="javascript:addCode('[sub][/sub]')"><img src="$cfg{imagesurl}/forum/sub.gif" align="bottom" width="23" height="22" alt="sub" border="0" /></a>
<a href="javascript:addCode('[pre][/pre]')"><img src="$cfg{imagesurl}/forum/pre.gif" align="bottom" width="23" height="22" alt="pre" border="0" /></a>
<br />
<a href="javascript:addCode('[img]http://www.url.com/image[/img]')"><img src="$cfg{imagesurl}/forum/img.gif" align="bottom" width="23" height="22" alt="Image" border="0" /></a>
<a href="javascript:addCode('[url=http://www.url.com]name[/url]')"><img src="$cfg{imagesurl}/forum/url.gif" align="bottom" width="23" height="22" alt="$msg{insert_link}" border="0" /></a>
<a href="javascript:addCode('[email]e\@mail.com[/email]')"><img src="$cfg{imagesurl}/forum/email2.gif" align="bottom" width="23" height="22" alt="$msg{insert_email}" border="0" /></a>
<a href="javascript:addCode('[code][/code]')"><img src="$cfg{imagesurl}/forum/code.gif" align="bottom" width="23" height="22" alt="$msg{insert_code}" border="0" /></a>
<a href="javascript:addCode('[quote][/quote]')"><img src="$cfg{imagesurl}/forum/quote2.gif" align="bottom" width="23" height="22" alt="$msg{quote}" border="0" /></a>
<a href="javascript:addCode('[ol]Title [li=1][/li] [li][/li] [li][/li][/ol]')"><img src="$cfg{imagesurl}/forum/list.gif" align="bottom" width="23" height="22" alt="$msg{insert_list}" border="0" /></a>
<a href="javascript:void(0)" onclick="window.open('$cfg{pageurl}/index.$cfg{ext}?op=print_smilies,smilies$option','_blank','scrollbars=yes,toolbar=no,height=270,width=270')"><img src="$cfg{imagesurl}/forum/smilie.gif" align="bottom" width="23" height="22" alt="$msg{insert_smilie}" border="0" /></a>
<a href="javascript:addCode('[page://]')"><img src="$cfg{imagesurl}/forum/wiki.gif" align="bottom" width="23" height="22" alt="page" border="0" /></a>
<a href="javascript:addCode('[search://]')"><img src="$cfg{imagesurl}/forum/search.png" align="bottom" width="23" height="22" alt="search" border="0" /></a>
<a href="javascript:void(0)" onclick="window.open('$cfg{pageurl}/upload.$cfg{ext}','_blank','scrollbars=yes,toolbar=no,height=270,width=270')"><img src="$cfg{imagesurl}/image.png" align="bottom" width="23" height="22" alt="upload_image" border="0" /></a>
<br />
<a href="javascript:addCode('[wikipedia://]')"><img src="$cfg{imagesurl}/forum/wikipedia.gif" align="bottom" width="23" height="22" alt="wikipedia" border="0" /></a>
<a href="javascript:addCode('[wikispecies://]')"><img src="$cfg{imagesurl}/forum/wikispecies.gif" align="bottom" width="23" height="23" alt="wikispecies" border="0" /></a>
<a href="javascript:addCode('[wikiquote://]')"><img src="$cfg{imagesurl}/forum/wikiquote.gif" align="bottom" width="23" height="22" alt="wikiquote" border="0" /></a>
<a href="javascript:addCode('[wikibooks://]')"><img src="$cfg{imagesurl}/forum/wikibooks.gif" align="bottom" width="23" height="22" alt="wikibooks" border="0" /></a>
<a href="javascript:addCode('[wikisource://]')"><img src="$cfg{imagesurl}/forum/wikisource.gif" align="bottom" width="23" height="22" alt="wikisource" border="0" /></a>
<a href="javascript:addCode('[cpan://]')"><img src="$cfg{imagesurl}/forum/cpan.gif" align="bottom" width="23" height="22" alt="cpan" border="0" /></a>
<a href="javascript:addCode('[google://]')"><img src="$cfg{imagesurl}/forum/google.gif" align="bottom" width="23" height="22" alt="google" border="0" /></a>
<a href="javascript:addCode('[yahoo://]')"><img src="$cfg{imagesurl}/forum/yahoo.png" align="bottom" width="23" height="22" alt="yahoo" border="0" /></a>
<a href="javascript:addCode('[msn://]')"><img src="$cfg{imagesurl}/forum/msn.gif" align="bottom" width="23" height="22" alt="msn" border="0" /></a>
<br />
<b>Font Color:</b> <select name="color" onChange="showColor(this.options[this.selectedIndex].value)">
<option value="Black" selected>$msg{black}</option>
<option value="Red">$msg{red}</option>
<option value="Yellow">$msg{yellow}</option>
<option value="Pink">$msg{pink}</option>
<option value="Green">$msg{green}</option>
<option value="Orange">$msg{orange}</option>
<option value="Purple">$msg{purple}</option>
<option value="Blue">$msg{blue}</option>
<option value="Beige">$msg{beige}</option>
<option value="Brown">$msg{brown}</option>
<option value="Teal">$msg{teal}</option>
<option value="Navy">$msg{navy}</option>
<option value="Maroon">$msg{maroon}</option>
<option value="LimeGreen">$msg{lime}</option>
</select>
HTML

}

sub print_ubbc_image_selector {
        my $selected_icon = shift || 'xx.gif';

        # Display the pre selected icon?
        my $pre_selected_icon = '';
        if ($selected_icon) {
#        my $thumb = '';
#        if($selected_icon eq 'thumbup') { $thumb = $msg{thumb_up}; }
#        elsif($selected_icon eq 'thumbdown') { $thumb = $msg{thumb_down}; }
#        elsif($selected_icon eq 'exclamation') { $thumb = $msg{excl_marl}; }
#        elsif($selected_icon eq 'question') { $thumb = $msg{question_mark}; }
#        elsif($selected_icon eq 'xx') { $thumb = $msg{standard}; }
#        elsif($selected_icon eq 'lamp') { $thumb = $msg{lamp}; }
                $pre_selected_icon = "<option value=\"$selected_icon\" selected>$selected_icon</option>\n";
        }

my $icons = $Flex_WPS->dir2array($cfg{imagesdir}.'/icon');
my $options = '';
 foreach(@{$icons}) {
  $options .= "<option value=\"$_\">$_</option>\n"
   if ($_ && $_ !~ /\A\./);
 }

                return <<HTML;
<script language="javascript" type="text/javascript"><!--
function showImage() {
document.images.icons.src="$cfg{imagesurl}/icon/"+
document.creator.icon.options[document.creator.icon.selectedIndex].value;
}
// --></script>
<select name="icon" onChange="showImage()">
$pre_selected_icon
$options
</select>
<img src="$cfg{imagesurl}/icon/$selected_icon" name="icons" width="16"
height="16" border="0" hspace="15" alt="" /></td>
</tr>
<tr>
<td valign=top><b>$msg{textC}</b></td>
<td>
<script language="javascript" type="text/javascript">
<!--
function addCode(anystr) {
insertAtCursor(document.creator.message, anystr);
}
function showColor(color) {
var colortag = "[color="+color+"][/color]";
insertAtCursor(document.creator.message, colortag);
}
// -->
</script>
HTML

}

1;
