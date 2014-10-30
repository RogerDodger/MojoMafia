package Mafia::Schema::ResultSet::Player;

use base 'Mafia::Schema::ResultSet';

sub living {
	return shift->search({ alive => 1 });
}

sub dead {
	return shift->search({ alive => 0 });
}

sub sorted {
	return shift->search({}, { order_by => 'alias' });
}

sub with_role {
	my ($self, $role) = @_;

	return $self->search(
		{ "role_id" => $role->id },
		{ join => "player_roles" },
	);
}

1;
