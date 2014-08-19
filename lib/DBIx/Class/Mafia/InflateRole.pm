package DBIx::Class::Mafia::InflateRole;

use base 'DBIx::Class::Core';
use Mafia::Timestamp;

__PACKAGE__->load_components(qw/InflateColumn/);

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
