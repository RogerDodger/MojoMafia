package Mafia::Schema::ResultSet::Game;

use base 'DBIx::Class::ResultSet';

sub active {
	my $self = shift;

	return $self->search({ created => { '>' => Mafia::Timestamp->new } });
}

1;
