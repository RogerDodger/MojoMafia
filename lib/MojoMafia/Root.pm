package MojoMafia::Root;
use Mojo::Base 'Mojolicious::Controller';

sub index {
	my $c = shift;

	$c->render;
}

1;
