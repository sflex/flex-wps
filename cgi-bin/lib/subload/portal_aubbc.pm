package portal_aubbc;

use vars qw(
        %cfg %user_data %usr
        $Flex_WPS $AUBBC %back_ends
        );
use strict;
use Flex_Porter;

# %sub_action
#%sub_action = (portal_aubbc_load => 1);

sub sub_action {
  return ( portal_aubbc_load => 1);
}

sub portal_aubbc_load {
#my %smileys = ();
#my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM smilies");
#$sth->execute;
#while(my @row = $sth->fetchrow)  {
#        $smileys{$row[1]} = $row[2];
#}
#$sth->finish;
#$AUBBC_mod->smiley_hash(%smileys);

#  $AUBBC_mod->add_build_tag(
#        name     => 'wiki',
#        pattern  => 'l,n,-,:,_,s',
#        type     => 1,
#        function => 'portal_aubbc::build_link_name',
#        );
#  $AUBBC_mod->add_build_tag(
#        name     => 'wkid',
#        pattern  => 'n',
#        type     => 1,
#        function => 'portal_aubbc::build_link_id',
#        );

#require forum_home;
#  $AUBBC_mod->add_build_tag(
#        name     => 'id',
#        pattern  => 'all',
#        type     => 1,
#        function => 'portal_aubbc::build_link_aubbc',
#        );
$AUBBC->add_tag(
        'tag'         => 'page',
        'type'        => 'linktag',
        'security'    => 0, # security level number
        'error'       => '', # '' blank for unchanged, ' ' space to remove
        'function'    => 'portal_aubbc::page_links',# Class::Sub
        'description' => 'Portal [page://#] tag.',
        'message'     => '\d+', # regex
        'attribute'       => '', # regex
        'markup'      => '',
        );

#  $AUBBC_mod->add_build_tag(
#        name     => 'search',
#        pattern  => 'all',
#        type     => 1,
#        function => 'portal_aubbc::search_links',
#        );
#  $AUBBC_mod->add_build_tag(
#        name     => 'page',
#        pattern  => 'n',
#        type     => 1,
#        function => 'portal_aubbc::page_links',
#        );

#foreach my $tag (('wsp','wikispecies','msn','yahoo','cpan','google','wikisource','ws','wikiquote','wq','wikibooks','wb','wikipedia','wp')) {
#  $AUBBC_mod->add_build_tag(
#        name     => $tag,
#        pattern  => 'all',
#        type     => 1,
#        function => 'portal_aubbc::other_sites',
#        );
# }
my $tags = join ('|', 'wsp','wikispecies','msn','yahoo','cpan','google','wikisource','ws','wikiquote','wq','wikibooks','wb','wikipedia','wp');
$AUBBC->add_tag(
        'tag'         => $tags,
        'type'        => 'linktag',
        'security'    => 0, # security level number
        'error'       => '', # '' blank for unchanged, ' ' space to remove
        'function'    => 'portal_aubbc::other_sites',# Class::Sub
        'description' => 'Link to other sites [cpan://Module] tags.',
        'message'     => 'any', # regex
        'attribute'       => '', # regex
        'markup'      => '',
        );
$AUBBC->add_tag(
        'tag'         => 'time',
        'type'        => 'single',
        'link'        => 0,
        'group'       => 'smileys',
        'security'    => 0, # security level number
        'error'       => '', # '' blank for unchanged, ' ' space to remove
        'function'    => 'portal_aubbc::get_time',# Class::Sub
        'description' => 'Time tag [time]',
        'message'     => '', # regex
        'attribute'   => '', # regex
        'markup'      => '',
        );
#  $AUBBC_mod->add_build_tag(
#        name     => 'time',
#        pattern  => '',
#        type     => 3,
#        function => 'portal_aubbc::other_sites',
#        );

if ($cfg{module} && $cfg{op}) {
# Help section for each module, need to add in
$AUBBC->add_tag(
        'tag'         => 'help',
        'type'        => 'single',
        'security'    => 0, # security level number
        'error'       => '', # '' blank for unchanged, ' ' space to remove
        'function'    => '',# Class::Sub
        'description' => 'Help tag [help]',
        'message'     => '', # regex
        'attribute'       => '', # regex
        'markup'      => "<a href=\"#top\" onclick=\"javascript:gethelpBox(\'$cfg{module}:\:$cfg{op}\');\">Help?</a>",
        );
$AUBBC->add_tag(
        'tag'         => 'close_help',
        'type'        => 'single',
        'security'    => 0, # security level number
        'error'       => '', # '' blank for unchanged, ' ' space to remove
        'function'    => '',# Class::Sub
        'description' => 'Close help tag [close_help]',
        'message'     => '', # regex
        'attribute'       => '', # regex
        'markup'      => "<a href=\"#top\" onclick=\"javascript:closeMessage(\'help\');\">Close <img src=\"$cfg{imagesurl}/button_cance.png\" alt=\"Close\" border=\"0\" /></a>",
        );
#$AUBBC_mod->add_build_tag(
#        name     => 'help',
#        pattern  => '',
#        type     => 4,
#        function => "<a href=\"#top\" onclick=\"javascript:gethelpBox(\'$cfg{module}:\:$cfg{op}\');\">Help?</a>",
#        );
#$AUBBC_mod->add_build_tag(
#        name     => 'close_help',
#        pattern  => '',
#        type     => 4,
#        function => "<a href=\"#top\" onclick=\"javascript:closeMessage(\'help\');\">Close <img src=\"$cfg{imagesurl}/button_cance.png\" alt=\"Close\" border=\"0\" /></a>",
#        );
    }
}

