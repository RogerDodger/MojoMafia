package Mafia::Timestamp;

use Mojo::Base -base;

use overload (
	q{""} => 'rfc3339',
	fallback => 1
);

has year   => 1900;
has month  => 1;
has day    => 1;
has hour   => 0;
has minute => 0;
has second => 0;

our $SIGNIFICANT_FIGURES = 2;

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

sub parse {
	my ($class, $str) = @_;

	state $iso8601_re = qr{
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

	if ($str =~ $iso8601_re) {
		return $class->new(map { $_ => int $+{$_} } keys %+);
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

sub mysql {
	my $self = shift;

	return sprintf '%04d-%02d-%02d %02d:%02d:%02d',
			$self->year, $self->month, $self->day,
			$self->hour, $self->minute, $self->second;
}

sub delta {
	my $self                = shift;
	my $other               = shift || $self->now;
	my $significant_figures = $SIGNIFICANT_FIGURES;
	state $units            = [qw/year month day hour minute second/];

	if (!ref $other) {
		$other = $self->parse($other);
	}

	return "just now" if $self eq $other;

	my ($big, $small, $neg) = (
		($self cmp $other) > 0
			? ($self, $other, 0)
			: ($other, $self, 1)
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
		if (my $n = $delta{$unit}) {
			push @deltas, "$n $unit" . ($n == 1 ? '' : 's');
		}
		if (@deltas) {
			# Significant figures start counting as soon as a non-zero is
			# found.
			last if --$significant_figures == 0;
		}
	}

	my $time = eval {
		# x and y
		if (@deltas <= 2) {
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

Mafia::Timestamp - Portable timestamps with human-readable deltas

=head1 SYNOPSIS

    use Mafia::Timestamp;

    my $t = Mafia::Timestamp->now;

    sleep(5);
    say $t->delta; # "5 seconds ago"
    sleep(60);
    say $t->delta; # "1 minute and 5 seconds ago"
    sleep(3660);
    say $t->delta; # "1 hour and 2 minutes ago"

    $Mafia::Timestamp::SIGNIFICANT_FIGURES = 1;
    say $t->delta; # "1 hour ago"

    my $t2 = Mafia::Timestamp->parse('2013-04-11T06:00:00Z');
    say $t2->rfc2822; # "Thu, 11 Apr 2013 06:00:00"
    say $t2->mysql;   # "2013-04-11 06:00:00"

    my $date_str = $t->rfc3339;
    sleep(3600);
    my $t3 = Mafia::Timestamp->parse($date_str);
    say $t3->delta;   # "2 hours ago"

    say $t3->delta_html;
    # Assuming we started at 2013-04-11 06:00:00,
    #
    # <time title="Thu, 11 Apr 2013 06:00:00"
    #       datetime="2013-04-11T06:00:00Z">2 hours ago</time>

This module has two main purposes: to portably create, store and retrieve
timestamps, and to present them in a human-readable way. A particular use is
in web applications where timestamps on user-created data need to be
wrapped in HTML, and dropping long ISO-8601 dates just won't cut it.

=head1 METHODS

=head2 Constructors

=head3 new

    my $t = Mafia::Timestamp->new(
        year   => 1900,
        month  => 1,    # 1 = January
        day    => 1,
        hour   => 0,
        minute => 0,
        second => 0
    );

Constructs a new timestamp with explicit attributes. Takes a hash or hash ref.

=head3 now

Returns a timestamp at the current time.

=head3 from_epoch

Returns a timestamp from a given UNIX epoch.

=head3 parse

Constructs a new timestamp from an ISO-8601 datetime string.

=head3

=head2 Output formats

=head3 delta

Returns a human-readable string of the duration of the timestamp from now. If
given a timestamp object will give the time between them.

Will output up to two signficant figures. For example, the delta of 1 month, 0
days, and 5 hours is three signficant units (105 = three sig figs), and so
truncates to 1 month and 0 days (or simply "1 month").

The number of significant figures can be changed with the package variable
C<$SIGNIFICANT_FIGURES>.

=head3 delta_html

Same as C<delta>, but wraps the output in an HTML E<lt>timeE<gt> element whose
title attribute is the RFC2822 format and datetime attribute is the ISO-8601
format.

This allows users to highlight a timestamp to get the exact time, and also
allows for easy interaction with JavaScript's Date class (whose constructor
very much likes ISO-8601 dates).

=head3 iso8601

Returns the timestamp as an ISO-8601 datetime, e.g. "2013-04-11T20:09:00Z".

=head3 rfc3339

Same as iso8601

=head3 rfc2822

Returns the timestamp as an RFC2822 datetime, e.g. "Thu, 11 Apr 2013 20:09:00".

=head3 mysql

Returns the timestamp in the format of a MySQL timestamp, e.g. "2013-04-11
20:09:00".

=head1 Why not DateTime?

Yes, none of the functionality here could not otherwise be performed by
L<DateTime> and its various submodules. The sell here is performance:

    $ time perl -MMafia::Timestamp -e ''

    real  0m0.074s
    user  0m0.064s
    sys   0m0.012s

    $ time perl -MDateTime -e ''

    real  0m0.464s
    user  0m0.440s
    sys   0m0.016s

    $ time perl -MDateTime -e 'DateTime->now->day for 0..10_000;'

    real  0m6.510s
    user  0m6.452s
    sys   0m0.044s

    $ time perl -MMafia::Timestamp -e 'Mafia::Timestamp->now->day for 0..10_000;'

    real  0m0.504s
    user  0m0.496s
    sys   0m0.008s

When a database query returns a few hundreds rows, each with a created and
updated timestamp, inflating the timestamp columns to a DateTime object has a
noticeable run-time cost. Using a lighter module instead helps with
performance.

If you do however need more complex date/time operations, you should
definitely use the fantastic L<DateTime> module.

=head1 AUTHOR

Cameron Thornton E<lt>cthor@cpan.org#<gt>

=head1 COPYRIGHT

Copyright (c) 2013 Cameron Thornton.

This program is free software; you can redistribute and/or
modify it under the same terms as Perl version 5.14.2.

=cut
