use utf8;
package Mafia::Schema::Result::Post;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("posts");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"thread_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"user_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"is_op",
	{ data_type => "boolean", default_value => 0, is_nullable => 1 },
	"class",
	{ data_type => "text", is_nullable => 1 },
	"plain",
	{ data_type => "text", is_nullable => 1 },
	"render",
	{ data_type => "text", is_nullable => 1 },
	"gamedate",
	{ data_type => "integer", is_nullable => 1 },
	"created",
	{ data_type => "timestamp", is_nullable => 1 },
	"updated",
	{ data_type => "timestamp", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to(
	"thread",
	"Mafia::Schema::Result::Thread",
	{ id => "thread_id" },
	{
		is_deferrable => 1,
		join_type     => "LEFT",
		on_delete     => "CASCADE",
		on_update     => "CASCADE",
	},
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
