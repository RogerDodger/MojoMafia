package Mafia::Config;

use Mojo::Base -strict;
use YAML;

sub load {
	my $filename = shift || 'site/config.yml';

	my %defaults = (

	);

	my ($site, $err);
	if (-e $filename) {
		$site = YAML::LoadFile($filename);
		if (ref $site ne 'HASH') {
			$site = {};
		}
	} else {
		# $err = "Config file $filename does not exist. Have you deployed yet?";
	}

	my %constants = (
		dsn => 'dbi:SQLite:site/data.db',
	);

	my %config = (%defaults, %{ $site || {} }, %constants);

	return \%config;
}

1;
