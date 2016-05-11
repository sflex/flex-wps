#!perl
$| = 1;

use strict;
use warnings;
use vars qw(%mysql $Flex_WPS $AUBBC_mod %user_data %cfg);

use lib 'lib';
use exporter;
use Flex_WPS;
$Flex_WPS = Flex_WPS->new();

# get database info
require "$cfg{log_path}/db/config.pl";
# Connect to a database and return a special name
my $DB_Name = $Flex_WPS->SQL_Connect(
        backend_name => $mysql{backendname},
        username => $mysql{username},
        password => $mysql{password},
        host => $mysql{host},
        port => $mysql{port},
        DBI_Settings => { 'RaiseError' => 1, 'AutoCommit' => 1, },
        );

# Load portal settings
$Flex_WPS->Portal_Config(
        backend_name  => $DB_Name,
        portal_config => 1,
        Auth_DB      => '',
        Theme_DB     => '',
        SubLoad_DB   => '',
        Portal_DB    => '',
        );
        
# Load CGI.pm and return the object
my $query = $Flex_WPS->Load_CGI(
        max_upload_size => 100,
        cgi             => 1,
        );

# Authenticate user
%user_data = $Flex_WPS->Auth_Session();

# Load AUBBC mod
$AUBBC_mod = $Flex_WPS->Load_AUBBC( Debug => 0 );
$AUBBC_mod->settings(
        images_url => $cfg{imagesurl},
        html_type => 'xhtml',
        code_class => ' class="codepost"',
        code_extra => '<div style="clear: left"> </div>',
        quote_class => ' class="border"',
        quote_extra => '<div style="clear: left"> </div>',
        script_escape => 0,
        protect_email => 4,
        icon_image => 0,
        highlight_class1 => ' class="highlightclass1"',
        highlight_class2 => ' class="highlightclass2"',
        highlight_class3 => ' class="highlightclass1"',
        highlight_class4 => ' class="highlightclass1"',
        highlight_class5 => ' class="highlightclass5"',
        highlight_class6 => ' class="highlightclass6"',
        highlight_class7 => ' class="highlightclass7"',
        highlight_class8 => ' class="highlightclass5"',
        highlight_class9 => ' class="highlightclass5"',
        );

$AUBBC_mod->tag_security(
    code                => { level => 0, text => 'register', },
    img               => { level => 0, text => 'none', },
    url                => { level => 0, text => 'register2', },
    );
$AUBBC_mod->user_level($user_data{sec_level});

# Load Subload
$Flex_WPS->SubLoad(location => 1,);

# Print the portal
$Flex_WPS->print_portal();


