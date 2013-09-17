use utf8;
package Mafia::Schema::Result::Setup;

use strict;
use warnings;

use base 'Mafia::Schema::Result';

__PACKAGE__->table("setups");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"user_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"name",
	{ data_type => "text", is_nullable => 1 },
	"descr",
	{ data_type => "text", is_nullable => 1 },
	"allow_nk",
	{ data_type => "boolean", default_value => 1, is_nullable => 1 },
	"allow_nv",
	{ data_type => "boolean", default_value => 1, is_nullable => 1 },
	"day_start",
	{ data_type => "boolean", default_value => 0, is_nullable => 1 },
	"final",
	{ data_type => "boolean", default_value => 0, is_nullable => 1 },
	"private",
	{ data_type => "boolean", default_value => 1, is_nullable => 1 },
	"plays",
	{ data_type => "integer", default_value => 0, is_nullable => 1 },
	"created",
	{ data_type => "timestamp", is_nullable => 1 },
	"updated",
	{ data_type => "timestamp", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
	"games",
	"Mafia::Schema::Result::Game",
	{ "foreign.setup_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"setup_roles",
	"Mafia::Schema::Result::SetupRole",
	{ "foreign.setup_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
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

sub player_nos {
	my $self = shift;

	return $self->setup_roles
	            ->search({}, { group_by => [ 'player_no' ] })
	            ->get_column('player_no');
}

sub size {
	my $self = shift;

	# Assume the pools are properly balanced
	return $self->setup_roles->search({}, { group_by => [ 'player_no' ] })->count;
}

sub random_pool {
	my $self = shift;

	my @pools = $self->setup_roles
	                 ->search({}, { group_by => [ 'pool' ] })
	                 ->get_column('pool')
	                 ->all;

	my $pool = $pools[int rand @pools];

	return $self->setup_roles->search({ pool => $pool });
}

1;
