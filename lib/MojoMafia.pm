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

	if ($self->app->mode eq 'development') {
		$self->app->log(Mafia::Log->new);

		$self->routes->get('/watchcss')->to('root#watchcss');
	}

	if ($self->app->mode eq 'production') {
		$self->app->log(Mafia::Log->new(
			path  => 'site/mafia.log',
			level => 'info',
		));
	}

	$self->moniker('mafia');
	$self->secret('OIAJDOIPEJOIIOXFGOIFJMIZZOFJWOIROIFJOIJDKOKFSDFKDMMNNASPDOQ');

	# Allow use of commands in the Mafia::Command namespace
	unshift $self->commands->namespaces, 'Mafia::Command';

	# Routes
	my $r = $self->routes;

	$r->get('/')->to('root#index');
	$r->get('/events')->to('root#events');

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

	# For certain static files, users will request a file with the app version
	# appended to force cache revalidation. However, we don't want to actually
	# rename the files constantly, so we rewrite the requests instead.
	$self->hook(before_dispatch => sub {
		my $c = shift;

		if ($c->req->url->path =~ m{^ / (style|js) / mafia .+ [.] (css|js) $}x) {
			$c->req->url->path("/$1/mafia.$2");
		}
	});

	# Tidy HTML output after rendering
	$self->hook(after_render => sub {
		my ($self, $output, $format) = @_;

		return unless $format eq 'html';

		$self->app->log->debug("Tidying rendered HTML");

		Mafia::HTML::tidy($output);
	});
}

sub meta {
	return shift->_dict(meta => @_);
}

1;
