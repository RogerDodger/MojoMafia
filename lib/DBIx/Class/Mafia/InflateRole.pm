package DBIx::Class::Mafia::InflateRole;

use base 'DBIx::Class::Core';
use Mafia::Timestamp;

__PACKAGE__->load_components(qw/InflateColumn/);

# This probably just makes things more confusing + expensive. In cases where
# the role object is actually desired, it can be inflated manually. Deflation
# is as simple as going ->id when doing insertions/updates.

sub register_column {
	my $self = shift;
	my ($col, $info, @rest) = @_;

	$self->next::method(@_);

	return unless $col eq 'role_id';

	$self->inflate_column($col, {
		inflate => sub {
			my $id = shift;
			return Mafia::Role->find($id);
		},
		deflate => sub {
			my $obj = shift;
			return $obj->id;
		},
	});
}

1;
