package core;

# Clean up the environment.
delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};

# Load necessary modules.
use warnings;
use strict;
use vars qw(%cfg $VERSION %err);

use exporter;
use Fcntl qw(:DEFAULT :flock);

# Core Version
$VERSION = '1.0 beta 4';

use constant IS_MODPERL => $ENV{MOD_PERL};
use subs qw(exit);
# Select the correct exit function
*exit = IS_MODPERL ? \&Apache::exit(Apache::Constants::DONE) : sub { CORE::exit };

# make the path to the db
my $log_path = $ENV{'SCRIPT_FILENAME'} || '';
$log_path = ($log_path =~ m/\A([^\.]+)\/[^\/]+\z/) ? $1 : '';
$cfg{log_path} = $log_path;

# Catch fatal errors.
$SIG{__DIE__} = \&fatal_error;

# Log Perl Warnings and Errors - Improved
    use CGI::Carp qw(carpout);
    sysopen(LOG_WARN, "$log_path/db/error.log", O_WRONLY | O_APPEND)
        or die "Unable to append to error-log: at $!\n";
    carpout(\*LOG_WARN);

# die interface
sub fatal_error {
my $error = shift || '';
$error =~ s/\n/ /g if $error;
$error =~ s/\|/&#124;/g if $error;
my ($msg, $path) = ('','');
($msg, $path) = split( " at ", $error) if ($error && $error =~ m/\bat\b/io);

                write_error($error);

        print "Content-type: text/html\n\n" if !$cfg{theme_printed};
        print <<HTML if !$cfg{theme_printed};
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>Fatal Error</title>
<meta name="Generator" content="$Flex_WPS::VERSION" />
</head>
<body>
HTML

        print <<HTML;
<font face="arial, verdana, helvetica" size="6"
color="#333366">$Flex_WPS::VERSION Fatal Error</font>
<hr size="1" color="#000000" noshade />
<font face="arial, verdana, helvetica" size="3" color="#00000">Flex has
exited with the following error:<br /><br />
<b>$msg</b><br /><br />This error was reported at: <font color="#000099"
face="arial, verdana, helvetica">$path</font><br />
<font face="arial, verdana, helvetica" size="1" color="#00000"><b>Original Error: $error</b></font><br />
<hr size="1" color="#000000" noshade />
<font size="3" color="#990000"><b>Please inform the webmaster if this
error persists.</b></font>
</body>
</html>
HTML
exit;
}

sub write_error {
my $error_msg = shift;

# Update log file.
my $date = '[' . scalar(localtime) . ']|' . $error_msg;
sysopen(FH, "$log_path/db/fatal_error.log", O_WRONLY | O_APPEND) or die $!;
flock(FH, LOCK_EX);
print FH $date . "\n";
close(FH);

}

sub file2array {
my ($file, $chomp) = @_;
        return '' if ! $file || ! -r $file;
        my @content = ();
        sysopen(FH, $file, O_RDONLY);
        flock(FH, LOCK_EX);
        @content = <FH>;
        close(FH);

        chomp(@content) unless ! $chomp;

        return \@content;
}

sub file2scalar {
my ($file, $chomp) = @_;

        return '' if ! $file || ! -r $file;
        sysopen(FH, $file, O_RDONLY);
        flock(FH, LOCK_EX);
        local $/ = undef;
        my $content = <FH>;
        close(FH);

        chomp($content) unless ! $chomp;
        return $content;
}
sub array2file {
 my (%file_set) = @_;
 return '' if ! $file_set{file} || ! -r $file_set{file};
 sysopen(FH, $file_set{file}, O_WRONLY | O_TRUNC)
  or die("$err{not_writable} $file_set{file}. ($!)");
 flock(FH, LOCK_EX);
 if (exists $file_set{array} && @{$file_set{array}}) {
 # this part was not tested
  print FH "$_\n" foreach (@{$file_set{array}});
 }
  elsif (exists $file_set{string} && $file_set{string}) {
  print FH $file_set{string};
 }
  else {
  print FH ""; # used to clear error logs
 }
 close(FH);
}

1;

__END__

=pod

=head1 COPYLEFT

core.pm, v1.0 beta 4 01/20/2011 N.K.A.
Flex Web Portal System Evolution 3

This object is a compilation of methods I normaly use
for web page programing.

 The core.pm is mainly an error log and die interface.
 If any part faults out or produces a warn this script should handle it.
 The other stuff you see in this script is to settup
 the portal for mod_perl or to clean the environment.
 Also has some flat file functions now.

 Main Core.

 shakaflex [at] gmail.com
 http://search.cpan.org/~sflex/

=cut
