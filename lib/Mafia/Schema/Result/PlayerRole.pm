use utf8;
package Mafia::Schema::Result::PlayerRole;

use strict;
use warnings;

use base 'Mafia::Schema::Result';

__PACKAGE__->table("player_role");

__PACKAGE__->load_components('InflateColumn::Serializer');

__PACKAGE__->add_columns(
	"player_no",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
	"game_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
	"role_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
	"state",
	{ data_type => "text", serializer_class => 'JSON', is_nullable => 1 },
);

__PACKAGE__->set_primary_key("player_no", "game_id", "role_id");

__PACKAGE__->belongs_to(
	"player",
	"Mafia::Schema::Result::Player",
	{
		"foreign.no"      => "self.player_no",
		"foreign.game_id" => "self.game_id",
	},
	{ is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->belongs_to(
	"role",
	"Mafia::Schema::Result::Role",
	{ id => "role_id" },
	{ is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

1;
