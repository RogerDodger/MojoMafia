use utf8;
package Mafia::Schema::Result::SetupRole;

use strict;
use warnings;

use base 'Mafia::Schema::Result';

__PACKAGE__->table("setup_role");

__PACKAGE__->load_components(qw/InflateColumn::Serializer Mafia::InflateRole/);

__PACKAGE__->add_columns(
	"setup_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
	"player_no",
	{ data_type => "integer", is_nullable => 0 },
	"role_id",
	{ data_type => "integer", is_foreign_key => 0, is_nullable => 0 },
	"pool",
	{ data_type => "integer", is_nullable => 0 },
	"initial_state",
	{ data_type => "text", serializer_class => "JSON", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("setup_id", "player_no", "role_id", "pool");

__PACKAGE__->belongs_to(
	"setup",
	"Mafia::Schema::Result::Setup",
	{ id => "setup_id" },
	{ is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

1;
