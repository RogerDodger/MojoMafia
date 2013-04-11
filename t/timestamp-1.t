use Mojo::Base -strict;
use Test::More;
use constant DT => 'Mafia::Timestamp';

use_ok('Mafia::Timestamp');

say DT->parse("2013-03-10T14:00:00Z")->delta;

my %d = (
	'2016-07-01T00:00:00Z' => 'Fri',
	'2013-04-10T00:00:00Z' => 'Wed',
	'2007-01-01 00:00:00Z' => 'Mon',
	'2000-06-19T00:00:00Z' => 'Mon',
	'1987-09-01T00:00:00'  => 'Tue',
	'1676-03-23T00:00:00Z' => 'Mon',
);

for my $rfc3339 (sort keys %d) {
	my $day = $d{$rfc3339};
	my $dt = DT->parse($rfc3339);
	is(
		$dt->day_abbr, 
		$day, 
		sprintf "%02d %s %04d = $day", $dt->day, $dt->month_abbr, $dt->year
	);
}

done_testing;
