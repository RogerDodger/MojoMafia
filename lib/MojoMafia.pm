package MojoMafia;
use Mafia::Base 'Mojolicious';

use Class::Null;
use Mafia::Config;
use Mafia::HTML;
use Mafia::Log;
use Mafia::Schema;
use YAML ();

sub startup {
	my $self = shift;

	$self->moniker('mafia');

	$self->meta(YAML::LoadFile('meta.yml'));
	$self->config(Mafia::Config::load());

	if (defined $self->config('secrets')) {
		$self->secrets($self->config('secrets'));
	}
	else {
		$self->secrets([
			q{This is an insecure secret, but a deployment would have to} .
			q{manually delete its auto-generated secret from the config} .
			q{for this to ever be used anyway}
		]);
	}

	$self->app->log->format(sub {
		my ($time, $level, @lines) = @_;

		my $timestamp = POSIX::strftime('%b %d %H:%M:%S', localtime $time);
		return "$timestamp [$level] " . join("\n", @lines) . "\n";
	});

	if ($self->app->mode eq 'development') {
		$self->plugin('Mafia::Names');
		$self->plugin('Mafia::Watcher');
	}

	if ($self->app->mode eq 'production') {
		$self->app->log->path('site/mafia.log');
		$self->app->log->level('info');
	}

	# Allow use of commands in the Mafia::Command namespace
	unshift $self->commands->namespaces->@*, 'Mafia::Command';

	# Load routes from lib/mafia.routes
	$self->plugin('PlainRoutes', { autoname => 1 });

	# Add extra validation checks
	$self->plugin('Mafia::Validation');

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

		if (defined $c->session->{user_id}) {
			my $user = $c->db('User')->find($c->session->{user_id});
			if (defined $user) {
				return $c->stash->{$key} = $user;
			}
		}
		return Class::Null->new;
	});

	# Fetch and cache player
	$self->helper(player => sub {
		my $c = shift;
		state $key = '_player_object';
		return $c->stash($key) if defined $c->stash($key);

		if (defined $c->stash->{game} && $c->user) {
			my $player = $c->db('Player')->find({
				user_id => $c->user->id,
				game_id => $c->stash->{game}->id,
			});
			if (defined $player) {
				return $c->stash->{$key} = $player;
			}
		}
		return Class::Null->new;
	});

	# Shorthand helpers
	$self->helper(game => sub {
		my ($c, $game) = @_;
		$c->stash->{game} = $game if $game;
		$c->stash->{game};
	});

	$self->helper(referrer => sub {
		shift->req->headers->referrer;
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

	# Periodically check games for threshold conditions (viz. when to cycle)
	Mojo::IOLoop->recurring(2 => sub {
		$_->touch for $self->db('Game')->active->all;
	});
}

sub meta { Mojo::Util::_stash(meta => @_) }

1;
