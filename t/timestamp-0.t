use Mojo::Base -strict;
use Test::More;
use Mafia::Timestamp;
use Carp;

can_ok 'Mafia::Timestamp', qw/
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

isa_ok $date[$_], 'Mafia::Timestamp', "date $_" for 0..$#date;

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

# Just now
is $date[0]->delta($date[0]), "just now", "delta date 0 to itself";
is $date[4]->delta($date[4]), "just now", "delta date 4 to itself";

sub delta_ok {
	my ($small, $big, $expected, $desc) = @_;
	eval { $date[$small]->isa("Mafia::Timestamp") } or croak "small is not a timestamp";
	eval { $date[$big]->isa("Mafia::Timestamp")   } or croak "big is not a timestamp";
	is $date[$small]->delta($date[$big]), "$expected ago",  "delta $desc $small-$big";
	is $date[$big]->delta($date[$small]), "in $expected", "delta $desc $small-$big";
}

# Year significant
@date     = Mafia::Timestamp->parse("2011-01-16 00:00:00");
$date[1]  = Mafia::Timestamp->parse("2020-03-23 00:00:00");
$date[2]  = Mafia::Timestamp->parse("2015-11-16 00:00:00");
$date[3]  = Mafia::Timestamp->parse("2015-11-15 00:00:00");
$date[4]  = Mafia::Timestamp->parse("2019-11-17 00:00:00");
$date[5]  = Mafia::Timestamp->parse("2019-01-16 00:00:00");
$date[6]  = Mafia::Timestamp->parse("2019-01-17 00:00:00");
$date[7]  = Mafia::Timestamp->parse("2019-01-15 00:00:00");
$date[10] = Mafia::Timestamp->parse("2012-01-16 00:00:00");
$date[11] = Mafia::Timestamp->parse("2012-01-22 00:00:00");
$date[12] = Mafia::Timestamp->parse("2012-02-15 00:00:00");
$date[13] = Mafia::Timestamp->parse("2012-02-16 00:00:00");
$date[14] = Mafia::Timestamp->parse("2012-02-17 00:00:00");
$date[15] = Mafia::Timestamp->parse("2012-05-20 00:00:00");
$date[16] = Mafia::Timestamp->parse("2012-05-10 00:00:00");
$date[17] = Mafia::Timestamp->parse("2020-02-16 00:00:00");
$date[18] = Mafia::Timestamp->parse("2020-03-15 00:00:00");
delta_ok 0, 1, "9 years and 2 months",  "year significant";
delta_ok 0, 2, "4 years and 10 months", "year significant";
delta_ok 0, 3, "4 years and 9 months",  "year significant";
delta_ok 0, 4, "8 years and 10 months", "year significant";
delta_ok 0, 5, "8 years",               "year significant";
delta_ok 0, 6, "8 years",               "year significant";
delta_ok 0, 7, "7 years and 11 months", "year significant";
delta_ok 0, 10, "1 year",              "year significant";
delta_ok 0, 11, "1 year",              "year significant";
delta_ok 0, 12, "1 year",              "year significant";
delta_ok 0, 13, "1 year and 1 month",  "year significant";
delta_ok 0, 14, "1 year and 1 month",  "year significant";
delta_ok 0, 15, "1 year and 4 months", "year significant";
delta_ok 0, 16, "1 year and 3 months", "year significant";
delta_ok 0, 17, "9 years and 1 month", "year significant";
delta_ok 0, 18, "9 years and 1 month", "year significant";

@date    = Mafia::Timestamp->parse("2012-12-31 01:00:00");
$date[1] = Mafia::Timestamp->parse("2014-01-01 00:00:00");
delta_ok 0, 1, "1 year", "year significant upper bound";

# Month significant
@date    = Mafia::Timestamp->parse("2016-04-16 00:00:00");
$date[1] = Mafia::Timestamp->parse("2016-08-23 00:00:00");
$date[2] = Mafia::Timestamp->parse("2016-05-27 00:00:00");
$date[3] = Mafia::Timestamp->parse("2016-10-17 00:00:00");
$date[4] = Mafia::Timestamp->parse("2016-11-05 00:00:00");#days04 - 16 + 5 = 19
$date[5] = Mafia::Timestamp->parse("2016-12-02 00:00:00");#days04 - 16 + 2 = 16
$date[6] = Mafia::Timestamp->parse("2016-05-16 00:00:00");
$date[7] = Mafia::Timestamp->parse("2016-06-16 00:00:00");
delta_ok 0, 1, "4 months and 7 days",  "month significant 04";
delta_ok 0, 2, "1 month and 11 days",  "month significant 04";
delta_ok 0, 3, "6 months and 1 day",   "month significant 04";
delta_ok 0, 4, "6 months and 19 days", "month significant 04";
delta_ok 0, 5, "7 months and 16 days", "month significant 04";
delta_ok 0, 6, "1 month",              "month significant 04";
delta_ok 0, 7, "2 months",             "month significant 04";

