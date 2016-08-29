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
use Flex_Porter;

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
<a href="javascript:addCode('[b][/b]')"><img src="$cfg{imagesurl}/forum/bold.gif" class="pure-img img-l" hspace="2" alt="$msg{bold}" /></a>
 <a href="javascript:addCode('[i][/i]')"><img src="$cfg{imagesurl}/forum/italicize.gif" class="pure-img img-l" hspace="2" alt="$msg{italic}" /></a>
 <a href="javascript:addCode('[u][/u]')"><img src="$cfg{imagesurl}/forum/underline.gif" class="pure-img img-l" hspace="2" alt="$msg{underline}" /></a>
 <a href="javascript:addCode('[strike][/strike]')"><img src="$cfg{imagesurl}/forum/strike.gif" class="pure-img img-l" hspace="2" alt="Strike" /></a>
 <a href="javascript:addCode('[left][/left]')"><img src="$cfg{imagesurl}/forum/left.gif" class="pure-img img-l" hspace="2" alt="Left" /></a>
 <a href="javascript:addCode('[center][/center]')"><img src="$cfg{imagesurl}/forum/center.gif" class="pure-img img-l" hspace="2" alt="$msg{center}" /></a>
 <a href="javascript:addCode('[right][/right]')"><img src="$cfg{imagesurl}/forum/right.gif" class="pure-img img-l" hspace="2" alt="Right" /></a>
 <a href="javascript:addCode('[sup][/sup]')"><img src="$cfg{imagesurl}/forum/sup.gif" class="pure-img img-l" hspace="2" alt="sup" /></a>
 <a href="javascript:addCode('[sub][/sub]')"><img src="$cfg{imagesurl}/forum/sub.gif" class="pure-img img-l" hspace="2" alt="sub" /></a>
 <a href="javascript:addCode('[pre][/pre]')"><img src="$cfg{imagesurl}/forum/pre.gif" class="pure-img img-l" hspace="2" alt="pre" /></a>
<div style="clear:both;"> </div>
<a href="javascript:addCode('[img]http://www.url.com/image[/img]')"><img src="$cfg{imagesurl}/forum/img.gif" class="pure-img img-l" hspace="2" alt="Image" /></a>
<a href="javascript:addCode('[url=http://www.url.com]name[/url]')"><img src="$cfg{imagesurl}/forum/url.gif" class="pure-img img-l" hspace="2" alt="$msg{insert_link}" /></a>
<a href="javascript:addCode('[email]e\@mail.com[/email]')"><img src="$cfg{imagesurl}/forum/email2.gif" class="pure-img img-l" hspace="2" alt="$msg{insert_email}" /></a>
<a href="javascript:addCode('[code][/code]')"><img src="$cfg{imagesurl}/forum/code.gif" class="pure-img img-l" hspace="2" alt="$msg{insert_code}" /></a>
<a href="javascript:addCode('[quote][/quote]')"><img src="$cfg{imagesurl}/forum/quote2.gif" class="pure-img img-l" hspace="2" alt="$msg{quote}" /></a>
<a href="javascript:addCode('[ol]Title [li=1][/li] [li][/li] [li][/li][/ol]')"><img src="$cfg{imagesurl}/forum/list.gif" class="pure-img img-l" hspace="2" alt="$msg{insert_list}" /></a>
<a href="javascript:void(0)" onclick="window.open('$cfg{pageurl}/index.$cfg{ext}?op=print_smilies,smilies$option','_blank','scrollbars=yes,toolbar=no,height=270,width=270')"><img src="$cfg{imagesurl}/forum/smilie.gif" class="pure-img img-l" hspace="2" alt="$msg{insert_smilie}" /></a>
<a href="javascript:addCode('[page://]')"><img src="$cfg{imagesurl}/forum/wiki.gif" class="pure-img img-l" hspace="2" alt="page" /></a>
<a href="javascript:addCode('[search://]')"><img src="$cfg{imagesurl}/forum/search.png" class="pure-img img-l" hspace="2" alt="search" /></a>
<a href="javascript:void(0)" onclick="window.open('$cfg{pageurl}/upload.$cfg{ext}','_blank','scrollbars=yes,toolbar=no,height=270,width=270')"><img src="$cfg{imagesurl}/image.png" class="pure-img img-l" width="23" height="22" hspace="2" alt="upload_image" /></a>
<div style="clear:both;"> </div>
<a href="javascript:addCode('[wikipedia://]')"><img src="$cfg{imagesurl}/forum/wikipedia.gif" class="pure-img img-l" hspace="2" alt="wikipedia" /></a>
<a href="javascript:addCode('[wikispecies://]')"><img src="$cfg{imagesurl}/forum/wikispecies.gif" class="pure-img img-l" hspace="2" alt="wikispecies" /></a>
<a href="javascript:addCode('[wikiquote://]')"><img src="$cfg{imagesurl}/forum/wikiquote.gif" class="pure-img img-l" hspace="2" alt="wikiquote" /></a>
<a href="javascript:addCode('[wikibooks://]')"><img src="$cfg{imagesurl}/forum/wikibooks.gif" class="pure-img img-l" hspace="2" alt="wikibooks" /></a>
<a href="javascript:addCode('[wikisource://]')"><img src="$cfg{imagesurl}/forum/wikisource.gif" class="pure-img img-l" hspace="2" alt="wikisource" /></a>
<a href="javascript:addCode('[cpan://]')"><img src="$cfg{imagesurl}/forum/cpan.gif" class="pure-img img-l" hspace="2" alt="cpan" /></a>
<a href="javascript:addCode('[google://]')"><img src="$cfg{imagesurl}/forum/google.gif" class="pure-img img-l" hspace="2" alt="google" /></a>
<a href="javascript:addCode('[yahoo://]')"><img src="$cfg{imagesurl}/forum/yahoo.png" class="pure-img img-l" hspace="2" alt="yahoo" /></a>
<a href="javascript:addCode('[msn://]')"><img src="$cfg{imagesurl}/forum/msn.gif" class="pure-img img-l" hspace="2" alt="msn" /></a>
<div style="clear:both;"> </div>
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

                return <<"HTML";
<script language="javascript" type="text/javascript">
<!--
function showImage() {
document.images.icons.src="$cfg{imagesurl}/icon/"+
document.creator.icon.options[document.creator.icon.selectedIndex].value;
}
function addCode(anystr) {
insertAtCursor(document.creator.message, anystr);
}
function showColor(color) {
var colortag = "[color="+color+"][/color]";
insertAtCursor(document.creator.message, colortag);
}
// -->
</script>
<div class="pure-g">
    <div class="pure-u-1-7">
    <select id="icon" name="icon" onChange="showImage()">
        $pre_selected_icon
        $options
        </select>
        </div>
    <div class="pure-u-1-12">
    <img src="$cfg{imagesurl}/icon/$selected_icon" name="icons" class="pure-img" hspace="15" alt="icon" />
    </div>
</div>

HTML

}

1;
