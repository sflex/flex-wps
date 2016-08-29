package Flex_Porter;
# =====================================================================
# Flex_Porter.pm version 1.1
# Date: 05/23/2016
# For: Flex (Web Portal System)
# By: N. K. A.
#
# This file helps keep the objects and variables in scope.
#
# =====================================================================
use strict;
use warnings;
BEGIN {
use vars qw(
    @ISA @EXPORT $Flex_WPS $AUBBC %back_ends $query
    %usr %err %msg %btn %nav %inf %hlp %months %week_days %adm
    %user_data %user_action %cfg
    );
    

@ISA = qw(Exporter);
# Export global routines and variables.
require Exporter;
@EXPORT = qw(
          $Flex_WPS $AUBBC %back_ends $query
          %usr %err %msg %btn %nav %inf %hlp %months %week_days %adm
          %user_data %user_action %cfg
          );
}

1;
