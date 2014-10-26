package MojoMafia::Game;
use Mojo::Base 'Mojolicious::Controller';
use Scalar::Util qw/looks_like_number/;

sub create {
	my $c = shift;

	$c->render;
}

sub fetch {
	my $c = shift;
	my $id = $c->param('id');
	return $c->render_not_found unless looks_like_number $id;

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

	my $param = $c->param('page');
	my $page = looks_like_number($param) ? int $param : 1;

	$c->stash->{posts} = $c->game->thread->posts->visible($c->player)->search(
		{},
		{
			page => $page,
			rows => $c->app->config->{rows},
			prefetch => [ qw/user/ ],
		}
	);

	$c->render('game/view');
}

"Geemu no jikan da.";
