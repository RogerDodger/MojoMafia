package MojoMafia;
use Mojo::Base 'Mojolicious';

use Class::Null;
use Mafia::Config;
use Mafia::HTML;
use Mafia::Log;
use Mafia::Schema;
use YAML ();

sub startup {
	my $self = shift;

	$self->moniker('mafia');
	$self->secret('OIAJDOIPEJOIIOXFGOIFJMIZZOFJWOIROIFJOIJDKOKFSDFKDMMNNASPDOQ');

	# Allow use of commands in the Mafia::Command namespace
	unshift $self->commands->namespaces, 'Mafia::Command';

	# Routes
	my $r = $self->routes;

	$r->get('/')->to('root#index');

	$r->get('/register')->to('user#register');
	$r->post('/login')->to('user#login');
	$r->post('/logout')->to('user#logout');
	$r->post('/register')->to('user#do_register');

	my $g = $r->bridge('/game/:id')->to('game#fetch');
	$g->get('/')->to('game#thread');

	$self->config(Mafia::Config::load());
	$self->meta(YAML::LoadFile('meta.yml'));

	# Access database
	$self->helper(db => sub {
		my ($c, $table) = @_;
		state $schema = Mafia::Schema->connect(
			'dbi:SQLite:site/mafia.db','','',
			{ sqlite_unicode => 1 },
		);
		if (defined $table) {
			return $schema->resultset($table);
		}
		else {
			return $schema;
		}
	});

	# Fetch and cache user
	$self->helper(user => sub {
		my $c = shift;
		state $key = '_user_object';
		return $c->stash($key) if defined $c->stash($key);

		if (defined $c->session->{email}) {
			my $email = $c->db('Email')->find($c->session->{email});
			if (defined $email) {
				return $c->stash->{$key} = $email->user;
			}
		}
		return Class::Null->new;
	});

	# Get static file with mtime query param to force cache revalidation
	$self->helper(url_for_static => sub {
		my ($c, $url) = @_;
		if ($url !~ m{^/}) {
			$c->app->log->warn("Relative path given to url_for_static");
		}
		my $filename = 'public' . $url;
		my $mtime = (stat $filename)[9] || '';
		return "$url?v=$mtime";
	});

	# Tidy HTML output after rendering
	# $self->hook(after_render => sub {
	# 	my ($self, $output, $format) = @_;

	# 	return unless $format eq 'html';

	# 	$self->app->log->debug("Tidying rendered HTML");

	# 	Mafia::HTML::tidy($output);
	# });
}

sub meta {
	return shift->_dict(meta => @_);
}

sub development_mode {
	my $self = shift;

	$self->log(Mafia::Log->new);
}

sub production_mode {
	my $self = shift;

	my $log = Mafia::Log->new(
		path  => 'site/mafia.log',
		level => 'info',
	);

	$self->log($log);
}

1;
