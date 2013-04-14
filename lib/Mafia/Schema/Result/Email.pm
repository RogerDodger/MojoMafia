use utf8;
package Mafia::Schema::Result::Email;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("emails");

__PACKAGE__->add_columns(
	"address",
	{ data_type => "varchar", is_nullable => 0, size => 256 },
	"user_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"main",
	{ data_type => "boolean", default_value => 0, is_nullable => 1 },
	"verified",
	{ data_type => "boolean", default_value => 0, is_nullable => 1 },
	"created",
	{ data_type => "timestamp", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("address");

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
