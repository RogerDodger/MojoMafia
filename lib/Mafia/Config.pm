package Mafia::Config;

use Mojo::Base -strict;
use YAML;

sub load {
	my $filename = shift || 'site/conf.yml';

	# Configuration variables set by default but changeable in deployment
	my %defaults = (
		bcost => '10',
		rows => 40,
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
		cfn => $filename,
		dsn => 'dbi:SQLite:site/mafia.db',
	);

	my %config = (%defaults, %$site, %constants);

	return \%config;
}

1;

__DATA__

@@ conf-template.yml

---
bcost: 8
secrets:
    - %s
