package home_news;

use vars qw(
        $db_name %cfg %user_data %usr
        $Flex_WPS $AUBBC_mod %back_ends %msg %nav
        );
use strict;
use exporter;

# %sub_action
# %sub_action = (home_news_load => 1);

sub sub_action {
  return ( home_news_load => 1 );
}

 $cfg{max_items_per_page} = 15;
sub home_news_load {
my $backend_name = shift;

my ($post_msg, $last_date) = ('','');
my @messages = ();
#my $num_shown = 0;
# mySQL Query works
# WOOT mySQL!!!
my $query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll)' AND forum_cat.sec_level = '$usr{anonuser}' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};";
if ($user_data{sec_level} eq $usr{admin}) {
$query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll)' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
$query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll)' AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};";
 }
  elsif ($user_data{sec_level} eq $usr{user}) {
$query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll)' AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user})' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};";
  }
  my $row_color = ' class="tbl_row_dark"';
my $sth = $back_ends{$backend_name}->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow)  {
if($row[13]) { $last_date = $row[13]; }
else { $last_date = $row[5]; }

                $row_color =
                    ($row_color eq ' class="tbl_row_dark"')
                    ? ' class="tbl_row_light"'
                    : ' class="tbl_row_dark"';

my $cat_type = '';
# my $catname = $row[18];
$cat_type = $row[$#row] if $row[$#row];

                if (!$row[8]) {
                # Check if thread is hot or not.
                my $type;
                if ($row[3] <= 2) { $type = "off"; }
                if ($row[3] > 2 || $row[4] >= 10) { $type = "on"; }
                if ($row[3] >=10 || $row[4] >= 25) { $type = "thread"; }
                if ($row[3] >= 15 || $row[4] >= 75)  { $type = "hotthread"; }
                if ($row[3] >= 25 || $row[4] >= 100) { $type = "veryhotthread"; }
                if ($row[7]) { $type = "locked"; }
                #if(!$type) { $type = "thread"; }

                # Thread page navigator.
                my $num_messages = $row[3] + 1;
                my $count        = 0;
                my $pages = '';
                if ($num_messages > $cfg{max_items_per_page})
                {
                        while ($count * $cfg{max_items_per_page} < $num_messages)
                        {
                                my $view = $count + 1;
                                my $strt = ($count * $cfg{max_items_per_page});
                                if($strt) { $strt -= 1; }
                                $pages .=
                                    qq( [<a href="$cfg{pageurl}/index.$cfg{ext}?op=threads,Forum;cat=$row[1];subcat=$row[2];thread=$row[0];start=$strt;sticky=$cat_type">$view</a>]);
                                $count++;
                        }

                       # $pages =~ s/\n$//g;
                        $pages =
                            qq(( <img src="$cfg{imagesurl}/forum/multipage.gif" alt="" /> $pages ));
                }

             #   my $unseen = '';
                my $new = qq(<img src="$cfg{imagesurl}/forum/off.gif" alt="" />);
#                 if ($unseen)
#                         {
#                                 $new = qq(<img src="$cfg{imagesurl}/forum/on.gif" alt="">);
#                         }
                my $last_post = $row[14];
                if($last_post ne 'Self') {
                #$last_post =~ s/\|/\,/gso;
                $last_post =~ s/(.*?)\,(.*?)\,(.*?)\,(.*?)\,(.*?)$//i;
                #my ($dt, $lcat, $lsubcat, $lthread, $lposter) = split (/\|/, $_);
                #require DATE_TIME;
                my $format_dt = $Flex_WPS->format_date($1, 2);
                $last_post = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=threads,Forum;cat=$2;subcat=$3;sticky=$cat_type;thread=$4">$format_dt</a><br>$msg{by} $5);
                } else {
                $last_post = qq(No Replies/ Edited);
                }
                my $subject = $row[11];
                #use UBBC;
                #$subject = UBBC::do_smileys($subject);
                $AUBBC_mod->settings( for_links => 1 );
                $subject = $AUBBC_mod->do_all_ubbc($subject);
                $AUBBC_mod->settings( for_links => 0 );
                $post_msg .= <<HTML;
<tr$row_color>
<td width="16"><img src="$cfg{imagesurl}/forum/$type.gif" alt="" /></td>
<td width="15"><img src="$cfg{imagesurl}/forum/$row[6].gif" alt="" border="0" align="middle" /></td>
<td width="45%"><b>$nav{$cat_type}:</b><a href="$cfg{pageurl}/index.$cfg{ext}?op=threads,Forum;cat=$row[1];subcat=$row[2];thread=$row[0];sticky=$cat_type"><b>$subject</b></a><br>$pages</td>
<td width="15%">$row[10]</td>
<td width="10%" align="center">$row[3]</td>
<td width="10%" align="center">$row[4]</td>
<td width="20%" align="center"><small>$last_post</small></td>
</tr>
HTML
} # no stick
}
$sth->finish;

        print <<HTML;
<br />
<table width="100%" border="0" cellspacing="0" cellpadding="2">
<tr>
<td>
<table width="100%" border="0" cellspacing="1" cellpadding="2">
<tr class="tbl_header">
<td width="16">&nbsp;</td>
<td width="15">&nbsp;</td>
<td width="45%"><b>Newest Topic $msg{subjectC}</b></td>
<td width="15%"><b>$msg{started_by}</b></td>
<td width="10%" align="center"><b>$msg{replies}</b></td>
<td width="10%" align="center"><b>$msg{views}</b></td>
<td width="20%" align="center"><b>$msg{last_post}</b></td>
HTML
print $post_msg;

        print <<HTML;
</table>
</td>
</tr>
</table>
<table border="0" width="100%">
<tr>
<td><b>
</td>
<td align="right"></td>
</tr>
<tr>
<td colspan="2" align="right" valign="bottom">
HTML

        print <<HTML;
</td>
</tr>
</table>
<hr />
HTML

### End Forum
$cfg{max_items_per_page} = 5;
$post_msg = '';
$query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type = 'articles' AND forum_cat.sec_level = '$usr{anonuser}' ORDER BY forum_threads.date DESC LIMIT 5;";
if ($user_data{sec_level} eq $usr{admin}) {
$query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type = 'articles' ORDER BY forum_threads.date DESC LIMIT 5;";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
$query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type = 'articles' AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' ORDER BY forum_threads.date DESC LIMIT 5;";
 }
  elsif ($user_data{sec_level} eq $usr{user}) {
$query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type = 'articles' AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user})' ORDER BY forum_threads.date DESC LIMIT 5;";
  }
