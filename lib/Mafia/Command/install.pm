package Mafia::Command::install;

use v5.14.2;
use Mojo::Base 'Mojolicious::Command';
use Mojo::UserAgent;

eval Mojo::UserAgent->new->get('https://raw.github.com/miyagawa/cpanminus/master/cpanm')->res->body;
require App::cpanminus;

sub run {
	my $self = shift;
	my $opt = ($_[0] || '') eq 'recommended' ? shift : 0;

	say "Installing required modules...";

	my $cpanm = App::cpanminus::script->new;
	$cpanm->parse_options('--skip-satisfied', @_);

	$cpanm->{argv} = ['YAML'];
	$cpanm->doit or exit(1);

	require YAML;
	my $meta = YAML::LoadFile($self->rel_file('meta.yml'));

	$cpanm->{argv} = $meta->{required};
	$cpanm->doit or exit(1);

	if($opt eq 'recommended') {
		say "Installing recommended modules...";
		$cpanm->{argv} = $meta->{recommended};
		$cpanm->doit or exit(1);
	}
}

1;
