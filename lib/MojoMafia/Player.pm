package MojoMafia::Player;
use Mojo::Base 'Mojolicious::Controller';

sub delete {
	my $c = shift;

	if (!$c->game->full) {
		$c->player->delete;
	}

	return $c->redirect_to($c->referrer || '/');
}

sub post {
	my $c = shift;

	if (!$c->user->plays($c->game)) {
		if ($c->game->full) {
			$c->flash(error_msg => 'Game is full');
		}
		else {
			my $v = $c->validation;
			$v->required('alias')->size(1, 64);

			if (!$v->has_error) {
				$c->user->create_related(players => {
					game_id => $c->game->id,
					alias => $v->param('alias'),
				});
			}
		}
	}

	$c->redirect_to('/');
}

'The only winning move is not to play.';
