package Mafia::Command::install;

use v5.14.2;
use Mojo::Base 'Mojolicious::Command';
use Mojo::UserAgent;

eval Mojo::UserAgent->new->get('https://raw.github.com/miyagawa/cpanminus/master/cpanm')->res->body;
require App::cpanminus;

sub run {
	my $self = shift;
	unshift @_, '--skip-satisfied';

	my $app = App::cpanminus::script->new;
	$app->parse_options(@_, 'YAML');
	$app->doit or exit(1);

	require YAML;
	my $meta = YAML::LoadFile($self->rel_file('meta.yml'));
	$app->{argv} = $meta->{dependencies};
	$app->doit or exit(1);
}

1;
