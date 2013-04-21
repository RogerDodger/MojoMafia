package MojoMafia::Game;
use Mojo::Base 'Mojolicious::Controller';

sub fetch {
	my $c = shift;
	my $id = $c->param('id');

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
	my $date = $c->param('date');
	my $time = $c->param('time');

	$c->stash->{posts} = $c->stash->{game}->thread->posts
			->search({ gamedate => $date })
			->have_class($time);

	$c->render;
}

"Gamu no jikan da.";
