package Search;
=head1 Flex-WPS Search
 By: N.K.A.
 
 Date: 2/10/2014
 Version: 1.4
 - Fixed term formating error
 
 Version: 1.3 - 5/21/2009
 - Fixed bug that prevented partial matching of single search terms.

 Version: 1.2 - 10/20/2007
 - Fixed Bug in Search Select
 - Added Wiki, Site Log, Members Search
 - Changed HTML Style

 First version 1.0 - 06/24/2006
 This is now a SQL back-end.

=cut

# Load necessary modules.
use strict;

# Assign global variables.
use vars qw(
    $query %back_ends $AUBBC_mod
    $search_term $match $case @what $start $max_items_per_page
    %user_data %nav %cfg %usr %msg %btn $Flex_WPS %user_action
    );

use exporter;
%user_action = ( search => $usr{anonuser} );

# search start
my $search_start = time;
# Get the input& Define missing veriables.
$search_term = $query->param('query');
$match       = $query->param('match') || 'OR';
$case        = $query->param('case') || 'i';
@what        = $query->param('what') || ('all');
$start = $query->param('start') || 0;
$max_items_per_page = $query->param('page') || 15;


if ($what[0] =~ /\s/) {
 my @whater = split (/\s/, $what[0]);
 @what = @whater;
}

# Change suspicious veriables w/ some protection.
if ($start && $start !~ /^[0-9]+$/ || length($start) > 10) { $start = 0; }
if ($max_items_per_page && $max_items_per_page !~ /^[0-9]+$/
     || $max_items_per_page && length($max_items_per_page) > 10
     || $max_items_per_page && $max_items_per_page <= 0) { $max_items_per_page = 15; }

# Cycle through category and display all entries.
my $num_shown = 0;

# Filter Search Term
if ($search_term) {
$search_term =~ s/&/&amp;/g;
$search_term =~ s/</&lt;/g;
$search_term =~ s/>/&gt;/g;
$search_term =~ s/"/&quot;/g;
$search_term =~ s~\$~&#36;~g;
$search_term =~ s~\(~&#40;~g;
$search_term =~ s~\)~&#41;~g;
$search_term =~ s~\*~&#42;~g;
$search_term =~ s~\+~&#43;~g;
#$search_term =~ s~\.~&#46;~g; # removed so i can search for IP's
#$search_term =~ s~\:~&#58;~g; # no problem found with it?
$search_term =~ s~\?~&#63;~g;
$search_term =~ s~\[~&#91;~g;
$search_term =~ s/\\/&#92;/g;
$search_term =~ s~\]~&#93;~g;
$search_term =~ s~\^~&#94;~g;
$search_term =~ s~\{~&#123;~g;
$search_term =~ s/\|/&#124;/g;
$search_term =~ s~\}~&#125;~g;
$search_term =~ s~\~~&#126;~g;
}

