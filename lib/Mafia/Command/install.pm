package Mafia::Command::install;

use v5.14.2;
use Mojo::Base 'Mojolicious::Command';
use Mojo::UserAgent;

eval Mojo::UserAgent->new->get('https://raw.github.com/miyagawa/cpanminus/master/cpanm')->res->body;
require App::cpanminus;

sub run {
	my $self = shift;

	say "Installing dependencies for MojoMafia...";

	my $cpanm = App::cpanminus::script->new;
	$cpanm->parse_options('--skip-satisfied', @_);

	$cpanm->{argv} = ['YAML'];
	$cpanm->doit or exit(1);

	require YAML;
	my $meta = YAML::LoadFile($self->rel_file('meta.yml'));

	$cpanm->{argv} = $meta->{dependencies};
	$cpanm->doit or exit(1);
}

1;
