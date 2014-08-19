package MojoMafia::Player;
use Mojo::Base 'Mojolicious::Controller';

sub post {
	my $c = shift;

	my $v = $c->validation;
	$v->required('alias')->size(1, 64);

	if (!$v->has_error) {
		# Woohoo
	}
	else {
		# Wuh-wuh-wuuhwuhwuhwuh
	}
}

'The only winning move is not to play.';
