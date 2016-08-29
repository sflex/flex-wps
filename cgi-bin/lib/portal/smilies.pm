package smilies;

use strict;

# Assign global variables.
use vars qw(
    %nav %cfg $VERSION $query %user_action %back_ends
    %usr
    );

use Flex_Porter;

%user_action = (print_smilies => $usr{anonuser});

# inputs
my $js = $query->param('js') || '';

if ($js) {
  $js = 'opener.document.send_win.chat_message.value+=anystr;';
}
 else {
 $js = 'insertAtCursor(opener.document.creator.message, anystr, \'1\');';
 # $js = 'opener.document.creator.message.value+=anystr;';
 }
 

 
sub print_smilies {
 my $row_color = ' class="tbl_row_dark"';
 my $smileys_html = '';

my $sth = $back_ends{$cfg{Portal_backend}}->prepare('SELECT * FROM smilies');
$sth->execute;
while(my @row = $sth->fetchrow)  {
# Alternate the row colors.
$row_color =
  ($row_color eq ' class="tbl_row_dark"')
  ? ' class="tbl_row_light"'
  : ' class="tbl_row_dark"';
  $smileys_html .= <<"HTML";
<tr$row_color>
<td valign="top" width="50%">[$row[1]]</td>
<td valign="top" width="50%">
<a href="javascript:void(0)" onclick="javascript:AddSmilies('[$row[1]]');">
<img src="$cfg{imagesurl}/smilies/$row[2]" border="0" alt=""></a>
</td>
</tr>
HTML

}
$sth->finish;

print <<"HTML";
Content-type: text/html

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta name="Generator" content="$VERSION">
<title>$cfg{pagetitle}</title>
<link rel="stylesheet" href="$cfg{themesurl}/$cfg{default_theme}/style.css" type="text/css">
<script type="text/javascript" src="$cfg{themesurl}/flex-wps.js"></script>
<script type="text/javascript">
//<![CDATA[
function AddSmilies(anystr) {
$js
}
//]]>
</script>
</head>

<body bgcolor="#C5D0DC" text="#000000">
<table align="left" border="0" cellspacing="1" cellpadding="0" width="260">
<tr>
<td>
<table align="left" border="0" cellspacing="1" cellpadding="2" width="260">
<tr class="tbl_header">
<td valign="top" width="50%"><b>Code</b></td>
<td valign="top" width="50%"><b>Smilie</b></td>
</tr>
$smileys_html
</table>
</td>
</tr>
</table><div style="clear: left"> </div>
<br>
<div align="left" class="textsmall">[<a href="javascript:window.close();">$nav{close_window}</a>]</div>
<br>
</body>
</html>
HTML

exit;
}
1;
