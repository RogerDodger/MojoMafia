package Mafia::DateTime;

use Mojo::Base -base;
use Carp ();
use Time::Local ();

use overload 
	q{""} => 'rfc3339',
	fallback => 1;

my @days = qw/Sun Mon Tue Wed Thu Fri Sat/;
my @months = qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/;
my @units = qw/year month day hour minute second/;

has year   => 1900;
has month  => 1;
has day    => 1;
has hour   => 0;
has minute => 0;
has second => 0;

sub now {
	return shift->from_epoch(time);
}

sub from_epoch {
	my ($class, $time) = @_;
	my %args;

	@args{qw/second minute hour day month year/} = (gmtime($time))[0..5];
	$args{year} += 1900;
	$args{month}++;

	return $class->new(%args);
}

my $rfc_3339_re = qr{
	(?<year>   \d{4} ) -
	(?<month>  \d{2} ) -
	(?<day>    \d{2} ) T
	(?<hour>   \d{2} ) :
	(?<minute> \d{2} ) :
	(?<second> \d{2} ) Z
}ax;

sub from_rfc3339 {
	my ($class, $str) = @_;

	if($str =~ $rfc_3339_re) {
		return $class->new(
			# Numify captures by adding 0
			map { $_ => $+{$_} + 0 } keys %+
		);
	}
	else {
		Carp::croak("Not an RFC3339 date time: $str");
	}
}

sub _days_in_month {
	my ($year, $month) = @_;
	my @days_in_month = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	
	if ($year % 4 == 0 && $year % 100 != 0 || $year % 400 == 0) {
		$days_in_month[1]++;
	}

	return $days_in_month[$month - 1];
}

sub day_abbr {
	my $self = shift;

	my $time = Time::Local::timegm_nocheck($self->second, $self->minute, 
		$self->hour, $self->day, $self->month - 1, $self->year);

	return $days[(gmtime($time))[6]];
}

sub month_abbr {
	my $self = shift;

	return $months[$self->month - 1];
}

sub rfc3339 {
	my $self = shift;

	return sprintf '%04d-%02d-%02dT%02d:%02d:%02dZ',
			$self->year, $self->month, $self->day,
			$self->hour, $self->minute, $self->second;
}

sub rfc2822 {
	my $self = shift;

	return sprintf "%s, %02d %s %04d %02d:%02d:%02d", $self->day_abbr,
			$self->day, $self->month_abbr, $self->year,
			$self->hour, $self->minute, $self->second;
}

sub delta {
	my $self = shift;
	my $other = shift // $self->now;

	return "just now" if $self eq $other;

	my ($big, $small, $neg) = (
		($self cmp $other) > 0 ?
		($self, $other, 0) :
		($other, $self, 1)
	);

	my %delta;
	for my $unit (@units) {
		$delta{$unit} = $big->$unit - $small->$unit;
	}

	# Normalise delta to positive values
	if ($delta{second} < 0) {
		$delta{minute}--;
		$delta{second} += 60;
	}
	
	if ($delta{minute} < 0) {
		$delta{hour}--;
		$delta{minute} += 60;
	}

	if ($delta{hour} < 0) {
		$delta{day}--;
		$delta{hour} += 24;
	}

	if ($delta{day} < 0) {
		$delta{month}--;
		$delta{day} += _days_in_month($small->year, $small->month);
	}

	if ($delta{month} < 0) {
		$delta{year}--;
		$delta{month} += 12;
	}

	# Find index of first signficant unit
	my $i;
	for ($i = 0; $i < @units && $delta{$units[$i]} == 0; $i++) {}

	# Golfing is bad for you
	my $time = 
		join " and ", 
		map  { 
			my $n = $delta{$_};
			"$n $_" . ($n == 1 ? '' : 's');
		} 
		grep { 
			defined && $delta{$_} 
		}
		@units[$i, $i + 1];

	return $neg ? "$time ago" : "in $time";
}

sub delta_html {
	my $self = shift;

	return sprintf q{<time title="%s" datetime="%s">%s</time>},
	                 $self->rfc2822, $self->rfc3339, $self->delta;
}

'The end of time.';
