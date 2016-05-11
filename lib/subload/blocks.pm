package blocks;

use strict;
use vars qw(
    %cfg %msg %usr
    $Flex_WPS %back_ends $AUBBC_mod
    );
use exporter;

sub sub_action {
  return ( block_left => 1, block_right => 1);
}

sub block_left { block('left'); }
sub block_right { block('right'); }
sub block {
my $position = shift;
my $block = '';
my $block2 = '';
my $sth = $back_ends{$cfg{Theme_backend}}->prepare("SELECT * FROM blocks WHERE `active` = '1' AND `type` = '$position'");
$sth->execute;
while(my @row = $sth->fetchrow)  {
$row[3] = $AUBBC_mod->do_all_ubbc($Flex_WPS->eval_theme_tags($row[3]));
 if ($row[2]) {
  $block .= $Flex_WPS->box_header($row[2]).$row[3].$Flex_WPS->box_footer();
 }
 elsif ($row[3]) {
  $block .= '<div>'.$row[3].'</div><br />';
 }

}
$sth->finish();

print $block;
}
1;
