#!/usr/bin/env perl

use Mojo::Base -strict;

use Mafia::Role qw/:all/;
use Mojo::Loader;
use Test::More;
use Test::Deep;

BEGIN {
	use_ok 'Mafia::Setup';
	Mafia::Setup->import(qw/decode_setup encode_setup/);
}

my $loader = Mojo::Loader->new;
my $setup = $loader->data('Mafia::Setup', 'f11.setup');
my $pools = decode_setup $setup;
cmp_deeply($pools, [
	[
		([ INNO ]) x 5,
		([ INNO, COP ]) x 1,
		([ INNO, DOC ]) x 1,
		([ GOON, RB ]) x 1,
		([ GOON ]) x 1,
	],
	[
		([ INNO ]) x 6,
		([ INNO, COP ]) x 1,
		([ GOON ]) x 2,
	],
	[
		([ INNO ]) x 6,
		([ INNO, DOC ]) x 1,
		([ GOON ]) x 2,
	],
	[
		([ INNO ]) x 7,
		([ GOON, RB ]) x 1,
		([ GOON ]) x 1,
	],
], 'decode f11');
is encode_setup($pools), $setup, 'encode f11';

done_testing;
