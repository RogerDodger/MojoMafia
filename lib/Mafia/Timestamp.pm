package Mafia::Timestamp;

use Mojo::Base -base;
use Carp ();

use overload 
	q{""} => 'rfc3339',
	fallback => 1;

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

my $iso8601_re = qr{
	(?<year>   \d{4} ) -
	(?<month>  \d{2} ) -
	(?<day>    \d{2} ) 
	(?: 
		[T\x20]
		(?<hour>   \d{2} ) :
		(?<minute> \d{2} ) :
		(?<second> \d{2} ) Z?
	)? # Time portion is optional
}axo;

sub parse {
	my ($class, $str) = @_;

	if($str =~ $iso8601_re) {
		return $class->new(map { $_ => int $+{$_} + 0 } keys %+);
	}
	else {
		Carp::croak("Not an ISO8601 date time: $str");
	}
}

sub leap_year {
	my $self = shift;
	return $self->year % 4 == 0 && $self->year % 100 != 0 || $self->year % 400 == 0;
}

sub days_in_month {
	my $self = shift;
	my $month = $self->month;

	if ($month == 4 || $month == 6 || $month == 9 || $month == 11) {
        return 30;
    }
    elsif ($month == 2) {
        return $self->leap_year ? 29 : 28;
    }
    else {
        return 31;
    }
}

sub day_of_week {
	# Tomohiko Sakamoto 1993, C FAQ 20.31 (http://c-faq.com/misc/zeller.html) 
	my $self = shift;
	my ($day, $month, $year) = ($self->day, $self->month, $self->year);
	state $offset = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4];
	
	$year -= $month < 3;

	return ($year + int($year / 4) - int($year / 100) + int($year / 400) 
	              + $offset->[$month-1] + $day) % 7;
}

sub day_abbr {
	my $self = shift;
	state $days = [qw/Sun Mon Tue Wed Thu Fri Sat/];

	return $days->[$self->day_of_week];
}

sub month_abbr {
	my $self = shift;
	state $months = [qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/];

	return $months->[$self->month - 1];
}

sub rfc3339 {
	my $self = shift;

	return sprintf '%04d-%02d-%02dT%02d:%02d:%02dZ',
			$self->year, $self->month, $self->day,
			$self->hour, $self->minute, $self->second;
}

sub iso8601 { shift->rfc3339; }

sub rfc2822 {
	my $self = shift;

	return sprintf "%s, %02d %s %04d %02d:%02d:%02d", $self->day_abbr,
			$self->day, $self->month_abbr, $self->year,
			$self->hour, $self->minute, $self->second;
}

sub delta {
	my $self              = shift;
	my $other             = shift || $self->now;
	my $significant_units = shift || 2;
	state $units          = [qw/year month day hour minute second/];

	if(!ref $other) {
		$other = $self->parse($other);
	}

	return "just now" if $self eq $other;

	my ($big, $small, $neg) = (
		($self cmp $other) > 0 ?
		($self, $other, 0) :
		($other, $self, 1)
	);

	my %delta;
	for my $unit (@$units) {
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
		$delta{day} += $small->days_in_month;
	}

	if ($delta{month} < 0) {
		$delta{year}--;
		$delta{month} += 12;
	}

	my @deltas;
	for my $unit (@$units) {
		if(my $n = $delta{$unit}) {
			push @deltas, "$n $unit" . ($n == 1 ? '' : 's');
		}
		if(@deltas) {
			# Put this check here so that deltas like "1 month and 4 minutes"
			# output as simply "1 month". That is, as soon as a non-zero
			# unit is found, start counting down, rather than counting down
			# only when a non-zero unit is found.
			last if --$significant_units == 0;
		}
	}

	my $time = eval {
		# x and y
		if(@deltas <= 2) {
			return join " and ", @deltas
		}
		# x, y, and z
		$deltas[-1] = "and $deltas[-1]";
		return join ", ", @deltas;
	};

	return $neg ? "$time ago" : "in $time";
}

sub delta_html {
	my $self = shift;

	return sprintf q{<time title="%s" datetime="%s">%s</time>},
	               $self->rfc2822, $self->rfc3339, $self->delta(@_);
}

'The end of time.';

__END__

=pod

=head1 NAME

Mafia::Timestamp - DateTime with only the features needed for timestamps

=head2 SYNOPSIS

    use Mafia::Timestamp;

    my $dt = Mafia::Timestamp->parse('2013-03-01 06:00:00');

    say $dt->delta('2013-03-02 12:00') # "1 day and 6 hours ago"

Mafia::Timestamp implements a subset of DateTime's features for improved
performance at the cost of minor precision.
