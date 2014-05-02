package MojoMafia::Game;
use Mojo::Base 'Mojolicious::Controller';
use Scalar::Util qw/looks_like_number/;

sub fetch {
	my $c = shift;
	my $id = $c->param('id');
	my $game = $c->db('Game')->find($id);

	if (defined $game) {
		$c->stash->{game} = $game;

		if ($game->is_active) {
			if ($game->is_day) {
				$c->stash->{votes} = $game->players->living;
			}
		}
	}

	defined $game;
}

sub view {
	my $c = shift;

	my @roles = $c->player->player_roles->get_column("role_id")->all;

	my $param = $c->param('page');
	my $page = looks_like_number($param) ? int $param : 1;

	$c->stash->{posts} = $c->stash->{game}->thread->posts->search(
		{
			-or => [
				{ private => 0 },
				{ "audiences.role_id" => { -in => \@roles } },
				{ "audiences.player_no" => $c->player->no || -1 },
			]
		},
		{
			page => $page,
			rows => 10,
			prefetch => [ qw/user/ ],
			join => [ qw/audiences/ ],
		}
	);

	$c->render;
}

"Geemu no jikan da.";
