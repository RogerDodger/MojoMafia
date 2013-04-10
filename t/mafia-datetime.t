use Mojo::Base -strict;
use Test::More;
use constant DT => 'Mafia::DateTime';

use_ok('Mafia::DateTime');

say DT->from_rfc3339("2013-03-10T14:00:00Z")->delta_html;
say DT->now->rfc2822;

done_testing;
