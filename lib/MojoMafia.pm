package MojoMafia;
use Mojo::Base 'Mojolicious';

require Mafia::DateTime;
require Mafia::HTML;
require Mafia::Log;

# This method will run once at server start
sub startup {
	my $self = shift;

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');

	# Routes
	my $r = $self->routes;

	$r->get('/')->to('root#index');

	# Tidy HTML output after rendering
	$self->hook(after_render => sub {
		my ($self, $output, $format) = @_;

		return unless $format eq 'html';

		$self->app->log->debug("Tidying rendered HTML");

		$$output = Mafia::HTML::tidy($$output);

		"We good";
	});
}

sub development_mode {
	my $self = shift;

	$self->log(Mafia::Log->new);
}

sub production_mode {
	my $self = shift;

	my $log = Mafia::Log->new(
		path  => $self->home->rel_file('log/mafia.log'),
		level => 'info',
	);

	$self->log($log);
}

1;
