#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

chdir "$FindBin::Bin/..";
require Mojolicious::Commands;
Mojolicious::Commands->start_app('MojoMafia');
