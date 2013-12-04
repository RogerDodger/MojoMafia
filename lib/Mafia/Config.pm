package Mafia::Config;

use Mojo::Base -strict;
use YAML;

sub load {
	my $filename = shift || 'site/config.yml';

	# Configuration variables set by default but changeable in deployment
	my %defaults = (

	);

	my $site = {};
	if (-e $filename) {
		$site = YAML::LoadFile($filename);
		if (ref $site ne 'HASH') {
			$site = {};
		}
	}

	# Configuration variables not changeable in deployment
	my %constants = (
		dsn => 'dbi:SQLite:site/mafia.db',
	);

	my %config = (%defaults, %$site, %constants);

	return \%config;
}

1;
