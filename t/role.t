#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Deep;

BEGIN {
	use_ok "Mafia::Role";
	Mafia::Role->import(':all');
}

my $townie = INNO;

is $townie->id, 1, 'role attributes';
is $townie->name, 'Townie', 'role attributes';
ok defined $townie->order, 'role attributes';

cmp_deeply(
	[
		(INNO) x 2,
		(GOON) x 4,
		(RB)   x 2,
		(GF)   x 2,
		(COP)  x 3,
		(DOC)  x 2,
	],
	[
		sort { $a->order <=> $b->order }
			INNO, GOON, DOC, COP, GOON, RB, COP, GOON, COP, GF, RB, GF, GOON,
			INNO, DOC
	],
	'role ordering',
);

cmp_deeply(Mafia::Role->find('Cop'), COP, 'find role by name');

done_testing;
