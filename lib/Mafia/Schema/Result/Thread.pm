use utf8;
package Mafia::Schema::Result::Thread;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("threads");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"board_id",
	{ data_type => "integer", is_nullable => 1 },
	"game_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"title",
	{ data_type => "varchar", is_nullable => 1, size => 64 },
);

__PACKAGE__->set_primary_key("id");

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
	"posts",
	"Mafia::Schema::Result::Post",
	{ "foreign.thread_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);







1;
