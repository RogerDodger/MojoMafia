use utf8;
package Mafia::Schema::Result::Thread;

use strict;
use warnings;

use base 'Mafia::Schema::Result';

__PACKAGE__->table("threads");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"board_id",
	{ data_type => "integer", is_nullable => 1 },
	"title",
	{ data_type => "varchar", is_nullable => 1, size => 64 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
	"posts",
	"Mafia::Schema::Result::Post",
	{ "foreign.thread_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->might_have(
	"game",
	"Mafia::Schema::Result::Game",
	{ "foreign.thread_id" => "self.id" },
);

sub op {
	my $self = shift;

	return $self->posts->search({ is_op => 1 })->first;
}

1;
