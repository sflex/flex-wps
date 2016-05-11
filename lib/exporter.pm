package exporter;
# =====================================================================
# Flex-WPS, exporter version 1.0 beta 2
#
# Copyright (C) 2008 by N. K. A. (sflex@cpan.org)
#
# This file helps keep the objects or variables in scope.
# There could be a better way. =p
#
# exporter.pm
#
# Date: 08/20/2009
# =====================================================================

use strict;
use vars qw(
    @ISA @EXPORT $VERSION $Flex_WPS $AUBBC_mod %back_ends $query
    %usr %err %msg %btn %nav %inf %hlp %months %week_days %adm
    %user_data %user_action %cfg
    );

@ISA = qw(Exporter); #AutoLoader

BEGIN {
# Export global routines and variables.
require Exporter;
#require AutoLoader;
@EXPORT = qw(
          $VERSION $Flex_WPS $AUBBC_mod %back_ends $query
          %usr %err %msg %btn %nav %inf %hlp %months %week_days %adm
          %user_data %user_action %cfg
          );
}

1;
