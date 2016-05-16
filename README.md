# flex-wps<br />

Flex Web Portal System<br />
Perl object oriented lightweight web framework built into a CMS<br />
Should work under mod_perl<br /><br />
Only prints XHTML, for now..<br /><br />

Requires:<br /> 
Perl 5.08 (exporter.pm could still be the reason, but I removed the use of AutoLoad and never tested a higher version.)<br />
Apache HTTP server<br />
MySQL server<br /><br />

OS: Best under Unix or Linux OS<br />
Windows OS has an issue with it's non case sensitive filing system, But will still work.<br /><br />
Perl Modules Required:<br />
GD::SecurityImage<br />
Digest::SHA1<br />
Image::ExifTool<br />
DBI<br /><br />

TO DO:<br />
Would like to move this project to the next evolution, by turning the theme in to a single database with place holders and program it to use AUBBC2. This change will allow the theme to controle what HTML type the page will run and will have an editable database for UBBC tags to add or remove.<br />
Fix what is preventing the system from using the latest version of Perl 5.22 not 6...<br />
Make the files ready for server install.<br />
