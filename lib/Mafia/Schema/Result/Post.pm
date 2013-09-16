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
	"user_alias",
	{ data_type => "text", is_nullable => 1 },
	"user_hidden",
	{ data_type => "boolean", is_nullable => 1, default_value => 0 },
	"class",
	{ data_type => "text", is_nullable => 1 },
	"body_plain",
	{ data_type => "text", is_nullable => 1 },
	"body_render",
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

__PACKAGE__->has_many(
	"audiences",
	"Mafia::Schema::Result::Audience",
	{ "foreign.post_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

sub apply_markup {
	############# TEMPORARY! ##############
	my $self = shift;
	my $text = $self->body_plain;

	$text =~ s/^\s+|\s+$//g;

	$text =~ s/&/&amp;/g;
	$text =~ s/</&lt;/g;
	$text =~ s/>/&gt;/g;
	$text =~ s/"/&quot;/g;
	$text =~ s/'/&#39;/g;

	$text = join "\n\n",
	          map { s/\n/<br>\n/g; "<p>$_</p>" }
	            split /\n\n/, $text;

	$self->update({ body_render => $text });
}

sub has_class {
	my ($self, $class) = @_;
	return scalar $self->class =~ /\b\Q$class\E\b/;
}

1;
