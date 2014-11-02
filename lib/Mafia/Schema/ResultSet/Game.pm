package Mafia::Schema::ResultSet::Game;

use base 'DBIx::Class::ResultSet';

sub active {
	shift->search({ active => 1 });
}

1;
