package Mafia::Log;
use Mojo::Base 'Mojo::Log';

sub format {
	my ($self, $level, @lines) = @_;

	my $timestamp = POSIX::strftime('%b %d %H:%M:%S', localtime);
	return "$timestamp [$level] " . join("\n", @lines) . "\n";
}

1;
