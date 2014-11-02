use utf8;
package Mafia::Schema::Result::Game;

use strict;
use warnings;

use base 'Mafia::Schema::Result';
use List::Util 'shuffle';
use Mafia::Role qw/:all/;

__PACKAGE__->table("games");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"host_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"setup_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"title",
	{ data_type => "varchar", is_nullable => 1 },
	"day",
	{ data_type => "boolean", is_nullable => 1 },
	"date",
	{ data_type => "integer", is_nullable => 1 },
	"active",
	{ data_type => "boolean", is_nullable => 1 },
	"end",
	{ data_type => "timestamp", is_nullable => 1 },
	"created",
	{ data_type => "timestamp", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to(
	"host",
	"Mafia::Schema::Result::User",
	{ id => "host_id" },
	{
		is_deferrable => 1,
		join_type     => "LEFT",
		on_delete     => "CASCADE",
		on_update     => "CASCADE",
	},
);

__PACKAGE__->has_many(
	"players",
	"Mafia::Schema::Result::Player",
	{ "foreign.game_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"player_roles",
	"Mafia::Schema::Result::PlayerRole",
	{ "foreign.game_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"posts",
	"Mafia::Schema::Result::Post",
	{ "foreign.game_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->belongs_to(
	"setup",
	"Mafia::Schema::Result::Setup",
	{ id => "setup_id" },
	{
		is_deferrable => 1,
		join_type     => "LEFT",
		on_delete     => "CASCADE",
		on_update     => "CASCADE",
	},
);

sub begin {
	my $self = shift;
	my $setup = $self->setup;

	if ($setup->size != $self->players->count) {
		Carp::croak "Game does not have correct number of players.";
	}

	# Assign players a player no
	my $players = $self->players;
	$players->next->update({ no => $_ }) for shuffle $self->setup->player_nos->all;

	my $pool = $setup->random_pool;

	while (my $role = $pool->next) {
		$self->create_related(player_roles => {
			player_no => $role->player_no,
			role_id   => $role->role_id,
			state     => $role->initial_state,
		});
	}

	$self->update({
		active => 1,
		date   => 1,
		day    => $setup->day_start,
	});

	$self->log('%s has begun.', ucfirst $self->datetime);
}

sub candidates {
	my $self = shift;

	return $self->players->living;
}

sub check {
	my $self = shift;
	my $goons = $self->players->living->with_role(GOON)->count;
	my $players = $self->players->living->count;

	if ($goons == 0) {
		# Town wins
	}
	elsif ($goons >= $players / 2) {
		# Mafia wins
	}
	else {
		return;
	}

	$self->update({ active => 0 });
}

sub create_post {
	my ($self, $body) = @_;

	my $post = $self->create_related(posts => {
		user_hidden => !$self->end,
		body_plain  => $body,
		gamedate    => $self->date,
		gametime    => $self->time,
	});

	$post->apply_markup;
}

sub cycle {
	my $self = shift;

	$self->update({
		date => $self->date + ($self->day != $self->setup->day_start),
		day  => 0 + !$self->day,
	});

	$self->log('%s has begun.', ucfirst $self->datetime);
}

sub datetime {
	my $self = shift;
	return $self->timeofday . ' ' . $self->date;
}

sub full {
	my $self = shift;
	$self->players->count >= $self->setup->size;
}

sub log {
	my $self = shift;

	my $opt = ref $_[0] eq 'HASH' ? shift : {};
	my $msg = sprintf shift, @_;
	my $v = delete $opt->{v};

	my $post = $self->create_related('posts', { %{$opt},
		body_plain  => $msg,
		gametime    => $self->time,
		gamedate    => $self->date,
	});

	if ($v) {
		$post->update({ body_render => $msg });
	}
	else {
		$post->apply_markup;
	}

	return $post;
}

sub lynch {
	my ($self, $player) = @_;

	$player->update({ alive => 0 });

	$self->log({ trigger => 'lynch' },
		'%s (%s) has been %s.',
		$player->alias, $player->role, $self->day ? 'lynched' : 'killed'
	);
}

sub showform {
	my ($self, $user) = @_;

	$user && !$user->plays($self) && !$self->full;
}

sub time {
	my $self = shift;

	$self->active
		? $self->day
			? 'day' : 'night'
		: $self->end
			? 'post-game' : 'pre-game';
}

sub touch {
	my $self = shift;
	return unless $self->id == 2;
	# YES THIS IS INEFFICIENT BUT IT'S CRUNCH TIME DAMMIT
	my %tally;
	my $n = 0;
	for my $p ($self->players->living) {
		if ($p->votes) {
			$n++;
			if (defined $p->vote_id) {
				$tally{$p->vote_id}++;
			}
		}
	}

	my $cut = int(($n+1) / 2);

	for my $pid (keys %tally) {
		if ($tally{$pid} >= $cut) {
			$self->lynch($self->players->find($pid));
			$self->players->update({ vote_id => undef });
			$self->check;

			if ($self->active) {
				$self->cycle;
			}
		}
	}
}

BEGIN { *timeofday = \&time }

1;
