package MojoMafia::Player;
use Mojo::Base 'Mojolicious::Controller';

sub delete {
	my $c = shift;

	if (!$c->game->full && $c->player) {
		$c->game->log("%s left the game", $c->player->alias);
		$c->player->delete;
	}

	return $c->redirect_to('/');
}

sub post {
	my $c = shift;

	# There are race conditions all over this. One day I'll have to come back
	# and address them.

	if (!$c->user->plays($c->game)) {
		if ($c->game->full) {
			$c->flash(error_msg => 'Game is full');
		}
		else {
			my $v = $c->validation;
			$v->required('alias')->size(1, 64);

			if (!$v->has_error) {
				my $player = $c->user->create_related(players => {
					game_id => $c->game->id,
					alias => $v->param('alias'),
				});

				$c->game->log("%s joined the game", $player->alias);

				if ($c->game->full) {
					$c->game->begin;
				}
			}
		}
	}

	$c->redirect_to('/');
}

'The only winning move is not to play.';
