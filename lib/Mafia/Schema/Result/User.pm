use utf8;
package Mafia::Schema::Result::User;

use base 'Mafia::Schema::Result';
use strict;
use warnings;

use Bytes::Random::Secure qw/random_bytes/;
use Crypt::Eksblowfish::Bcrypt qw/bcrypt en_base64/;
use Scalar::Util qw/looks_like_number/;

__PACKAGE__->table("users");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"name",
	{ data_type => "varchar", is_nullable => 0 },
	"nname",
	{ data_type => "varchar", is_nullable => 0 },
	"dname",
	{ data_type => "varchar", is_nullable => 0 },
	"is_admin",
	{ data_type => "boolean", default_value => 0, is_nullable => 1 },
	"is_mod",
	{ data_type => "boolean", default_value => 0, is_nullable => 1 },
	"active",
	{ data_type => "boolean", default_value => 1, is_nullable => 1 },
	"games",
	{ data_type => "integer", default_value => 0, is_nullable => 1 },
	"wins",
	{ data_type => "integer", default_value => 0, is_nullable => 1 },
	"losses",
	{ data_type => "integer", default_value => 0, is_nullable => 1 },
	"abandons",
	{ data_type => "integer", default_value => 0, is_nullable => 1 },
	"created",
	{ data_type => "timestamp", is_nullable => 1 },
	"updated",
	{ data_type => "timestamp", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
	"emails",
	"Mafia::Schema::Result::Email",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"games",
	"Mafia::Schema::Result::Game",
	{ "foreign.host_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"passwords",
	"Mafia::Schema::Result::Password",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"players",
	"Mafia::Schema::Result::Player",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"posts",
	"Mafia::Schema::Result::Post",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"setups",
	"Mafia::Schema::Result::Setup",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	'name_history',
	'Mafia::Schema::Result::UserNameHistory',
	{ 'foreign.user_id', => 'self.id' },
	{ cascade_copy => 0, cascade_delete => 0 },
);

sub password_check {
	my ($self, $plain) = @_;

	my $cipher = $self->passwords->order_by({ -desc => 'created' })->first->cipher;

	return bcrypt($plain, $cipher) eq $cipher;
}

sub password_set {
	my ($self, $plain, $cost) = @_;

	if (looks_like_number($cost) && 0 < $cost && $cost < 100) {
		$cost = sprintf "%02d", int $cost;
	} else {
		$cost = '10';
	}

	my $salt = en_base64 random_bytes 16;
	my $settings =  join '$', '$2', $cost, $salt;
	my $cipher = bcrypt($plain, $settings);

	$self->create_related(passwords => { cipher => $cipher });
}

sub plays {
	my ($self, $game) = @_;

	$self->search_related(players => { game_id => $game->id })->count;
}

1;
