package Mafia::Schema::ResultSet::Player;

use base 'DBIx::Class::ResultSet';

sub scum {
	return shift->search(
		{ 'team.type' => 'scum' },
		{ prefetch => 'team' },
	);
}

sub inno {
	return shift->search(
		{ 'team.type' => 'inno' },
		{ prefetch => 'team' },
	);
}

sub living {
	return shift->search({ is_alive => 1 });
}

sub dead {
	return shift->search({ is_alive => 0 });
}

1;
