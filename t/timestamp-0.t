use Mojo::Base -strict;
use Test::More;
use Mafia::Timestamp;
use Carp;

use_ok "Mafia::Timestamp";

can_ok "Mafia::Timestamp", qw/
	new parse from_epoch now
	delta delta_html rfc3339 rfc2822 iso8601
	year month day hour minute second
/;

my @date = Mafia::Timestamp->new(year => 2013, month => 4, day => 12, hour => 2, minute => 20, second => 45);
$date[1] = Mafia::Timestamp->parse("2013-04-16 06:32:04");
$date[2] = Mafia::Timestamp->parse("2013-12-31 18:59:30");
$date[3] = Mafia::Timestamp->parse("2013-09-07 04:06:00");
$date[4] = Mafia::Timestamp->parse("2020-02-29 23:00:55");
$date[5] = Mafia::Timestamp->now;

isa_ok $date[$_], "Mafia::Timestamp", "date $_" for 0..$#date;

is $date[0]->year,   2013, "date new year";
is $date[0]->month,  4,    "date new month";
is $date[0]->day,    12,   "date new day";
is $date[0]->hour,   2,    "date new hour";
is $date[0]->minute, 20,   "date new minute";
is $date[0]->second, 45,   "date new second";

is $date[1]->year,   2013, "date parse year";
is $date[1]->month,  4,    "date parse month";
is $date[1]->day,    16,   "date parse day";
is $date[1]->hour,   6,    "date parse hour";
is $date[1]->minute, 32,   "date parse minute";
is $date[1]->second, 4,    "date parse second";

cmp_ok $date[5]->year,   '>=', 0,  "date now year";
cmp_ok $date[5]->month,  '>=', 1,  "date now ^month";
cmp_ok $date[5]->month,  '<=', 12, "date now month^";
cmp_ok $date[5]->day,    '>=', 1,  "date now ^day";
cmp_ok $date[5]->day,    '<=', 31, "date now day^";
cmp_ok $date[5]->hour,   '>=', 0,  "date now ^hour";
cmp_ok $date[5]->hour,   '<',  24, "date now hour^";
cmp_ok $date[5]->minute, '>=', 0,  "date now ^minute";
cmp_ok $date[5]->minute, '<',  60, "date now minute^";
cmp_ok $date[5]->second, '>=', 0,  "date now ^second";
cmp_ok $date[5]->second, '<',  60, "date now second^";

{
	my @rfc3339 = (
		"2013-04-12T02:20:45Z",
		"2013-04-16T06:32:04Z",
		"2013-12-31T18:59:30Z",
		"2013-09-07T04:06:00Z",
		"2020-02-29T23:00:55Z",
	);
	my @rfc2822 = (
		"Fri, 12 Apr 2013 02:20:45",
		"Tue, 16 Apr 2013 06:32:04",
		"Tue, 31 Dec 2013 18:59:30",
		"Sat, 07 Sep 2013 04:06:00",
		"Sat, 29 Feb 2020 23:00:55",
	);
	is $date[$_]->rfc3339, $rfc3339[$_], "date $_ rfc3339" for 0..$#rfc3339;
	is $date[$_]->rfc2822, $rfc2822[$_], "date $_ rfc2822" for 0..$#rfc2822;
}

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
	my $dt = Mafia::Timestamp->parse($rfc3339);
	is(
		$dt->day_abbr,
		$day,
		sprintf "%02d %s %04d = $day", $dt->day, $dt->month_abbr, $dt->year
	);
}

done_testing;
