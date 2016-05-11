package serverinfo;

# Perl Digger
# This script will only work on *inux
# use strict;
#
# # Assign global variables.
use vars qw(
  %user_action $Flex_WPS
  %user_data %usr %err
  );
use exporter;

# Define possible user actions.
%user_action = ( info => $usr{admin} );
#use CGI qw(:standard);
#use CGI::Carp qw(fatalsToBrowser);
#print "Content-type: text/html\n\n";
#-----------------------------------------------------------------------




# NO NEED TO TOUCH ANYTHING BEYOND THIS POINT #=========================

#Location of Perl
$whereperl      = join("<BR>", split(/\s+/, qx/whereis perl/));

#Location of Sendmail
$wheresendmail  = join("<BR>", split(/\s+/, qx/whereis sendmail/));

#Location of Current Directory
$currentdirectory = `pwd`;


# List of processes
$processes = qx/ps aux/;
$processes =~ s/<br>/\n/gi;
$processes =~ s/<br>/\n\n/gi;
$processes =~ s/<(?:[^>'"]*|(['"]).*?\1)*>//gs;

#Perl Variables
$perlversion = $];

$path_tar       = join("<BR>", split(/\s+/, qx/whereis tar/));
$path_gzip      = join("<BR>", split(/\s+/, qx/whereis gzip/));
$path_apache    = join("<BR>", split(/\s+/, qx/whereis apache/));
$path_httpd     = join("<BR>", split(/\s+/, qx/whereis httpd/));
$path_php       = join("<BR>", split(/\s+/, qx/whereis php/));
$path_mysql     = join("<BR>", split(/\s+/, qx/whereis mysql/));
$path_man       = join("<BR>", split(/\s+/, qx/whereis man/));
$path_perldoc   = join("<BR>", split(/\s+/, qx/whereis perldoc/));


#Perl Os
$perlos = $^O;
$perlos_version = get_server('version'); $perlos_version =~ s/#/<BR>#/s; $perlos_version =~ s/\(/<BR>(/s;

$perlos_cpu     = qx/cpuid/;
$perlos_mem     = qx/vmstat/;
#$perlos_mem     =~ s/^.*?\n.*?\n.*?\n//s;
$perlos_dsk     = `df -h`;

sub get_server
{
    open PROC, "</proc/$_[0]" || die("Cannot read proc [/proc/$_[0]] $!");
    my $res = join("<BR>", <PROC>);
    close PROC;
    return $res ? $res : undef;
}
sub get_server_detail
{
    open PROC, "</proc/$_[0]" || die("Cannot read proc [/proc/$_[0]] $!");
    my $res = join("", <PROC>);
    close PROC;
    return $res ? $res : undef;
}

sub info {
#Module Paths
foreach $line (@INC)
        {
        $modulepaths .= "$line<br>";
        }

#Environment Variables
$environment = qq~
<table width="69%" cellspacing="0" cellpadding="4" bordercolor="#c5c5c5">
<tr>
<td colspan="2" bgcolor="#efefef">ENVIRONMENTVARIABLES </td>
</tr>
~;


@allkeys = keys(%ENV);
foreach  $key (@allkeys)
{
$value = $ENV{$key};
if ($value eq "") {$value = "-";}
$environment .= qq~
<tr>
<td width="168" class="tableitems">$key</td> <td class="tablevalue">$value</td> </tr> ~; } $environment .= qq~ </table> ~;


$documentroot = $ENV{'DOCUMENT_ROOT'};
if ($documentroot ne "")
{
@lines = `du -c -k $documentroot`;
$lastline = @lines-1;
($diskusage) = split/[\t| ]/,$lines[$lastline]; }

#Server Software
$serverip = $ENV{'SERVER_ADDR'};
$servername = $ENV{'SERVER_NAME'};
$serverport = $ENV{'SERVER_PORT'};

$serversoftware = $ENV{'SERVER_SOFTWARE'};

$serveruptime =`uptime`;


#Localtime
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time); @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
$date = sprintf("%02d-%s-%04d",$mday,$months[$mon],$year+1900);
$time = sprintf("%02d:%02d:%02d",$hour,$min,$sec);
$localtime = "$date, $time";

#GMTtime
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time); @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
$date = sprintf("%02d-%s-%04d",$mday,$months[$mon],$year+1900);
$time = sprintf("%02d:%02d:%02d",$hour,$min,$sec);
$gmttime = "$date, $time";

