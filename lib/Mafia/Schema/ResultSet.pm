package Mafia::Schema::ResultSet;

use base 'DBIx::Class::ResultSet';

sub order_by {
	my $self = shift;
	return $self->search({}, { -order_by => shift });
}

1;
