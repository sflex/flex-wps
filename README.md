# flex-wps<br />

Flex (WPS) - Flexible Web Pollution Solution<br />
Perl object oriented lightweight web framework built into a small scale CMS that can be scaled up.<br />
Should work under mod_perl<br /><br />
The new theme allows any HTML type, but the CMS is being programmed with XHTML and HTML5 supported HTML. Reduced a lot of HTML in the CMS and uses more CSS. Target was to make it support HTML5 and use more CSS to reduce HTML and see if the framework would handle a responsive and none responsive theme. It dose now.<br /><br />

The framework of Flex (WPS) has been shrunk again. The workflow below shows there is no core file, all that code has been optimized and moved to Flex_WPS.pm.<br />
Workflow:



            /db/config.pl   /----Flex_Porter-\
                     |      ^       ^     ^  ^
                     |      |       |     |  |
                     V      V       V     |  |
    Server<->Perl<->index.cgi<->Flex_WPS  |  |
                       ^          ^    ^  |  |
                       |          |    |  |  |
                       V          V    V  V  |
                     /lib  /subload  /portal |
                                   \------<--/

Requires:<br /> 
Tested on Perl 5.8 and 5.22, should work on all versions 5.8 and above.<br />
Apache HTTP server<br />
MySQL server<br /><br />

OS: Best under Unix or Linux OS<br />
Windows OS has an issue with it's non case sensitive filing system, But will still work.<br /><br />
Required Perl Modules<br />
Framework Perl Modules: Exporter, Fcntl, Digest::SHA1, CGI::Carp, Apache::DBI, Carp, Socket, Config.<br />
Flex Modules: Flex_CGI, AUBBC2, Flex_WPS, Flex_Porter, UBBC<br />
Portal, SubLoad and Upload Perl Modules: GD::SecurityImage, Text::Wrap, CGI(upload), Image::ExifTool(upload).<br /><br />   
Flex_Porter is the variable exporter for the system, keeping all the frameworks variables in scope.<br />
There are only two files with the Perl shebang line the main index.cgi and the uploads.cgi<br />
When a call to the index.cgi CMS/portal area is made the param name op must equal Subroutine,Class<br />
The security checking and directing of param op's action is all done for you with very little needed to be done in your /portal script.<br />
Your first hello world script in Flex (WPS).<br />


    package hello;
    # http://place.com/?op=view,hello
    # http://place.com/?op=admin,hello
    use strict; # should be used when you can
    use warnings; # same as above
    # minimum variables used
    use vars qw(
    $Flex_WPS %user_action %usr
     );
    
    # Keep the above variables in this packages scope
    use Flex_Porter;
    
    # This tells the framework that these subroutines can be used in op
    # and what security level the area is
    %user_action = (
    admin => $usr{admin},
    view => $usr{anonuser},
    );
    
    sub view {
    $Flex_WPS->print_page(
       markup       => '<h2>Hello World</h2>',
       cookie1      => '',
       cookie2      => '',
       location     => '',
       ajax_name    => '',
       navigation   => 'Hello World Page',
       );
    }
    
    sub admin {
    $Flex_WPS->print_page(
       markup       => '<h2>Hello Admin World</h2>',
       cookie1      => '',
       cookie2      => '',
       location     => '',
       ajax_name    => '',
       navigation   => 'Hello Admin World Page',
       );
    }
    
    1; 

The header and theme will be wrapped around the markup provided.<br />
All security levels can be modified with the Super Places table to increase the security access to selected areas and can be used in your script to give access to some parts of the page like admin links, moderator links or even for a new Super Group name links.<br /><br />
The variables found in Flex_Porter are the heart of the framework they are ether object, object hash or hash variables.<br /><br />

Object variables:<br />
Web framework methods: $Flex_WPS<br /> 
BBcode engine: $AUBBC <br />
Param,Cookies,Header CGI: $query<br /><br />

Object hash variable:<br />
MySQL backend's connected to: %back_ends<br /><br />

Hash variables:<br />
language variables: %usr %err %msg %btn %nav %inf %hlp %months %week_days %adm<br />
Current User Data: %user_data<br /> 
Allowed subroutines in portal script for op action: %user_action<br /> 
Framework configuration and information variable: %cfg<br /><br /> 

TO DO:<br />
Make the files ready for server install.<br />
