use utf8;
package Mafia::Schema::Result::Game;

use strict;
use warnings;

use base 'Mafia::Schema::Result';
use List::Util 'shuffle';

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
	"is_day",
	{ data_type => "boolean", is_nullable => 1 },
	"date",
	{ data_type => "integer", is_nullable => 1 },
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
	{ "foreign.thread_id" => "self.id" },
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

sub active { !!shift->date; }

sub begin {
	my $self = shift;
	my $setup = $self->setup;

	if ($setup->size != $self->players->count) {
		Carp::croak "Game does not have correct number of players.";
	}

	# Assign players a player no
	my $players = $self->players;
	$players->next->update({ no => $_ }) for shuffle $self->setup->player_nos;

	my $pool = $setup->random_pool;

	while (my $role = $pool->next) {
		$self->create_related(player_roles => {
			player_no => $role->player_no,
			role_id   => $role->role_id,
			state     => $role->initial_state,
		});
	}

	$self->update({
		date   => 1,
		is_day => $setup->day_start,
	});

	$self->log('%s has begun.', ucfirst $self->datetime);
}

sub create_post {
	my ($self, $body) = @_;

	my $post = $self->thread->create_related(posts => {
		user_hidden => !$self->end,
		body_plain  => $body,
		gamedate    => $self->date,
		gametime    => $self->time,
	});

	$post->apply_markup;
}

sub cycle {
	my $self = shift;

	# Process votes ...

	$self->update({
		date   => $self->date + ($self->is_day != $self->setup->day_start),
		is_day => !$self->is_day,
	});
}

sub datetime {
	my $self = shift;
	return join(' ', $self->timeofday, $self->date);
}

sub full {
	my $self = shift;
	$self->players->count >= $self->setup->size;
}

BEGIN { *is_active = \&active }

sub log {
	my ($self, $fmt, @list) = @_;

	my $opt = ref $list[-1] eq 'HASH' ? pop @list : {};
	my $msg = sprintf $fmt, @list;

	my $post = $self->thread->create_related('posts', {
		body_plain  => $msg,
		gametime    => $self->time,
		gamedate    => $self->date,
	});

	if ($opt->{literal}) {
		$post->update({ body_render => $msg });
	}
	else {
		$post->apply_markup;
	}

	return $post;
}

sub showform {
	my ($self, $user) = @_;

	$user && !$user->plays($self) && !$self->full;
}

sub time {
	my $self = shift;
	return         $self->is_day ? 'day' :
	       defined $self->is_day ? 'night' :
	       defined $self->end    ? 'post-game' : 'pre-game';
}

BEGIN { *timeofday = \&time }

1;
