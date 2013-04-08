#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

chdir "$FindBin::Bin/..";
require Mojolicious::Commands;
Mojolicious::Commands->namespaces(['Mafia::Command']);
Mojolicious::Commands->run(@ARGV);
