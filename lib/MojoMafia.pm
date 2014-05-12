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

		$self->plugin('Mafia::Watcher');
	}

	if ($self->app->mode eq 'production') {
		$self->app->log(Mafia::Log->new(
			path  => 'site/mafia.log',
			level => 'info',
		));
	}

	$self->moniker('mafia');

	$self->meta(YAML::LoadFile('meta.yml'));
	$self->config(Mafia::Config::load());
	if (defined $self->config('secret')) {
		$self->secret($self->config('secret'));
	}

	# Allow use of commands in the Mafia::Command namespace
	unshift $self->commands->namespaces, 'Mafia::Command';

	# Load routes from lib/mafia.routes
	$self->plugin('PlainRoutes', { autoname => 1 });

	# Access database
	$self->helper(db => sub {
		my ($c, $table) = @_;
		state $schema = Mafia::Schema->connect(
			$self->config->{dsn},'','',
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

	# Fetch and cache player
	$self->helper(player => sub {
		my $c = shift;
		state $key = '_player_object';
		return $c->stash($key) if defined $c->stash($key);

		if (defined $c->stash->{game}) {
			if ($c->app->mode eq 'development' && defined $c->param('player')) {
				my $query = $c->stash->{game}->search_related('players', {
					alias => $c->param('player'),
				});

				if ($query->count == 1) {
					return $c->stash->{$key} = $query->single;
				}
			}
			elsif ($c->user) {
				my $player = $c->db('Player')->find({
					user_id => $c->user->id,
					game_id => $c->stash->{game}->id,
				});
				if (defined $player) {
					return $c->stash->{$key} = $player;
				}
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

	# # Tidy HTML output after rendering
	# $self->hook(after_render => sub {
	# 	my ($self, $output, $format) = @_;

	# 	return unless $format eq 'html';

	# 	$self->app->log->debug("Tidying rendered HTML");

	# 	${ $output } = Mafia::HTML::tidy(${ $output });
	# });
}

sub meta {
	return shift->_dict(meta => @_);
}

1;
