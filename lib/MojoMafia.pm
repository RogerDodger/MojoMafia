package MojoMafia;
use Mojo::Base 'Mojolicious';

require Mafia::HTML;
require Mafia::Log;
require Mafia::Schema;
require YAML;

sub startup {
	my $self = shift;
	
	$self->moniker('mafia');

	# Allow use of commands in the Mafia::Command namespace
	unshift $self->commands->namespaces, 'Mafia::Command';

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');

	# Get app metadata, e.g. version number
	$self->helper(meta => sub {
		my ($c, $key) = @_;
		state $meta = YAML::LoadFile($self->home->rel_file('meta.yml'));
		return defined $key ? $meta->{$key} : $meta;
	});

	# Access database
	$self->helper(db => sub {
		my ($c, $table) = @_;
		state $schema = Mafia::Schema->connect(
			'dbi:SQLite:' . $c->app->home->rel_file('data/mafia.db'),'','',
			{ sqlite_unicode => 1 },
		);
		if (defined $table) {
			return $schema->resultset($table);
		}
		else {
			return $schema;
		}
	});

	# User
	$self->helper(user => sub {
		my $c = shift;
		return $c->stash->{user} if defined $c->stash->{user};

		return $c->db('User')->find(8);
		return undef;
	});

	# Routes
	my $r = $self->routes;

	$r->get('/')->to('root#index');

	my $g = $r->bridge('/game/:id')->to('game#fetch');
	$g->get('/:time')->to('game#thread');
	$g->get('/:time/:date')->to('game#thread');

	# Tidy HTML output after rendering
	$self->hook(after_render => sub {
		my ($self, $output, $format) = @_;

		return unless $format eq 'html';

		$self->app->log->debug("Tidying rendered HTML");

		${$output} = Mafia::HTML::tidy(${$output}) and 1;
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
