package Mafia::Schema::ResultSet::Player;

use base 'DBIx::Class::ResultSet';

sub living {
	return shift->search({ is_alive => 1 });
}

sub dead {
	return shift->search({ is_alive => 0 });
}

sub sorted {
	return shift->search({}, { order_by => 'alias' });
}

sub with_role {
	my ($self, $role) = @_;

	return $self->search(
		{ "role.name" => $role },
		{ join => { "player_roles" => "role" } },
	);
}

1;
