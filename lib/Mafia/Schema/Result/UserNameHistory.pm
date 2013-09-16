use utf8;
package Mafia::Schema::Result::UserNameHistory;

use strict;
use warnings;

use base 'Mafia::Schema::Result';

__PACKAGE__->table('user_name_history');

__PACKAGE__->add_columns(
	'user_id',
	{ data_type => 'integer', is_foreign_key => 1, is_nullable => 0 },
	'name',
	{ data_type => 'varchar', is_nullable => 0 },
	'created',
	{ data_type => 'timestamp', is_nullable => 0 },
);

__PACKAGE__->belongs_to(
	'user',
	'Mafia::Schema::Result::User',
	{ id => 'user_id' },
	{ is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

1;
