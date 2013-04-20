package DBIx::Class::Mafia::Timestamp;

use base 'DBIx::Class::Core';
use Mafia::Timestamp;

__PACKAGE__->load_components(qw/DynamicDefault InflateColumn/);

sub register_column {
	my $self = shift;
	my ($col, $info, @rest) = @_;

	$self->next::method(@_);

	next unless $info->{data_type} eq 'timestamp';

	$self->inflate_column($col, {
		inflate => sub {
			my $str = shift;
			return Mafia::Timestamp->parse($str);
		},
		deflate => sub {
			my $obj = shift;
			return $obj->mysql;
		},
	});
}

sub add_columns {
	my $self = shift;
	my %cols = @_;

	while (my($col, $info) = each %cols) {
		next unless $info->{data_type} eq 'timestamp';

		if ($col eq 'created') {
			$info->{dynamic_default_on_create} = 'get_timestamp';
		}
		if ($col eq 'updated') {
			$info->{dynamic_default_on_create} = 'get_timestamp';
			$info->{dynamic_default_on_update} = 'get_timestamp';
		}
	}

	$self->next::method(@_);
}

sub get_timestamp {
	return Mafia::Timestamp->now->mysql;
}

1;