#sub search_links {
#my ($tag_name, $message) = @_;
##my $message = shift;
#my $search_pat = 'a-zA-Z\d\:\-\s\_\/\.';
# # Flex-WPS Search
# if ($message =~ m/\A([$search_pat]+)\,([a-z\s]+)\z/i) {
# # Pattern, search in   [search://search_term,wiki forums poll]
# $message = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=search,Search;query=$1;match=OR;what=$2\"$cfg{hreftarget}>$1</a>";
# }
#  elsif ($message =~ m/\A([$search_pat]+)\,([a-z\s]+)\,(AND|OR)\z/i) {
# # Pattern, search in, Boolean   [search://search_term,wiki forums poll,OR]
# $message = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=search,Search;query=$1;match=$3;what=$2\"$cfg{hreftarget}>$1</a>";
# }
#  elsif ($message =~ m/\A([$search_pat]+)\,([a-z\s]+)\,(AND|OR)\,(i|s)\z/i) {
# # Pattern, search in, Boolean, case   [search://search_term,wiki forums poll,OR,s]
# $message = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=search,Search;case=$4;query=$1;match=$3;what=$2\"$cfg{hreftarget}>$1</a>";

# # All Search  [search://search_term]
# }
#  elsif ($message =~ m/\A([$search_pat]+)\z/i) {
# $message = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=search,Search;query=$1;match=OR\"$cfg{hreftarget}>$1</a>";
# }
#  else {
#  $message = '';
#  }
# return $message;
#}
sub get_time {
my ($type, $tag, $txt, $markup, $extra, $attrs) = @_;
 # localtime()
 if ($tag eq 'time') {
        my $time = scalar(localtime);
        $txt = "<b>[$time]</b>";
        }
 return ($txt, '');
}
sub other_sites {
my ($type, $tag, $txt, $markup, $extra, $attrs) = @_;
 #my ($tag_name, $text_from_AUBBC) = @_;

# cpan modules
 $txt = &AUBBC2::make_link("http://search.cpan.org/search?mode=module&amp;query=$txt",$txt,'',1)
  if $tag eq 'cpan';

# wikipedia Wiki
 $txt = &AUBBC2::make_link("http://wikipedia.org/wiki/Special:Search?search=$txt",$txt,'',1)
  if ($tag eq 'wikipedia' || $tag eq 'wp');

# wikibooks Wiki Books
 $txt = &AUBBC2::make_link("http://wikibooks.org/wiki/Special:Search?search=$txt",$txt,'',1)
  if ($tag eq 'wikibooks' || $tag eq 'wb');

# wikiquote Wiki Quote
 $txt = &AUBBC2::make_link("http://wikiquote.org/wiki/Special:Search?search=$txt",$txt,'',1)
  if ($tag eq 'wikiquote' || $tag eq 'wq');

# wikisource Wiki Source
 $txt = &AUBBC2::make_link("http://wikisource.org/wiki/Special:Search?search=$txt",$txt,'',1)
  if ($tag eq 'wikisource' || $tag eq 'ws');

# google search
 $txt = &AUBBC2::make_link("http://www.google.com/search?q=$txt",$txt,'',1)
  if $tag eq 'google';
  
 # yahoo search
 # http://search.yahoo.com/search?p=search%20terms
 $txt = &AUBBC2::make_link("http://search.yahoo.com/search?p=$txt",$txt,'',1)
  if $tag eq 'yahoo';

 # msn search
 # http://search.msn.com/results.aspx?q=search%20terms
 $txt = &AUBBC2::make_link("http://search.msn.com/results.aspx?q=$txt",$txt,'',1)
  if $tag eq 'msn';

# # localtime()
# if ($tag eq 'time') {
#        my $time = scalar(localtime);
#        $txt = "<b>[$time]</b>";
#        }
 return ($txt, $markup);
}
 
