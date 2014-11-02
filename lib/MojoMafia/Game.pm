package MojoMafia::Game;
use Mojo::Base 'Mojolicious::Controller';

use Mafia::Role qw/:all/;
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
		$c->game($game);

		if ($game->active) {
			if ($game->day) {
				$c->stash->{votes} = $game->players->living->sorted;
			}
			elsif ($c->player->has_role(GOON)) {
				$c->stash->{votes} = $game->players->with_role(GOON)->sorted;
			}
		}
	}

	defined $game;
}

sub view {
	my $c = shift;

	my $param = $c->param('page');
	my $page = looks_like_number($param) ? int $param : 1;

	$c->stash->{posts} = $c->game->posts->visible($c->player)->search(
		{},
		{
			page => $page,
			rows => $c->app->config->{rows},
			prefetch => [ qw/user/ ],
		}
	);

	$c->render('game/view');
}

sub vote {
	my $c = shift;

	if ($c->player->votes) {
		my $v = $c->validation;
		$v->required('vote')->in(0, $c->game->candidates->get_column('id')->all);

		if (!$v->has_error) {
			my $vote = $c->db('Player')->find($v->param('vote'));
			my $unvote = $c->player->vote;

			# Check that someone isn't just recasting the same vote
			unless (defined $unvote && defined $vote && $unvote->id == $vote->id) {
				my %vis = (trigger => 'vote');
				if ($c->game->day) {
					$vis{private} = 0;
				}
				else {
					$vis{private} = 1;
					$vis{audience_type} = 'r';
					$vis{audience_id} = GOON()->id;
				}

				if (defined $unvote) {
					$c->game->log(\%vis,
						'%s unvoted %s', $c->player->alias, $unvote->alias
					);
				}
				if (defined $vote) {
					$c->player->update({ vote_id => $vote->id });
					$c->game->log(\%vis,
						'%s voted %s', $c->player->alias, $vote->alias
					);
				}
			}
		}
	}

	$c->redirect_to($c->referrer || $c->url_for('game-view', id => $c->game->id));
}

'I want to play a game.';