sub search {

# Check if input is valid.
if (!$search_term || length($search_term) < 3 || length($search_term) > 50) {
$Flex_WPS->print_page(
        markup       => search_box(),
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => $nav{search},
        );
}
 else {
 
#my @search_term = split (/\s+/, $search_term);
my (@matches, @data, @sorted_matches);

# Save Searched Term and Count Times Term is Searched
my $add = 1;
my $number = 1;
my $name = '';
my $name_quote = '';
$name_quote = $search_term;
$name_quote = $back_ends{$cfg{Portal_backend}}->quote($name_quote);
my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM search_log WHERE term=$name_quote LIMIT 1 ;");
$name_quote = '';
$sth->execute;
# Get page content.
while(my @row = $sth->fetchrow)  {

if ($row[1] eq $search_term) {
$add = 2;
$number = $row[2] + $number;
$name = $search_term;
   }
}
# Upadte or add to Search log.
if($add eq 2) {
$name_quote = $name;
$name_quote = $back_ends{$cfg{Portal_backend}}->quote($name_quote);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "UPDATE `search_log` SET `count` = '$number' WHERE `term` =$name_quote LIMIT 1 ;");
} else {
$name_quote = $search_term;
$name_quote = $back_ends{$cfg{Portal_backend}}->quote($name_quote);
$Flex_WPS->SQL_Edit($cfg{Portal_backend}, "INSERT INTO search_log VALUES (NULL,$name_quote,'1')");
}

# Perform search.
foreach my $what (@what) {

# Flex Product Manager
# if ($what eq 'Cart_PM' || $what eq 'all')
# {
#
# # Search for pages.
# my $query1 = "SELECT * FROM cart_product_details";
# my $sth = $dbh->prepare($query1);
# $sth->execute;
# # Get page content.
# while(my @row = $sth->fetchrow)  {
# # Search in page's title and body.
# my $string = join (' ', $row[0], $row[1], $row[2], $row[3], $row[4], $row[5], $row[6], $row[7]);
# my $found = do_search($string);
# if ($found) {
#    push (@matches,
#    join ('|', $row[0], "$row[1] - $row[2] - $row[3] - $row[5], $row[6], $row[7]", $usr{admin}, '', 'Cart_PM'));
#    }
# }
# $sth->finish();
# }

# Cart Search
if ($what eq 'cart' || $what eq 'all') {
my $new_term = $search_term;
my $search_case = '';
$search_case = ' BINARY' if $case eq 's';
#$new_term =~ s/\s/\|/gso if $match eq 'OR';
if ($match eq 'OR' && $new_term =~ m/\s{1}/) {
 #$new_term =~ s/\s/\|/gs; # (?<!>)
 $new_term = term_format($new_term);
}
 elsif ($match eq 'OR') {
    $new_term = $new_term.'|'.$new_term;
 }
# Search for pages.
my $query1 = "SELECT id, title, description FROM `cart_products` WHERE `active`='Yes' AND (`title` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `description` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\") LIMIT 0 , 30";

#SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};
my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute;
# Get page content.
while(my @row = $sth->fetchrow)  {
#($id, $subject, $poster, $cat, $type)
   push (@matches,
   join ('|', $row[0], $row[1], $cfg{pagetitle}, '', 'cart'));
}
$sth->finish();
}

# Page Search - mySQL Search
if ($what eq 'pages' || $what eq 'all') {
my $new_term = $search_term;
my $search_case = '';
$search_case = ' BINARY' if $case eq 's';
#$new_term =~ s/\s/\|/gso if $match eq 'OR';
if ($match eq 'OR' && $new_term =~ m/\s{1}/) {
 #$new_term =~ s/\s/\|/gs; # (?<!>)
 $new_term = term_format($new_term);
}
 elsif ($match eq 'OR') {
    $new_term = $new_term.'|'.$new_term;
 }
# Search for pages.
my $query1 = "SELECT pageid, title FROM `pages` WHERE `active`='1' AND (`title` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `pagetext` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level`='$usr{anonuser}' LIMIT 0 , 30";
if ($user_data{sec_level} eq $usr{admin}) {
$query1 = "SELECT pageid, title FROM `pages` WHERE `title` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `pagetext` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" LIMIT 0 , 30";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
 $query1 = "SELECT pageid, title FROM `pages` WHERE `active`='1' AND (`title` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `pagetext` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 0 , 30";
 }
  elsif ($user_data{sec_level} eq $usr{user}) {
  $query1 = "SELECT pageid, title FROM `pages` WHERE `active`='1' AND (`title` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `pagetext` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user})' LIMIT 0 , 30";
  }
#SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};
my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
$sth->execute;
# Get page content.
while(my @row = $sth->fetchrow)  {
   push (@matches,
   join ('|', $row[0], $row[1], $cfg{pagetitle}, '', 'pages'));
}
$sth->finish();
}

## ProRV ads Search - mySQL Search
#if ($what eq 'listing' || $what eq 'all') {
#my $new_term = $search_term;
#my $search_case = '';
#$search_case = ' BINARY' if $case eq 's';
##$new_term =~ s/\s/\|/gso if $match eq 'OR';
#if ($match eq 'OR' && $new_term =~ m/\s{1}/) {
# $new_term = term_format($new_term);
#}
# elsif ($match eq 'OR') {
#    $new_term = $new_term.'|'.$new_term;
# }
## Search for pages.   WHERE expire >= $date ORDER BY `expire` DESC
#my $date = Flex_CGI::expire_calc('now','');
#my $query1 = "SELECT id, customer_id, year, make, model FROM `prorv_posts`
#WHERE expire >= $date
#AND (`description` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `year` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `make` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `model` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `class` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `ad_number` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `verification` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `expire` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\")
#ORDER BY `expire` DESC LIMIT 0 , 30";

#if ($user_data{sec_level} eq $usr{admin}) {
#$query1 = "SELECT id, customer_id, year, make, model FROM `prorv_posts`
#WHERE `description` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `year` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `make` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `model` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `class` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `ad_number` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `verification` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `expire` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#ORDER BY `expire` DESC LIMIT 0 , 30";
#}

##SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};
#my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
#$sth->execute;
## Get page content.
#while(my @row = $sth->fetchrow)  {
#   push (@matches,
#   join ('|', $row[0].';lead='.$row[1], "$row[2] $row[3] $row[4]", $cfg{pagetitle}, '', 'listing'));
#}
#$sth->finish();
#}

## ProRV customers Search - mySQL Search
#if ($user_data{sec_level} eq $usr{admin} && $what eq 'customers') {
#my $new_term = $search_term;
#my $search_case = '';
#$search_case = ' BINARY' if $case eq 's';
##$new_term =~ s/\s/\|/gso if $match eq 'OR';
#if ($match eq 'OR' && $new_term =~ m/\s{1}/) {
# $new_term = term_format($new_term);
#}
# elsif ($match eq 'OR') {
#    $new_term = $new_term.'|'.$new_term;
# }
## Search for pages.   WHERE expire >= $date ORDER BY `expire` DESC
#my $query1 = "SELECT id, first_name, last_name, phone1, fax2, date FROM `orders_customers`
#WHERE `first_name` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `last_name` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `phone1` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `fax2` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#OR `date` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
#LIMIT 0 , 30";

#my $sth = $back_ends{$cfg{Portal_backend}}->prepare($query1);
#$sth->execute;
## Get page content.
#while(my @row = $sth->fetchrow)  {
#   push (@matches,
#   join ('|', $row[0], "$row[1] $row[2] $row[3]", $cfg{pagetitle}, '', 'customers'));
#}
#$sth->finish();
#}

## FAQ search - mySQL Search
#if ($what eq 'faq' || $what eq 'all') {
#my $new_term = $search_term;
#my $search_case = '';
#$search_case = ' BINARY' if $case eq 's';
#$new_term =~ s/\s/\|/gso if $match eq 'OR';
## Search for pages.
#my $query1 = "SELECT id, question FROM faq WHERE (`question` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\")";
## if ($user_data{sec_level} eq $usr{admin}) {
## $query1 = "SELECT id, question FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") LIMIT 0 , 30";
## }
##  elsif ($user_data{sec_level} eq $usr{mod}) {
##  $query1 = "SELECT id, question FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 0 , 30";
##  }
##   elsif ($user_data{sec_level} eq $usr{user}) {
##   $query1 = "SELECT id, question FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user})' LIMIT 0 , 30";
##   }
##$query1 = "SELECT * FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 0 , 30";
#my $sth = $back_ends{$search_set{backend_name}}->prepare($query1);
#$sth->execute;
## Get page content.
#while(my @row = $sth->fetchrow)  {
#   push (@matches,
#   join ('|', $row[0], $row[1], $usr{admin}, '', 'faq'));
# }
# $sth->finish();
#}

## Members search - mySQL Search
#if ($what eq 'members' && $user_data{sec_level} ne $usr{anonuser}) {
#my $new_term = $search_term;
#my $search_case = '';
#$search_case = ' BINARY' if $case eq 's';
#$new_term =~ s/\s/\|/gso if $match eq 'OR';
## Search for pages.
#my $query1 = '';
#if ($user_data{sec_level} eq $usr{admin}) {
#$query1 = "SELECT memberid, uid, nick FROM members WHERE (`uid` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `nick` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\") LIMIT 0 , 30";
#}
# elsif ($user_data{sec_level} eq $usr{mod} || $user_data{sec_level} eq $usr{user}) {
# $query1 = "SELECT memberid, uid, nick FROM members WHERE (`uid` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `nick` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\") AND `approved`='1' LIMIT 0 , 30";
# }

##$query1 = "SELECT * FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 0 , 30";
#my $sth = $back_ends{$search_set{backend_name}}->prepare($query1);
#$sth->execute;
## Get page content.
#while(my @row = $sth->fetchrow)  {
#my $s_name = $row[1] . '<small>/(' . $row[2] . ')</small>';
#   push (@matches,
#   join ('|', $row[0], $s_name, $s_name, '', 'members'));
# }
# $sth->finish();
#}
## SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};
## Forum search - mySQL Search
#if ($what eq 'forums' || $what eq 'all') {
#my $new_term = $search_term;
#my $search_case = '';
#$search_case = ' BINARY' if $case eq 's';
#$new_term =~ s/\s/\|/gso if $match eq 'OR';
## Search for pages.
#my $query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND forum_cat.sec_level = '$usr{anonuser}' AND (forum_threads.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_threads.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
#if ($user_data{sec_level} eq $usr{admin}) {
#$query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND (forum_threads.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_threads.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
#}
# elsif ($user_data{sec_level} eq $usr{mod}) {
# $query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' AND (forum_threads.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_threads.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
# }
#  elsif ($user_data{sec_level} eq $usr{user}) {
#  $query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user})' AND (forum_threads.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_threads.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
#  }
##$query1 = "SELECT * FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 0 , 30";
#my $sth = $back_ends{$search_set{backend_name}}->prepare($query1);
#$sth->execute;
## Get page content.
#while(my @row = $sth->fetchrow)  {
#my $s_name =  $row[4] . ',' . $row[1] . ','. $row[0] . ',' . $row[5] . ',' . '';
#   push (@matches,
#   join ('|', $s_name, $row[3], $row[2], $row[5], 'forums'));
# }
# $sth->finish();
#$query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type, forum_reply.id FROM forum_threads, forum_reply, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND forum_reply.thread_id=forum_threads.id AND forum_cat.sec_level = '$usr{anonuser}' AND (forum_reply.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_reply.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
#if ($user_data{sec_level} eq $usr{admin}) {
#$query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type, forum_reply.id FROM forum_threads, forum_reply, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND forum_reply.thread_id=forum_threads.id AND (forum_reply.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_reply.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
#}
# elsif ($user_data{sec_level} eq $usr{mod}) {
# $query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type, forum_reply.id FROM forum_threads, forum_reply, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND forum_reply.thread_id=forum_threads.id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' AND (forum_reply.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_reply.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
# }
#  elsif ($user_data{sec_level} eq $usr{user}) {
#  $query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type, forum_reply.id FROM forum_threads, forum_reply, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND forum_reply.thread_id=forum_threads.id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user})' AND (forum_reply.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_reply.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
#  }
##$query1 = "SELECT * FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 0 , 30";
#my $sth = $back_ends{$search_set{backend_name}}->prepare($query1);
#$sth->execute;
## Get page content.
#while(my @row = $sth->fetchrow)  {
#my $s_name =  $row[4] . ',' . $row[1] . ','. $row[0] . ',' . $row[5] . ",#0$row[6]";
#   push (@matches,
#   join ('|', $s_name, $row[3], $row[2], $row[5], 'forums'));
# }
# $sth->finish();
#}

## Wiki search - mySQL Search
#if ($what eq 'wiki' || $what eq 'all') {
#my $new_term = $search_term;
#my $search_case = '';
#$search_case = ' BINARY' if $case eq 's';
#$new_term =~ s/\s/\|/gso if $match eq 'OR';
## Search for pages.
#my $query1 = "SELECT id, name, lastauther FROM wiki_site WHERE (`name` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `desc` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `also_see` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\") LIMIT 0 , 30";

##$query1 = "SELECT * FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 0 , 30";
#my $sth = $back_ends{$search_set{backend_name}}->prepare($query1);
#$sth->execute;
## Get page content.
#while(my @row = $sth->fetchrow)  {

#   push (@matches,
#   join ('|', $row[0], $row[1], $row[2], '', 'wiki'));

# }
# $sth->finish();
#}

# Site Log Search - mySQL Search
if ($user_data{sec_level} eq $usr{admin} && $what eq 'statlog') {
my $new_term = $search_term;
my $search_case = '';
$search_case = ' BINARY' if $case eq 's';
#$new_term =~ s/\s/\|/gso if $match eq 'OR';
if ($match eq 'OR' && $new_term =~ m/\s{1}/) {
 $new_term = term_format($new_term);
}
 elsif ($match eq 'OR') {
    $new_term = $new_term.'|'.$new_term;
 }
# Search for pages.
#SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};
my $sth = $back_ends{$cfg{Portal_backend}}->prepare("SELECT * FROM `stats_log` WHERE `stats_info` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" ORDER BY id DESC");
$sth->execute;
# Get page content.
while(my @row = $sth->fetchrow)  {
$row[2] =~ s/\|/ &#124;/gso;
   push (@matches,
   join ('|', $row[0], "$row[2]", $cfg{pagetitle}, $row[1], 'statlog'));
}
$sth->finish();
}

## Listings Search - mySQL Search
#if ($what eq 'all' || $what eq 'listing') {
#my $new_term = $search_term;
#my $search_case = '';
#$search_case = ' BINARY' if $case eq 's';
##$new_term =~ s/\s/\|/gso if $match eq 'OR';
#if ($match eq 'OR' && $new_term =~ m/\s{1}/) {
# $new_term =~ s/\s/\|/gs;
#}
# elsif ($match eq 'OR') {
#    $new_term = $new_term.'|'.$new_term;
# }
#my $date = CGI::Util::expire_calc('now','');
## Search for pages.
##SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};
#my $sth = $back_ends{$cfg{Portal_backend}}->prepare(
#"SELECT listing_cats.`title`, listing_posts.`id`, listing_posts.`title`, listing_posts.`zipcode`, listing_posts.`listpic`
#FROM `listing_cats`, `listing_posts`
#WHERE (listing_posts.`description` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
# OR listing_posts.`title` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\"
# OR listing_posts.`zipcode` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\")
#AND listing_cats.`id` = listing_posts.`cat`
#AND listing_posts.`expire` >= $date
#ORDER BY id DESC");
#$sth->execute;
## Get page content.
#while(my @row = $sth->fetchrow)  {
#my $listpic = ($row[4])
#? "<img src=\"$cfg{imagesurl}/uploads/listings/$row[4]\" border=\"0\" alt=\"\" height=\"25\" width=\"25\" />"
#: '';
#my $sub_link = "$listpic <b>$row[0]</b> - $row[2] - <small>zip: $row[3]</small>";
#$sub_link =~ s/\|/ &#124;/gso;
#$AUBBC_mod->settings(for_links => 1,);
#$sub_link = $AUBBC_mod->do_all_ubbc($sub_link);
#$AUBBC_mod->settings(for_links => 0,);
#   push (@matches,
#   join ('|', $row[1], $sub_link, 'a member.', '', 'listing'));
#}
#$sth->finish();
#}

}

for (0 .. $#matches)
{
        my @fields = split (/\|/, $matches[$_]);
        for my $i (0 .. $#fields) { $data[$_][$i] = $fields[$i]; }
}

# Sort the matches by category.
my @sorted = sort { $a->[4] cmp $b->[4] } @data;
for (@sorted) {
        my $sorted_row = join ("|", @$_);
        push (@sorted_matches, $sorted_row);
}

$Flex_WPS->print_header( cookie1 => '', cookie2 => '',);
$Flex_WPS->print_html(
        page_name    => $nav{search},
        type         => '',
        ajax_name    => '',
        );
print search_box();

# Print the results.
if (!@matches) { print "<b>$msg{db_was_searched} \"<i>$search_term</i>\"<br />$msg{no_matches}.</b>"; }
else
{
        my $sorted_matches = @sorted_matches;

        my $result = $sorted_matches . ' ' . $msg{matches};
        if ($sorted_matches == 1)
        {
                $result = $sorted_matches . ' ' . $msg{match};
        }
  $search_start = time - $search_start;
        print <<HTML;
<table border="0" cellpadding="0" cellspacing="5" width="100%">
<tr>
<td><b>$msg{db_was_searched} "<i>$search_term</i>".<br />
$msg{search_returned} $result in $search_start second(s).</b></td>
</tr>
HTML

        for (my $i = $start; $i < @sorted_matches; $i++) {
                my ($id, $subject, $poster, $cat, $type) =
                    split (/\|/, $sorted_matches[$i]);

                # Get nick of link poster.
                my $user_profile = '';#= file2array("$cfg{memberdir}/$poster.dat", 1);

                print <<HTML;
<tr>
<td><div style="padding: 3px 5px 3px 5px;" class="navtable"><img src="$cfg{imagesurl}/icon/urlgo.gif" border="0" alt="" />&nbsp;&nbsp;
HTML
                if ($type eq 'cart') {
                        print <<HTML;
<b>Product:</b> <b><a href="$cfg{pageurl}/index.$cfg{ext}?op=view,cart_view;id=$id">$subject</a></b><br />\n
HTML
                }
                if ($type eq 'pages') {
                        print <<HTML;
<b>$nav{pages}:</b> <b><a href="$cfg{homeurl}/page/$id/">$subject</a></b><br />\n
HTML
                }
#                if ($type eq 'listing') {
#                        print <<HTML;
#<b>Listing:</b> <b><a href="$cfg{pageurl}/index.$cfg{ext}?op=view,prorv_list;id=$id">$subject</a></b><br />\n
#HTML
#    }
#                if ($type eq 'customers') {
#                        print <<HTML;
#<b>Customer:</b> <b><a href="$cfg{pageurl}/index.$cfg{ext}?op=ct_form,prorv;id=$id">$subject</a></b><br />\n
#HTML
#    }
                # Search sub load
                #&search_subload('3');
#                if ($type eq 'faq') {
#                        print <<HTML;
#<b>FAQ's:</b> <b><a href="$cfg{pageurl}/index.$cfg{ext}?op=view_answer,FAQ;id=$id">$subject</a></b><br />\n
#HTML
#    }
#                if ($type eq 'members') {
#                        print <<HTML;
#<b>Member:</b> <b><a href="$cfg{pageurl}/index.$cfg{ext}?op=view_profile,user;username=$id">$subject</a></b><br />\n
#HTML
#                }
#                if ($type eq 'forums') {
#                       my ($cats, $subs, $threads, $stickys, $jump_forum) = split(/\,/, $id);
#                        print <<HTML;
#<b>$nav{$cat}:</b> <b>
#<a href="$cfg{pageurl}/index.$cfg{ext}?op=threads,Forum;cat=$cats;subcat=$subs;thread=$threads;sticky=$stickys$jump_forum">$subject</a></b><br />\n
#<font color=DarkRed>Link to this Thread: [id://$threads$jump_forum]</font><br />\n
#HTML
#                }
                if ($type eq 'statlog') {
                      # my ($cats, $subs, $threads, $stickys) = split(/\,/, $id);
                        $cat = $Flex_WPS->format_date($cat, 11);
                        print <<HTML;
<b>Log:</b> $id - $subject<br /><font color=DarkRed>$cat</font><br />\n);
HTML
                }
#                if ($type eq 'wiki') {
#                      # my ($cats, $subs, $threads, $stickys) = split(/\,/, $id);
#                        print <<HTML;
#<b>Wiki:</b> <a href="$cfg{pageurl}/index.$cfg{ext}?op=view,Wiki;id=$id"><b>$subject</b></a><br />
#<font color=DarkRed><b>Link to this wiki:</b> [wkid://$id] <b>or</b> [wiki://$subject]</font><br />\n
#HTML
#                        print <<HTML if $user_data{sec_level} eq $usr{admin};
#<small><a href="$cfg{pageurl}/index.$cfg{ext}?op=admin,Wiki;id=$id">Edit This Wiki</a> | <a href="$cfg{pageurl}/index.$cfg{ext}?op=admin,Wiki">Add New Wiki</a></small><br />
#HTML
#                }
                print '<small>' . $msg{written_by} . ' ' . $poster . '</small>' if $poster;

                print <<HTML;
</div>
</td>
</tr>
HTML
                $num_shown++;
                if ($num_shown >= $max_items_per_page) { last; }
        }
print '</table>';

        if ($num_shown)
        {
                print "<hr noshade=\"noshade\" size=\"1\" />\n Number of Pages ";
                my $num_links = scalar @sorted_matches;

                my $count = 0;
                while (($count * $max_items_per_page) < $num_links)
                {
                        my $viewc = $count + 1;
                        my $strt  = ($count * $max_items_per_page);
                        if ($start == $strt) { print " [$viewc] &nbsp;"; }
                        else
                        {
                                print "&nbsp;<a href=\"index.$cfg{ext}?op=search,Search;start=$strt;query=$search_term;page=$max_items_per_page;match=$match;what=@what\">$viewc</a> &nbsp;";
                        }
                        $count++;
                }
        }

}

$Flex_WPS->print_html(
        page_name    => $nav{search},
        type         => 1,
        ajax_name    => '',
        );
 }
}
# Load other modules for search
# Not fully used yet
# Note: Make Main sub load with changing query, for small code
#sub search_subload {
#my ($location) = @_;
#my $query1 = "SELECT * FROM search_subload WHERE location='$location'";
#my $sth = $dbh->prepare($query1);
#$sth->execute || die("Couldn't exec sth!");
#no strict 'refs'; # 0, well..
#while(my @row = $sth->fetchrow) {
#if (!$row[1] && $row[4]) { require "$row[2].pm"; my $load = $row[2] . '::' . $row[3]; $load->(); }
#elsif ($row[1]) { use lib './lib/modules'; require "$row[2].pm"; my $load = $row[2] . '::' . $row[3]; $load->(); }
#}
#$sth->finish();
#}
# Search Box
sub search_box {
my $search_html = '';
if (!$search_term) { $search_term = ''; }
        $search_html = <<HTML;
<b>$msg{new} $msg{search}:</b><br />
<form action="" method="post" name="sform" onsubmit="if (document.sform.query.value=='') return false">
<table border="0" cellpadding="2" cellspacing="0" width="100%">
<tr>
<td valign="top"><table border="0" cellpadding="2" cellspacing="0">
<tr>
<td><b>$msg{search_for}:</b></td>
<td><input name="query" type="text" size="20" value="$search_term" maxlength="256" /></td>
</tr>
<tr>
<td><b>$msg{boolean}:</b></td>
<td><select name="match">
<option value="OR">$msg{search_or}</option>
<option value="AND">$msg{search_and}</option>
</select></td>
</tr>
<tr>
<td><b>$msg{case}:</b></td>
<td><select name="case">
<option value="i">$msg{search_insensitive}</option>
<option value="s">$msg{search_sensitive}</option>
</select></td>
</tr>
<tr>
<td><b>Items Per Page:</b></td>
<td><select name="page">
<option value="35">35</option>
<option value="30">30</option>
<option value="25">25</option>
<option value="20">20</option>
<option value="15">15</option>
<option value="10">10</option>
<option value="5">5</option>
</select></td>
</tr>
</table>
</td>
<td valign="top"><table border="0" cellpadding="2" cellspacing="0">
<tr>
<td valign="top"><b>$msg{search_in}:</b></td>
<td><select name="what" size="6" multiple>
HTML

# Bug fixxed
my ($listing,$c_check, $forum_check, $page_check, $faq_check, $mem_check, $stat_check) = ('','','','','','','');
foreach my $what (@what) {
#$c_check = ' selected' if $what eq 'customers';
#$forum_check = ' selected' if $what eq 'forums';
$page_check = ' selected' if $what eq 'pages';
$listing = ' selected' if $what eq 'cart';
#$faq_check = ' selected' if $what eq 'faq';
#$mem_check = ' selected' if ($what eq 'members' && $user_data{sec_level} eq $usr{admin});
$stat_check = ' selected' if ($what eq 'statlog' && $user_data{sec_level} eq $usr{admin});
}
 $search_html .= <<HTML;
<option value="pages"$page_check>$nav{pages}</option>
<option value="cart"$listing>Products</option>
HTML
#<option value="wiki"$wk_check>Wiki</option>
#<option value="forums"$forum_check>$nav{forums}</option>
#<option value="faq"$faq_check>FAQ's</option>
#$search_html .= "<option value=\"customers\"$c_check>Customers</option>" if ($user_data{sec_level} eq $usr{admin});
$search_html .= "<option value=\"statlog\"$stat_check>Site Log</option>" if ($user_data{sec_level} eq $usr{admin});

 $search_html .= <<HTML;
</select></td>
</tr>
</table></td>
</tr>
<tr>
<td><input type="hidden" name="op" value="search,Search" /><input type="submit" value="$btn{search}" /></td>
</tr>
</table>
</form>
<hr size="1" />
HTML

return $search_html;
}

sub term_format {
 my $term = shift;
 
 my @search_term = split (/\s/, $term);
 $term = '';
 foreach (@search_term) {
  if ($term) {
    $term .= '|' . $_ if $_;
  } else {
    $term .= $_ if $_;
   }
 }
 
 return $term;
}

# ---------------------------------------------------------------------
# Perform boolean search in given text string.
# ---------------------------------------------------------------------
# Nothing is using this
# sub do_search
# {
#         my $string = shift;
#         my $found  = 0;
#
#         if ($match eq 'AND')
#         {
#                 foreach my $term (@search_term)
#                 {
#                         if ($case eq 'Insensitive')
#                         {
#                                 if (!($string =~ /$term/i)) { $found = 0; last; }
#                                 else { $found = 1; }
#                         }
#                         if ($case eq 'Sensitive')
#                         {
#                                 if (!($string =~ /$term/)) { $found = 0; last; }
#                                 else { $found = 1; }
#                         }
#                 }
#         }
#
#         if ($match eq 'OR')
#         {
#                 foreach my $term (@search_term)
#                 {
#                         if ($case eq 'Insensitive')
#                         {
#                                 if ($string =~ /$term/i) { $found = 1; last; }
#                                 else { $found = 0; }
#                         }
#                         if ($case eq 'Sensitive')
#                         {
#                                 if (!($string =~ /$term/)) { $found = 1; last; }
#                                 else { $found = 0; }
#                         }
#                 }
#         }
#
#         return $found;
# }
1;