$sth = $back_ends{$backend_name}->prepare($query1);
$sth->execute;
$row_color = ' class="tbl_row_dark"';
while(my @row = $sth->fetchrow)  {
                $row_color =
                    ($row_color eq ' class="tbl_row_dark"')
                    ? ' class="tbl_row_light"'
                    : ' class="tbl_row_dark"';
     my $cat_type = $row[$#row] if $row[$#row];

                my $subject = $row[11];
                if (length($subject) > 250) {
                    $subject = substr($subject, 0, 250);
                    $subject =~ s/(.*)\s.*/$1 \.\.\./;
                    }

                $AUBBC_mod->settings( for_links => 1 );
                $subject = $AUBBC_mod->do_all_ubbc($subject);
                $AUBBC_mod->settings( for_links => 0 );
                my $message = $row[12];
                if (length($message) > 250) {
                    $message = substr($message, 0, 250);
                    $message =~ s/(.*)\s.*/$1 \.\.\./;
                    }

                $message = $AUBBC_mod->do_all_ubbc($message);
                $post_msg .= <<HTML;
  <tr$row_color valign="top">
    <td rowspan="2" width="82"><img src="$cfg{imagesurl}/topics/$row[2].gif" alt="" /></td>
    <td height="5"><a href="$cfg{pageurl}/index.$cfg{ext}?op=threads,Forum;cat=$row[1];subcat=$row[2];thread=$row[0];sticky=$cat_type"><b>$subject</b></a>&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=print_thread,Forum;cat=$row[1];subcat=$row[2];thread=$row[0];id=1" target="_blank"><img src="$cfg{imagesurl}/print.gif" alt="$msg{print_friendly}" border="0" /></a></td>
  </tr>
  <tr$row_color>
    <td valign="top" height="50">$message</td>
  </tr>
HTML
}
$sth->finish;

print <<HTML;
<br>
<table width="100%" border="0" cellspacing="2" cellpadding="2">
$post_msg
</table>
HTML
}
1;
