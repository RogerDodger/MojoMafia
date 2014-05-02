package MojoMafia::Post;
use Mojo::Base "Mojolicious::Controller";
use Mafia::Markup qw/markup/;

sub post_game {
	my $c = shift;
	return $c->render_exception("You cannot talk") unless $c->player->can_talk;

	my $v = $c->validation;
	$v->required('body')->size(1, 65535);
	$v->required('audience')->in($c->player->audiences);

	if (!$v->has_error) {
		# TODO:
		return $c->redirect_to('game-view', id => $c->stash->{game}->id);
	}

	$c->render(text => "Bad input");
}

sub preview {
	my $c = shift;

	my $response = markup $c->param('text');
	Mojo::IOLoop->timer(2 => sub {
		$c->render(text => $response);
	});
}

1;