@date    = Mafia::Timestamp->parse("2016-03-16 00:00:00");
$date[1] = Mafia::Timestamp->parse("2016-04-24 00:00:00");
$date[2] = Mafia::Timestamp->parse("2016-05-25 00:00:00");
$date[3] = Mafia::Timestamp->parse("2016-06-07 00:00:00");#days 03 - 16 + 7  = 22
$date[4] = Mafia::Timestamp->parse("2016-05-15 00:00:00");#days 03 - 16 + 15 = 30
$date[5] = Mafia::Timestamp->parse("2016-04-16 00:00:00");
$date[6] = Mafia::Timestamp->parse("2016-12-16 00:00:00");
delta_ok 0, 1, "1 month and 8 days",   "month significant 03";
delta_ok 0, 2, "2 months and 9 days",  "month significant 03";
delta_ok 0, 3, "2 months and 22 days", "month significant 03";
delta_ok 0, 4, "1 month and 30 days",  "month significant 03";
delta_ok 0, 5, "1 month",              "month significant 03";
delta_ok 0, 6, "9 months",             "month significant 03";

@date    = Mafia::Timestamp->parse("2016-04-07 00:00:00");
$date[1] = Mafia::Timestamp->parse("2017-02-24 00:00:00");
$date[2] = Mafia::Timestamp->parse("2017-03-05 00:00:00");#days 04 - 7 + 5 = 28
$date[3] = Mafia::Timestamp->parse("2017-03-07 00:00:00");
delta_ok 0, 1, "10 months and 17 days", "month significant across years";
delta_ok 0, 2, "10 months and 28 days", "month significant across years";
delta_ok 0, 3, "11 months",             "month significant across years";

@date    = Mafia::Timestamp->parse("2016-02-16 00:00:00");
$date[1] = Mafia::Timestamp->parse("2016-09-18 00:00:00");
$date[2] = Mafia::Timestamp->parse("2016-04-02 00:00:00");#29 - 16 + 2 = 15
$date[3] = Mafia::Timestamp->parse("2017-01-29 00:00:00");
$date[4] = Mafia::Timestamp->parse("2017-02-01 00:00:00");#29 - 16 + 1 = 14
$date[10] = Mafia::Timestamp->parse("2017-02-16 00:00:00");
$date[11] = Mafia::Timestamp->parse("2017-09-18 00:00:00");
$date[12] = Mafia::Timestamp->parse("2017-04-02 00:00:00");#28 - 16 + 2 = 14
$date[13] = Mafia::Timestamp->parse("2018-01-29 00:00:00");
$date[14] = Mafia::Timestamp->parse("2018-02-01 00:00:00");#28 - 16 + 1 = 13
delta_ok 0, 1, "7 months and 2 days",   "month significant across leap year";
delta_ok 0, 2, "1 month and 15 days",   "month significant across leap year";
delta_ok 0, 3, "11 months and 13 days", "month significant across leap year";
delta_ok 0, 4, "11 months and 14 days", "month significant across leap year";
delta_ok 10, 11, "7 months and 2 days",   "month significant across non-leap year";
delta_ok 10, 12, "1 month and 14 days",   "month significant across non-leap year";
delta_ok 10, 13, "11 months and 13 days", "month significant across non-leap year";
delta_ok 10, 14, "11 months and 13 days", "month significant across non-leap year";

@date    = Mafia::Timestamp->parse("2016-02-15 05:12:43");
$date[1] = Mafia::Timestamp->parse("2016-02-16 01:03:11");
$date[2] = Mafia::Timestamp->parse("2016-02-15 05:13:44");
$date[3] = Mafia::Timestamp->parse("2016-02-15 05:13:43");
$date[4] = Mafia::Timestamp->parse("2016-02-15 05:13:42");

delta_ok 0, 1, "19 hours and 50 minutes", "hour significant";
delta_ok 0, 2, "1 minute and 1 second", "minute significant";
delta_ok 0, 3, "1 minute", "minute significant";
delta_ok 0, 4, "59 seconds", "second significant";

{
	use Mojo::DOM;
	my $date = Mafia::Timestamp->parse("2012-12-31 01:00:00");
	my $html = $date->delta_html($date[0]);
	my $dom = Mojo::DOM->new($html);
	my $time = $dom->at("time");
	ok $time, "delta_html";
	is $time->attrs("title"), "Mon, 31 Dec 2012 01:00:00", "delta_html title";
	is $time->attrs("datetime"), "2012-12-31T01:00:00Z", "delta_html timestamp";
	is $time->text, "3 years and 1 month ago", "delta_html text";
}

done_testing;
