package MojoMafia::Post;
use Mojo::Base "Mojolicious::Controller";
use Mafia::Markup qw/render_markup/;
use Mafia::Util qw/maybe/;

sub post_game {
	my $c = shift;

	my $v = $c->validation;
	$v->required('body')->size(1, 65535);
	$v->required('audience')->in($c->player->audiences);

	my $error_msg;
	$error_msg = "You cannot post" if !$c->player->can_talk;
	$error_msg = "Invalid audience" if $v->has_error;
	if (defined $error_msg) {
		$c->flash(error_msg => $error_msg);
		return $c->respond_to(
			html => sub {
				$c->redirect_to(
					$c->url_for('game-view', id => $c->stash->{game}->id)
						->query({ maybe player => scalar $c->param('player') })
						->query({ maybe page => scalar $c->param('page') })
				);
			},
			json => { json => { error => $error_msg }},
		);
	}

	# Post is good to go
	my $game = $c->stash->{game};
	my ($body, $audience) = $v->param([qw/body audience/]);

	my $post = $game->create_post($body);

	$post->update({
		user_id     => $c->user->id,
		user_alias  => $c->player->alias,
		user_hidden => 1,
		private     => $audience ne 'town' || 0,
	});

	$c->respond_to(
		html => sub { $c->redirect_to('game-view', id => $game->id) },
		json => { json => { id =>  $post->id }},
	);
}

sub preview {
	my $c = shift;
	my $response = render_markup $c->param('text');

	if ($c->app->mode eq 'development') {
		# Add a delay to test our kewl animation
		Mojo::IOLoop->timer(1 => sub {
			$c->render(text => $response);
		});
	}
	else {
		$c->render(text => $response);
	}
}

1;
