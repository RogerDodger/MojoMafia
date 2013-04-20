package MojoMafia::Root;
use Mojo::Base 'Mojolicious::Controller';

sub index {
	my $self = shift;

	$self->app->log->info("Root::index accessed.");

	$self->render();
}

1;
