package MojoMafia::Game;
use Mojo::Base 'Mojolicious::Controller';

sub fetch {
	my $c = shift;
	my $id = $c->param('id');
	$c->app->log->info($id);
	my $game = $c->db('Game')->find($id);

	if (defined $game) {
		$c->stash->{game} = $game;

		if (defined $c->user) {
			$c->stash->{player} = $c->db('Player')->find({
				user_id => $c->user->id,
				game_id => $game->id,
			});
		}

		if ($game->is_active) {
			if ($game->is_day) {
				$c->stash->{votes} = $game->players->living;
			}
		}

		return 1;
	}
	else {
		return 0;
	}
}

sub thread {
	my $c = shift;

	$c->stash->{posts} = $c->stash->{game}->thread->posts->search({}, {
		join => [qw/player/],
	});

	$c->render;
}

"Gamu no jikan da.";
