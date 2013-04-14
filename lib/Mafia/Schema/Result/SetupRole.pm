use utf8;
package Mafia::Schema::Result::SetupRole;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("setup_role");

__PACKAGE__->add_columns(
	"role_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
	"team_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
	"pool",
	{ data_type => "integer", is_nullable => 0 },
	"count",
	{ data_type => "integer", is_nullable => 0 },
);

__PACKAGE__->set_primary_key("role_id", "team_id", "pool");

__PACKAGE__->belongs_to(
	"role",
	"Mafia::Schema::Result::Role",
	{ id => "role_id" },
	{ is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->belongs_to(
	"team",
	"Mafia::Schema::Result::Team",
	{ id => "team_id" },
	{ is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);







1;
