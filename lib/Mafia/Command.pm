package Mafia::Command;
use Mojo::Base 'Mojolicious::Command';
use Mafia::Config;
use Mafia::Schema;

sub config {
	my ($self, $key) = @_;
	my $config = Mafia::Config::load();
	if (defined $key) {
		return $config->{$key};
	} else {
		return $config;
	}
}

sub db {
	my ($self, $table) = @_;
	state $schema = Mafia::Schema->connect(
		$self->config->{dsn},'','',
		{ sqlite_unicode => 1 }
	);
	if (defined $table) {
		return $schema->resultset($table);
	} else {
		return $schema;
	}
}

1;
