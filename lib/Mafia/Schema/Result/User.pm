use utf8;
package Mafia::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("users");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"name",
	{ data_type => "varchar", is_nullable => 0, size => 24 },
	"is_admin",
	{ data_type => "boolean", default_value => 0, is_nullable => 1 },
	"is_mod",
	{ data_type => "boolean", default_value => 0, is_nullable => 1 },
	"active",
	{ data_type => "boolean", default_value => 1, is_nullable => 1 },
	"token",
	{ data_type => "varchar", is_nullable => 1, size => 32 },
	"wins",
	{ data_type => "integer", default_value => 0, is_nullable => 1 },
	"losses",
	{ data_type => "integer", default_value => 0, is_nullable => 1 },
	"games",
	{ data_type => "integer", default_value => 0, is_nullable => 1 },
	"created",
	{ data_type => "timestamp", is_nullable => 1 },
	"updated",
	{ data_type => "timestamp", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
	"emails",
	"Mafia::Schema::Result::Email",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"games",
	"Mafia::Schema::Result::Game",
	{ "foreign.host_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"players",
	"Mafia::Schema::Result::Player",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"posts",
	"Mafia::Schema::Result::Post",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"setups",
	"Mafia::Schema::Result::Setup",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);







1;
