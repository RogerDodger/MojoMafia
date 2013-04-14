use utf8;
package Mafia::Schema::Result::Game;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("games");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"host_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"setup_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"is_day",
	{ data_type => "boolean", is_nullable => 1 },
	"gamedate",
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

__PACKAGE__->has_many(
	"threads",
	"Mafia::Schema::Result::Thread",
	{ "foreign.game_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);







1;
