package MojoMafia::Root;
use Mojo::Base 'Mojolicious::Controller';

sub index {
	my $c = shift;

	$c->stash->{games} = $c->db('Game');

	$c->render('game/list');
}

sub events {
	my $c = shift;

	$c->render(text => 'Not yet implemented');
}

1;
