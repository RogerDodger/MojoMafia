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

	# Routes
	my $r = $self->routes;

	$r->get('/')->to('root#index');

	$r->post('/login')   ->to('user#login');
	$r->post('/logout')  ->to('user#logout');

	my $g = $r->bridge('/game/:id')->to('game#fetch');
	$g->get('/:time')      ->to('game#thread');
	$g->get('/:time/:date')->to('game#thread');

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

	# Fetch and cache user
	$self->helper(user => sub {
		my $c = shift;
		return $c->stash->{user} if defined $c->stash->{user};

		if (defined $c->session->{email}) {
			my $email = $c->db('Email')->find($c->session->{email});
			if (defined $email) {
				return $c->stash->{user} = $email->user;
			}
		}
		return undef;
	});

	# Prompt a new user to register
	$self->hook(before_routes => sub {
		my $c = shift;
		return if $c->stash('mojo.static');

		if (defined $c->session->{email} && !defined $c->user) {
			if ($c->req->method eq 'GET') {
				$c->render(template => 'user/register');
			}
			elsif ($c->req->method eq 'POST') {
				my $name = $c->param('username');

				if ($c->db('User')->find({ name => $name })) {
					$c->stash->{form}{user}{error} = 'User already exists';;
					return $c->render(template => 'user/register');
				}

				$c->db('Email')->create({
					address  => $c->session->{email},
					main     => 1,
					verified => 1,
					user => {
						name => $name,
					},
				});

				$c->redirect_to($c->req->url->to_abs);
			}
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
