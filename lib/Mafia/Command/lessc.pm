package Mafia::Command::lessc;

use Mojo::Base 'Mojolicious::Command';
use YAML;

sub run {
	my $self = shift;
	
	my $meta = YAML::LoadFile($self->rel_file('meta.yml'));

	my $in  = $self->rel_file('public/style/mafia.less');
	my $out = $self->rel_file('public/style/mafia.css');

	say "Compiling LESS...";
	system('lessc', $in, $out) == 0 or die "Compilation failed: $?";
	say "[write] $out";
}

1;
