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

sub add_pools {
	my ($self, $pools) = @_;

	my $i = 0;
	for my $pool (@$pools) {
		for my $player (@$pool) {
			for my $role (@$player) {
				$self->create_related('setup_roles', {
					player_no => 1 + $i % 9,
					role_id   => $role,
					pool      => 1 + int($i / 9),
				});
			}
			$i++;
		}
	}
}

sub player_nos {
	my $self = shift;

	return $self->setup_roles
	            ->search({}, { group_by => [ 'player_no' ] })
	            ->get_column('player_no');
}

sub pools {
	my $self = shift;

	my (@pools, $pool, $player, $prev);
	for ($self->setup_roles->order_by([qw/pool player_no role_id/])->all) {
		if (!defined $prev || $prev->pool != $_->pool) {
			$pool = [];
			push @pools, $pool;
		}

		if (!defined $prev || $prev->player_no != $_->player_no) {
			$player = [];
			push @{$pool}, $player;
		}

		push @{$player}, $_->role_id;
		$prev = $_;
	}

	return \@pools;
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