sub page_links {
my ($type, $tag, $txt, $markup, $extra, $attrs) = @_;
#my ($tag_name, $page_id) = @_;
#my $page_id = shift;  [page://#]

if ($txt) {
$txt = $back_ends{$cfg{Portal_backend}}->quote($txt);
my $sth = "SELECT pageid, title FROM pages WHERE pageid=$txt AND active='1' AND sec_level='$usr{anonuser}' LIMIT 1;";
if ($user_data{sec_level} eq $usr{admin}) {
     $sth = "SELECT pageid, title FROM pages WHERE pageid=$txt LIMIT 1;";
       }
        elsif ($user_data{sec_level} eq $usr{mod}) {
                $sth = "SELECT pageid, title FROM pages WHERE pageid=$txt AND active='1' AND sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 1;";
        }
         elsif ($user_data{sec_level} eq $usr{user}) {
                $sth = "SELECT pageid, title FROM pages WHERE pageid=$txt AND active='1' AND sec_level REGEXP '($usr{anonuser}|$usr{user})' LIMIT 1;";
         }
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
$txt = '';
while(my @row = $sth->fetchrow)  {
$txt = &AUBBC2::make_link("$cfg{homeurl}/page/$row[0]/",$row[1],'',0) if $row[0];
}
$sth->finish;

}
 else {
  $txt = '';
 }

#return $page_id;
return ($txt, $markup);
}

sub build_link_id {
#
my ($tag_name, $wiki_info) = @_;
#my $wiki_info = shift;
my $wiki_return = '';

my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT `id`, `name` FROM `wiki_site` WHERE `id` = '$wiki_info' LIMIT 1");
$sth->execute;
while(my @row = $sth->fetchrow)  {
      if ($row[0]) {
      $wiki_return = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=view,Wiki;id=$row[0]\"$cfg{hreftarget}>$row[1]</a>";
      }
}
$sth->finish;

 return $wiki_return;
}
# make a link v2 Fast version
sub build_link_name {
#
my ($tag_name, $wiki_info) = @_;
#my $wiki_info = shift;
my $wiki_return = '';

my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT `id`, `name` FROM `wiki_site` WHERE `name` REGEXP '^$wiki_info\$' LIMIT 1");
$sth->execute;
while(my @row = $sth->fetchrow)  {
      if ($row[0]) {
         $wiki_return = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=view,Wiki;id=$row[0]\"$cfg{hreftarget}>$wiki_info</a>";
         }
}
$sth->finish;

 return $wiki_return;
}

sub build_link_aubbc {
my ($tag_name, $thread_id) = @_;
#my $thread_id = shift;
my $jump_num = '';
my $return_link = '';
if ($thread_id =~ m/\A(\d+)(\#\d+)?\z/i) {
$thread_id = $1;
$jump_num = $2 || '';
#$jump_num = '#' . $jump_num if $jump_num;
my $query1 = "SELECT forum_threads.id, forum_threads.cat_id, forum_threads.subcat_id, forum_threads.subject, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_threads.id = '$thread_id' AND forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll|articles)' AND forum_cat.sec_level = '$usr{anonuser}' LIMIT 1;";
if ($user_data{sec_level} eq $usr{admin}) {
$query1 = "SELECT forum_threads.id, forum_threads.cat_id, forum_threads.subcat_id, forum_threads.subject, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_threads.id = '$thread_id' AND forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll|articles)' LIMIT 1;";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
$query1 = "SELECT forum_threads.id, forum_threads.cat_id, forum_threads.subcat_id, forum_threads.subject, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_threads.id = '$thread_id' AND forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll|articles)' AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 1;";
 }
  elsif ($user_data{sec_level} eq $usr{user}) {
$query1 = "SELECT forum_threads.id, forum_threads.cat_id, forum_threads.subcat_id, forum_threads.subject, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_threads.id = '$thread_id' AND forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll|articles)' AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user})' LIMIT 1;";
  }
my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute || return;
while(my @row = $sth->fetchrow)  {
if ($row[0]) {
$return_link = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=threads;module=Forum;cat=$row[1];subcat=$row[2];thread=$row[0];sticky=$row[4]$jump_num\"$cfg{hreftarget}>$row[3]</a>";
}
# cat=$row[1];subcat=$row[2];thread=$row[0];sticky=$row[4]
# <a href="">$row[3]</a>

}
$sth->finish;
}
return $return_link;
}
1;
