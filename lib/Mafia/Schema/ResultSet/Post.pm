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

sub no {
	my ($self, $post) = @_;

	return $self->search({ id => { '<' => $post->id } })->count;
}

sub visible {
	my ($self, $player) = @_;

	return $self->search({ private => 0 }) unless $player;

	my @roles = $player->player_roles->get_column("role_id")->all;

	$self->search(
		{
			-or => [
				{ private => 0 },
				{ "audiences.role_id" => { -in => \@roles } },
				{ "audiences.player_id" => $player->id },
			]
		},
		{
			join => [ qw/audiences/ ],
		},
	);
}


1;
