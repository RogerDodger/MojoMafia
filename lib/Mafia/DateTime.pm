package Mafia::DateTime;

require DateTime;
require DateTime::Format::Human::Duration;

package DateTime;

my $RFC2822 = '%a, %d %b %Y %T %Z';

sub duration_since_now {
	my $self = shift;

	return sprintf '<time title="%s" datetime="%sZ">%s</time>',
		$self->set_time_zone('UTC')->strftime($RFC2822), 
		$self->iso8601, 
		DateTime::Format::Human::Duration->new->format_duration_between(
			DateTime->now,
			$self,
			past => '%s ago',
			future => 'in %s',
			no_time => 'just now',
			significant_units => 2,
		);
}

1;
