use utf8;
package Mafia::Schema::Result::Post;

use strict;
use warnings;

use base 'Mafia::Schema::Result';
use Mafia::Markup qw/render_markup/;
use Mafia::Role;

__PACKAGE__->table("posts");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"thread_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"game_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"user_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"player_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"user_alias",
	{ data_type => "text", is_nullable => 1 },
	"user_hidden",
	{ data_type => "boolean", is_nullable => 1, default_value => 0 },
	"body_plain",
	{ data_type => "text", is_nullable => 1 },
	"body_render",
	{ data_type => "text", is_nullable => 1 },
	"private",
	{ data_type => "boolean", is_nullable => 1, default_value => 0 },
	"audience_type",
	{ data_type => "char", is_nullable => 1 },
	"audience_id",
	{ data_type => "integer", is_nullable => 1 },
	"trigger",
	{ data_type => "text", is_nullable => 1 },
	"gamedate",
	{ data_type => "integer", is_nullable => 1 },
	"gametime",
	{ data_type => "text", is_nullable => 1 },
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
	"game",
	"Mafia::Schema::Result::Game",
	{ id => "game_id" },
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

__PACKAGE__->belongs_to(
	"audience_player",
	"Mafia::Schema::Result::Player",
	{ id => "audience_id" },
	{
		is_deferrable => 1,
		join_type     => "LEFT",
		on_delete     => "NO ACTION",
		on_update     => "NO ACTION",
	},
);

sub apply_markup {
	my $self = shift;
	my ($render, @cited) = render_markup $self->body_plain;

	$self->update({ body_render => $render });

	# TODO: track cites

	$self;
}

sub audience_role {
	my $self = shift;

	return unless $self->audience_type eq 'r';
	return Mafia::Role->find($self->audience_id);
}

sub class {
	my $self = shift;

	return join q{ }, (
		$self->gametime ? ("game", $self->gametime) : (),
		$self->user_id  ? "user" : "system",
		$self->trigger // (),
	);
}

sub posts {
	my $self = shift;

	if (defined $self->game_id) {
		return $self->game->posts;
	} elsif (defined $self->thread_id) {
		return $self->thread->posts;
	}

	undef;
}

1;
