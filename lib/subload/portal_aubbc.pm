package portal_aubbc;

use vars qw(
        %cfg %user_data %usr
        $Flex_WPS $AUBBC_mod %back_ends
        );
use strict;
use exporter;

# %sub_action
#%sub_action = (portal_aubbc_load => 1);

sub sub_action {
  return ( portal_aubbc_load => 1);
}

sub portal_aubbc_load {
my %smileys = ();
my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM smilies");
$sth->execute;
while(my @row = $sth->fetchrow)  {
        $smileys{$row[1]} = $row[2];
}
$sth->finish;
$AUBBC_mod->smiley_hash(%smileys);

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

  $AUBBC_mod->add_build_tag(
        name     => 'search',
        pattern  => 'all',
        type     => 1,
        function => 'portal_aubbc::search_links',
        );
  $AUBBC_mod->add_build_tag(
        name     => 'page',
        pattern  => 'n',
        type     => 1,
        function => 'portal_aubbc::page_links',
        );

foreach my $tag (('wsp','wikispecies','msn','yahoo','cpan','google','wikisource','ws','wikiquote','wq','wikibooks','wb','wikipedia','wp')) {
  $AUBBC_mod->add_build_tag(
        name     => $tag,
        pattern  => 'all',
        type     => 1,
        function => 'portal_aubbc::other_sites',
        );
 }

  $AUBBC_mod->add_build_tag(
        name     => 'time',
        pattern  => '',
        type     => 3,
        function => 'portal_aubbc::other_sites',
        );

if ($cfg{module} && $cfg{op}) {
# Help section for each module, need to add in
$AUBBC_mod->add_build_tag(
        name     => 'help',
        pattern  => '',
        type     => 4,
        function => "<a href=\"#top\" onclick=\"javascript:gethelpBox(\'$cfg{module}:\:$cfg{op}\');\">Help?</a>",
        );
$AUBBC_mod->add_build_tag(
        name     => 'close_help',
        pattern  => '',
        type     => 4,
        function => "<a href=\"#top\" onclick=\"javascript:closeMessage(\'help\');\">Close <img src=\"$cfg{imagesurl}/button_cance.png\" alt=\"Close\" border=\"0\" /></a>",
        );
    }
}

sub search_links {
my ($tag_name, $message) = @_;
#my $message = shift;
my $search_pat = 'a-zA-Z\d\:\-\s\_\/\.';
 # Flex-WPS Search
 if ($message =~ m/\A([$search_pat]+)\,([a-z\s]+)\z/i) {
 # Pattern, search in   [search://search_term,wiki forums poll]
 $message = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=search,Search;query=$1;match=OR;what=$2\"$cfg{hreftarget}>$1</a>";
 }
  elsif ($message =~ m/\A([$search_pat]+)\,([a-z\s]+)\,(AND|OR)\z/i) {
 # Pattern, search in, Boolean   [search://search_term,wiki forums poll,OR]
 $message = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=search,Search;query=$1;match=$3;what=$2\"$cfg{hreftarget}>$1</a>";
 }
  elsif ($message =~ m/\A([$search_pat]+)\,([a-z\s]+)\,(AND|OR)\,(i|s)\z/i) {
 # Pattern, search in, Boolean, case   [search://search_term,wiki forums poll,OR,s]
 $message = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=search,Search;case=$4;query=$1;match=$3;what=$2\"$cfg{hreftarget}>$1</a>";

 # All Search  [search://search_term]
 }
  elsif ($message =~ m/\A([$search_pat]+)\z/i) {
 $message = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=search,Search;query=$1;match=OR\"$cfg{hreftarget}>$1</a>";
 }
  else {
  $message = '';
  }
 return $message;
}
 sub other_sites {
 my ($tag_name, $text_from_AUBBC) = @_;

# cpan modules
 $text_from_AUBBC = AUBBC::make_link("http://search.cpan.org/search?mode=module&amp;query=$text_from_AUBBC",$text_from_AUBBC,'',1)
  if $tag_name eq 'cpan';

# wikipedia Wiki
 $text_from_AUBBC = AUBBC::make_link("http://wikipedia.org/wiki/Special:Search?search=$text_from_AUBBC",$text_from_AUBBC,'',1)
  if ($tag_name eq 'wikipedia' || $tag_name eq 'wp');

# wikibooks Wiki Books
 $text_from_AUBBC = AUBBC::make_link("http://wikibooks.org/wiki/Special:Search?search=$text_from_AUBBC",$text_from_AUBBC,'',1)
  if ($tag_name eq 'wikibooks' || $tag_name eq 'wb');

# wikiquote Wiki Quote
 $text_from_AUBBC = AUBBC::make_link("http://wikiquote.org/wiki/Special:Search?search=$text_from_AUBBC",$text_from_AUBBC,'',1)
  if ($tag_name eq 'wikiquote' || $tag_name eq 'wq');

# wikisource Wiki Source
 $text_from_AUBBC = AUBBC::make_link("http://wikisource.org/wiki/Special:Search?search=$text_from_AUBBC",$text_from_AUBBC,'',1)
  if ($tag_name eq 'wikisource' || $tag_name eq 'ws');

# google search
 $text_from_AUBBC = AUBBC::make_link("http://www.google.com/search?q=$text_from_AUBBC",$text_from_AUBBC,'',1)
  if $tag_name eq 'google';
  
 # yahoo search
 # http://search.yahoo.com/search?p=search%20terms
 $text_from_AUBBC = AUBBC::make_link("http://search.yahoo.com/search?p=$text_from_AUBBC",$text_from_AUBBC,'',1)
  if $tag_name eq 'yahoo';

 # msn search
 # http://search.msn.com/results.aspx?q=search%20terms
 $text_from_AUBBC = AUBBC::make_link("http://search.msn.com/results.aspx?q=$text_from_AUBBC",$text_from_AUBBC,'',1)
  if $tag_name eq 'msn';

 # localtime()
 if ($tag_name eq 'time') {
        my $time = scalar(localtime);
        $text_from_AUBBC = "<b>[$time]</b>";
        }
        return $text_from_AUBBC;
 }
 
sub page_links {
my ($tag_name, $page_id) = @_;
#my $page_id = shift;

if ($page_id) {
$page_id = $back_ends{$cfg{Portal_backend}}->quote($page_id);
my $sth = "SELECT pageid, title FROM pages WHERE pageid=$page_id AND active='1' AND sec_level='$usr{anonuser}' LIMIT 1;";
if ($user_data{sec_level} eq $usr{admin}) {
     $sth = "SELECT pageid, title FROM pages WHERE pageid=$page_id LIMIT 1;";
       }
        elsif ($user_data{sec_level} eq $usr{mod}) {
                $sth = "SELECT pageid, title FROM pages WHERE pageid=$page_id AND active='1' AND sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 1;";
        }
         elsif ($user_data{sec_level} eq $usr{user}) {
                $sth = "SELECT pageid, title FROM pages WHERE pageid=$page_id AND active='1' AND sec_level REGEXP '($usr{anonuser}|$usr{user})' LIMIT 1;";
         }
$sth = $back_ends{$cfg{Portal_backend}}->prepare($sth);
$sth->execute;
$page_id = '';
while(my @row = $sth->fetchrow)  {
$page_id = AUBBC::make_link("$cfg{homeurl}/page/$row[0]/",$row[1],'',0) if $row[0];
}
$sth->finish;

}
 else {
  $page_id = '';
 }

return $page_id;
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
