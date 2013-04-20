use utf8;
package Mafia::Schema::Result::Player;

use strict;
use warnings;

use base 'Mafia::Schema::Result';

__PACKAGE__->table("players");

__PACKAGE__->load_components('InflateColumn::Serializer');

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"alias",
	{ data_type => "varchar", is_nullable => 1, size => 16 },
	"user_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"game_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"role_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"vote_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"team_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"is_alive",
	{ data_type => "boolean", default_value => 1, is_nullable => 0 },
	"roledata",
	{ data_type => "text", serializer_class => 'JSON', is_nullable => 1 },
	"created",
	{ data_type => "timestamp", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->add_unique_constraint("user_id_game_id_unique", ["user_id", "game_id"]);

__PACKAGE__->has_many(
	"actions_actors",
	"Mafia::Schema::Result::Action",
	{ "foreign.actor_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"actions_targets",
	"Mafia::Schema::Result::Action",
	{ "foreign.target_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

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

__PACKAGE__->has_many(
	"players",
	"Mafia::Schema::Result::Player",
	{ "foreign.vote_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->belongs_to(
	"role",
	"Mafia::Schema::Result::Role",
	{ id => "role_id" },
	{
		is_deferrable => 1,
		join_type     => "LEFT",
		on_delete     => "CASCADE",
		on_update     => "CASCADE",
	},
);

__PACKAGE__->belongs_to(
	"team",
	"Mafia::Schema::Result::Team",
	{ id => "team_id" },
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
	{ id => "vote_id" },
	{
		is_deferrable => 1,
		join_type     => "LEFT",
		on_delete     => "CASCADE",
		on_update     => "CASCADE",
	},
);







1;
