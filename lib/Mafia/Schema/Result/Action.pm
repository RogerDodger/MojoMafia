use utf8;
package Mafia::Schema::Result::Action;

use strict;
use warnings;

use base 'Mafia::Schema::Result';

__PACKAGE__->table("actions");

__PACKAGE__->add_columns(
	"actor_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
	"target_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
	"gamedate",
	{ data_type => "integer", is_nullable => 0 },
);

__PACKAGE__->set_primary_key("actor_id", "target_id", "gamedate");

__PACKAGE__->belongs_to(
	"actor",
	"Mafia::Schema::Result::Player",
	{ id => "actor_id" },
	{ is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->belongs_to(
	"target",
	"Mafia::Schema::Result::Player",
	{ id => "target_id" },
	{ is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);







1;
