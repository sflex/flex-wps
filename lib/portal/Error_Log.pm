package Error_Log;
# ==============================================================================
#
# Perl Warning & Error Log View & Delete/Clear.
# Fatal Error Log View & Delete/Clear.
#
# Help: sflex@cpan.org
#
# original by: DJ
# ==============================================================================

# Load necessary modules.
use strict;
use vars qw(
    $query %cfg %user_action %nav
    %user_data %usr %err $Flex_WPS $AUBBC_mod
    );
use exporter;

# Error Log
$cfg{errorlog} = $cfg{datadir} . '/error.log';
$cfg{errorlog2} = $cfg{datadir} . '/fatal_error.log';

# Define possible user actions.
%user_action = (
    admin_index => $usr{admin},
    clear => $usr{admin},
    admin_index2 => $usr{admin},
    clear2 => $usr{admin},
);

sub admin_index {
my $errorlog = $Flex_WPS->file2array($cfg{errorlog}, 1);

                my $print_html = <<HTML;
<center><a href="$cfg{pageurl}/index.$cfg{ext}?op=clear,Error_Log">Delete</a></center>
HTML
        if(scalar @{$errorlog} == 0) {
                $print_html .= 'No Errors Found.';
        }
         else {
                foreach my $error (@{$errorlog}) {
                    if ($error) {
                         $error = $AUBBC_mod->script_escape($error);
                         $print_html .= "<br />$error <br />";
                    }
                }
        }
$Flex_WPS->print_page(
        markup       => $print_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Error Log Admin View',
        );
}

# ================
# Clear Log file
# ================
sub clear {

$Flex_WPS->array2file(
        file => $cfg{errorlog},
        );

print $query->redirect(
        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=admin_index,Error_Log'
        );
}

sub admin_index2 {
my $errorlog = $Flex_WPS->file2array($cfg{errorlog2}, 1);

                my $print_html = <<HTML;
<center><a href="$cfg{pageurl}/index.$cfg{ext}?op=clear2,Error_Log">Delete</a></center>
HTML
        if(scalar @{$errorlog} == 0) {
                $print_html .= 'No Errors Found.';
        }
        else {
                foreach my $ln (@{$errorlog}) {
                    if ($ln) {
                     $ln =~ s/\|/ - /g;
                     $ln = $AUBBC_mod->script_escape($ln);
                         $print_html .= "<br />$ln <br />";
                    }
                }
        }
$Flex_WPS->print_page(
        markup       => $print_html,
        cookie1      => '',
        cookie2      => '',
        location     => '',
        ajax_name    => '',
        navigation   => 'Error Log Admin View',
        );
}

# ================
# Clear fatal Log file
# ================
sub clear2 {
$Flex_WPS->array2file(
        file => $cfg{errorlog2},
        );

print $query->redirect(
        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=admin_index2,Error_Log'
        );
}
1;