$Flex_WPS->print_header( cookie1 => '', cookie2 => '',);
$Flex_WPS->print_html(
        page_name    => $nav{home},
        type         => '',
        ajax_name    => '',
        );
        
print qq~

    <p align="left">
            <a href="#perlinfo">PERL INFORMATION</a>
        &nbsp; | &nbsp; <a href="#serverinfo">SERVER INFORMATION</a>
        &nbsp; | &nbsp; <a href="#env">ENVIRONMENT VARIABLES</a>
        &nbsp; | &nbsp; <a href="#modules">INSTALLED PERL MODULES</a>
    </p>

<br>
<a name="perlinfo"></a><br>

<table width="69%" cellpadding="4" cellspacing="0">
  <tr bgcolor="#efefef">
    <td colspan="2"> PERL INFORMATION</td></tr>

  <tr>
    <td class="tableitems" width="168" valign="top">Perl version</td>
    <td class="tablevalue">$perlversion</td>
  </tr>

  <tr>
    <td class="tableitems" width="168" valign="top">Perl</td>
    <td class="tablevalue">$whereperl</td>
  </tr>

  <tr>
    <td class="tableitems" width="168" valign="top">Sendmail</td>
    <td class="tablevalue">$wheresendmail</td>
  </tr>

</table>

<br>
<a name="serverinfo"></a><br>

<table width="69%" cellspacing="0" cellpadding="4"
bordercolor="#c5c5c5">
  <tr bgcolor="#efefef">
    <td colspan="2" class="h"> SERVER INFORMATION </td> </tr>

 <tr>
    <td class="tableitems" width="168" valign="top">Name</td>
    <td class="tablevalue">$servername</td>
  </tr>

  <tr>
    <td class="tableitems" width="168" valign="top">IP</td>
    <td class="tablevalue">$serverip</td>
  </tr>

  <tr>
    <td class="tableitems" width="168" valign="top">Listing Port</td>
    <td class="tablevalue">$serverport</td>
  </tr>

  <tr>
    <td class="tableitems" width="168" valign="top">Document Root</td>
    <td class="tablevalue">$documentroot</td>
  </tr>

  <tr>
    <td class="tableitems" width="168" valign="top">Disk Usage by Root</td>
    <td class="tablevalue">$diskusage KB</td>
  </tr>

  <tr>
    <td class="tableitems" width="168" valign="top">Server stamp</td>
    <td class="tablevalue">$serversoftware</td>
  </tr>

  <tr>
    <td class="tableitems" width="168" valign="top">Server Time (Local)</td>
    <td class="tablevalue">$localtime</td>
  </tr>

  <tr>
    <td class="tableitems" width="168" valign="top">Server Time (GMT)</td>
    <td class="tablevalue">$gmttime</td>
  </tr>

  <tr>
    <td class="tableitems" width="168" valign="top">Server Details </td>
    <td class="tablevalue">
        <p><strong>OPERATING SYSTEM:</strong><br>$perlos_version
        <p><strong>CPU UTILIZATION:</strong><br><textarea rows=10 cols=80>$perlos_cpu</textarea>
        <p><strong>MEMORY UTILIZATION:</strong><br><textarea rows=10 cols=80>$perlos_mem</textarea>
        <p><strong>DISK UTILIZATION:</strong><br><textarea rows=10 cols=80 wrap="OFF">TOTAL DISK USAGE:\n$diskusage KB \n\n$perlos_dsk</textarea>
    </td>
  </tr>
  <tr>
    <td class="tableitems" width="168" valign="top">Module Paths</td>
    <td class="tablevalue">$modulepaths</td>
  </tr>
  <tr>
    <td class="tableitems" width="168" valign="top">Path(s) to TAR</td>
    <td class="tablevalue">$path_tar</td>
  </tr>
    <tr>
    <td class="tableitems" width="168" valign="top">Path(s) to GZIP</td>
    <td class="tablevalue">$path_gzip</td>
  </tr>
  <tr>
    <td class="tableitems" width="168" valign="top">Path to APACHE/HTTPD</td>
    <td class="tablevalue">$path_apache<p>$path_httpd</td>
  </tr>
  <tr>
    <td class="tableitems" width="168" valign="top">Path to PHP</td>
    <td class="tablevalue">$path_php</td>
  </tr>
  <tr>
    <td class="tableitems" width="168" valign="top">Path to MYSQL</td>
    <td class="tablevalue">$path_mysql</td>
  </tr>
  <tr>
    <td class="tableitems" width="168" valign="top">Path to MAN (Unix manual)</td>
    <td class="tablevalue">$path_man</td>
  </tr>
  <tr>
    <td class="tableitems" width="168" valign="top">Path to PERLDOC</td>
    <td class="tablevalue">$path_perldoc</td>
  </tr>
  <tr>
    <td class="tableitems" width="168" valign="top">Processes currently on the server</td>
    <td class="tablevalue"><textarea rows=10 cols=60 wrap="OFF">$processes</textarea> </td>
  </tr>
