use utf8;
package Mafia::Schema::Result::Team;

use strict;
use warnings;

use base 'Mafia::Schema::Result';

__PACKAGE__->table("teams");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"name",
	{ data_type => "text", is_nullable => 1 },
	"type",
	{ data_type => "text", is_nullable => 0 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
	"players",
	"Mafia::Schema::Result::Player",
	{ "foreign.team_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"setup_roles",
	"Mafia::Schema::Result::SetupRole",
	{ "foreign.team_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);







1;