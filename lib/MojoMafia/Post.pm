package MojoMafia::Post;
use Mojo::Base "Mojolicious::Controller";
use Mafia::Markup qw/render_markup/;
use Mafia::Role qw/:all/;
use Mafia::Util qw/maybe/;
use Scalar::Util qw/looks_like_number/;

sub fetch {
	my $c = shift;
	my $id = $c->param('id');
	$c->render_not_found and return undef unless looks_like_number $id;

	my $post = $c->db('Post')->find($id);

	if (defined $post) {
		$c->stash->{post} = $post;
	}
	else {
		$c->render_not_found and return undef;
	}

	1;
}

sub post_game {
	my $c = shift;

	my $v = $c->validation;
	$v->required('body')->size(1, 65535);
	$v->required('audience')->in(map $_->[0], $c->player->audiences);

	my $error_msg;
	$error_msg = "You cannot post" if !$c->player->can_talk;
	$error_msg = "Invalid audience" if $v->has_error;
	if (defined $error_msg) {
		return $c->respond_to(
			html => sub {
				$c->flash(error_msg => $error_msg);
				$c->redirect_to(
					$c->url_for('game-view', id => $c->stash->{game}->id)
						->query({ maybe page => scalar $c->param('page') })
				);
			},
			json => { json => { error => $error_msg }},
		);
	}

	# Post is good to go
	my $body = $v->param('body');
	my ($a_id, $a_type) = split ";", $v->param('audience');

	my %vis;
	if ($a_type eq 'r' && $a_id == INNO()->id) {
		$vis{private} = 0;
	}
	else {
		$vis{audience_type} = $a_type;
		$vis{audience_id} = $a_id;
		$vis{private} = 1;
	}

	my $post = $c->game->create_post($body);

	$post->update({
		user_id     => $c->user->id,
		user_alias  => $c->player->alias,
		user_hidden => 1,
		%vis,
	});

	$c->respond_to(
		html => sub { $c->redirect_to('post-thread', id => $post->id) },
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

sub thread {
	my $c = shift;
	my $post = $c->stash->{post};

	# Set game so that $c->player works, if necessary
	$c->game($post->game) if defined $post->game_id;

	my $posts = $post->posts->visible($c->player);

	# 404 if user shouldn't see found post
	return $c->render_not_found unless $posts->find($post->id);

	my $page = 1 + int ($posts->no($post) / $c->app->config->{rows});

	if ($c->game) {
		$c->redirect_to(
			$c->url_for('game-view', id => $c->game->id)
					->query(page => $page)
					->fragment($post->id)
		);
	}
	else {
		$c->redirect_to(
			$c->url_for('thread-view', id => $post->thread_id)
					->query(page => $page)
					->fragment($post->id)
		);
	}
}

1;
