package MojoMafia::Root;
use Mojo::Base 'Mojolicious::Controller';

sub index {
	my $c = shift;

	$c->app->log->info("Root::index accessed.");

	$c->render;
}

1;
