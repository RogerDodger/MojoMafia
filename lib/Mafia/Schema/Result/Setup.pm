use utf8;
package Mafia::Schema::Result::Setup;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("setups");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"user_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"title",
	{ data_type => "varchar", is_nullable => 1, size => 64 },
	"descr",
	{ data_type => "varchar", is_nullable => 1, size => 2048 },
	"allow_nk",
	{ data_type => "boolean", default_value => 1, is_nullable => 1 },
	"allow_nv",
	{ data_type => "boolean", default_value => 1, is_nullable => 1 },
	"day_start",
	{ data_type => "boolean", default_value => 0, is_nullable => 1 },
	"final",
	{ data_type => "boolean", default_value => 0, is_nullable => 1 },
	"private",
	{ data_type => "boolean", default_value => 1, is_nullable => 1 },
	"plays",
	{ data_type => "integer", default_value => 0, is_nullable => 1 },
	"created",
	{ data_type => "timestamp", is_nullable => 1 },
	"updated",
	{ data_type => "timestamp", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
	"games",
	"Mafia::Schema::Result::Game",
	{ "foreign.setup_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
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







1;
