package Mafia::Schema::ResultSet::Post;

use base 'DBIx::Class::ResultSet';

sub no {
	my ($self, $post) = @_;

	return $self->search({ id => { '<' => $post->id } })->count;
}

sub visible {
	my ($self, $player) = @_;

	return $self->search({ private => 0 }) unless $player;

	my @roles = $player->player_roles->get_column("role_id")->all;

	$self->search({
		-or => [
			{ private => 0 },
			{ player_id => $player->id },
			-and => [
				{ audience_type => 'p' },
				{ audience_id => $player->id },
			],
			-and => [
				{ audience_type => 'r' },
				{ audience_id => { -in => \@roles }},
			],
			(
				{ audience_type => 'd' },
			) x !$player->alive,
		],
	});
}


1;
