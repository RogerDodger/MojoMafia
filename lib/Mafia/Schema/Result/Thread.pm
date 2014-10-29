use utf8;
package Mafia::Schema::Result::Thread;

use strict;
use warnings;

use base 'Mafia::Schema::Result';

__PACKAGE__->table("threads");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"title",
	{ data_type => "varchar", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
	"posts",
	"Mafia::Schema::Result::Post",
	{ "foreign.thread_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

1;
