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
	"thread_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
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

__PACKAGE__->belongs_to(
	"thread",
	"Mafia::Schema::Result::Thread",
	{ id => "thread_id" },
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
	"threads",
	"Mafia::Schema::Result::Thread",
	{ "foreign.game_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

sub timeofday {
	my $self = shift;
	return         $self->is_day ? 'day' : 
	       defined $self->is_day ? 'night' :
	       defined $self->end    ? 'post-game' : 'pre-game';
}

sub datetime {
	my $self = shift;
	return join(' ', $self->timeofday, $self->date);
}

sub log {
	my ($self, $fmt, @list, $opt) = @_;

	if (ref $list[-1] eq 'HASH') {
		$opt = pop @list;
	}
	else {
		$opt = {};
	}

	my $msg = sprintf $fmt, @list;

	my $post = $self->thread->create_related('posts', {
		class    => join(' ', 'system', 'game', $self->timeofday),
		plain    => $msg,
		gamedate => $self->date,
	});

	if ($opt->{literal}) {
		$post->update({ render => $msg });
	}
	else {
		$post->apply_markup;
	}

	return $post;
}

sub begin {
	my $self = shift;
	my $setup = $self->setup;

	if ($setup->size != $self->players->count) {
		Carp::croak "Game does not have correct number of players.";
	}

	my @pool = shuffle map { ($_) x $_->count } $setup->random_pool;

	for my $player (shuffle $self->players->all) {
		my $allocation = pop @pool;
		$player->update({ 
			role_id => $allocation->role_id,
			team_id => $allocation->team_id, 
		});
	}

	$self->update({
		date   => 1,
		is_day => $setup->day_start,
	});

	$self->log('%s has begun.', ucfirst $self->datetime);
}

sub cycle {
	my $self = shift;

	# Process votes ...

	$self->update({ 
		date   => $self->date + ($self->is_day != $self->setup->day_start),
		is_day => !$self->is_day,
	});
}

sub is_active {
	return 1 if shift->date;
	0;
}

1;