</table>

<br>
<a name="env"></a><br>
$environment

<!-- ALL MODULES -->
<br><br>

<table width="70%" cellspacing="0" cellpadding="4" bordercolor="#c5c5c5">
<tr>
<td colspan="2" bgcolor="#efefef"><a name="modules">LIST OF ALL INSTALLED PERL MODULES <a href="#top" title="Back to top"></a></td>
</tr>
  <tr>
  <td>
~;

&vars;
find(\&wanted,@INC);
$modcount = 0;
foreach $line(@foundmods)
{
    $match = lc($line);
    if ($found{$line}[0] >0)
    {$found{$line} = [$found{$line}[0]+1,$match]}
    else
    {$found{$line} = ["1",$match];$modcount++} } @foundmods = sort count keys(%found); chomp @foundmods;
print "$modcount modules found</td></tr><tr><td>\n";

$third = $modcount/3;
$count=0;
$firstroundtotal = 0;

    foreach $mod(@foundmods)
    {
        $count++;
        if ($count <= $third)
        {
            $firstroundtotal++;
            print qq~
             $firstroundtotal. <a href="http://search.cpan.org/search?module=$mod" title="Click here to see $mod on CPAN [Opens in a new window]" target="_blank">$mod</a><br>
            ~;
        }
        else
        {
            push (@mod1,$mod)
        }
    }

    $count = 0;
    print qq~ </td><td>~;
    foreach $mod1(@mod1)
    {
        $count++;
        if ($count <= $third)
        {
            $firstroundtotal++;
            print qq~
             $firstroundtotal. <a href="http://search.cpan.org/search?module=$mod1" title="Click here to see $mod1 on CPAN [Opens in a new window]" target="_blank">$mod1</a><br>
            ~;
        }
        else
        {
            push (@mod2,$mod1)
        }
    }
    $count = 0;
    print qq~ </td><td>~;
    foreach $mod2(@mod2)
    {
        $count++;
        $firstroundtotal++;
        print qq~
         $firstroundtotal. <a href="http://search.cpan.org/search?module=$mod2" title="Click here to see $mod2 on CPAN [Opens in a new window]" target="_blank">$mod2</a><br>
        ~;
    }
    print qq~
    </td>


  </tr>
</table>
</div>


<p>&nbsp;</p>
<p align="left"><a href="#top" title="Back to top"></a></p><br>~;

$Flex_WPS->print_html(
        page_name    => $nav{home},
        type         => 1,
        ajax_name    => '',
        );

}
sub count
{
    return $found{$a}[1] cmp $found{$b}[1]

}



sub vars {use File::Find;}
sub wanted { $count = 0; if ($File::Find::name =~ /\.pm$/) {
open(MODFILE,$File::Find::name) || return; while(<MODFILE>){ if (/^ *package +(\S+);/){ push (@foundmods, $1); last; } } } }
1;
