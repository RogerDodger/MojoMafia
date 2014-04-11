package MojoMafia::Root;
use Mojo::Base 'Mojolicious::Controller';

use File::stat;

sub index {
	my $c = shift;

	$c->stash->{games} = $c->db('Game')->active;

	$c->render;
}

sub events {
	my $c = shift;

	$c->render(text => 'Not yet implemented');
}

1;
