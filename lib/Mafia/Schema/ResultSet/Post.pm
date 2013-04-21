package Mafia::Schema::ResultSet::Post;

use base 'DBIx::Class::ResultSet';

sub have_class {
	my ($self, $class) = @_;

	$class =~ s/[ %]//g;

	return $self->search([
		{ class => { like => "$class"     } }, # Only
		{ class => { like => "$class %"   } }, # First
		{ class => { like => "% $class %" } }, # N-th
		{ class => { like => "% $class"   } }, # Last 
	]);
}

1;
