package aubbc_js;
use vars qw(
    $AUBBC_mod %user_action
    );
use exporter;

%user_action = ( js_print => $usr{anonuser},);

sub js_print {
$AUBBC_mod->js_print();
}

1;
