use utf8;
package Mafia::Schema::Result::Audience;

use strict;
use warnings;

use base 'Mafia::Schema::Result';

__PACKAGE__->table("audiences");

__PACKAGE__->load_components(qw/Mafia::InflateRole/);

__PACKAGE__->add_columns(
	"post_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
	"role_id",
	{ data_type => "integer", is_nullable => 1 },
	"player_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

__PACKAGE__->belongs_to(
	"post",
	"Mafia::Schema::Result::Post",
	{ id => "post_id" },
	{
		is_deferrable => 1,
		join_type     => "LEFT",
		on_delete     => "CASCADE",
		on_update     => "CASCADE",
	},
);

__PACKAGE__->belongs_to(
	"player",
	"Mafia::Schema::Result::Player",
	{ id => "player_id" },
	{
		is_deferrable => 1,
		join_type     => "LEFT",
		on_delete     => "CASCADE",
		on_update     => "CASCADE",
	},
);

1;
