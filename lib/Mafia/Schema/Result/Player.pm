use utf8;
package Mafia::Schema::Result::Player;

use strict;
use warnings;

use base 'Mafia::Schema::Result';
use Mafia::Role qw/:all/;

__PACKAGE__->table("players");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"no",
	{ data_type => "integer", is_nullable => 1 },
	"alias",
	{ data_type => "varchar", is_nullable => 0 },
	"user_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"game_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
	"vote_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"is_alive",
	{ data_type => "boolean", default_value => 1, is_nullable => 0 },
	"created",
	{ data_type => "timestamp", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->add_unique_constraint("game_id_user_id_unique", ["game_id", "user_id"]);
__PACKAGE__->add_unique_constraint("game_id_player_no_unique", ["game_id", "no"]);

__PACKAGE__->belongs_to(
	"game",
	"Mafia::Schema::Result::Game",
	{ id => "game_id" },
	{
		is_deferrable => 1,
		join_type     => "LEFT",
		on_delete     => "CASCADE",
		on_update     => "CASCADE",
	},
);

__PACKAGE__->belongs_to(
	"user",
	"Mafia::Schema::Result::User",
	{ id => "user_id" },
	{
		is_deferrable => 1,
		join_type     => "LEFT",
		on_delete     => "CASCADE",
		on_update     => "CASCADE",
	},
);

__PACKAGE__->belongs_to(
	"vote",
	"Mafia::Schema::Result::Player",
	{
		"foreign.id"      => "self.vote_id",
		"foreign.game_id" => "self.game_id",
	},
	{
		is_deferrable => 1,
		join_type     => "LEFT",
		on_delete     => "CASCADE",
		on_update     => "CASCADE",
	},
);

__PACKAGE__->has_many(
	"player_roles",
	"Mafia::Schema::Result::PlayerRole",
	{
		"foreign.player_no" => "self.no",
		"foreign.game_id"   => "self.game_id",
	},
	{ cascade_copy => 0, cascade_delete => 0 },
);

sub audiences {
	my $self = shift;
	my @audiences;

	if (!$self->game->active) {
		@audiences = (
			('town'),
		);
	}
	elsif ($self->alive) {
		@audiences = (
			('town')  x!! $self->game->day,
			('mafia') x!! $self->has_role(GOON),
		);
	}
	else {
		@audiences = (
			# Unlike "Town" for living players, there's not really any reason
			# to disallow dead people from talking at night.
			('dead'),
		);
	}

	return @audiences;
}

sub can_talk {
	my $self = shift;
	return scalar $self->audiences;
}

sub has_role {
	my $self = shift;
	return $self->player_roles->search({ role_id => shift->id })->count;
}

sub name {
	my $self = shift;
	return $self->alias // $self->user->name;
}

sub role {
	my $self = shift;
	return join ' ', map $_->name, $self->roles;
}

sub roles {
	return sort { $a->order <=> $b->order }
	         map { Mafia::Role->find($_) }
	           shift->player_roles->get_column('role_id')->all;
}

1;
