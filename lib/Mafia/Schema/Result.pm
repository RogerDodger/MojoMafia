package Mafia::Schema::Result;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/Mafia::Timestamp/);

1;
