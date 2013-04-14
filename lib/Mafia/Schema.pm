use utf8;
package Mafia::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

our $VERSION = 1;

__PACKAGE__->load_namespaces;
__PACKAGE__->load_components('Schema::Versioned');

1;
