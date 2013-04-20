use utf8;
package Mafia::Schema::Result::Post;

use strict;
use warnings;

use base 'Mafia::Schema::Result';

__PACKAGE__->table("posts");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"thread_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"user_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"player_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
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

sub apply_markup {
	############# WARNING! #############
	## Temporary. This has XSS holes. ##
	####################################
	my $self = shift;

	my $text = $self->plain;

	require Text::Markdown;
	$text =~ s/</&lt;/g;
	$text = Text::Markdown->new->markdown($text);

	$self->update({ render => $text });
}

sub has_class {
	my ($self, $class) = @_;
	return $self->class =~ /\b\Q$class\E\b/;
}

1;
